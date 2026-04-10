/* ============================================================
   RENNER DANIEL — PORTFOLIO SCRIPT
   ============================================================ */

// ============================================================
// CANVAS — PARTICLE BACKGROUND
// ============================================================
(function initCanvas() {
  const canvas = document.getElementById('canvas3d');
  if (!canvas) return;
  const ctx = canvas.getContext('2d');

  let particles = [];
  let mouse = { x: null, y: null, radius: 130 };
  let animId;

  function resize() {
    canvas.width  = window.innerWidth;
    canvas.height = window.innerHeight;
    init();
  }

  window.addEventListener('mousemove', (e) => { mouse.x = e.clientX; mouse.y = e.clientY; });
  window.addEventListener('resize', () => { clearTimeout(window._canvasResizeTimer); window._canvasResizeTimer = setTimeout(resize, 200); });

  class Particle {
    constructor() { this.reset(); }
    reset() {
      this.x  = Math.random() * canvas.width;
      this.y  = Math.random() * canvas.height;
      this.vx = (Math.random() - 0.5) * 0.4;
      this.vy = (Math.random() - 0.5) * 0.4;
      this.size = Math.random() * 2 + 0.5;
      this.life = Math.random() * 0.5 + 0.5;
    }
    update() {
      this.x += this.vx;
      this.y += this.vy;
      if (this.x < 0 || this.x > canvas.width)  this.vx *= -1;
      if (this.y < 0 || this.y > canvas.height)  this.vy *= -1;
      if (mouse.x !== null) {
        const dx = mouse.x - this.x, dy = mouse.y - this.y;
        const d  = Math.sqrt(dx * dx + dy * dy);
        if (d < mouse.radius) {
          const force = (mouse.radius - d) / mouse.radius;
          this.x -= dx / d * force * 1.5;
          this.y -= dy / d * force * 1.5;
        }
      }
    }
    draw() {
      const isDark = !document.body.classList.contains('light-theme');
      ctx.beginPath();
      ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
      ctx.fillStyle = isDark
        ? `rgba(240,165,0,${0.45 * this.life})`
        : `rgba(184,104,0,${0.25 * this.life})`;
      ctx.fill();
    }
  }

  function init() {
    cancelAnimationFrame(animId);
    particles = [];
    const n = Math.min(Math.floor((canvas.width * canvas.height) / 14000), 120);
    for (let i = 0; i < n; i++) particles.push(new Particle());
    animate();
  }

  function connect() {
    const isDark = !document.body.classList.contains('light-theme');
    for (let a = 0; a < particles.length; a++) {
      for (let b = a + 1; b < particles.length; b++) {
        const dx = particles[a].x - particles[b].x;
        const dy = particles[a].y - particles[b].y;
        const d  = Math.sqrt(dx * dx + dy * dy);
        if (d < 110) {
          const op = (1 - d / 110) * (isDark ? 0.35 : 0.18);
          ctx.strokeStyle = isDark
            ? `rgba(240,165,0,${op})`
            : `rgba(184,104,0,${op})`;
          ctx.lineWidth = 0.8;
          ctx.beginPath();
          ctx.moveTo(particles[a].x, particles[a].y);
          ctx.lineTo(particles[b].x, particles[b].y);
          ctx.stroke();
        }
      }
    }
  }

  function animate() {
    animId = requestAnimationFrame(animate);
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    particles.forEach(p => { p.update(); p.draw(); });
    connect();
  }

  resize();
})();


// ============================================================
// THEME TOGGLE — DARK / LIGHT
// ============================================================
(function initTheme() {
  const btn  = document.getElementById('themeToggle');
  const body = document.body;
  const KEY  = 'rd-theme';

  function applyTheme(theme) {
    if (theme === 'light') {
      body.classList.add('light-theme');
      btn.textContent = '☀️';
    } else {
      body.classList.remove('light-theme');
      btn.textContent = '🌙';
    }
    localStorage.setItem(KEY, theme);
  }

  // Restore saved preference
  const saved = localStorage.getItem(KEY) || 'dark';
  applyTheme(saved);

  btn.addEventListener('click', () => {
    const next = body.classList.contains('light-theme') ? 'dark' : 'light';
    applyTheme(next);
  });
})();


// ============================================================
// NAVBAR — SCROLL & ACTIVE LINK & HAMBURGER
// ============================================================
(function initNav() {
  const navbar    = document.getElementById('navbar');
  const hamburger = document.getElementById('hamburger');
  const navMenu   = document.getElementById('navMenu');
  const navLinks  = document.querySelectorAll('.nav-link');
  const sections  = document.querySelectorAll('section[id]');

  // Scroll shadow
  window.addEventListener('scroll', () => {
    navbar.classList.toggle('scrolled', window.scrollY > 40);
    updateActiveLink();
  }, { passive: true });

  // Active link
  function updateActiveLink() {
    let current = '';
    sections.forEach(sec => {
      if (window.scrollY >= sec.offsetTop - 100) current = sec.id;
    });
    navLinks.forEach(link => {
      link.classList.toggle('active', link.getAttribute('href') === '#' + current);
    });
  }

  // Hamburger
  hamburger.addEventListener('click', () => {
    hamburger.classList.toggle('open');
    navMenu.classList.toggle('open');
  });

  // Close menu on link click
  navLinks.forEach(link => {
    link.addEventListener('click', () => {
      hamburger.classList.remove('open');
      navMenu.classList.remove('open');
    });
  });
})();


// ============================================================
// REVEAL ON SCROLL
// ============================================================
(function initReveal() {
  const els = document.querySelectorAll('[data-reveal]');

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('revealed');
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.12 });

  els.forEach(el => observer.observe(el));
})();


// ============================================================
// SKILL BARS — ANIMATE ON SCROLL
// ============================================================
(function initSkillBars() {
  const bars = document.querySelectorAll('.skill-progress');

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const el    = entry.target;
        const width = el.getAttribute('data-width') || '0';
        el.style.width = width + '%';
        el.classList.add('animated');
        observer.unobserve(el);
      }
    });
  }, { threshold: 0.3 });

  bars.forEach(bar => {
    bar.style.width = '0%';
    observer.observe(bar);
  });
})();


// ============================================================
// CONTACT FORM
// ============================================================
(function initContactForm() {
  const form = document.getElementById('contactForm');
  if (!form) return;

  form.addEventListener('submit', function(e) {
    e.preventDefault();
    const btn = form.querySelector('button[type="submit"]');
    const orig = btn.textContent;
    btn.textContent = 'Enviando…';
    btn.disabled = true;

    setTimeout(() => {
      btn.textContent = '✓ Mensagem Enviada!';
      btn.style.background = 'var(--accent3)';
      form.reset();
      setTimeout(() => {
        btn.textContent = orig;
        btn.style.background = '';
        btn.disabled = false;
      }, 3000);
    }, 1200);
  });
})();


// ============================================================
// PROJECT MODALS
// ============================================================
const projectModal = document.getElementById('projectModal');
const projectContainer = document.getElementById('projectContainer');

function openProject(type) {
  const content = buildProjectContent(type);
  if (!content) return;
  projectContainer.innerHTML = content;
  projectModal.classList.add('active');
  document.body.style.overflow = 'hidden';
  initProjectEvents(type);
}

function closeProject() {
  projectModal.classList.remove('active');
  document.body.style.overflow = '';
  setTimeout(() => { projectContainer.innerHTML = ''; }, 350);
}

document.addEventListener('keydown', (e) => {
  if (e.key === 'Escape') closeProject();
});

// ============================================================
// PROJECT CONTENT BUILDERS
// ============================================================
function buildProjectContent(type) {
  const builders = {
    calculator: buildCalculator,
    todo:       buildTodo,
    weather:    buildWeather,
    music:      buildMusic,
    quiz:       buildQuiz,
    phpauth:    buildPhpAuth,
    api:        buildApiDocs,
  };
  return builders[type] ? builders[type]() : null;
}

function initProjectEvents(type) {
  if (type === 'calculator') initCalculator();
  if (type === 'todo')       initTodo();
  if (type === 'weather')    initWeather();
  if (type === 'music')      initMusic();
  if (type === 'quiz')       initQuiz();
}

// ---------- CALCULADORA ----------
function buildCalculator() {
  return `
    <div style="padding:2rem;font-family:var(--font-mono)">
      <h2 style="font-family:var(--font-display);font-size:1.3rem;font-weight:800;color:var(--text-0);margin-bottom:1.5rem;letter-spacing:-0.02em">🧮 Calculadora Científica</h2>
      <div id="calcApp" style="max-width:320px;margin:0 auto;background:var(--bg-2);border:1px solid var(--border-sub);border-radius:var(--r-lg);overflow:hidden;box-shadow:var(--shadow-md)">
        <div id="calcHistory" style="padding:0.75rem 1rem;min-height:28px;font-size:0.7rem;color:var(--text-2);text-align:right;border-bottom:1px solid var(--border-sub)"></div>
        <div id="calcDisplay" style="padding:0.75rem 1rem 0.5rem;font-size:2.2rem;text-align:right;color:var(--accent);word-break:break-all;min-height:60px;letter-spacing:-0.02em">0</div>
        <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:1px;background:var(--border-sub)">
          ${[
            ['C','±','%','÷'],
            ['7','8','9','×'],
            ['4','5','6','−'],
            ['1','2','3','+'],
            ['0','.',null,'=']
          ].map((row, ri) => row.map((k, ci) => {
            if (k === null) return `<div style="background:var(--bg-2)"></div>`;
            const isOp = ['÷','×','−','+','='].includes(k);
            const isWide = k === '0';
            const bg = isOp ? (k === '=' ? 'var(--accent)' : 'var(--bg-3)') : 'var(--bg-2)';
            const color = isOp ? (k === '=' ? 'var(--bg-0)' : 'var(--accent)') : 'var(--text-0)';
            return `<button onclick="calcPress('${k}')"
              style="background:${bg};color:${color};padding:1rem;font-size:1rem;font-family:var(--font-mono);border:none;cursor:pointer;transition:filter 0.1s;${isWide?'grid-column:span 2;text-align:left;padding-left:1.4rem':''}"
              onmouseover="this.style.filter='brightness(1.2)'" onmouseout="this.style.filter='brightness(1)'">${k}</button>`;
          }).join('')).join('')}
        </div>
      </div>
    </div>`;
}

function initCalculator() {
  let val = '0', prev = '', op = '', hist = '';
  const display = () => { document.getElementById('calcDisplay').textContent = val; document.getElementById('calcHistory').textContent = hist; };
  window.calcPress = function(k) {
    if (k === 'C') { val = '0'; prev = ''; op = ''; hist = ''; }
    else if (k === '±') { val = String(-parseFloat(val)); }
    else if (k === '%') { val = String(parseFloat(val) / 100); }
    else if (['÷','×','−','+'].includes(k)) {
      prev = val; op = k; val = '0';
      hist = prev + ' ' + k;
    } else if (k === '=') {
      if (!op || !prev) return;
      const a = parseFloat(prev), b = parseFloat(val);
      const ops = { '÷': a/b, '×': a*b, '−': a-b, '+': a+b };
      hist = prev + ' ' + op + ' ' + val + ' =';
      val = String(Number(ops[op].toFixed(10)));
      prev = ''; op = '';
    } else if (k === '.') {
      if (!val.includes('.')) val += '.';
    } else {
      val = val === '0' ? k : val + k;
    }
    display();
  };
}

// ---------- TODO ----------
function buildTodo() {
  return `
    <div style="padding:2rem">
      <h2 style="font-family:var(--font-display);font-size:1.3rem;font-weight:800;color:var(--text-0);margin-bottom:1.5rem;letter-spacing:-0.02em">✅ Gerenciador de Tarefas</h2>
      <div style="max-width:500px;margin:0 auto">
        <div style="display:flex;gap:0.5rem;margin-bottom:1rem">
          <input id="todoInput" placeholder="Nova tarefa…" style="flex:1;background:var(--bg-2);border:1px solid var(--border-sub);border-radius:var(--r-sm);padding:0.65rem 0.9rem;color:var(--text-0);font-family:var(--font-body);font-size:0.9rem">
          <button onclick="addTodo()" style="background:var(--accent);color:var(--bg-0);border:none;border-radius:var(--r-sm);padding:0.65rem 1.2rem;font-family:var(--font-display);font-size:0.78rem;font-weight:700;cursor:pointer">+ Add</button>
        </div>
        <div id="todoList" style="display:flex;flex-direction:column;gap:0.4rem"></div>
        <p id="todoEmpty" style="text-align:center;color:var(--text-2);font-size:0.82rem;padding:1.5rem 0">Nenhuma tarefa. Adicione uma acima!</p>
      </div>
    </div>`;
}

function initTodo() {
  let todos = [
    { id: 1, text: 'Estudar React hooks', done: true },
    { id: 2, text: 'Revisar API REST', done: false },
    { id: 3, text: 'Commit no GitHub', done: false },
  ];
  function render() {
    const list = document.getElementById('todoList');
    const empty = document.getElementById('todoEmpty');
    if (!list) return;
    list.innerHTML = todos.map(t => `
      <div style="display:flex;align-items:center;gap:0.75rem;background:var(--bg-2);border:1px solid ${t.done ? 'var(--accent3)' : 'var(--border-sub)'};border-radius:var(--r-sm);padding:0.65rem 0.9rem;transition:all 0.2s">
        <input type="checkbox" ${t.done ? 'checked' : ''} onchange="toggleTodo(${t.id})" style="width:16px;height:16px;accent-color:var(--accent3);cursor:pointer">
        <span style="flex:1;font-size:0.88rem;color:var(--text-${t.done ? '2' : '0'});text-decoration:${t.done ? 'line-through' : 'none'}">${t.text}</span>
        <button onclick="removeTodo(${t.id})" style="background:none;border:none;color:var(--text-2);font-size:1rem;cursor:pointer;line-height:1;padding:0 0.2rem" onmouseover="this.style.color='#f97583'" onmouseout="this.style.color='var(--text-2)'">×</button>
      </div>`).join('');
    empty.style.display = todos.length ? 'none' : 'block';
  }
  window.addTodo = function() {
    const input = document.getElementById('todoInput');
    const text = input.value.trim();
    if (!text) return;
    todos.push({ id: Date.now(), text, done: false });
    input.value = '';
    render();
  };
  window.toggleTodo = function(id) {
    todos = todos.map(t => t.id === id ? { ...t, done: !t.done } : t);
    render();
  };
  window.removeTodo = function(id) {
    todos = todos.filter(t => t.id !== id);
    render();
  };
  document.getElementById('todoInput').addEventListener('keypress', e => { if (e.key === 'Enter') addTodo(); });
  render();
}

// ---------- WEATHER ----------
function buildWeather() {
  const cities = [
    { name: 'São Paulo', temp: 26, icon: '⛅', desc: 'Parcialmente nublado', humidity: 72, wind: 14 },
    { name: 'Rio de Janeiro', temp: 32, icon: '☀️', desc: 'Ensolarado', humidity: 65, wind: 18 },
    { name: 'Brasília', temp: 28, icon: '🌤️', desc: 'Céu limpo', humidity: 55, wind: 12 },
    { name: 'Curitiba', temp: 18, icon: '🌧️', desc: 'Chuvas leves', humidity: 88, wind: 22 },
    { name: 'Porto Alegre', temp: 21, icon: '⛈️', desc: 'Tempestade', humidity: 82, wind: 30 },
  ];
  return `
    <div style="padding:2rem">
      <h2 style="font-family:var(--font-display);font-size:1.3rem;font-weight:800;color:var(--text-0);margin-bottom:1.5rem;letter-spacing:-0.02em">🌤️ App de Clima</h2>
      <div style="max-width:480px;margin:0 auto">
        <div style="display:flex;gap:0.5rem;margin-bottom:1.5rem">
          <select id="citySelect" style="flex:1;background:var(--bg-2);border:1px solid var(--border-sub);border-radius:var(--r-sm);padding:0.65rem 0.9rem;color:var(--text-0);font-family:var(--font-body)">
            ${cities.map((c, i) => `<option value="${i}">${c.name}</option>`).join('')}
          </select>
          <button onclick="showWeather()" style="background:var(--accent);color:var(--bg-0);border:none;border-radius:var(--r-sm);padding:0.65rem 1.2rem;font-family:var(--font-display);font-size:0.78rem;font-weight:700;cursor:pointer">Buscar</button>
        </div>
        <div id="weatherCard" style="background:var(--bg-2);border:1px solid var(--border-sub);border-radius:var(--r-lg);padding:2rem;text-align:center;display:none">
          <div id="wIcon" style="font-size:4rem;margin-bottom:0.5rem"></div>
          <div id="wCity" style="font-family:var(--font-display);font-size:1.2rem;font-weight:700;color:var(--text-0);margin-bottom:0.25rem"></div>
          <div id="wTemp" style="font-family:var(--font-display);font-size:3rem;font-weight:800;color:var(--accent);margin-bottom:0.25rem"></div>
          <div id="wDesc" style="font-size:0.85rem;color:var(--text-1);margin-bottom:1rem"></div>
          <div style="display:flex;justify-content:center;gap:2rem">
            <div><div style="font-size:0.7rem;color:var(--text-2);margin-bottom:0.2rem;font-family:var(--font-mono)">UMIDADE</div><div id="wHumidity" style="color:var(--accent2);font-weight:600"></div></div>
            <div><div style="font-size:0.7rem;color:var(--text-2);margin-bottom:0.2rem;font-family:var(--font-mono)">VENTO</div><div id="wWind" style="color:var(--accent2);font-weight:600"></div></div>
          </div>
        </div>
      </div>
    </div>`;
}

function initWeather() {
  const cities = [
    { name: 'São Paulo', temp: 26, icon: '⛅', desc: 'Parcialmente nublado', humidity: 72, wind: 14 },
    { name: 'Rio de Janeiro', temp: 32, icon: '☀️', desc: 'Ensolarado', humidity: 65, wind: 18 },
    { name: 'Brasília', temp: 28, icon: '🌤️', desc: 'Céu limpo', humidity: 55, wind: 12 },
    { name: 'Curitiba', temp: 18, icon: '🌧️', desc: 'Chuvas leves', humidity: 88, wind: 22 },
    { name: 'Porto Alegre', temp: 21, icon: '⛈️', desc: 'Tempestade', humidity: 82, wind: 30 },
  ];
  window.showWeather = function() {
    const i = parseInt(document.getElementById('citySelect').value);
    const c = cities[i];
    document.getElementById('weatherCard').style.display = 'block';
    document.getElementById('wIcon').textContent   = c.icon;
    document.getElementById('wCity').textContent   = c.name;
    document.getElementById('wTemp').textContent   = c.temp + '°C';
    document.getElementById('wDesc').textContent   = c.desc;
    document.getElementById('wHumidity').textContent = c.humidity + '%';
    document.getElementById('wWind').textContent   = c.wind + ' km/h';
  };
  showWeather();
}

// ---------- MUSIC ----------
function buildMusic() {
  const tracks = [
    { title: 'Lofi Study Beat', artist: 'LoFi Coder', dur: '3:24' },
    { title: 'Focus Flow', artist: 'Ambient Dev', dur: '4:12' },
    { title: 'Code Night', artist: 'Digital Waves', dur: '2:58' },
  ];
  return `
    <div style="padding:2rem">
      <h2 style="font-family:var(--font-display);font-size:1.3rem;font-weight:800;color:var(--text-0);margin-bottom:1.5rem;letter-spacing:-0.02em">🎵 Player de Música</h2>
      <div style="max-width:380px;margin:0 auto;background:var(--bg-2);border:1px solid var(--border-sub);border-radius:var(--r-lg);overflow:hidden">
        <div style="padding:2rem;text-align:center">
          <div id="musicDisc" style="width:100px;height:100px;border-radius:50%;background:conic-gradient(var(--accent) 0deg,var(--accent2) 120deg,var(--accent3) 240deg,var(--accent) 360deg);margin:0 auto 1.5rem;box-shadow:0 0 30px var(--accent-glow);position:relative" class="">
            <div style="width:28px;height:28px;border-radius:50%;background:var(--bg-2);position:absolute;top:50%;left:50%;transform:translate(-50%,-50%)"></div>
          </div>
          <div id="musicTitle" style="font-family:var(--font-display);font-size:1rem;font-weight:700;color:var(--text-0);margin-bottom:0.2rem">Lofi Study Beat</div>
          <div id="musicArtist" style="font-size:0.78rem;color:var(--text-2);margin-bottom:1.5rem">LoFi Coder</div>
          <div style="height:3px;background:var(--bg-3);border-radius:2px;margin-bottom:1rem;cursor:pointer" onclick="seekMusic(event,this)">
            <div id="musicProgress" style="height:100%;width:0%;background:linear-gradient(to right,var(--accent),var(--accent2));border-radius:2px;transition:width 0.5s linear"></div>
          </div>
          <div style="display:flex;align-items:center;justify-content:center;gap:1.5rem;font-size:1.4rem">
            <button onclick="prevTrack()" style="background:none;border:none;cursor:pointer;font-size:1.2rem;color:var(--text-1)" title="Anterior">⏮</button>
            <button id="playBtn" onclick="togglePlay()" style="background:var(--accent);border:none;cursor:pointer;width:52px;height:52px;border-radius:50%;font-size:1.3rem;display:flex;align-items:center;justify-content:center;box-shadow:0 4px 16px var(--accent-glow)">▶</button>
            <button onclick="nextTrack()" style="background:none;border:none;cursor:pointer;font-size:1.2rem;color:var(--text-1)" title="Próxima">⏭</button>
          </div>
        </div>
        <div style="border-top:1px solid var(--border-sub)">
          ${tracks.map((t,i) => `
            <div onclick="selectTrack(${i})" id="track${i}" style="display:flex;align-items:center;gap:0.75rem;padding:0.75rem 1.25rem;cursor:pointer;border-bottom:1px solid var(--border-sub);transition:background 0.15s" onmouseover="this.style.background='var(--bg-3)'" onmouseout="this.style.background=''">
              <span style="font-size:1rem">${i === 0 ? '▶' : '○'}</span>
              <div style="flex:1"><div style="font-size:0.85rem;color:var(--text-0);font-weight:${i===0?'600':'400'}">${t.title}</div><div style="font-size:0.72rem;color:var(--text-2)">${t.artist}</div></div>
              <span style="font-family:var(--font-mono);font-size:0.72rem;color:var(--text-2)">${t.dur}</span>
            </div>`).join('')}
        </div>
      </div>
    </div>`;
}

function initMusic() {
  const tracks = [
    { title: 'Lofi Study Beat', artist: 'LoFi Coder', dur: '3:24' },
    { title: 'Focus Flow', artist: 'Ambient Dev', dur: '4:12' },
    { title: 'Code Night', artist: 'Digital Waves', dur: '2:58' },
  ];
  let current = 0, playing = false, progress = 0, timer = null;

  window.togglePlay = function() {
    playing = !playing;
    document.getElementById('playBtn').textContent = playing ? '⏸' : '▶';
    const disc = document.getElementById('musicDisc');
    disc.style.animation = playing ? 'spin 3s linear infinite' : 'none';
    if (playing) {
      timer = setInterval(() => {
        progress = Math.min(progress + 0.3, 100);
        const el = document.getElementById('musicProgress');
        if (el) el.style.width = progress + '%';
        if (progress >= 100) nextTrack();
      }, 100);
    } else {
      clearInterval(timer);
    }
  };
  window.selectTrack = function(i) {
    current = i;
    progress = 0;
    clearInterval(timer);
    playing = false;
    document.getElementById('playBtn').textContent = '▶';
    document.getElementById('musicDisc').style.animation = 'none';
    document.getElementById('musicTitle').textContent = tracks[i].title;
    document.getElementById('musicArtist').textContent = tracks[i].artist;
    document.getElementById('musicProgress').style.width = '0%';
    tracks.forEach((_, idx) => {
      const el = document.getElementById('track' + idx);
      if (el) {
        el.querySelector('span').textContent = idx === i ? '▶' : '○';
        el.querySelector('div div').style.fontWeight = idx === i ? '600' : '400';
      }
    });
  };
  window.nextTrack = function() { selectTrack((current + 1) % tracks.length); };
  window.prevTrack = function() { selectTrack((current - 1 + tracks.length) % tracks.length); };
  window.seekMusic  = function(e, bar) {
    const rect = bar.getBoundingClientRect();
    progress = ((e.clientX - rect.left) / rect.width) * 100;
    document.getElementById('musicProgress').style.width = progress + '%';
  };
}

// ---------- QUIZ ----------
function buildQuiz() {
  return `
    <div style="padding:2rem">
      <h2 style="font-family:var(--font-display);font-size:1.3rem;font-weight:800;color:var(--text-0);margin-bottom:1.5rem;letter-spacing:-0.02em">🧠 Quiz de Tecnologia</h2>
      <div id="quizApp" style="max-width:500px;margin:0 auto"></div>
    </div>`;
}

function initQuiz() {
  const questions = [
    { q: 'O que significa "API"?', opts: ['Application Programming Interface','Advanced Program Integration','Automatic Process Input','Application Process Index'], ans: 0 },
    { q: 'Qual linguagem é interpretada pelo navegador nativamente?', opts: ['Python','Java','JavaScript','PHP'], ans: 2 },
    { q: 'O que é "Git"?', opts: ['Banco de dados','Sistema de controle de versões','Linguagem de programação','Framework CSS'], ans: 1 },
    { q: 'O método HTTP para buscar dados é:', opts: ['POST','PUT','DELETE','GET'], ans: 3 },
    { q: 'Node.js é baseado em qual motor JavaScript?', opts: ['SpiderMonkey','V8','Chakra','JavaScriptCore'], ans: 1 },
  ];
  let qi = 0, score = 0;

  function render() {
    const app = document.getElementById('quizApp');
    if (!app) return;
    if (qi >= questions.length) {
      const pct = Math.round((score / questions.length) * 100);
      app.innerHTML = `
        <div style="text-align:center;padding:1.5rem">
          <div style="font-size:3rem;margin-bottom:1rem">${pct >= 70 ? '🎉' : '📚'}</div>
          <div style="font-family:var(--font-display);font-size:2rem;font-weight:800;color:var(--accent);margin-bottom:0.5rem">${score}/${questions.length}</div>
          <div style="color:var(--text-1);margin-bottom:1.5rem">${pct}% de acertos · ${pct >= 70 ? 'Ótimo resultado!' : 'Continue estudando!'}</div>
          <button onclick="qi=0;score=0;initQuiz()" style="background:var(--accent);color:var(--bg-0);border:none;border-radius:var(--r-sm);padding:0.75rem 1.75rem;font-family:var(--font-display);font-size:0.82rem;font-weight:700;cursor:pointer">Jogar Novamente</button>
        </div>`;
      return;
    }
    const q = questions[qi];
    app.innerHTML = `
      <div style="background:var(--bg-2);border-radius:var(--r-sm);padding:0.5rem 0.85rem;font-size:0.72rem;color:var(--text-2);font-family:var(--font-mono);margin-bottom:1rem">Pergunta ${qi+1} de ${questions.length} · Placar: ${score}</div>
      <div style="font-size:1.05rem;font-weight:600;color:var(--text-0);margin-bottom:1.25rem;line-height:1.5">${q.q}</div>
      <div style="display:flex;flex-direction:column;gap:0.5rem">
        ${q.opts.map((o, i) => `
          <button onclick="answerQuiz(${i})" style="background:var(--bg-2);border:1px solid var(--border-sub);border-radius:var(--r-sm);padding:0.75rem 1rem;color:var(--text-1);text-align:left;font-family:var(--font-body);font-size:0.88rem;cursor:pointer;transition:all 0.2s" onmouseover="this.style.borderColor='var(--accent)';this.style.color='var(--accent)'" onmouseout="this.style.borderColor='var(--border-sub)';this.style.color='var(--text-1)'">${String.fromCharCode(65+i)}) ${o}</button>`).join('')}
      </div>`;
    window.answerQuiz = function(i) {
      if (i === q.ans) score++;
      qi++;
      render();
    };
  }
  render();
}

// ---------- PHP AUTH (detalhes) ----------
function buildPhpAuth() {
  return `
    <div style="padding:2rem">
      <h2 style="font-family:var(--font-display);font-size:1.3rem;font-weight:800;color:var(--text-0);margin-bottom:0.5rem;letter-spacing:-0.02em">🔐 Sistema de Autenticação PHP + MySQL</h2>
      <p style="color:var(--text-1);font-size:0.9rem;margin-bottom:2rem">Projeto backend completo com PHP puro, PDO e MySQL</p>

      <div style="display:grid;grid-template-columns:1fr 1fr;gap:1.25rem;margin-bottom:1.5rem">
        ${[
          ['🗂️ Estrutura do Projeto','MVC organizado: Models, Views, Controllers separados. Autoloader PSR-4 sem frameworks externos.'],
          ['🔒 Segurança','Senhas com password_hash (bcrypt). Proteção CSRF com tokens únicos. SQL Injection bloqueado com PDO prepared statements.'],
          ['🍪 Sessões','Session regeneration após login. Timeout automático de sessão. Logout seguro com destruição de cookies.'],
          ['📧 Validação','Validação server-side completa. Sanitização de inputs. Mensagens de erro amigáveis sem expor detalhes internos.'],
        ].map(([t, d]) => `
          <div style="background:var(--bg-2);border:1px solid var(--border-sub);border-radius:var(--r-md);padding:1.1rem">
            <div style="font-family:var(--font-display);font-size:0.82rem;font-weight:700;color:var(--accent);margin-bottom:0.4rem">${t}</div>
            <div style="font-size:0.8rem;color:var(--text-1);line-height:1.6">${d}</div>
          </div>`).join('')}
      </div>

      <div style="background:var(--bg-0);border:1px solid var(--border-sub);border-radius:var(--r-md);padding:1.25rem;margin-bottom:1.25rem">
        <div style="font-family:var(--font-mono);font-size:0.68rem;color:var(--text-2);margin-bottom:0.6rem">📁 Estrutura de arquivos</div>
        <pre style="font-family:var(--font-mono);font-size:0.72rem;color:var(--text-1);line-height:1.8">${escHtml(`php-auth/
├── index.php
├── config/
│   └── database.php       # PDO connection
├── src/
│   ├── Models/
│   │   └── User.php       # password_hash, PDO
│   ├── Controllers/
│   │   ├── AuthController.php
│   │   └── DashboardController.php
│   └── Middleware/
│       └── AuthMiddleware.php
├── views/
│   ├── login.php
│   ├── register.php
│   └── dashboard.php
└── public/
    └── assets/`)}</pre>
      </div>

      <div style="background:var(--bg-0);border:1px solid var(--border-sub);border-radius:var(--r-md);padding:1.25rem">
        <div style="font-family:var(--font-mono);font-size:0.68rem;color:var(--text-2);margin-bottom:0.6rem">🔑 AuthController.php — trecho de login</div>
        <pre style="font-family:var(--font-mono);font-size:0.72rem;color:var(--text-1);line-height:1.8;overflow-x:auto">${escHtml(`public function login(array $data): void {
  $user = $this->userModel->findByEmail($data['email']);
  if (!$user || !password_verify($data['password'], $user['hash'])) {
    $this->redirect('/login?error=invalid');
  }
  session_regenerate_id(true);
  $_SESSION['user_id']  = $user['id'];
  $_SESSION['expires']  = time() + 3600;
  $this->redirect('/dashboard');
}`)}</pre>
      </div>
    </div>`;
}

// ---------- API DOCS ----------
function buildApiDocs() {
  return `
    <div style="padding:2rem">
      <h2 style="font-family:var(--font-display);font-size:1.3rem;font-weight:800;color:var(--text-0);margin-bottom:0.5rem;letter-spacing:-0.02em">⚡ API REST — Gerenciador de Tarefas (Node.js)</h2>
      <p style="color:var(--text-1);font-size:0.9rem;margin-bottom:2rem">Node.js + Express + MySQL + JWT + Swagger</p>

      <div style="display:flex;flex-direction:column;gap:0.6rem;margin-bottom:1.5rem">
        ${[
          ['GET',    '/api/tasks',        '200','Lista todas as tarefas do usuário autenticado'],
          ['POST',   '/api/tasks',        '201','Cria nova tarefa (body: { title, description, priority })'],
          ['PUT',    '/api/tasks/:id',    '200','Atualiza uma tarefa existente'],
          ['DELETE', '/api/tasks/:id',    '204','Remove uma tarefa'],
          ['POST',   '/api/auth/login',   '200','Autentica usuário e retorna JWT + refresh token'],
          ['POST',   '/api/auth/refresh', '200','Renova o access token com refresh token'],
          ['POST',   '/api/auth/logout',  '200','Invalida o refresh token'],
        ].map(([method, route, status, desc]) => {
          const colors = { GET:'var(--accent3)', POST:'var(--accent)', PUT:'var(--accent2)', DELETE:'#f97583' };
          return `<div style="display:flex;align-items:flex-start;gap:0.75rem;background:var(--bg-2);border:1px solid var(--border-sub);border-radius:var(--r-sm);padding:0.7rem 1rem">
            <span style="font-family:var(--font-mono);font-size:0.68rem;font-weight:700;color:${colors[method]||'var(--text-1)'};min-width:46px;padding-top:1px">${method}</span>
            <span style="font-family:var(--font-mono);font-size:0.78rem;color:var(--text-1);min-width:160px">${route}</span>
            <span style="font-family:var(--font-mono);font-size:0.68rem;color:${colors[method]||'var(--text-2)'};min-width:28px;padding-top:1px">${status}</span>
            <span style="font-size:0.78rem;color:var(--text-2)">${desc}</span>
          </div>`;
        }).join('')}
      </div>

      <div style="background:var(--bg-0);border:1px solid var(--border-sub);border-radius:var(--r-md);padding:1.25rem">
        <div style="font-family:var(--font-mono);font-size:0.68rem;color:var(--text-2);margin-bottom:0.6rem">📄 routes/tasks.js — exemplo de rota protegida</div>
        <pre style="font-family:var(--font-mono);font-size:0.72rem;color:var(--text-1);line-height:1.8;overflow-x:auto">${escHtml(`const router = require('express').Router();
const auth   = require('../middleware/auth');   // JWT
const { body, validationResult } = require('express-validator');

router.get('/', auth, async (req, res) => {
  const tasks = await Task.findByUser(req.user.id);
  res.json({ tasks });
});

router.post('/', auth,
  body('title').notEmpty().isLength({ max: 120 }),
  async (req, res) => {
    if (!validationResult(req).isEmpty())
      return res.status(422).json({ errors: validationResult(req).array() });
    const task = await Task.create({ ...req.body, userId: req.user.id });
    res.status(201).json({ task });
  }
);`)}</pre>
      </div>
    </div>`;
}

function escHtml(str) {
  return str.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
}
