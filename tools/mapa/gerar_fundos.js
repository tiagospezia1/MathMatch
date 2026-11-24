// Gera os fundos dos 6 lugares do mapa da jornada: assets/imagens/mapa/mundo_1.png ... mundo_6.png
// Cada fundo é uma cena ilustrada em SVG (feita aqui, sem imagens de terceiros), escurecida
// para que as fases e os textos do mapa continuem fáceis de ler.
// Uso: node gerar_fundos.js <pasta de saída>
const { chromium } = require('/opt/node-tools/node_modules/playwright');
const path = require('path');

const W = 1488, H = 700; // o dobro de 744x350, o tamanho do cartão no mapa
const out = process.argv[2];

// Pequeno gerador de números aleatórios com semente, para as cenas saírem sempre iguais.
function rng(seed) {
  let s = seed;
  return () => { s = (s * 16807) % 2147483647; return (s - 1) / 2147483646; };
}

const sky = (top, bottom) => `<defs><linearGradient id="sky" x1="0" y1="0" x2="0" y2="1">
  <stop offset="0" stop-color="${top}"/><stop offset="1" stop-color="${bottom}"/></linearGradient></defs>
  <rect width="${W}" height="${H}" fill="url(#sky)"/>`;

const stars = (seed, n, color = '#FFF6D5') => {
  const r = rng(seed); let s = '';
  for (let i = 0; i < n; i++) s += `<circle cx="${r() * W}" cy="${r() * H * 0.45}" r="${1.5 + r() * 2.5}" fill="${color}" opacity="${0.35 + r() * 0.5}"/>`;
  return s;
};

const moon = (x, y, r = 46) => `<circle cx="${x}" cy="${y}" r="${r * 2.2}" fill="#FFE9A8" opacity="0.08"/>
  <circle cx="${x}" cy="${y}" r="${r}" fill="#FFF1C4" opacity="0.85"/>`;

// Morro ondulado do fundo ao chão.
const hill = (y, amp, color, seed, waves = 3) => {
  const r = rng(seed); let d = `M0 ${H} L0 ${y}`;
  const step = W / (waves * 2);
  for (let i = 0; i < waves * 2; i++) {
    const x1 = i * step + step / 2, x2 = (i + 1) * step;
    d += ` Q${x1} ${y + (i % 2 ? amp : -amp) * (0.6 + r() * 0.6)} ${x2} ${y + (r() - 0.5) * amp * 0.4}`;
  }
  return `<path d="${d} L${W} ${H} Z" fill="${color}"/>`;
};

// ---------------------------------------------------------------- elementos

const fruitTree = (x, y, s, leaf, fruit, seed) => {
  const r = rng(seed); let fruits = '';
  for (let i = 0; i < 7; i++) {
    const a = r() * Math.PI * 2, d = r() * 52 * s;
    fruits += `<circle cx="${x + Math.cos(a) * d}" cy="${y - 120 * s + Math.sin(a) * d * 0.8}" r="${9 * s}" fill="${fruit}"/>`;
  }
  return `<rect x="${x - 9 * s}" y="${y - 70 * s}" width="${18 * s}" height="${70 * s}" rx="${5 * s}" fill="#4A3220"/>
    <circle cx="${x}" cy="${y - 120 * s}" r="${70 * s}" fill="${leaf}"/>
    <circle cx="${x - 40 * s}" cy="${y - 95 * s}" r="${42 * s}" fill="${leaf}"/>
    <circle cx="${x + 42 * s}" cy="${y - 98 * s}" r="${44 * s}" fill="${leaf}"/>${fruits}`;
};

const house = (x, y, s, wall, roof, lit = true) => `<g transform="translate(${x} ${y}) scale(${s})">
  <rect x="-60" y="-90" width="120" height="90" fill="${wall}"/>
  <path d="M-75 -88 L0 -150 L75 -88 Z" fill="${roof}"/>
  <rect x="30" y="-150" width="18" height="40" fill="${roof}"/>
  <rect x="-40" y="-65" width="28" height="28" rx="3" fill="${lit ? '#FFD88A' : '#2A3550'}" opacity="${lit ? 0.85 : 1}"/>
  <rect x="12" y="-52" width="28" height="52" rx="3" fill="#3A2716"/>
</g>`;

const crate = (x, y, s, c = '#8A5A2B') => `<g transform="translate(${x} ${y}) scale(${s})">
  <rect x="-30" y="-60" width="60" height="60" fill="${c}" stroke="#3A2716" stroke-width="4"/>
  <path d="M-30 -60 L30 0 M30 -60 L-30 0" stroke="#3A2716" stroke-width="4"/>
</g>`;

const ship = (x, y, s) => `<g transform="translate(${x} ${y}) scale(${s})">
  <path d="M-120 0 L120 0 L90 45 L-95 45 Z" fill="#5A3A22"/>
  <rect x="-4" y="-190" width="8" height="190" fill="#3A2716"/>
  <path d="M8 -180 Q90 -120 8 -30 Z" fill="#E9DFC6"/>
  <path d="M-8 -160 Q-80 -110 -8 -40 Z" fill="#D8CBA8"/>
  <path d="M4 -195 L40 -185 L4 -175 Z" fill="#C0392B"/>
</g>`;

const lighthouse = (x, y, s) => `<g transform="translate(${x} ${y}) scale(${s})">
  <path d="M-30 0 L-20 -200 L20 -200 L30 0 Z" fill="#E9DFC6"/>
  <path d="M-27 -60 L27 -60 L25 -100 L-25 -100 Z M-23 -140 L23 -140 L21 -175 L-21 -175 Z" fill="#B8413A"/>
  <rect x="-24" y="-235" width="48" height="35" fill="#3A2716"/>
  <rect x="-16" y="-230" width="32" height="25" fill="#FFE08A"/>
  <path d="M-30 -235 L0 -265 L30 -235 Z" fill="#B8413A"/>
  <path d="M16 -218 L380 -290 L380 -150 Z" fill="#FFE9A8" opacity="0.10"/>
</g>`;

const pine = (x, y, s, c) => `<g transform="translate(${x} ${y}) scale(${s})">
  <rect x="-8" y="-40" width="16" height="40" fill="#3A2716"/>
  <path d="M0 -260 L60 -150 L35 -150 L80 -70 L-80 -70 L-35 -150 L-60 -150 Z" fill="${c}"/>
</g>`;

const bigTree = (x, y, s, c) => `<g transform="translate(${x} ${y}) scale(${s})">
  <path d="M-22 0 Q-14 -120 -10 -200 L10 -200 Q14 -120 22 0 Z" fill="#4A3220"/>
  <circle cx="0" cy="-250" r="95" fill="${c}"/><circle cx="-80" cy="-200" r="60" fill="${c}"/><circle cx="80" cy="-205" r="65" fill="${c}"/>
</g>`;

const hive = (x, y, s) => `<g transform="translate(${x} ${y}) scale(${s})">
  <path d="M0 -6 L0 14" stroke="#3A2716" stroke-width="4"/>
  <ellipse cx="0" cy="40" rx="34" ry="30" fill="#E0A43A"/>
  <path d="M-30 30 Q0 22 30 30 M-33 45 Q0 37 33 45 M-26 60 Q0 54 26 60" stroke="#9A6A1E" stroke-width="4" fill="none"/>
  <ellipse cx="0" cy="62" rx="9" ry="6" fill="#3A2716"/>
</g>`;

const honeycomb = (x, y, r, rows, cols, color) => {
  let s = '';
  const w = Math.sqrt(3) * r;
  for (let i = 0; i < rows; i++) for (let j = 0; j < cols; j++) {
    const cx = x + j * w + (i % 2 ? w / 2 : 0), cy = y + i * r * 1.5;
    let pts = '';
    for (let k = 0; k < 6; k++) { const a = Math.PI / 6 + k * Math.PI / 3; pts += `${cx + Math.cos(a) * r},${cy + Math.sin(a) * r} `; }
    s += `<polygon points="${pts}" fill="none" stroke="${color}" stroke-width="4"/>`;
  }
  return s;
};

const bee = (x, y, s) => `<g transform="translate(${x} ${y}) scale(${s})">
  <ellipse cx="-6" cy="-12" rx="9" ry="6" fill="#FFFFFF" opacity="0.55"/><ellipse cx="6" cy="-12" rx="9" ry="6" fill="#FFFFFF" opacity="0.55"/>
  <ellipse cx="0" cy="0" rx="15" ry="10" fill="#F2C94C"/>
  <path d="M-4 -9 L-4 9 M5 -8 L5 8" stroke="#2B1A0E" stroke-width="4"/>
</g>`;

const bunting = (x1, y1, x2, y2, sag, seed) => {
  const r = rng(seed); const colors = ['#C0392B', '#F2C94C', '#2E86C1', '#27AE60', '#8E44AD'];
  let s = `<path d="M${x1} ${y1} Q${(x1 + x2) / 2} ${(y1 + y2) / 2 + sag} ${x2} ${y2}" stroke="#3A2716" stroke-width="3" fill="none"/>`;
  const n = 12;
  for (let i = 1; i < n; i++) {
    const t = i / n, x = (1 - t) * (1 - t) * x1 + 2 * (1 - t) * t * (x1 + x2) / 2 + t * t * x2;
    const y = (1 - t) * (1 - t) * y1 + 2 * (1 - t) * t * ((y1 + y2) / 2 + sag) + t * t * y2;
    s += `<path d="M${x - 14} ${y} L${x + 14} ${y} L${x} ${y + 30} Z" fill="${colors[Math.floor(r() * colors.length)]}"/>`;
  }
  return s;
};

const table = (x, y, w) => {
  let food = '';
  const items = [
    (cx) => `<ellipse cx="${cx}" cy="${y - 22}" rx="30" ry="18" fill="#C98A3E"/><path d="M${cx - 20} ${y - 28} l10 -6 M${cx - 4} ${y - 30} l10 -6 M${cx + 12} ${y - 28} l10 -6" stroke="#8A5A1E" stroke-width="4"/>`,
    (cx) => `<rect x="${cx - 26}" y="${y - 44}" width="52" height="36" rx="6" fill="#E8C7D8"/><rect x="${cx - 26}" y="${y - 50}" width="52" height="12" rx="6" fill="#FFF3F8"/><circle cx="${cx}" cy="${y - 56}" r="7" fill="#C0392B"/>`,
    (cx) => `<path d="M${cx - 30} ${y - 8} Q${cx} ${y - 46} ${cx + 30} ${y - 8} Z" fill="#B0703A"/>`,
    (cx) => `<circle cx="${cx - 10}" cy="${y - 20}" r="12" fill="#D94A3A"/><circle cx="${cx + 10}" cy="${y - 20}" r="12" fill="#E8A13A"/><circle cx="${cx}" cy="${y - 36}" r="12" fill="#7BB33A"/>`,
  ];
  for (let i = 0; i < Math.floor(w / 110); i++) food += items[i % items.length](x + 60 + i * 110);
  return `<rect x="${x}" y="${y - 8}" width="${w}" height="16" rx="4" fill="#8B5A2B"/>
    <rect x="${x}" y="${y + 8}" width="${w}" height="34" fill="#F3EBD8" opacity="0.9"/>
    <rect x="${x + 20}" y="${y + 42}" width="12" height="40" fill="#5A3A22"/><rect x="${x + w - 32}" y="${y + 42}" width="12" height="40" fill="#5A3A22"/>${food}`;
};

const clockTower = (x, y, s) => {
  let ticks = '';
  for (let i = 0; i < 12; i++) {
    const a = i * Math.PI / 6;
    ticks += `<line x1="${Math.cos(a) * 52}" y1="${-330 + Math.sin(a) * 52}" x2="${Math.cos(a) * 62}" y2="${-330 + Math.sin(a) * 62}" stroke="#3A2716" stroke-width="5"/>`;
  }
  return `<g transform="translate(${x} ${y}) scale(${s})">
    <rect x="-90" y="-420" width="180" height="420" fill="#4B4A66"/>
    <rect x="-90" y="-420" width="180" height="420" fill="url(#brick)" opacity="0.35"/>
    <path d="M-110 -420 L0 -560 L110 -420 Z" fill="#2F2E46"/>
    <circle cx="0" cy="-330" r="72" fill="#F3EBD8" stroke="#C99A1E" stroke-width="10"/>${ticks}
    <line x1="0" y1="-330" x2="0" y2="-372" stroke="#3A2716" stroke-width="7" stroke-linecap="round"/>
    <line x1="0" y1="-330" x2="34" y2="-318" stroke="#3A2716" stroke-width="7" stroke-linecap="round"/>
    <rect x="-28" y="-200" width="56" height="80" rx="28" fill="#FFD88A" opacity="0.8"/>
    <rect x="-34" y="-80" width="68" height="80" rx="34" fill="#2B2236"/>
  </g>`;
};

const gear = (x, y, r, teeth, color) => {
  let d = '';
  for (let i = 0; i < teeth * 2; i++) {
    const a = i * Math.PI / teeth, rr = i % 2 ? r : r * 1.22;
    const a2 = (i + 1) * Math.PI / teeth;
    d += `${i ? 'L' : 'M'}${x + Math.cos(a) * rr} ${y + Math.sin(a) * rr} L${x + Math.cos(a2) * rr} ${y + Math.sin(a2) * rr} `;
  }
  return `<path d="${d}Z" fill="${color}"/><circle cx="${x}" cy="${y}" r="${r * 0.35}" fill="#1A2138"/>`;
};

const rooftops = (y, color, seed) => {
  const r = rng(seed); let s = '', x = -20;
  while (x < W) {
    const w = 90 + r() * 120, h = 80 + r() * 140;
    s += `<rect x="${x}" y="${y - h}" width="${w}" height="${h + 400}" fill="${color}"/>`;
    s += r() > 0.5 ? `<path d="M${x - 10} ${y - h} L${x + w / 2} ${y - h - 50} L${x + w + 10} ${y - h} Z" fill="${color}"/>` : '';
    for (let k = 0; k < 3; k++) if (r() > 0.45) s += `<rect x="${x + 18 + k * 30}" y="${y - h + 30 + r() * 40}" width="16" height="22" fill="#FFD88A" opacity="0.55"/>`;
    x += w + 6;
  }
  return s;
};

const stall = (x, y, s, c1, c2, sign) => {
  let stripes = '';
  for (let i = 0; i < 6; i++) stripes += `<path d="M${-120 + i * 40} -150 L${-80 + i * 40} -150 L${-80 + i * 40} -110 Q${-100 + i * 40} -90 ${-120 + i * 40} -110 Z" fill="${i % 2 ? c2 : c1}"/>`;
  return `<g transform="translate(${x} ${y}) scale(${s})">
    <rect x="-110" y="-150" width="10" height="150" fill="#5A3A22"/><rect x="100" y="-150" width="10" height="150" fill="#5A3A22"/>
    <rect x="-120" y="-60" width="240" height="60" fill="#8B5A2B"/>
    ${stripes}
    <rect x="-46" y="-205" width="92" height="44" rx="8" fill="#F3EBD8"/>
    <text x="0" y="-172" text-anchor="middle" font-family="Georgia, serif" font-weight="700" font-size="32" fill="#5A3A22">${sign}</text>
    ${crate(-60, -60, 0.7, '#A0703A')}${crate(55, -60, 0.6, '#A0703A')}
  </g>`;
};

const palace = (x, y, s) => `<g transform="translate(${x} ${y}) scale(${s})">
  <rect x="-200" y="-200" width="400" height="200" fill="#3E2A55"/>
  <rect x="-260" y="-140" width="70" height="140" fill="#35244A"/><rect x="190" y="-140" width="70" height="140" fill="#35244A"/>
  <path d="M-120 -200 Q-120 -330 0 -360 Q120 -330 120 -200 Z" fill="#5B3E7A"/>
  <path d="M-260 -140 Q-260 -210 -225 -225 Q-190 -210 -190 -140 Z M190 -140 Q190 -210 225 -225 Q260 -210 260 -140 Z" fill="#5B3E7A"/>
  <path d="M0 -360 L0 -410" stroke="#C99A1E" stroke-width="6"/><path d="M0 -410 L50 -396 L0 -382 Z" fill="#C0392B"/>
  <rect x="-30" y="-90" width="60" height="90" rx="30" fill="#1E142B"/>
  <rect x="-150" y="-160" width="30" height="40" rx="15" fill="#FFD88A" opacity="0.7"/><rect x="120" y="-160" width="30" height="40" rx="15" fill="#FFD88A" opacity="0.7"/>
</g>`;

// ---------------------------------------------------------------- as 6 cenas

const scenes = [
  // 1. Vila do Pomar (adição): morros verdes, árvores de fruta e casinhas.
  () => sky('#1B2A4A', '#3B5D6E') + stars(11, 40) + moon(1300, 120) +
    hill(430, 50, '#2F5A3E', 1) +
    fruitTree(140, 470, 1.0, '#2E6B3F', '#E0533A', 3) + fruitTree(1360, 480, 1.1, '#2E6B3F', '#F0A030', 4) +
    house(1130, 470, 0.9, '#D9C7A0', '#9A3B2E') + house(330, 470, 0.75, '#CDB894', '#7A4A26') +
    hill(540, 30, '#244A33', 2, 4) +
    `<path d="M0 600 L${W} 600" stroke="#7A5A3A" stroke-width="6"/>` +
    Array.from({ length: 30 }, (_, i) => `<rect x="${i * 52}" y="575" width="10" height="50" fill="#7A5A3A"/>`).join('') +
    fruitTree(680, 700, 0.8, '#245C35', '#E0533A', 5) + fruitTree(940, 700, 0.75, '#245C35', '#D94A3A', 6),

  // 2. Porto das Cargas (subtração): mar, cais, caixas, navio e farol.
  () => sky('#14203D', '#2D4B6B') + stars(21, 50) + moon(240, 110, 40) +
    `<rect y="420" width="${W}" height="${H}" fill="#1D3B5A"/>` +
    Array.from({ length: 14 }, (_, i) => `<path d="M${i * 110} ${450 + (i % 3) * 30} q25 -10 50 0" stroke="#5C86A8" stroke-width="4" fill="none" opacity="0.6"/>`).join('') +
    ship(700, 470, 1.1) + lighthouse(1340, 560, 1.15) +
    `<rect x="0" y="540" width="${W}" height="40" fill="#6B4A2E"/><rect x="0" y="580" width="${W}" height="${H}" fill="#4A3220"/>` +
    Array.from({ length: 16 }, (_, i) => `<rect x="${20 + i * 96}" y="580" width="14" height="140" fill="#3A2716"/>`).join('') +
    crate(120, 540, 1.2) + crate(195, 540, 1.0) + crate(155, 470, 0.9) + crate(1060, 540, 1.1) + crate(1130, 540, 0.9) +
    `<path d="M260 540 L260 330 L380 330" stroke="#3A2716" stroke-width="10" fill="none"/><path d="M370 330 L370 410" stroke="#3A2716" stroke-width="3"/>` + crate(370, 470, 0.9, '#A0703A'),

  // 3. Floresta das Colmeias (multiplicação): árvores altas, colmeias e favos.
  () => sky('#132A2A', '#2C4B3A') + stars(31, 30, '#FFF2B0') +
    honeycomb(980, 60, 34, 4, 8, 'rgba(242,201,76,0.16)') + honeycomb(40, 90, 30, 3, 5, 'rgba(242,201,76,0.12)') +
    pine(80, 620, 1.3, '#1F4A35') + pine(1420, 640, 1.4, '#1F4A35') + pine(1260, 600, 1.0, '#24563D') + pine(260, 600, 0.9, '#24563D') +
    bigTree(420, 700, 1.2, '#2A5E3E') + bigTree(1080, 700, 1.1, '#2A5E3E') +
    hive(330, 520, 1.2) + hive(1170, 500, 1.1) + hive(1000, 520, 0.9) +
    bee(520, 300, 1.2) + bee(600, 260, 1) + bee(900, 330, 1.1) + bee(760, 210, 0.9) + bee(1250, 260, 1) +
    hill(620, 25, '#1B3D2B', 7, 4),

  // 4. Aldeia do Banquete (divisão): casinhas, bandeirinhas e uma mesa de festa.
  () => sky('#2A1F3D', '#5A3D4E') + stars(41, 35) + moon(760, 100, 36) +
    hill(470, 30, '#3B3048', 8) +
    house(170, 520, 1.0, '#D9C7A0', '#8A3B2E') + house(420, 500, 0.8, '#CDB894', '#5A3A6A') +
    house(1080, 500, 0.85, '#D9C7A0', '#3A5A8A') + house(1320, 520, 1.0, '#CDB894', '#8A3B2E') +
    bunting(0, 230, 744, 230, 80, 9) + bunting(744, 230, W, 230, 80, 10) +
    `<rect x="0" y="560" width="${W}" height="${H}" fill="#3A2E2A"/>` +
    table(330, 600, 830) +
    `<circle cx="140" cy="640" r="30" fill="#FFB347" opacity="0.15"/><circle cx="1350" cy="640" r="30" fill="#FFB347" opacity="0.15"/>`,

  // 5. Torre do Relógio (frações): telhados da cidade, engrenagens e a torre.
  () => `<defs><pattern id="brick" width="40" height="20" patternUnits="userSpaceOnUse"><path d="M0 0 H40 M0 10 H40 M20 0 V10 M0 10 V20" stroke="#000" stroke-width="2"/></pattern></defs>` +
    sky('#151A33', '#3A3360') + stars(51, 45) +
    gear(200, 200, 70, 10, 'rgba(201,154,30,0.20)') + gear(320, 120, 40, 8, 'rgba(201,154,30,0.16)') + gear(1280, 160, 60, 9, 'rgba(201,154,30,0.18)') +
    rooftops(600, '#262545', 12) + clockTower(744, 700, 1.15) +
    `<rect x="0" y="640" width="${W}" height="${H}" fill="#1E1D36"/>`,

  // 6. Grande Mercado (porcentagem): barracas listradas e o palácio do Barão.
  () => sky('#24183A', '#4A2E4E') + stars(61, 40) + moon(1320, 110, 40) +
    palace(744, 470, 1.0) +
    `<rect x="0" y="470" width="${W}" height="${H}" fill="#3A2A30"/>` +
    Array.from({ length: 12 }, (_, i) => `<rect x="${i * 130}" y="470" width="128" height="4" fill="#2A1E24"/>`).join('') +
    stall(190, 620, 1.1, '#C0392B', '#F3EBD8', '50%') + stall(480, 640, 0.9, '#2E86C1', '#F3EBD8', '25%') +
    stall(1010, 640, 0.9, '#27AE60', '#F3EBD8', '10%') + stall(1300, 620, 1.1, '#F2C94C', '#8A3B2E', '%') +
    bunting(0, 300, 560, 330, 60, 12) + bunting(930, 330, W, 300, 60, 13),
];

(async () => {
  const b = await chromium.launch();
  const p = await b.newPage({ viewport: { width: W, height: H } });
  for (let i = 0; i < scenes.length; i++) {
    const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}" viewBox="0 0 ${W} ${H}">
      <defs><clipPath id="card"><rect width="${W}" height="${H}" rx="48"/></clipPath>
        <linearGradient id="veil" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stop-color="#0B1120" stop-opacity="0.30"/>
          <stop offset="0.5" stop-color="#0B1120" stop-opacity="0.42"/>
          <stop offset="1" stop-color="#0B1120" stop-opacity="0.30"/></linearGradient></defs>
      <g clip-path="url(#card)">${scenes[i]()}
        <rect width="${W}" height="${H}" fill="url(#veil)"/></g>
      <rect x="2" y="2" width="${W - 4}" height="${H - 4}" rx="47" fill="none" stroke="#C99A1E" stroke-opacity="0.55" stroke-width="4"/>
    </svg>`;
    await p.setContent(`<html><body style="margin:0;background:transparent">${svg}</body></html>`);
    await p.screenshot({ path: path.join(out, `mundo_${i + 1}.png`), omitBackground: true, clip: { x: 0, y: 0, width: W, height: H } });
    console.log('mundo', i + 1);
  }
  await b.close();
})();
