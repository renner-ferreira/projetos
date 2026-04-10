# FitPro — Guia de Configuração

## Estrutura de arquivos

```
fitpro/
├── index.html          # Frontend SPA
├── style.css           # Estilos completos
├── app.js              # Lógica do frontend + integração API
├── index.php           # Backend REST (rodar na raiz do servidor PHP)
├── generate_workout.py # Microserviço Python (FastAPI)
├── schema.sql          # Banco de dados MySQL
└── README.md           # Este arquivo
```

---

## 1. Banco de Dados

```bash
mysql -u root -p < schema.sql
```

Isso cria o banco `fitpro_db` com todas as tabelas e dados demo.

**Usuário demo:** joao@fitpro.com / 123456

---

## 2. PHP (Backend)

### Apache — adicione `.htaccess` na raiz:
```apache
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteRule ^api/(.*)$ index.php [QSA,L]
```

### Nginx — adicione no `server {}`:
```nginx
location /api/ {
    try_files $uri $uri/ /index.php?$query_string;
}
```

### Variáveis de ambiente (recomendado):
```bash
export DB_HOST=localhost
export DB_USER=fitpro_user
export DB_PASS=sua_senha_segura
export DB_NAME=fitpro_db
export JWT_SECRET=$(openssl rand -hex 32)
export AI_SERVICE_URL=http://localhost:8000
```

---

## 3. Python (Microserviço IA)

```bash
pip install anthropic fastapi uvicorn pydantic

export ANTHROPIC_API_KEY=sk-ant-...

# Desenvolvimento
uvicorn generate_workout:app --host 0.0.0.0 --port 8000 --reload

# Produção
uvicorn generate_workout:app --host 0.0.0.0 --port 8000 --workers 2
```

Testar se está funcionando:
```bash
curl http://localhost:8000/health
```

---

## 4. Testando a integração completa

```bash
# 1. Login
curl -X POST http://localhost/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"joao@fitpro.com","password":"123456"}'

# 2. Gerar treino com IA (use o token retornado acima)
curl -X POST http://localhost/api/gerar-treino \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SEU_TOKEN" \
  -d '{
    "objetivo": "hipertrofia",
    "nivel": "intermediario",
    "dias_semana": 5,
    "duracao_min": 60,
    "equipamentos": "academia_completa"
  }'
```

---

## Funcionalidades implementadas

- [x] Tela de login com JWT
- [x] Navegação SPA (Dashboard, Treinos, Plano, Dieta, Profissionais, Progresso, IA)
- [x] Skeleton loaders em todas as seções
- [x] Timer de descanso entre séries
- [x] Painel de notificações
- [x] Geração de treino com IA (Claude)
- [x] Gráfico de evolução de peso (Chart.js)
- [x] Registro de progresso com feedback
- [x] Filtro de treinos por grupo muscular
- [x] Fallback demo quando backend está offline
- [x] Dados de demonstração no banco
- [x] FastAPI em vez de shell_exec (seguro)
- [x] Autenticação em todos os endpoints PHP
- [x] Tabela de notificações no schema

## Próximos passos sugeridos

- [ ] Adicionar PWA (manifest.json + service worker)
- [ ] Push notifications para lembrar de treinar
- [ ] Upload de foto de progresso
- [ ] Chat com o profissional via WebSocket
- [ ] Modo escuro / claro alternável
- [ ] Exportar treino como PDF
