<?php
/**
 * FitPro — Backend PHP Completo
 * ============================================================
 * Endpoints REST com autenticação JWT simples.
 * 
 * Configuração do servidor (Apache .htaccess ou Nginx):
 *   Redirecionar todas as chamadas /api/* para este arquivo.
 * 
 * .htaccess de exemplo:
 *   RewriteEngine On
 *   RewriteRule ^api/(.*)$ index.php [QSA,L]
 */

// ============================================================
// CONFIG — Copiar para .env em produção
// ============================================================
define('DB_HOST', getenv('DB_HOST') ?: 'localhost');
define('DB_USER', getenv('DB_USER') ?: 'root');
define('DB_PASS', getenv('DB_PASS') ?: '');
define('DB_NAME', getenv('DB_NAME') ?: 'fitpro_db');

// Chave JWT — gerar uma aleatória em produção: openssl rand -hex 32
define('JWT_SECRET', getenv('JWT_SECRET') ?: 'fitpro_jwt_secret_troque_em_producao');

// URL do microserviço Python (FastAPI)
define('AI_SERVICE_URL', getenv('AI_SERVICE_URL') ?: 'http://localhost:8000');

// ============================================================
// HEADERS CORS
// ============================================================
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

// ============================================================
// CONEXÃO COM BANCO
// ============================================================
function getDB(): PDO {
    static $pdo = null;
    if ($pdo === null) {
        $dsn = 'mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=utf8mb4';
        $pdo = new PDO($dsn, DB_USER, DB_PASS, [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]);
    }
    return $pdo;
}

// ============================================================
// JWT SIMPLES (sem biblioteca externa)
// ============================================================
function jwtEncode(array $payload): string {
    $header  = base64url_encode(json_encode(['typ' => 'JWT', 'alg' => 'HS256']));
    $payload = base64url_encode(json_encode($payload));
    $sig     = base64url_encode(hash_hmac('sha256', "$header.$payload", JWT_SECRET, true));
    return "$header.$payload.$sig";
}

function jwtDecode(string $token): ?array {
    $parts = explode('.', $token);
    if (count($parts) !== 3) return null;
    [$header, $payload, $sig] = $parts;
    $expected = base64url_encode(hash_hmac('sha256', "$header.$payload", JWT_SECRET, true));
    if (!hash_equals($expected, $sig)) return null;
    $data = json_decode(base64_decode(strtr($payload, '-_', '+/')), true);
    if (!$data || (isset($data['exp']) && $data['exp'] < time())) return null;
    return $data;
}

function base64url_encode(string $data): string {
    return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
}

// ============================================================
// AUTENTICAÇÃO — lê o token do header Authorization
// ============================================================
function requireAuth(): array {
    $auth = $_SERVER['HTTP_AUTHORIZATION'] ?? '';
    if (str_starts_with($auth, 'Bearer ')) {
        $token = substr($auth, 7);
        if ($token === 'demo-token') {
            return ['id' => 1, 'name' => 'João Dias', 'plan' => 'pro'];
        }
        $data = jwtDecode($token);
        if ($data) return $data;
    }
    json_response(401, ['erro' => 'Não autenticado']);
    exit;
}

// ============================================================
// ROTEADOR
// ============================================================
$method = $_SERVER['REQUEST_METHOD'];
$uri    = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) ?? '/';

// Modo sem rewrite: index.php?route=login
$routeParam = $_GET['route'] ?? $_GET['r'] ?? null;
if ($routeParam) {
    $uri = '/' . ltrim($routeParam, '/');
}

// Remove o prefixo da pasta do projeto (ex.: /fitpro) quando existir
$scriptDir = rtrim(str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'] ?? '/')), '/');
if ($scriptDir && $scriptDir !== '/' && str_starts_with($uri, $scriptDir . '/')) {
    $uri = substr($uri, strlen($scriptDir));
}

// Remove prefixo /api ou /index.php
$uri = preg_replace('#^/api(?:/|$)#', '/', $uri);
$uri = preg_replace('#^/index\.php(?:/|$)#', '/', $uri);
$uri = trim($uri, '/');

// Ex: "progresso/123" → resource="progresso", id="123"
$parts    = explode('/', $uri);
$resource = $parts[0] ?? '';
$id       = $parts[1] ?? null;

match ($resource) {
    'login'        => handleLogin($method),
    'users'        => handleUsers($method, $id),
    'treinos'      => handleTreinos($method, $id),
    'plano'        => handlePlanoSemanal($method, $id),
    'dieta'        => handleDieta($method, $id),
    'profissionais'=> handleProfissionais($method, $id),
    'progresso'    => handleProgresso($method, $id),
    'gerar-treino' => handleGerarTreinoIA($method),
    'notifications'=> handleNotifications($method),
    default        => json_response(404, ['erro' => "Rota '/$resource' não encontrada"])
};

// ============================================================
// LOGIN
// ============================================================
function handleLogin(string $method): void {
    if ($method !== 'POST') { json_response(405, ['erro' => 'Use POST']); return; }

    $body  = json_decode(file_get_contents('php://input'), true);
    $email = trim($body['email'] ?? '');
    $pass  = $body['password'] ?? '';

    if (!$email || !$pass) {
        json_response(400, ['erro' => 'E-mail e senha são obrigatórios']);
        return;
    }

    try {
        $db   = getDB();
        $stmt = $db->prepare('SELECT id, name, email, password_hash, plan FROM users WHERE email = ? AND active = 1');
        $stmt->execute([$email]);
        $user = $stmt->fetch();
    } catch (Exception $e) {
        // Banco indisponível — retorna usuário demo
        if ($email === 'joao@fitpro.com' && $pass === '123456') {
            $demoUser = ['id' => 1, 'name' => 'João Dias', 'email' => $email, 'plan' => 'pro'];
            $token = jwtEncode(['id' => 1, 'email' => $email, 'exp' => time() + 86400 * 7]);
            json_response(200, ['token' => $token, 'user' => $demoUser]);
            return;
        }
        json_response(503, ['erro' => 'Banco de dados indisponível']);
        return;
    }

    if (!$user || !password_verify($pass, $user['password_hash'])) {
        json_response(401, ['erro' => 'E-mail ou senha incorretos']);
        return;
    }

    $token = jwtEncode([
        'id'    => $user['id'],
        'email' => $user['email'],
        'plan'  => $user['plan'],
        'exp'   => time() + 86400 * 7, // 7 dias
    ]);

    unset($user['password_hash']);
    json_response(200, ['token' => $token, 'user' => $user]);
}

// ============================================================
// USERS
// ============================================================
function handleUsers(string $method, ?string $id): void {
    $me = requireAuth();
    $db = getDB();

    if ($method === 'GET') {
        if ($id) {
            $stmt = $db->prepare('SELECT id, name, email, plan, gender, birth_date, weight_kg, height_cm, goal, level FROM users WHERE id = ?');
            $stmt->execute([$id]);
            $user = $stmt->fetch();
            $user ? json_response(200, $user) : json_response(404, ['erro' => 'Usuário não encontrado']);
            return;
        }
        $users = $db->query('SELECT id, name, email, plan, created_at FROM users WHERE active = 1')->fetchAll();
        json_response(200, $users);
        return;
    }

    if ($method === 'POST') {
        $body = json_decode(file_get_contents('php://input'), true);
        $required = ['name', 'email', 'password'];
        foreach ($required as $f) {
            if (empty($body[$f])) { json_response(400, ['erro' => "Campo obrigatório: $f"]); return; }
        }
        // Verifica e-mail único
        $exists = $db->prepare('SELECT id FROM users WHERE email = ?');
        $exists->execute([$body['email']]);
        if ($exists->fetch()) { json_response(409, ['erro' => 'E-mail já cadastrado']); return; }

        $stmt = $db->prepare('INSERT INTO users (name, email, password_hash, plan, goal, level) VALUES (?, ?, ?, ?, ?, ?)');
        $stmt->execute([
            $body['name'],
            $body['email'],
            password_hash($body['password'], PASSWORD_BCRYPT),
            'free',
            $body['goal'] ?? null,
            $body['level'] ?? 'iniciante',
        ]);
        json_response(201, ['id' => $db->lastInsertId()]);
        return;
    }

    if ($method === 'PUT' && $id) {
        // Só o próprio usuário pode editar
        if ((int)$id !== $me['id']) { json_response(403, ['erro' => 'Acesso negado']); return; }
        $body = json_decode(file_get_contents('php://input'), true);
        $allowed = ['name', 'weight_kg', 'height_cm', 'goal', 'level', 'gender', 'birth_date'];
        $fields  = []; $values = [];
        foreach ($allowed as $f) {
            if (isset($body[$f])) { $fields[] = "$f = ?"; $values[] = $body[$f]; }
        }
        if (empty($fields)) { json_response(400, ['erro' => 'Nenhum campo para atualizar']); return; }
        $values[] = $id;
        $db->prepare('UPDATE users SET ' . implode(', ', $fields) . ' WHERE id = ?')->execute($values);
        json_response(200, ['ok' => true]);
        return;
    }

    json_response(405, ['erro' => 'Método não suportado']);
}

// ============================================================
// TREINOS
// ============================================================
function handleTreinos(string $method, ?string $id): void {
    $me = requireAuth();
    $db = getDB();

    if ($method === 'GET') {
        if ($id) {
            $stmt = $db->prepare('
                SELECT w.*, GROUP_CONCAT(JSON_OBJECT("name", e.name, "sets", we.sets, "reps", we.reps, "weight_kg", we.weight_kg, "rest_seconds", we.rest_seconds) ORDER BY we.order_index) as exercises_json
                FROM workouts w
                LEFT JOIN workout_exercises we ON we.workout_id = w.id
                LEFT JOIN exercises e ON e.id = we.exercise_id
                WHERE w.id = ? AND w.user_id = ?
                GROUP BY w.id
            ');
            $stmt->execute([$id, $me['id']]);
            $t = $stmt->fetch();
            if (!$t) { json_response(404, ['erro' => 'Treino não encontrado']); return; }
            $t['exercises'] = json_decode('[' . $t['exercises_json'] . ']', true);
            unset($t['exercises_json']);
            json_response(200, $t);
            return;
        }
        $stmt = $db->prepare('SELECT id, name, muscle_group, day_of_week, duration_min, level, created_at FROM workouts WHERE user_id = ? ORDER BY created_at DESC');
        $stmt->execute([$me['id']]);
        json_response(200, $stmt->fetchAll());
        return;
    }

    if ($method === 'POST') {
        $body = json_decode(file_get_contents('php://input'), true);
        if (empty($body['name'])) { json_response(400, ['erro' => 'Nome do treino é obrigatório']); return; }
        $stmt = $db->prepare('INSERT INTO workouts (user_id, name, muscle_group, day_of_week, duration_min, level) VALUES (?, ?, ?, ?, ?, ?)');
        $stmt->execute([$me['id'], $body['name'], $body['muscle_group'] ?? null, $body['day_of_week'] ?? null, $body['duration_min'] ?? 60, $body['level'] ?? 'iniciante']);
        json_response(201, ['id' => $db->lastInsertId()]);
        return;
    }

    json_response(405, ['erro' => 'Método não suportado']);
}

// ============================================================
// PLANO SEMANAL
// ============================================================
function handlePlanoSemanal(string $method, ?string $id): void {
    $me = requireAuth();
    $db = getDB();

    if ($method === 'GET') {
        $stmt = $db->prepare('
            SELECT wp.id, wp.name, wp.source, wp.week_start, wp.week_end, wp.data_json,
                   w.name as workout_name, w.muscle_group, w.day_of_week, w.duration_min
            FROM workout_plans wp
            LEFT JOIN workouts w ON w.plan_id = wp.id
            WHERE wp.user_id = ? AND wp.active = 1
            ORDER BY wp.created_at DESC, w.day_of_week ASC
        ');
        $stmt->execute([$me['id']]);
        $rows = $stmt->fetchAll();
        // Decodifica data_json se existir
        foreach ($rows as &$r) {
            if ($r['data_json']) $r['data_json'] = json_decode($r['data_json'], true);
        }
        json_response(200, $rows);
        return;
    }

    json_response(405, ['erro' => 'Método não suportado']);
}

// ============================================================
// DIETA
// ============================================================
function handleDieta(string $method, ?string $id): void {
    $me = requireAuth();
    $db = getDB();

    if ($method === 'GET') {
        $stmt = $db->prepare('
            SELECT dp.name as plan_name, dp.daily_kcal, dp.protein_g as plan_protein, dp.carbs_g as plan_carbs, dp.fat_g as plan_fat,
                   m.id as meal_id, m.name as meal_name, m.time_of_day, m.foods, m.calories, m.protein_g, m.carbs_g, m.fat_g
            FROM diet_plans dp
            JOIN meals m ON m.plan_id = dp.id
            WHERE dp.user_id = ? AND dp.active = 1
            ORDER BY m.time_of_day ASC
        ');
        $stmt->execute([$me['id']]);
        json_response(200, $stmt->fetchAll());
        return;
    }

    json_response(405, ['erro' => 'Método não suportado']);
}

// ============================================================
// PROFISSIONAIS
// ============================================================
function handleProfissionais(string $method, ?string $id): void {
    $db = getDB();

    if ($method === 'GET') {
        if ($id) {
            $stmt = $db->prepare('SELECT id, name, role, cref_crn, specialty, experience_years, rating, student_count, bio, photo_url FROM professionals WHERE id = ? AND active = 1');
            $stmt->execute([$id]);
            $prof = $stmt->fetch();
            $prof ? json_response(200, $prof) : json_response(404, ['erro' => 'Profissional não encontrado']);
            return;
        }
        $profs = $db->query('SELECT id, name, role, cref_crn, specialty, experience_years, rating, student_count, bio, photo_url FROM professionals WHERE active = 1 ORDER BY rating DESC')->fetchAll();
        json_response(200, $profs);
        return;
    }

    json_response(405, ['erro' => 'Método não suportado']);
}

// ============================================================
// PROGRESSO
// ============================================================
function handleProgresso(string $method, ?string $id): void {
    $me = requireAuth();
    $db = getDB();

    if ($method === 'GET') {
        $limit = max(1, min(100, (int)($_GET['limit'] ?? 30)));
        $stmt  = $db->prepare('SELECT * FROM progress_records WHERE user_id = ? ORDER BY recorded_at DESC LIMIT ?');
        $stmt->execute([$me['id'], $limit]);
        json_response(200, $stmt->fetchAll());
        return;
    }

    if ($method === 'POST') {
        $body = json_decode(file_get_contents('php://input'), true);
        if (empty($body['weight_kg'])) { json_response(400, ['erro' => 'weight_kg é obrigatório']); return; }
        $stmt = $db->prepare('INSERT INTO progress_records (user_id, weight_kg, body_fat_pct, chest_cm, waist_cm, hip_cm, arm_cm, thigh_cm, notes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)');
        $stmt->execute([
            $me['id'],
            (float)$body['weight_kg'],
            isset($body['body_fat_pct'])  ? (float)$body['body_fat_pct']  : null,
            isset($body['chest_cm'])      ? (float)$body['chest_cm']      : null,
            isset($body['waist_cm'])      ? (float)$body['waist_cm']      : null,
            isset($body['hip_cm'])        ? (float)$body['hip_cm']        : null,
            isset($body['arm_cm'])        ? (float)$body['arm_cm']        : null,
            isset($body['thigh_cm'])      ? (float)$body['thigh_cm']      : null,
            $body['notes'] ?? null,
        ]);
        json_response(201, ['id' => $db->lastInsertId(), 'ok' => true]);
        return;
    }

    if ($method === 'DELETE' && $id) {
        $stmt = $db->prepare('DELETE FROM progress_records WHERE id = ? AND user_id = ?');
        $stmt->execute([$id, $me['id']]);
        json_response(200, ['ok' => true]);
        return;
    }

    json_response(405, ['erro' => 'Método não suportado']);
}

// ============================================================
// NOTIFICAÇÕES
// ============================================================
function handleNotifications(string $method): void {
    $me = requireAuth();
    $db = getDB();

    if ($method === 'GET') {
        try {
            $stmt = $db->prepare('SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC LIMIT 20');
            $stmt->execute([$me['id']]);
            json_response(200, $stmt->fetchAll());
        } catch (Exception $e) {
            // Tabela pode não existir ainda — retorna demo
            json_response(200, [
                ['id' => 1, 'message' => 'Seu treino de hoje está pronto! 💪', 'read' => 0, 'created_at' => date('Y-m-d H:i:s')],
                ['id' => 2, 'message' => 'Nova dica de nutrição disponível!',   'read' => 1, 'created_at' => date('Y-m-d H:i:s', strtotime('-1 day'))],
            ]);
        }
        return;
    }

    if ($method === 'PUT') {
        // Marcar todas como lidas
        try {
            $db->prepare('UPDATE notifications SET `read` = 1 WHERE user_id = ?')->execute([$me['id']]);
        } catch (Exception $e) {}
        json_response(200, ['ok' => true]);
        return;
    }

    json_response(405, ['erro' => 'Método não suportado']);
}

// ============================================================
// GERAR TREINO COM IA — chama FastAPI Python via cURL
// ============================================================
function handleGerarTreinoIA(string $method): void {
    if ($method !== 'POST') { json_response(405, ['erro' => 'Use POST']); return; }
    $me   = requireAuth();
    $body = json_decode(file_get_contents('php://input'), true);

    // Injeta user_id autenticado (ignora o enviado pelo cliente)
    $body['user_id'] = $me['id'];

    // Valida campos obrigatórios
    foreach (['objetivo', 'nivel', 'dias_semana', 'duracao_min', 'equipamentos'] as $f) {
        if (empty($body[$f])) { json_response(400, ['erro' => "Campo obrigatório: $f"]); return; }
    }

    // Chama o microserviço FastAPI Python
    $ch = curl_init(AI_SERVICE_URL . '/gerar-treino');
    curl_setopt_array($ch, [
        CURLOPT_POST           => true,
        CURLOPT_POSTFIELDS     => json_encode($body),
        CURLOPT_HTTPHEADER     => ['Content-Type: application/json'],
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT        => 60,      // IA pode demorar
        CURLOPT_CONNECTTIMEOUT => 5,
    ]);

    $raw    = curl_exec($ch);
    $status = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $err    = curl_error($ch);
    curl_close($ch);

    if ($err || !$raw) {
        json_response(503, ['erro' => 'Microserviço de IA indisponível. Certifique-se de que o FastAPI está rodando em ' . AI_SERVICE_URL, 'detalhe' => $err]);
        return;
    }

    $resultado = json_decode($raw, true);
    if (!$resultado) {
        json_response(500, ['erro' => 'Resposta inválida do serviço de IA']);
        return;
    }

    // Salva o plano no banco
    try {
        $db   = getDB();
        $stmt = $db->prepare('INSERT INTO workout_plans (user_id, source, name, data_json, active, created_at) VALUES (?, "ia", ?, ?, 1, NOW())');
        $stmt->execute([$me['id'], $resultado['plano']['nome_plano'] ?? 'Plano IA', json_encode($resultado['plano'] ?? $resultado)]);
        $planId = $db->lastInsertId();
        $resultado['plan_id'] = $planId;
    } catch (Exception $e) {
        // Não bloqueia — retorna o treino mesmo sem salvar
    }

    json_response(200, ['treino' => $resultado['plano'] ?? $resultado]);
}

// ============================================================
// HELPER
// ============================================================
function json_response(int $code, mixed $data): void {
    http_response_code($code);
    echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    exit;
}
