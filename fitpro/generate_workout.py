"""
FitPro â€” Gerador de Treino com IA
==================================
MicroserviÃ§o FastAPI que integra com a API da Anthropic (Claude)
para gerar treinos e dicas nutricionais personalizados.

InstalaÃ§Ã£o:
    pip install anthropic fastapi uvicorn pydantic

Rodar em desenvolvimento:
    uvicorn generate_workout:app --host 0.0.0.0 --port 8000 --reload

Rodar em produÃ§Ã£o:
    uvicorn generate_workout:app --host 0.0.0.0 --port 8000 --workers 2

Uso via CLI (legado, mantido para compatibilidade):
    python3 generate_workout.py '{"user_id":1,"objetivo":"hipertrofia",...}'
"""

import sys
import json
import os
import re
import logging
from typing import Optional

import anthropic
from fastapi import FastAPI, HTTPException, Depends, Header
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field, validator

# ============================================================
# LOGGING
# ============================================================
logging.basicConfig(level=logging.INFO, format='%(asctime)s %(levelname)s %(message)s')
log = logging.getLogger('fitpro-ai')

# ============================================================
# CONFIG
# ============================================================
ANTHROPIC_API_KEY = os.environ.get("ANTHROPIC_API_KEY", "").strip()
INTERNAL_SECRET   = os.environ.get("INTERNAL_SECRET", "fitpro-interno-troque-em-producao")
MODEL             = "claude-sonnet-4-20250514"

# ============================================================
# FASTAPI APP
# ============================================================
app = FastAPI(
    title="FitPro AI Service",
    description="Gerador de treinos personalizados com Claude",
    version="2.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],   # Restringir ao domÃ­nio do PHP em produÃ§Ã£o
    allow_methods=["*"],
    allow_headers=["*"],
)

# ============================================================
# MODELOS PYDANTIC
# ============================================================
class PerfilAluno(BaseModel):
    user_id:      int
    objetivo:     str  = Field(..., pattern=r'^(hipertrofia|emagrecimento|condicionamento|forca)$')
    nivel:        str  = Field(..., pattern=r'^(iniciante|intermediario|avancado)$')
    dias_semana:  int  = Field(..., ge=2, le=6)
    duracao_min:  int  = Field(..., ge=30, le=120)
    equipamentos: str  = Field(..., pattern=r'^(academia_completa|academia_basica|em_casa)$')
    restricoes:   Optional[str] = None
    peso_kg:      Optional[float] = Field(None, ge=30, le=300)
    altura_cm:    Optional[int]   = Field(None, ge=100, le=250)
    sexo:         Optional[str]   = Field(None, pattern=r'^(M|F|outro)$')
    idade:        Optional[int]   = Field(None, ge=10, le=100)

    @validator('objetivo')
    def objetivo_valido(cls, v):
        mapa = {
            'hipertrofia': 'Hipertrofia (ganho de massa muscular)',
            'emagrecimento': 'Emagrecimento (perda de gordura)',
            'condicionamento': 'Condicionamento fÃ­sico geral',
            'forca': 'ForÃ§a mÃ¡xima',
        }
        return mapa.get(v, v)

class RespostaTreino(BaseModel):
    ok:     bool
    plano:  dict

class RespostaNutricao(BaseModel):
    ok:        bool
    nutricao:  dict

# ============================================================
# AUTENTICAÃ‡ÃƒO INTERNA (PHP â†’ Python)
# ============================================================
async def verify_internal(x_internal_secret: str = Header(None)):
    """
    O PHP passa o header X-Internal-Secret para garantir que
    apenas o backend prÃ³prio chama este microserviÃ§o.
    Em produÃ§Ã£o, coloque o serviÃ§o em rede interna (nÃ£o exposto).
    """
    if INTERNAL_SECRET and x_internal_secret != INTERNAL_SECRET:
        raise HTTPException(status_code=403, detail="Acesso nÃ£o autorizado")

# ============================================================
# PROMPTS DE SISTEMA
# ============================================================
SYSTEM_TREINO = """
VocÃª Ã© um educador fÃ­sico especialista com 15 anos de experiÃªncia em prescriÃ§Ã£o de treinos.
Gere planos de treino detalhados, seguros e eficazes baseados no perfil do aluno.

REGRAS ABSOLUTAS:
1. Responda SOMENTE com JSON vÃ¡lido â€” sem texto antes ou depois, sem markdown, sem ```.
2. Todos os campos da estrutura abaixo sÃ£o obrigatÃ³rios.
3. Sugira cargas realistas para o nÃ­vel do aluno.
4. Respeite as restriÃ§Ãµes fÃ­sicas informadas â€” substitua exercÃ­cios contraindicados.
5. Inclua aquecimento e cool-down em cada sessÃ£o.

ESTRUTURA EXATA (siga fielmente):
{
  "nome_plano": "string descritiva",
  "objetivo": "string",
  "nivel": "string",
  "semanas_recomendadas": number,
  "dias_por_semana": number,
  "dias": [
    {
      "dia_semana": "Segunda",
      "grupo_muscular": "Peito & TrÃ­ceps",
      "duracao_minutos": number,
      "aquecimento": "descriÃ§Ã£o em 1 linha",
      "exercicios": [
        {
          "nome": "Supino Reto",
          "series": 4,
          "repeticoes": "8-12",
          "carga_sugerida": "70-80kg",
          "descanso_segundos": 90,
          "tecnica": "dica tÃ©cnica em 1 linha",
          "substituicao": "exercÃ­cio alternativo"
        }
      ],
      "finalizacao": "descriÃ§Ã£o do cool-down em 1 linha"
    }
  ],
  "dicas_gerais": ["dica 1", "dica 2", "dica 3"],
  "observacoes": "observaÃ§Ãµes sobre restriÃ§Ãµes ou personalizaÃ§Ãµes"
}
"""

SYSTEM_NUTRICAO = """
VocÃª Ã© uma nutricionista esportiva especializada.
Responda SOMENTE com JSON vÃ¡lido â€” sem texto extra, sem markdown.

ESTRUTURA EXATA:
{
  "calorias_recomendadas": number,
  "proteina_g": number,
  "carboidrato_g": number,
  "gordura_g": number,
  "distribuicao_refeicoes": [
    { "nome": "CafÃ© da ManhÃ£", "horario": "07:00", "calorias": number, "alimentos": "descriÃ§Ã£o" }
  ],
  "dicas": ["dica 1", "dica 2", "dica 3", "dica 4", "dica 5"],
  "alimentos_recomendados": ["alimento 1", "alimento 2"],
  "alimentos_evitar": ["alimento 1", "alimento 2"],
  "suplementos_sugeridos": ["suplemento 1"]
}
"""

# ============================================================
# FUNÃ‡Ã•ES CORE
# ============================================================
def get_client() -> anthropic.Anthropic:
    if not ANTHROPIC_API_KEY:
        raise RuntimeError("ANTHROPIC_API_KEY nÃ£o configurada no ambiente.")
    return anthropic.Anthropic(api_key=ANTHROPIC_API_KEY)

def parse_json_response(text: str) -> dict:
    """Extrai JSON da resposta, removendo possÃ­veis marcadores markdown."""
    text = text.strip()
    # Remove ```json ... ``` ou ``` ... ```
    text = re.sub(r'^```(?:json)?\s*', '', text)
    text = re.sub(r'\s*```$', '', text)
    text = text.strip()
    return json.loads(text)

def gerar_treino(perfil: dict) -> dict:
    """Gera um plano de treino estruturado via Claude."""
    client = get_client()

    equipamentos_label = {
        'academia_completa': 'academia completa (todos os equipamentos)',
        'academia_basica':   'academia bÃ¡sica (barras, halteres, mÃ¡quinas bÃ¡sicas)',
        'em_casa':           'exercÃ­cios em casa (peso corporal, elÃ¡sticos, halteres leves)',
    }.get(perfil.get('equipamentos', ''), perfil.get('equipamentos', ''))

    prompt = f"""
Gere um plano de treino personalizado para o seguinte aluno:

- Objetivo: {perfil.get('objetivo', 'Hipertrofia')}
- NÃ­vel: {perfil.get('nivel', 'intermediario')}
- Dias de treino por semana: {perfil.get('dias_semana', 5)}
- DuraÃ§Ã£o de cada sessÃ£o: {perfil.get('duracao_min', 60)} minutos
- Equipamentos: {equipamentos_label}
- RestriÃ§Ãµes fÃ­sicas: {perfil.get('restricoes') or 'nenhuma'}
- Peso: {perfil.get('peso_kg', 'nÃ£o informado')} kg
- Altura: {perfil.get('altura_cm', 'nÃ£o informado')} cm
- Sexo: {perfil.get('sexo', 'nÃ£o informado')}
- Idade: {perfil.get('idade', 'nÃ£o informado')} anos

Crie a divisÃ£o de treino mais eficiente para este perfil.
"""

    log.info(f"Gerando treino para user_id={perfil.get('user_id')} objetivo={perfil.get('objetivo')}")

    message = client.messages.create(
        model=MODEL,
        max_tokens=4096,
        system=SYSTEM_TREINO,
        messages=[{"role": "user", "content": prompt}]
    )

    texto = message.content[0].text
    plano = parse_json_response(texto)

    # ValidaÃ§Ã£o mÃ­nima
    if 'dias' not in plano or not isinstance(plano['dias'], list):
        raise ValueError("Resposta da IA nÃ£o contÃ©m campo 'dias' vÃ¡lido")
    if len(plano['dias']) == 0:
        raise ValueError("Plano de treino retornou sem dias")

    log.info(f"Treino gerado: {plano.get('nome_plano')} â€” {len(plano['dias'])} dias")
    return plano


def gerar_nutricao(perfil: dict) -> dict:
    """Gera dicas nutricionais baseadas no perfil do aluno."""
    client = get_client()

    prompt = f"""
Gere um plano nutricional completo para:
- Objetivo: {perfil.get('objetivo', 'Hipertrofia')}
- Peso: {perfil.get('peso_kg', 80)} kg
- Altura: {perfil.get('altura_cm', 175)} cm
- Sexo: {perfil.get('sexo', 'M')}
- Idade: {perfil.get('idade', 30)} anos
- NÃ­vel de atividade: {perfil.get('nivel', 'intermediario')}
- Dias de treino por semana: {perfil.get('dias_semana', 5)}
"""

    message = client.messages.create(
        model=MODEL,
        max_tokens=2048,
        system=SYSTEM_NUTRICAO,
        messages=[{"role": "user", "content": prompt}]
    )

    return parse_json_response(message.content[0].text)

# ============================================================
# ENDPOINTS FASTAPI
# ============================================================
@app.get("/health")
async def health():
    return {
        "status": "ok",
        "service": "FitPro AI",
        "model": MODEL,
        "api_key_configured": bool(ANTHROPIC_API_KEY),
    }


@app.post("/gerar-treino", response_model=RespostaTreino)
async def endpoint_gerar_treino(perfil: PerfilAluno):
    try:
        plano = gerar_treino(perfil.dict())
        return {"ok": True, "plano": plano}
    except RuntimeError as e:
        raise HTTPException(500, detail=str(e))
    except anthropic.APIConnectionError:
        raise HTTPException(503, detail="NÃ£o foi possÃ­vel conectar Ã  API da Anthropic. Verifique sua conexÃ£o e a chave de API.")
    except anthropic.AuthenticationError:
        raise HTTPException(401, detail="Chave da API Anthropic invÃ¡lida. Configure ANTHROPIC_API_KEY.")
    except anthropic.RateLimitError:
        raise HTTPException(429, detail="Limite de requisiÃ§Ãµes da API atingido. Tente novamente em instantes.")
    except json.JSONDecodeError as e:
        log.error(f"Erro ao parsear resposta da IA: {e}")
        raise HTTPException(500, detail="A IA retornou uma resposta em formato inesperado.")
    except ValueError as e:
        raise HTTPException(422, detail=str(e))
    except Exception as e:
        log.error(f"Erro inesperado ao gerar treino: {e}", exc_info=True)
        raise HTTPException(500, detail=f"Erro interno: {str(e)}")


@app.post("/gerar-nutricao", response_model=RespostaNutricao)
async def endpoint_gerar_nutricao(perfil: PerfilAluno):
    try:
        nutricao = gerar_nutricao(perfil.dict())
        return {"ok": True, "nutricao": nutricao}
    except RuntimeError as e:
        raise HTTPException(500, detail=str(e))
    except anthropic.APIConnectionError:
        raise HTTPException(503, detail="NÃ£o foi possÃ­vel conectar Ã  API da Anthropic.")
    except anthropic.AuthenticationError:
        raise HTTPException(401, detail="Chave da API Anthropic invÃ¡lida.")
    except Exception as e:
        log.error(f"Erro ao gerar nutriÃ§Ã£o: {e}", exc_info=True)
        raise HTTPException(500, detail=str(e))

# ============================================================
# CLI â€” compatibilidade com shell_exec legado do PHP
# (Removido o shell_exec do PHP â€” use FastAPI em vez disso)
# ============================================================
if __name__ == "__main__":
    if len(sys.argv) < 2:
        # Modo servidor (alternativa ao uvicorn)
        import uvicorn
        uvicorn.run("generate_workout:app", host="0.0.0.0", port=8000, reload=True)
    else:
        # Modo CLI legado
        try:
            perfil = json.loads(sys.argv[1])
            plano  = gerar_treino(perfil)
            print(json.dumps(plano, ensure_ascii=False))
        except json.JSONDecodeError as e:
            print(json.dumps({"error": f"JSON invÃ¡lido: {str(e)}"}))
            sys.exit(1)
        except Exception as e:
            print(json.dumps({"error": str(e)}))
            sys.exit(1)



