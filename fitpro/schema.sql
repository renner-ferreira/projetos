-- ============================================================
-- FitPro — Schema Completo (MySQL 8.0+)
-- ============================================================
-- Execução:
--   mysql -u root -p < schema.sql
-- ============================================================

CREATE DATABASE IF NOT EXISTS fitpro_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE fitpro_db;

-- ============================================================
-- USUÁRIOS (alunos)
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100)  NOT NULL,
    email           VARCHAR(150)  NOT NULL UNIQUE,
    password_hash   VARCHAR(255)  NOT NULL,
    plan            ENUM('free','pro','elite') DEFAULT 'free',
    gender          ENUM('M','F','outro'),
    birth_date      DATE,
    weight_kg       DECIMAL(5,2),
    height_cm       SMALLINT,
    goal            ENUM('hipertrofia','emagrecimento','condicionamento','forca'),
    level           ENUM('iniciante','intermediario','avancado') DEFAULT 'iniciante',
    professional_id INT UNSIGNED,
    nutritionist_id INT UNSIGNED,
    active          TINYINT(1) DEFAULT 1,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================================================
-- PROFISSIONAIS
-- ============================================================
CREATE TABLE IF NOT EXISTS professionals (
    id                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name              VARCHAR(100) NOT NULL,
    email             VARCHAR(150) NOT NULL UNIQUE,
    password_hash     VARCHAR(255) NOT NULL,
    role              ENUM('educador_fisico','nutricionista') NOT NULL,
    cref_crn          VARCHAR(30),
    specialty         VARCHAR(200),
    experience_years  TINYINT UNSIGNED DEFAULT 0,
    bio               TEXT,
    photo_url         VARCHAR(500),
    rating            DECIMAL(3,2) DEFAULT 5.00,
    student_count     INT UNSIGNED DEFAULT 0,
    active            TINYINT(1) DEFAULT 1,
    created_at        DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================================================
-- BIBLIOTECA DE EXERCÍCIOS
-- ============================================================
CREATE TABLE IF NOT EXISTS exercises (
    id               INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name             VARCHAR(150) NOT NULL,
    muscle_group     VARCHAR(80)  NOT NULL,
    secondary_muscle VARCHAR(80),
    equipment        VARCHAR(80),
    difficulty       ENUM('iniciante','intermediario','avancado'),
    image_url        VARCHAR(500),
    video_url        VARCHAR(500),
    instructions     TEXT,
    tips             TEXT,
    created_at       DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================================================
-- PLANOS DE TREINO SEMANAIS
-- ============================================================
CREATE TABLE IF NOT EXISTS workout_plans (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id     INT UNSIGNED NOT NULL,
    created_by  INT UNSIGNED,
    source      ENUM('manual','ia') DEFAULT 'manual',
    name        VARCHAR(150),
    description TEXT,
    week_start  DATE,
    week_end    DATE,
    data_json   JSON,
    active      TINYINT(1) DEFAULT 1,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- TREINOS (sessões individuais)
-- ============================================================
CREATE TABLE IF NOT EXISTS workouts (
    id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    plan_id       INT UNSIGNED,
    user_id       INT UNSIGNED NOT NULL,
    name          VARCHAR(150) NOT NULL,
    muscle_group  VARCHAR(80),
    day_of_week   ENUM('segunda','terca','quarta','quinta','sexta','sabado','domingo'),
    duration_min  SMALLINT UNSIGNED DEFAULT 60,
    level         ENUM('iniciante','intermediario','avancado'),
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (plan_id) REFERENCES workout_plans(id) ON DELETE SET NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- EXERCÍCIOS DENTRO DE UM TREINO
-- ============================================================
CREATE TABLE IF NOT EXISTS workout_exercises (
    id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    workout_id    INT UNSIGNED NOT NULL,
    exercise_id   INT UNSIGNED NOT NULL,
    order_index   TINYINT UNSIGNED DEFAULT 0,
    sets          TINYINT UNSIGNED DEFAULT 3,
    reps          VARCHAR(20) DEFAULT '12',
    weight_kg     DECIMAL(6,2),
    rest_seconds  SMALLINT UNSIGNED DEFAULT 90,
    notes         VARCHAR(255),
    FOREIGN KEY (workout_id)  REFERENCES workouts(id)  ON DELETE CASCADE,
    FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- EXECUÇÕES DE TREINO (histórico de sessões)
-- ============================================================
CREATE TABLE IF NOT EXISTS workout_sessions (
    id           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id      INT UNSIGNED NOT NULL,
    workout_id   INT UNSIGNED NOT NULL,
    started_at   DATETIME,
    finished_at  DATETIME,
    duration_min SMALLINT UNSIGNED,
    calories     SMALLINT UNSIGNED,
    notes        TEXT,
    FOREIGN KEY (user_id)    REFERENCES users(id)    ON DELETE CASCADE,
    FOREIGN KEY (workout_id) REFERENCES workouts(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- PLANOS ALIMENTARES
-- ============================================================
CREATE TABLE IF NOT EXISTS diet_plans (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id         INT UNSIGNED NOT NULL,
    nutritionist_id INT UNSIGNED,
    name            VARCHAR(150),
    daily_kcal      SMALLINT UNSIGNED,
    protein_g       SMALLINT UNSIGNED,
    carbs_g         SMALLINT UNSIGNED,
    fat_g           SMALLINT UNSIGNED,
    active          TINYINT(1) DEFAULT 1,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- REFEIÇÕES
-- ============================================================
CREATE TABLE IF NOT EXISTS meals (
    id           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    plan_id      INT UNSIGNED NOT NULL,
    name         VARCHAR(100) NOT NULL,
    time_of_day  TIME,
    foods        TEXT,
    calories     SMALLINT UNSIGNED,
    protein_g    DECIMAL(5,1),
    carbs_g      DECIMAL(5,1),
    fat_g        DECIMAL(5,1),
    FOREIGN KEY (plan_id) REFERENCES diet_plans(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- PROGRESSO (peso, medidas corporais)
-- ============================================================
CREATE TABLE IF NOT EXISTS progress_records (
    id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id       INT UNSIGNED NOT NULL,
    weight_kg     DECIMAL(5,2),
    body_fat_pct  DECIMAL(4,2),
    chest_cm      DECIMAL(5,1),
    waist_cm      DECIMAL(5,1),
    hip_cm        DECIMAL(5,1),
    arm_cm        DECIMAL(5,1),
    thigh_cm      DECIMAL(5,1),
    notes         TEXT,
    recorded_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- RECORDES PESSOAIS
-- ============================================================
CREATE TABLE IF NOT EXISTS personal_records (
    id           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id      INT UNSIGNED NOT NULL,
    exercise_id  INT UNSIGNED NOT NULL,
    weight_kg    DECIMAL(6,2),
    reps         TINYINT UNSIGNED,
    notes        VARCHAR(255),
    recorded_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id)     REFERENCES users(id)      ON DELETE CASCADE,
    FOREIGN KEY (exercise_id) REFERENCES exercises(id)  ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- NOTIFICAÇÕES (novo — necessário para o painel de notificações)
-- ============================================================
CREATE TABLE IF NOT EXISTS notifications (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id     INT UNSIGNED NOT NULL,
    message     VARCHAR(255) NOT NULL,
    `type`      ENUM('treino','nutricao','progresso','sistema') DEFAULT 'sistema',
    `read`      TINYINT(1) DEFAULT 0,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- ÍNDICES DE PERFORMANCE
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_users_email        ON users(email);
CREATE INDEX IF NOT EXISTS idx_workouts_user      ON workouts(user_id);
CREATE INDEX IF NOT EXISTS idx_workouts_plan      ON workouts(plan_id);
CREATE INDEX IF NOT EXISTS idx_sessions_user      ON workout_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_workout   ON workout_sessions(workout_id);
CREATE INDEX IF NOT EXISTS idx_progress_user      ON progress_records(user_id);
CREATE INDEX IF NOT EXISTS idx_progress_date      ON progress_records(user_id, recorded_at);
CREATE INDEX IF NOT EXISTS idx_records_user       ON personal_records(user_id);
CREATE INDEX IF NOT EXISTS idx_plans_user         ON workout_plans(user_id);
CREATE INDEX IF NOT EXISTS idx_plans_active       ON workout_plans(user_id, active);
CREATE INDEX IF NOT EXISTS idx_diet_user          ON diet_plans(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id, `read`);

-- ============================================================
-- DADOS DE DEMONSTRAÇÃO
-- Senha de todos: 123456  (hash bcrypt)
-- ============================================================

-- Usuário demo
INSERT IGNORE INTO users (id, name, email, password_hash, plan, gender, weight_kg, height_cm, goal, level)
VALUES (
    1,
    'João Dias',
    'joao@fitpro.com',
    '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', -- 123456
    'pro',
    'M',
    78.5,
    178,
    'hipertrofia',
    'intermediario'
);

-- Profissionais demo
INSERT IGNORE INTO professionals (id, name, email, password_hash, role, cref_crn, specialty, experience_years, rating, student_count, photo_url)
VALUES
(1, 'Rafael Mendes',     'rafael@fitpro.com',  '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'educador_fisico', 'CREF 012345-G/SP', 'Especialista em hipertrofia e recomposição corporal', 8,  4.90, 320, 'https://images.unsplash.com/photo-1552374196-1ab2a1c593e8?w=300&h=300&fit=crop'),
(2, 'Dra. Camila Torres', 'camila@fitpro.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'nutricionista',   'CRN 45678',       'Especialista em nutrição esportiva e emagrecimento saudável', 6, 5.00, 240, 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=300&h=300&fit=crop'),
(3, 'Bruno Alves',        'bruno@fitpro.com',  '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'educador_fisico', 'CREF 098765-G/RJ', 'Especialista em CrossFit e condicionamento físico', 10, 4.80, 500, 'https://images.unsplash.com/photo-1600180758890-6b94519a8ba6?w=300&h=300&fit=crop');

-- Exercícios demo
INSERT IGNORE INTO exercises (id, name, muscle_group, equipment, difficulty) VALUES
(1,  'Supino Reto',           'Peito',  'Barra',     'intermediario'),
(2,  'Supino Inclinado',      'Peito',  'Barra',     'intermediario'),
(3,  'Crucifixo',             'Peito',  'Halteres',  'iniciante'),
(4,  'Tríceps Pulley',        'Braços', 'Máquina',   'iniciante'),
(5,  'Tríceps Testa',         'Braços', 'Halteres',  'intermediario'),
(6,  'Puxada Frontal',        'Costas', 'Máquina',   'iniciante'),
(7,  'Remada Curvada',        'Costas', 'Barra',     'intermediario'),
(8,  'Remada Unilateral',     'Costas', 'Halteres',  'iniciante'),
(9,  'Rosca Direta',          'Braços', 'Barra',     'iniciante'),
(10, 'Rosca Martelo',         'Braços', 'Halteres',  'iniciante'),
(11, 'Agachamento',           'Pernas', 'Barra',     'intermediario'),
(12, 'Leg Press',             'Pernas', 'Máquina',   'iniciante'),
(13, 'Extensão de Joelho',    'Pernas', 'Máquina',   'iniciante'),
(14, 'Flexão de Joelho',      'Pernas', 'Máquina',   'iniciante'),
(15, 'Panturrilha em Pé',     'Pernas', 'Máquina',   'iniciante'),
(16, 'Desenvolvimento Militar','Ombro', 'Barra',     'intermediario'),
(17, 'Elevação Lateral',      'Ombro',  'Halteres',  'iniciante'),
(18, 'Elevação Frontal',      'Ombro',  'Halteres',  'iniciante'),
(19, 'Levantamento Terra',    'Costas', 'Barra',     'avancado'),
(20, 'Supino Declinado',      'Peito',  'Barra',     'intermediario');

-- Progresso demo (últimos 6 meses)
INSERT IGNORE INTO progress_records (user_id, weight_kg, body_fat_pct, notes, recorded_at) VALUES
(1, 85.0, 22.0, 'Início do programa', DATE_SUB(NOW(), INTERVAL 6 MONTH)),
(1, 83.5, 21.2, 'Boa semana de treinos', DATE_SUB(NOW(), INTERVAL 5 MONTH)),
(1, 82.0, 20.5, 'Ajustei a dieta', DATE_SUB(NOW(), INTERVAL 4 MONTH)),
(1, 80.5, 19.8, 'Semana forte', DATE_SUB(NOW(), INTERVAL 3 MONTH)),
(1, 79.0, 19.0, 'Melhorando a resistência', DATE_SUB(NOW(), INTERVAL 2 MONTH)),
(1, 78.5, 18.2, 'Meu melhor peso até agora', DATE_SUB(NOW(), INTERVAL 1 MONTH));

-- Notificações demo
INSERT IGNORE INTO notifications (user_id, message, type, `read`) VALUES
(1, 'Seu treino de hoje está pronto! 💪',          'treino',   0),
(1, 'Rafael Mendes comentou no seu progresso.',    'sistema',  0),
(1, 'Nova dica de nutrição disponível!',           'nutricao', 1);

-- Plano alimentar demo
INSERT IGNORE INTO diet_plans (id, user_id, nutritionist_id, name, daily_kcal, protein_g, carbs_g, fat_g, active)
VALUES (1, 1, 2, 'Plano Hipertrofia — Dra. Camila', 2950, 229, 308, 62, 1);

INSERT IGNORE INTO meals (plan_id, name, time_of_day, foods, calories, protein_g, carbs_g, fat_g) VALUES
(1, 'Café da Manhã',   '07:00:00', 'Ovos mexidos (3un) + Aveia 80g + Banana + Whey 30g',               620, 45, 70, 12),
(1, 'Lanche da Manhã', '10:00:00', 'Iogurte grego 200g + Frutas vermelhas + Granola 30g',               310, 20, 38, 8),
(1, 'Almoço',          '13:00:00', 'Frango 200g + Arroz integral 150g + Feijão + Salada verde',          720, 52, 80, 14),
(1, 'Pré-Treino',      '16:00:00', 'Batata doce 120g + Frango 150g + Creatina 5g',                       480, 38, 55, 6),
(1, 'Pós-Treino',      '19:30:00', 'Whey 40g + Dextrose 30g + Água',                                    280, 32, 35, 2),
(1, 'Jantar',          '21:00:00', 'Salmão 180g + Brócolis + Azeite extra virgem 15ml + Quinoa 100g',    540, 42, 30, 20);
