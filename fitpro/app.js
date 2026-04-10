/* ============================================================
   FitPro — app.js
   Integração real com o backend PHP
   ============================================================ */

const APP_BASE = window.location.pathname.replace(/\/[^/]*$/, '') || '';
const API = `${APP_BASE}/index.php`; // funciona com e sem rewrite
let currentUser = null;
let restTimerInterval = null;
let restSeconds = 0;
let restTotal = 90;
let weightChart = null;

/* ============================================================
   AUTENTICAÇÃO
   ============================================================ */
async function doLogin() {
  const email = document.getElementById('login-email').value.trim();
  const pass  = document.getElementById('login-password').value;
  const errEl = document.getElementById('login-error');
  const btn   = document.getElementById('btn-login');

  if (!email || !pass) {
    showLoginError('Preencha e-mail e senha.');
    return;
  }

  btn.textContent = 'Entrando...';
  btn.disabled = true;

  try {
    const res  = await fetch(apiUrl('/login'), {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password: pass })
    });
    const data = await res.json();

    if (!res.ok || data.erro) {
      showLoginError(data.erro || 'E-mail ou senha incorretos.');
      btn.textContent = 'Entrar';
      btn.disabled = false;
      return;
    }

    // Salva token + usuário
    sessionStorage.setItem('fitpro_token', data.token);
    sessionStorage.setItem('fitpro_user', JSON.stringify(data.user));
    currentUser = data.user;
    initApp();
  } catch (e) {
    // Fallback demo quando backend não está disponível
    console.warn('Backend indisponível — modo demo ativado.');
    const demoUser = { id: 1, name: 'João Dias', email, plan: 'pro' };
    sessionStorage.setItem('fitpro_token', 'demo-token');
    sessionStorage.setItem('fitpro_user', JSON.stringify(demoUser));
    currentUser = demoUser;
    initApp();
  }
}

function doLogout() {
  sessionStorage.removeItem('fitpro_token');
  sessionStorage.removeItem('fitpro_user');
  currentUser = null;
  document.getElementById('app').style.display = 'none';
  document.getElementById('login-screen').style.display = 'flex';
}

function showLoginError(msg) {
  const el = document.getElementById('login-error');
  el.textContent = msg;
  el.style.display = 'block';
}

/* ============================================================
   INICIALIZAÇÃO
   ============================================================ */
function initApp() {
  document.getElementById('login-screen').style.display = 'none';
  document.getElementById('app').style.display = 'block';

  // Preenche info do usuário na sidebar
  const u = currentUser;
  const initials = u.name.split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase();
  document.getElementById('sidebar-avatar').textContent = initials;
  document.getElementById('sidebar-name').textContent = u.name;
  document.getElementById('sidebar-plan').textContent = `Plano ${u.plan === 'pro' ? 'Pro' : u.plan === 'elite' ? 'Elite' : 'Free'}`;

  // Navega para dashboard e carrega dados
  navigate('dashboard');
  bindNav();
  loadNotifications();
}

/* ============================================================
   HELPER: request autenticado
   ============================================================ */
async function apiFetch(path, options = {}) {
  const token = sessionStorage.getItem('fitpro_token');
  return fetch(apiUrl(path), {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`,
      ...(options.headers || {})
    }
  });
}

function apiUrl(path) {
  const route = String(path || '').replace(/^\/+/, '');
  return `${API}?route=${encodeURIComponent(route)}`;
}

/* ============================================================
   NAVEGAÇÃO
   ============================================================ */
const pages = {
  dashboard:     { title: 'Dashboard',        subtitle: () => `Bem-vindo de volta, ${currentUser?.name?.split(' ')[0] || ''} 💪` },
  treinos:       { title: 'Meus Treinos',     subtitle: () => 'Biblioteca de exercícios' },
  plano:         { title: 'Plano Semanal',    subtitle: () => 'Programação da semana' },
  dieta:         { title: 'Dieta & Nutrição', subtitle: () => 'Sua alimentação de hoje' },
  profissionais: { title: 'Profissionais',    subtitle: () => 'Equipe de especialistas' },
  progresso:     { title: 'Progresso',        subtitle: () => 'Sua evolução ao longo do tempo' },
  ia:            { title: 'IA Treino',        subtitle: () => 'Gere treinos personalizados com IA' },
};

const pageLoaders = {
  dashboard:     loadDashboard,
  treinos:       loadTreinos,
  plano:         loadPlano,
  dieta:         loadDieta,
  profissionais: loadProfissionais,
  progresso:     loadProgresso,
  ia:            () => {}, // estático
};

function navigate(key) {
  document.querySelectorAll('.nav-item').forEach(el => {
    el.classList.toggle('active', el.dataset.page === key);
  });
  document.querySelectorAll('.page').forEach(el => el.classList.remove('active'));
  const target = document.getElementById('page-' + key);
  if (target) target.classList.add('active');

  const meta = pages[key];
  if (meta) {
    document.getElementById('page-title').textContent = meta.title;
    document.getElementById('page-subtitle').textContent = meta.subtitle();
  }

  if (pageLoaders[key]) pageLoaders[key]();

  if (window.innerWidth < 900) {
    document.getElementById('sidebar').classList.remove('open');
  }

  // Fecha notificações
  document.getElementById('notifications-panel').style.display = 'none';
}

function bindNav() {
  document.querySelectorAll('.nav-item').forEach(el => {
    el.addEventListener('click', e => { e.preventDefault(); navigate(el.dataset.page); });
  });
  document.querySelectorAll('.filter-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      filterTreinos(btn.dataset.filter || 'todos');
    });
  });
  document.addEventListener('click', e => {
    const sidebar = document.getElementById('sidebar');
    if (window.innerWidth < 900 && !sidebar.contains(e.target) && !e.target.closest('.menu-toggle')) {
      sidebar.classList.remove('open');
    }
    if (!e.target.closest('.btn-notify') && !e.target.closest('.notifications-panel')) {
      document.getElementById('notifications-panel').style.display = 'none';
    }
  });

  // Enter no login
  document.getElementById('login-password')?.addEventListener('keydown', e => {
    if (e.key === 'Enter') doLogin();
  });
}

/* ============================================================
   DASHBOARD
   ============================================================ */
let dashboardLoaded = false;

async function loadDashboard() {
  if (dashboardLoaded) return;
  dashboardLoaded = true;

  await Promise.all([
    loadStats(),
    loadTodayWorkout(),
    loadDica(),
    loadWeekMini(),
    loadMacros(),
  ]);
}

async function loadStats() {
  // Dados de progresso
  try {
    const res  = await apiFetch(`/progresso?user_id=${currentUser.id}`);
    const data = await res.json();
    const latest = Array.isArray(data) && data.length ? data[0] : null;
    renderStats({
      treinos: '4/5',
      calorias: '2.340',
      sequencia: '12 dias 🔥',
      peso: latest ? `${parseFloat(latest.weight_kg).toFixed(1)} kg` : '78.5 kg'
    });
  } catch {
    renderStats({ treinos: '4/5', calorias: '2.340', sequencia: '12 dias 🔥', peso: '78.5 kg' });
  }
}

function renderStats({ treinos, calorias, sequencia, peso }) {
  document.getElementById('stats-row').innerHTML = `
    <div class="stat-card accent-green">
      <span class="stat-label">Treinos esta semana</span>
      <span class="stat-value">${treinos}</span>
      <div class="stat-bar"><div style="width:80%"></div></div>
    </div>
    <div class="stat-card accent-orange">
      <span class="stat-label">Calorias queimadas</span>
      <span class="stat-value">${calorias}</span>
      <div class="stat-bar"><div style="width:65%"></div></div>
    </div>
    <div class="stat-card accent-blue">
      <span class="stat-label">Sequência atual</span>
      <span class="stat-value">${sequencia}</span>
      <div class="stat-bar"><div style="width:90%"></div></div>
    </div>
    <div class="stat-card accent-purple">
      <span class="stat-label">Peso atual</span>
      <span class="stat-value">${peso}</span>
      <div class="stat-bar"><div style="width:55%"></div></div>
    </div>
  `;
}

const WEEK_DAYS = ['segunda','terca','quarta','quinta','sexta','sabado','domingo'];
const WEEK_LABELS = ['SEG','TER','QUA','QUI','SEX','SÁB','DOM'];
const GROUP_LABELS = ['Peito','Costas','Pernas','Ombro','Braços','Descanso','Descanso'];

async function loadTodayWorkout() {
  const todayIdx = (new Date().getDay() + 6) % 7; // 0=seg
  document.getElementById('today-group').textContent = GROUP_LABELS[todayIdx] || 'Treino';

  try {
    const res   = await apiFetch(`/plano?user_id=${currentUser.id}`);
    const plano = await res.json();
    renderTodayExercises(plano, todayIdx);
  } catch {
    renderTodayExercisesDemo(todayIdx);
  }
}

function renderTodayExercises(plano, dayIdx) {
  // plano pode ser array de workouts — usa demo como fallback
  renderTodayExercisesDemo(dayIdx);
}

function renderTodayExercisesDemo(dayIdx) {
  const sets = [
    [{n:'Supino Reto',s:'4 × 12 reps — 70kg',img:'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=80&h=80&fit=crop',done:true},
     {n:'Crucifixo',s:'3 × 15 reps — 20kg',img:'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=80&h=80&fit=crop',done:false},
     {n:'Tríceps Testa',s:'4 × 12 reps — 30kg',img:'https://images.unsplash.com/photo-1598971639058-fab3c3109a00?w=80&h=80&fit=crop',done:false}],
    [{n:'Puxada Frontal',s:'4 × 12 reps',img:'',done:false},{n:'Remada Curvada',s:'4 × 10 reps',img:'',done:false},{n:'Rosca Direta',s:'3 × 12 reps',img:'',done:false}],
    [{n:'Agachamento',s:'5 × 10 reps — 80kg',img:'',done:false},{n:'Leg Press',s:'4 × 12 reps',img:'',done:false},{n:'Extensão',s:'3 × 15 reps',img:'',done:false}],
    [{n:'Dev. Militar',s:'4 × 10 reps',img:'',done:false},{n:'Elevação Lateral',s:'4 × 15 reps',img:'',done:false},{n:'Encolhimento',s:'4 × 12 reps',img:'',done:false}],
    [{n:'Rosca Scott',s:'3 × 12 reps',img:'',done:false},{n:'Rosca Martelo',s:'3 × 10 reps',img:'',done:false},{n:'Tríceps Francês',s:'3 × 12 reps',img:'',done:false}],
    [{n:'Descanso ativo',s:'Caminhada ou alongamento',img:'',done:false}],
    [{n:'Descanso total',s:'Hidratação e sono',img:'',done:false}],
  ];
  const exercises = sets[Math.min(dayIdx, sets.length - 1)];
  document.getElementById('today-exercises').innerHTML = exercises.map(ex => `
    <div class="exercise-item ${ex.done ? 'done' : ''}" onclick="toggleExercise(this, ${ex.s.match(/(\d+)\s*s/)?.[1] || 90})">
      <div class="exercise-img" style="background-image:url('${ex.img}')"></div>
      <div class="exercise-info">
        <strong>${ex.n}</strong>
        <span>${ex.s}</span>
      </div>
      <span class="exercise-check ${ex.done ? 'done-check' : 'pending'}">${ex.done ? '✓' : '○'}</span>
    </div>
  `).join('');
}

function toggleExercise(el, restSec = 90) {
  const isDone = el.classList.toggle('done');
  const check  = el.querySelector('.exercise-check');
  check.textContent = isDone ? '✓' : '○';
  check.className   = `exercise-check ${isDone ? 'done-check' : 'pending'}`;
  if (isDone) startTimer(restSec);
}

async function loadDica() {
  const dicas = [
    { text: 'Para maximizar o ganho muscular, consuma proteína dentro de 30 minutos após o treino. O whey protein é uma excelente opção para absorção rápida.', author: 'Dr. Rafael Costa', role: 'Nutricionista Esportivo', img: 'https://images.unsplash.com/photo-1552374196-1ab2a1c593e8?w=60&h=60&fit=crop' },
    { text: 'Priorize o sono de qualidade. Durante o sono profundo, o hormônio do crescimento é liberado em maior quantidade, acelerando a recuperação muscular.', author: 'Dra. Camila Torres', role: 'Nutricionista', img: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=60&h=60&fit=crop' },
    { text: 'A periodização do treino é fundamental para evitar platôs. Alterne fases de volume e intensidade a cada 4-6 semanas.', author: 'Bruno Alves', role: 'Educador Físico', img: 'https://images.unsplash.com/photo-1600180758890-6b94519a8ba6?w=60&h=60&fit=crop' },
  ];
  const d = dicas[new Date().getDate() % dicas.length];
  document.getElementById('dica-texto').textContent = `"${d.text}"`;
  document.getElementById('dica-author-name').textContent = d.author;
  document.getElementById('dica-author-role').textContent = d.role;
  document.getElementById('dica-avatar').style.backgroundImage = `url('${d.img}')`;
}

function loadWeekMini() {
  const todayIdx = (new Date().getDay() + 6) % 7;
  const labels = GROUP_LABELS;
  document.getElementById('week-days-mini').innerHTML = WEEK_LABELS.map((l, i) => {
    const cls = i < todayIdx ? 'done' : i === todayIdx ? 'today' : i >= 5 ? 'rest' : '';
    return `
      <div class="day-item ${cls}">
        <span class="day-name">${l}</span>
        <span class="day-label">${labels[i]}</span>
        <span class="day-dot"></span>
      </div>`;
  }).join('');
}

function loadMacros() {
  const macros = [
    { label: 'Proteína', val: 78, current: 156, goal: 200, color: '#00ff88', trackColor: '#1a1a2e' },
    { label: 'Carboidrato', val: 55, current: 138, goal: 250, color: '#ff6b35', trackColor: '#1a1a2e' },
    { label: 'Gordura', val: 42, current: 29, goal: 70, color: '#8b5cf6', trackColor: '#1a1a2e' },
  ];
  document.getElementById('macros-grid').innerHTML = macros.map(m => {
    const circ = 2 * Math.PI * 15.9;
    const offset = circ * (1 - m.val / 100);
    return `
      <div class="macro-item">
        <div class="macro-ring">
          <svg viewBox="0 0 36 36">
            <circle cx="18" cy="18" r="15.9" fill="none" stroke="${m.trackColor}" stroke-width="3"/>
            <circle cx="18" cy="18" r="15.9" fill="none" stroke="${m.color}" stroke-width="3"
              stroke-dasharray="${circ.toFixed(1)} ${circ.toFixed(1)}"
              stroke-dashoffset="${offset.toFixed(1)}"
              stroke-linecap="round"
              transform="rotate(-90 18 18)"/>
          </svg>
          <span>${m.val}%</span>
        </div>
        <strong>${m.label}</strong>
        <span>${m.current}g / ${m.goal}g</span>
      </div>`;
  }).join('');
}

function startWorkout() {
  const first = document.querySelector('#today-exercises .exercise-item');
  if (first && !first.classList.contains('done')) {
    first.click();
  }
}

/* ============================================================
   REST TIMER
   ============================================================ */
function startTimer(seconds = 90) {
  restSeconds = seconds;
  restTotal   = seconds;
  document.getElementById('rest-timer').style.display = 'flex';
  document.getElementById('rest-countdown').textContent = seconds;
  updateRing(seconds);

  clearInterval(restTimerInterval);
  restTimerInterval = setInterval(() => {
    restSeconds--;
    document.getElementById('rest-countdown').textContent = restSeconds;
    updateRing(restSeconds);
    if (restSeconds <= 0) stopTimer();
  }, 1000);
}

function updateRing(remaining) {
  const circumference = 2 * Math.PI * 34;
  const offset = circumference * (1 - remaining / restTotal);
  document.getElementById('rest-ring').style.strokeDashoffset = offset;
}

function stopTimer() {
  clearInterval(restTimerInterval);
  document.getElementById('rest-timer').style.display = 'none';
}

/* ============================================================
   TREINOS
   ============================================================ */
let allTreinos = [];

async function loadTreinos() {
  if (allTreinos.length) { renderTreinos(allTreinos); return; }

  // Demo data (substituir por apiFetch('/treinos') quando backend estiver pronto)
  allTreinos = [
    { id:1, name:'Treino Peito Completo', muscle_group:'Peito', exercises:'5 exercícios', duration_min:60, level:'intermediario', img:'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=200&fit=crop' },
    { id:2, name:'Costas em V', muscle_group:'Costas', exercises:'6 exercícios', duration_min:70, level:'avancado', img:'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=400&h=200&fit=crop' },
    { id:3, name:'Dia de Pernas Brutal', muscle_group:'Pernas', exercises:'7 exercícios', duration_min:80, level:'avancado', img:'https://images.unsplash.com/photo-1574680178050-55c6a6a96e0a?w=400&h=200&fit=crop' },
    { id:4, name:'Ombros 3D', muscle_group:'Ombro', exercises:'5 exercícios', duration_min:55, level:'intermediario', img:'https://images.unsplash.com/photo-1598971639058-fab3c3109a00?w=400&h=200&fit=crop' },
    { id:5, name:'Braços Bombados', muscle_group:'Braços', exercises:'6 exercícios', duration_min:50, level:'iniciante', img:'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=400&h=200&fit=crop' },
    { id:6, name:'Full Body Iniciante', muscle_group:'Full Body', exercises:'8 exercícios', duration_min:45, level:'iniciante', img:'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=400&h=200&fit=crop' },
  ];

  try {
    const res  = await apiFetch('/treinos');
    const data = await res.json();
    if (Array.isArray(data) && data.length) allTreinos = data;
  } catch {}

  renderTreinos(allTreinos);
}

function renderTreinos(list) {
  const levelMap = { iniciante: 'Iniciante', intermediario: 'Intermediário', avancado: 'Avançado' };
  document.getElementById('treinos-grid').innerHTML = list.map(t => `
    <div class="treino-card" data-group="${t.muscle_group}">
      <div class="treino-img" style="background-image:url('${t.img || ''}')">
        <span class="treino-badge">${t.muscle_group}</span>
      </div>
      <div class="treino-content">
        <h3>${t.name}</h3>
        <p>${t.exercises || '—'} · ${t.duration_min || '60'} min · ${levelMap[t.level] || t.level}</p>
        <button class="btn-outline" onclick="alert('Abrir treino ${t.id} — conecte ao backend!')">Ver Treino</button>
      </div>
    </div>
  `).join('');
}

function filterTreinos(group) {
  const cards = document.querySelectorAll('.treino-card');
  cards.forEach(c => {
    c.style.display = (group === 'todos' || c.dataset.group === group) ? 'block' : 'none';
  });
}

/* ============================================================
   PLANO SEMANAL
   ============================================================ */
let planoLoaded = false;

async function loadPlano() {
  if (planoLoaded) return;
  planoLoaded = true;

  // Demo
  const dias = [
    { name:'Segunda', group:'Peito & Tríceps', exs:[['Supino Reto','4×12'],['Supino Inclinado','3×10'],['Crucifixo','3×15'],['Tríceps Pulley','4×12'],['Tríceps Testa','3×10']], status:'done' },
    { name:'Terça', group:'Costas & Bíceps', exs:[['Puxada Frontal','4×12'],['Remada Curvada','4×10'],['Remada Unilateral','3×12'],['Rosca Direta','3×12'],['Rosca Martelo','3×10']], status:'done' },
    { name:'Quarta', group:'Pernas', exs:[['Agachamento','5×10'],['Leg Press','4×12'],['Extensão','3×15'],['Flexão','3×15'],['Panturrilha','4×20']], status:'today' },
    { name:'Quinta', group:'Ombro', exs:[['Dev. Militar','4×10'],['Elevação Lateral','4×15'],['Elevação Frontal','3×12'],['Peck Deck','3×15'],['Encolhimento','4×12']], status:'' },
    { name:'Sexta', group:'Braços', exs:[['Rosca Scott','3×12'],['Rosca Concentrada','3×10'],['Tríceps Francês','3×12'],['Mergulho','3×15'],['Antebraço','4×15']], status:'' },
    { name:'Sábado', group:'Descanso', exs:[], status:'rest' },
    { name:'Domingo', group:'Descanso', exs:[], status:'rest' },
  ];

  document.getElementById('weekly-plan').innerHTML = dias.map(d => {
    if (d.status === 'rest') return `
      <div class="plan-day rest-day">
        <div class="plan-day-header rest">
          <span class="plan-day-name">${d.name}</span>
          <span class="plan-day-badge">Descanso</span>
        </div>
        <div class="rest-content"><span>😴</span><p>Recuperação ativa ou descanso total.</p></div>
      </div>`;
    return `
      <div class="plan-day ${d.status === 'today' ? 'today-plan' : ''}">
        <div class="plan-day-header ${d.status}">
          <span class="plan-day-name">${d.name}</span>
          <span class="plan-day-badge">${d.group}</span>
        </div>
        <div class="plan-exercises">
          ${d.exs.map(([n,s]) => `<div class="plan-ex"><span>${n}</span><span>${s}</span></div>`).join('')}
        </div>
      </div>`;
  }).join('');
}

/* ============================================================
   DIETA
   ============================================================ */
let dietaLoaded = false;

async function loadDieta() {
  if (dietaLoaded) return;
  dietaLoaded = true;

  const meals = [
    { time:'07:00', name:'Café da Manhã', foods:'Ovos mexidos (3un) + Aveia 80g + Banana + Whey 30g', cals:'620 kcal · P: 45g · C: 70g · G: 12g', highlight:false },
    { time:'10:00', name:'Lanche da Manhã', foods:'Iogurte grego 200g + Frutas vermelhas + Granola 30g', cals:'310 kcal · P: 20g · C: 38g · G: 8g', highlight:false },
    { time:'13:00', name:'Almoço', foods:'Frango 200g + Arroz integral 150g + Feijão + Salada', cals:'720 kcal · P: 52g · C: 80g · G: 14g', highlight:true },
    { time:'16:00', name:'Pré-Treino', foods:'Batata doce 120g + Frango 150g + Creatina 5g', cals:'480 kcal · P: 38g · C: 55g · G: 6g', highlight:false },
    { time:'19:30', name:'Pós-Treino', foods:'Whey 40g + Dextrose 30g + Água', cals:'280 kcal · P: 32g · C: 35g · G: 2g', highlight:false },
    { time:'21:00', name:'Jantar', foods:'Salmão 180g + Brócolis + Azeite + Quinoa 100g', cals:'540 kcal · P: 42g · C: 30g · G: 20g', highlight:false },
  ];

  try {
    const res  = await apiFetch(`/dieta?user_id=${currentUser.id}`);
    const data = await res.json();
    if (Array.isArray(data) && data.length) {
      document.getElementById('meal-list').innerHTML = data.map(m => `
        <div class="meal-item">
          <div class="meal-time">${m.time_of_day?.slice(0,5) || '—'}</div>
          <div class="meal-info">
            <strong>${m.meal_name}</strong>
            <span>${m.foods || '—'}</span>
            <span class="meal-cals">${m.calories} kcal · P: ${m.protein_g}g · C: ${m.carbs_g}g · G: ${m.fat_g}g</span>
          </div>
        </div>`).join('');
      const totalCals = data.reduce((s, m) => s + (m.calories || 0), 0);
      document.getElementById('total-cals').innerHTML = `${totalCals.toLocaleString('pt-BR')} <span>kcal</span>`;
      return;
    }
  } catch {}

  // Demo fallback
  document.getElementById('meal-list').innerHTML = meals.map(m => `
    <div class="meal-item ${m.highlight ? 'highlight' : ''}">
      <div class="meal-time">${m.time}</div>
      <div class="meal-info">
        <strong>${m.name}</strong>
        <span>${m.foods}</span>
        <span class="meal-cals">${m.cals}</span>
      </div>
    </div>`).join('');

  document.getElementById('total-cals').innerHTML = '2.950 <span>kcal</span>';
  document.getElementById('macro-bars').innerHTML = `
    <div class="macro-bar-item"><span>Proteína</span><div class="bar-track"><div class="bar-fill protein" style="width:78%"></div></div><span>229g</span></div>
    <div class="macro-bar-item"><span>Carboidrato</span><div class="bar-track"><div class="bar-fill carbo" style="width:60%"></div></div><span>308g</span></div>
    <div class="macro-bar-item"><span>Gordura</span><div class="bar-track"><div class="bar-fill fat" style="width:52%"></div></div><span>62g</span></div>
  `;
}

/* ============================================================
   PROFISSIONAIS
   ============================================================ */
let profLoaded = false;

async function loadProfissionais() {
  if (profLoaded) return;
  profLoaded = true;

  const demo = [
    { name:'Rafael Mendes', role:'educador_fisico', cref_crn:'CREF 012345-G/SP', specialty:'Especialista em hipertrofia e recomposição corporal', experience_years:8, student_count:320, rating:'4.9', photo_url:'https://images.unsplash.com/photo-1552374196-1ab2a1c593e8?w=300&h=300&fit=crop' },
    { name:'Dra. Camila Torres', role:'nutricionista', cref_crn:'CRN 45678', specialty:'Especialista em nutrição esportiva e emagrecimento saudável', experience_years:6, student_count:240, rating:'5.0', photo_url:'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=300&h=300&fit=crop' },
    { name:'Bruno Alves', role:'educador_fisico', cref_crn:'CREF 098765-G/RJ', specialty:'Especialista em CrossFit e condicionamento físico', experience_years:10, student_count:500, rating:'4.8', photo_url:'https://images.unsplash.com/photo-1600180758890-6b94519a8ba6?w=300&h=300&fit=crop' },
  ];

  let list = demo;
  try {
    const res  = await apiFetch('/profissionais');
    const data = await res.json();
    if (Array.isArray(data) && data.length) list = data;
  } catch {}

  document.getElementById('prof-grid').innerHTML = list.map(p => `
    <div class="prof-card">
      <div class="prof-img" style="background-image:url('${p.photo_url || ''}')"></div>
      <div class="prof-info">
        <span class="prof-tag ${p.role === 'nutricionista' ? 'nutri' : ''}">${p.role === 'nutricionista' ? 'Nutricionista' : 'Educador Físico'}</span>
        <h3>${p.name}</h3>
        <p>${p.cref_crn} · ${p.specialty}</p>
        <div class="prof-stats">
          <div><strong>${p.experience_years}+</strong><span>anos exp.</span></div>
          <div><strong>${p.student_count}</strong><span>${p.role === 'nutricionista' ? 'pacientes' : 'alunos'}</span></div>
          <div><strong>${p.rating}★</strong><span>avaliação</span></div>
        </div>
        <button class="btn-secondary" onclick="alert('Perfil de ${p.name} — em breve!')">Ver Perfil</button>
      </div>
    </div>`).join('');
}

/* ============================================================
   PROGRESSO
   ============================================================ */
let progressoLoaded = false;

async function loadProgresso() {
  if (progressoLoaded) return;
  progressoLoaded = true;

  let records = [];
  try {
    const res  = await apiFetch(`/progresso?user_id=${currentUser.id}`);
    records = await res.json();
  } catch {}

  renderWeightChart(records);
  renderPersonalRecords();
}

function renderWeightChart(records) {
  const ctx = document.getElementById('weight-chart').getContext('2d');
  if (weightChart) weightChart.destroy();

  let labels, values;
  if (records.length > 1) {
    labels = records.slice(0, 10).reverse().map(r => {
      const d = new Date(r.recorded_at);
      return `${d.getDate()}/${d.getMonth()+1}`;
    });
    values = records.slice(0, 10).reverse().map(r => parseFloat(r.weight_kg));
  } else {
    labels = ['Jan','Fev','Mar','Abr','Mai','Jun'];
    values = [85, 83.5, 82, 80.5, 79, 78.5];
  }

  document.getElementById('chart-labels').innerHTML = labels.map(l => `<span>${l}</span>`).join('');

  weightChart = new Chart(ctx, {
    type: 'line',
    data: {
      labels,
      datasets: [{
        data: values,
        borderColor: '#00ff88',
        backgroundColor: 'rgba(0,255,136,0.08)',
        borderWidth: 2.5,
        tension: 0.4,
        fill: true,
        pointBackgroundColor: '#00ff88',
        pointRadius: 4,
        pointHoverRadius: 6,
      }]
    },
    options: {
      responsive: true,
      plugins: { legend: { display: false } },
      scales: {
        x: { ticks: { color: '#5a5a7a', font: { size: 11 } }, grid: { color: 'rgba(255,255,255,0.04)' } },
        y: { ticks: { color: '#5a5a7a', font: { size: 11 } }, grid: { color: 'rgba(255,255,255,0.04)' } }
      }
    }
  });
}

function renderPersonalRecords() {
  const records = [
    { exercise: 'Supino Reto', weight: '100 kg 🏆', date: 'há 3 dias' },
    { exercise: 'Agachamento', weight: '130 kg 🏆', date: 'há 1 semana' },
    { exercise: 'Levantamento Terra', weight: '150 kg 🏆', date: 'há 2 semanas' },
    { exercise: 'Rosca Direta', weight: '50 kg 🏆', date: 'há 1 mês' },
  ];
  document.getElementById('records-list').innerHTML = records.map(r => `
    <div class="record-item">
      <span class="record-exercise">${r.exercise}</span>
      <span class="record-weight">${r.weight}</span>
      <span class="record-date">${r.date}</span>
    </div>`).join('');
}

async function saveProgress() {
  const weight = document.getElementById('prog-weight').value;
  const fat    = document.getElementById('prog-fat').value;
  const notes  = document.getElementById('prog-notes').value;
  const fb     = document.getElementById('prog-feedback');

  if (!weight) {
    fb.className = 'form-error';
    fb.textContent = 'Informe pelo menos o peso.';
    fb.style.display = 'block';
    return;
  }

  try {
    const res = await apiFetch('/progresso', {
      method: 'POST',
      body: JSON.stringify({ user_id: currentUser.id, weight_kg: parseFloat(weight), body_fat_pct: fat ? parseFloat(fat) : null, notes })
    });
    if (res.ok) {
      fb.className = 'form-success';
      fb.textContent = '✓ Progresso registrado com sucesso!';
      fb.style.display = 'block';
      progressoLoaded = false;
      loadProgresso();
    }
  } catch {
    fb.className = 'form-success';
    fb.textContent = '✓ Dados salvos (modo demo — conecte o backend para persistir)!';
    fb.style.display = 'block';
  }
  setTimeout(() => { fb.style.display = 'none'; }, 4000);
}

/* ============================================================
   NOTIFICAÇÕES
   ============================================================ */
async function loadNotifications() {
  const demo = [
    { id:1, message:'Seu treino de hoje está pronto! 💪', created_at: 'há 10 min', read: false },
    { id:2, message:'Rafael Mendes comentou no seu progresso.', created_at: 'há 2h', read: false },
    { id:3, message:'Nova dica de nutrição disponível!', created_at: 'ontem', read: true },
  ];

  const unread = demo.filter(n => !n.read).length;
  const badge  = document.getElementById('notify-count');
  badge.textContent = unread;
  badge.style.display = unread > 0 ? 'flex' : 'none';

  document.getElementById('notif-list').innerHTML = demo.map(n => `
    <div class="notif-item ${n.read ? '' : 'unread'}" onclick="markRead(${n.id})">
      <p>${n.message}</p>
      <span>${n.created_at}</span>
    </div>`).join('');
}

function toggleNotifications() {
  const panel = document.getElementById('notifications-panel');
  panel.style.display = panel.style.display === 'none' ? 'block' : 'none';
}

function markRead(id) {}

function markAllRead() {
  document.querySelectorAll('.notif-item.unread').forEach(el => el.classList.remove('unread'));
  document.getElementById('notify-count').style.display = 'none';
}

/* ============================================================
   IA TREINO — integração real com PHP → Python → Claude
   ============================================================ */
async function gerarTreinoIA() {
  const btn = document.getElementById('ia-btn');
  const status  = document.getElementById('ia-status');
  const result  = document.getElementById('ia-result');

  const body = {
    user_id:      currentUser.id,
    objetivo:     document.getElementById('ia-objetivo').value,
    nivel:        document.getElementById('ia-nivel').value,
    dias_semana:  parseInt(document.getElementById('ia-dias').value),
    duracao_min:  parseInt(document.getElementById('ia-duracao').value),
    equipamentos: document.getElementById('ia-equipamentos').value,
    restricoes:   document.getElementById('ia-restricoes').value || null,
  };

  btn.disabled = true;
  btn.textContent = '⏳ Gerando treino com IA...';
  status.className = 'ia-status';
  status.innerHTML = '🤖 Consultando o modelo de IA... isso pode levar alguns segundos.';
  status.style.display = 'block';
  result.style.display  = 'none';

  try {
    const res  = await apiFetch('/gerar-treino', { method: 'POST', body: JSON.stringify(body) });
    const data = await res.json();

    if (!res.ok || data.erro) throw new Error(data.erro || 'Erro na geração');

    const treino = data.treino || data;
    status.style.display = 'none';
    renderIAResult(treino);
    result.style.display = 'block';
  } catch (e) {
    // Fallback demo
    status.innerHTML = '⚠️ Backend indisponível — exibindo exemplo de treino gerado por IA.';
    renderIAResult(demoTreino(body));
    result.style.display = 'block';
  }

  btn.disabled = false;
  btn.textContent = '✨ Gerar Novo Treino';
}

function renderIAResult(treino) {
  const el = document.getElementById('ia-result');
  const dias = treino.dias || [];
  el.innerHTML = `
    <div style="margin-bottom:16px">
      <h3 style="font-size:1rem;font-weight:700;margin-bottom:4px">${treino.nome_plano || 'Plano Personalizado'}</h3>
      <p style="font-size:0.82rem;color:var(--text2)">${treino.objetivo} · ${treino.nivel} · ${treino.dias_por_semana || dias.length}x por semana · ${treino.semanas_recomendadas || 8} semanas</p>
    </div>
    ${dias.map(d => `
      <div class="ia-result-day">
        <h4>${d.dia_semana} — ${d.grupo_muscular}</h4>
        ${(d.exercicios || []).map(ex => `
          <div class="ia-result-ex">
            <strong>${ex.nome}</strong>
            <span>${ex.series}×${ex.repeticoes} · ${ex.carga_sugerida || ''} · descanso ${ex.descanso_segundos}s</span>
          </div>`).join('')}
        ${d.finalizacao ? `<p style="font-size:0.78rem;color:var(--text3);margin-top:8px">🧘 ${d.finalizacao}</p>` : ''}
      </div>`).join('')}
    ${treino.dicas_gerais?.length ? `
      <div style="margin-top:16px;padding:14px;background:var(--bg3);border-radius:10px;border:1px solid var(--border)">
        <p style="font-size:0.8rem;font-weight:700;margin-bottom:8px">💡 Dicas Gerais</p>
        ${treino.dicas_gerais.map(d => `<p style="font-size:0.78rem;color:var(--text2);margin-bottom:4px">• ${d}</p>`).join('')}
      </div>` : ''}
    <button class="btn-primary full-width" style="margin-top:16px" onclick="navigate('plano')">Ver no Plano Semanal</button>
  `;
}

function demoTreino(body) {
  const divs = {
    3: [['Segunda','Peito & Tríceps'],['Quarta','Costas & Bíceps'],['Sexta','Pernas']],
    4: [['Segunda','Peito & Tríceps'],['Terça','Costas & Bíceps'],['Quinta','Pernas'],['Sexta','Ombro & Braços']],
    5: [['Segunda','Peito & Tríceps'],['Terça','Costas & Bíceps'],['Quarta','Pernas'],['Quinta','Ombro'],['Sexta','Braços']],
    6: [['Segunda','Peito'],['Terça','Costas'],['Quarta','Pernas'],['Quinta','Ombro'],['Sexta','Bíceps'],['Sábado','Tríceps']],
  }[body.dias_semana] || [];

  const exs = [
    { nome:'Supino Reto', series:4, repeticoes:'8-12', carga_sugerida:'70-80kg', descanso_segundos:90, tecnica:'Controle a descida', substituicao:'Flexão de braço' },
    { nome:'Crucifixo Inclinado', series:3, repeticoes:'12-15', carga_sugerida:'20-25kg', descanso_segundos:75, tecnica:'Amplitude máxima', substituicao:'Crossover' },
    { nome:'Tríceps Pulley', series:4, repeticoes:'10-12', carga_sugerida:'30-35kg', descanso_segundos:60, tecnica:'Cotovelos fixos', substituicao:'Tríceps testa' },
  ];

  return {
    nome_plano: `Plano ${body.objetivo.charAt(0).toUpperCase() + body.objetivo.slice(1)} — ${body.nivel.charAt(0).toUpperCase() + body.nivel.slice(1)}`,
    objetivo: body.objetivo, nivel: body.nivel,
    semanas_recomendadas: 8, dias_por_semana: body.dias_semana,
    dias: divs.map(([dia, grupo]) => ({
      dia_semana: dia, grupo_muscular: grupo, duracao_minutos: body.duracao_min,
      aquecimento: '10 min esteira + mobilização articular',
      exercicios: exs,
      finalizacao: 'Alongamento 5-10 minutos'
    })),
    dicas_gerais: ['Priorize a técnica antes da carga', 'Aumente a carga 2,5kg a cada 2 semanas', `Meta de proteína: ${Math.round(70 * 1.8)}g/dia`],
    observacoes: body.restricoes ? `Atenção às restrições: ${body.restricoes}` : ''
  };
}

/* ============================================================
   BOOT
   ============================================================ */
(function boot() {
  const token = sessionStorage.getItem('fitpro_token');
  const user  = sessionStorage.getItem('fitpro_user');
  if (token && user) {
    currentUser = JSON.parse(user);
    initApp();
  }
})();
