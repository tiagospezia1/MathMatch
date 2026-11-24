// Gera o mapa da jornada como um pergaminho do Grande Livro dos Números:
//   assets/imagens/mapa/pergaminho.jpg      o mapa inteiro (780x2460 no jogo)
//   assets/imagens/mapa/regiao_oculta.png   o pedaço de papel que cobre um lugar ainda não alcançado
//   assets/imagens/mapa/fase_*.png          os marcos das fases (selo de cera, moeda, papel e pedra)
// A estrada e os textos são desenhados pelo jogo (progression_menu.gd). As posições das fases
// abaixo precisam ser as mesmas de _get_stage_position() em progression_menu.gd.
// Uso: node gerar_mapa.js <pasta de saída>
const { chromium } = require('/opt/node-tools/node_modules/playwright');
const fs = require('fs');
const path = require('path');
const D = require('./desenhos.js');
const { rng, fruitTree, house, crate, ship, lighthouse, pine, bigTree, hive, bee, bunting, table, clockTower, gear, stall, palace } = D;

const out = process.argv[2];
const repo = path.join(__dirname, '..', '..', 'assets');
const W = 780, H = 2460, SCALE = 1.5;
const font = fs.readFileSync(path.join(repo, 'fontes', 'fonte.ttf')).toString('base64');
const baron = fs.readFileSync(path.join(repo, 'imagens', 'personagens', 'barao_rindo.png')).toString('base64');

const X = [160, 350, 570, 620, 420, 210, 155, 350, 575, 625, 425, 215, 160, 365, 590, 620, 405, 190];
const stagePos = (id) => [X[id - 1], 135 + Math.floor((id - 1) / 3) * 390 + ((id - 1) % 3) * 100];
const top = (g) => 40 + g * 390; // começo de cada lugar

// Mancha de aquarela.
const wash = (cx, cy, rx, ry, color, o = 0.35) => `<ellipse cx="${cx}" cy="${cy}" rx="${rx}" ry="${ry}" fill="${color}" opacity="${o}" filter="url(#water)"/>`;
const at = (x, y, s, svg) => `<g transform="translate(${x} ${y}) scale(${s})">${svg}</g>`;

// Fronteira tracejada e ondulada entre dois lugares.
const border = (y, seed) => {
  const r = rng(seed); let d = `M24 ${y}`;
  for (let x = 24; x < W - 24; x += 40) d += ` Q${x + 20} ${y + (r() - 0.5) * 18} ${x + 40} ${y}`;
  return `<path d="${d}" fill="none" stroke="#6B4A2E" stroke-width="2.5" stroke-dasharray="3 9" stroke-linecap="round" opacity="0.7"/>`;
};

const compass = (x, y, r) => `<g transform="translate(${x} ${y})" opacity="0.85">
  <circle r="${r}" fill="none" stroke="#5A3A22" stroke-width="2"/><circle r="${r * 0.78}" fill="none" stroke="#5A3A22" stroke-width="1"/>
  <path d="M0 ${-r * 1.15} L${r * 0.18} 0 L0 ${r * 1.15} L${-r * 0.18} 0 Z" fill="#5A3A22"/>
  <path d="M${-r * 1.15} 0 L0 ${r * 0.18} L${r * 1.15} 0 L0 ${-r * 0.18} Z" fill="#8A6A4A"/>
  <path d="M0 ${-r * 1.15} L${r * 0.18} 0 L0 0 Z" fill="#A8322A"/>
  <text class="t" y="${-r * 1.3}" text-anchor="middle" font-size="${r * 0.55}" fill="#5A3A22">N</text>
</g>`;

const waves = (x, y, n, seed) => {
  const r = rng(seed); let s = '';
  for (let i = 0; i < n; i++) s += `<path d="M${x + r() * 300} ${y + r() * 150} q8 -6 16 0 q8 6 16 0" fill="none" stroke="#3F6E8C" stroke-width="2" opacity="0.6"/>`;
  return s;
};

// Os desenhos de cada lugar, nos cantos livres (longe das fases e dos textos ao lado delas).
const places = () => [
  // 1. Vila do Pomar
  wash(620, 160, 170, 80, '#7FA650') + wash(150, 330, 160, 110, '#9DBB6A') + wash(390, 260, 330, 170, '#B5C97A', 0.18) +
    fruitTree(600, 200, 0.42, '#5E8C3A', '#C0392B', 3) + fruitTree(670, 195, 0.48, '#5E8C3A', '#E08A2A', 4) + fruitTree(738, 205, 0.4, '#5E8C3A', '#C0392B', 5) +
    house(75, 340, 0.42, '#E6D2A8', '#9A3B2E') + house(170, 365, 0.38, '#E6D2A8', '#7A4A26') +
    `<path d="M24 395 L290 395" stroke="#7A5A3A" stroke-width="3"/>` +
    Array.from({ length: 12 }, (_, i) => `<rect x="${28 + i * 22}" y="383" width="5" height="22" fill="#7A5A3A"/>`).join(''),
  // 2. Porto das Cargas
  wash(150, 540, 190, 110, '#6F9DB8', 0.5) + wash(60, 650, 90, 80, '#6F9DB8', 0.4) + waves(20, 470, 9, 21) +
    ship(185, 565, 0.4) + wash(640, 760, 160, 70, '#C9A877', 0.4) +
    `<rect x="520" y="795" width="240" height="12" fill="#7A5A3A"/>` +
    crate(555, 795, 0.45) + crate(588, 795, 0.4) + crate(570, 768, 0.36) + lighthouse(705, 800, 0.45),
  // 3. Floresta das Colmeias
  wash(640, 930, 160, 90, '#5E8C4A', 0.45) + wash(150, 1120, 160, 110, '#5E8C4A', 0.45) +
    pine(520, 975, 0.32, '#3F6E3F') + pine(585, 972, 0.28, '#4A7A45') + bigTree(700, 1000, 0.35, '#4E7E40') + hive(655, 935, 0.45) +
    pine(55, 1160, 0.42, '#3F6E3F') + pine(125, 1185, 0.38, '#4A7A45') + pine(225, 1195, 0.33, '#3F6E3F') + hive(175, 1100, 0.45) +
    bee(110, 1055, 0.7) + bee(205, 1045, 0.6) + bee(560, 900, 0.6),
  // 4. Aldeia do Banquete
  wash(170, 1320, 180, 80, '#D9A066') + wash(630, 1520, 160, 80, '#D9A066') +
    bunting(28, 1262, 330, 1262, 28, 9) +
    house(70, 1362, 0.42, '#E6D2A8', '#8A3B2E') + house(170, 1352, 0.38, '#E6D2A8', '#5A3A6A') + house(268, 1362, 0.38, '#E6D2A8', '#3A5A8A') +
    bunting(500, 1462, 760, 1462, 24, 10) + at(510, 1532, 0.45, table(0, 0, 500)),
  // 5. Torre do Relógio
  wash(660, 1720, 130, 110, '#9C93B5', 0.45) + wash(160, 1920, 170, 70, '#9C93B5', 0.4) +
    gear(545, 1690, 20, 9, '#9A7A3A') + gear(588, 1662, 12, 8, '#9A7A3A') + clockTower(690, 1792, 0.3) +
    house(70, 1960, 0.42, '#C9C2D8', '#4B4A66') + house(160, 1950, 0.38, '#C9C2D8', '#4B4A66') + house(250, 1965, 0.34, '#C9C2D8', '#4B4A66'),
  // 6. Grande Mercado
  wash(180, 2100, 190, 90, '#B58BB0', 0.45) + wash(620, 2300, 170, 80, '#D9A066', 0.4) +
    palace(190, 2150, 0.28) +
    stall(560, 2332, 0.4, '#C0392B', '#F3EBD8', '50%') + stall(690, 2342, 0.4, '#2E86C1', '#F3EBD8', '25%'),
];

const map = () => {
  let s = '';
  for (let g = 1; g < 6; g++) s += border(top(g) - 6, 40 + g);
  s += `<g filter="url(#ink)">${places().join('')}</g>`;
  // O Barão, no palácio do Grande Mercado.
  s += `<g transform="translate(312 2082)">
      <circle r="34" fill="#F3EBD8" stroke="#5A3A22" stroke-width="4"/>
      <clipPath id="bc"><circle r="30"/></clipPath>
      <image href="data:image/png;base64,${baron}" x="-32" y="-30" width="64" height="64" clip-path="url(#bc)"/></g>`;
  s += compass(712, 2412, 26);
  return s;
};

const parchmentDefs = `
  <style>@font-face { font-family: Mapa; src: url(data:font/ttf;base64,${font}); } .t { font-family: Mapa; font-weight: 700; }</style>
  <filter id="paper" x="0" y="0" width="100%" height="100%">
    <feTurbulence type="fractalNoise" baseFrequency="0.035" numOctaves="4" seed="2"/>
    <feColorMatrix values="0 0 0 0 0.45  0 0 0 0 0.30  0 0 0 0 0.15  0 0 0 0.9 -0.35"/>
    <feComposite in2="SourceGraphic" operator="in"/>
  </filter>
  <filter id="water" x="-30%" y="-30%" width="160%" height="160%">
    <feTurbulence type="fractalNoise" baseFrequency="0.04" numOctaves="2" seed="5" result="n"/>
    <feDisplacementMap in="SourceGraphic" in2="n" scale="40"/>
    <feGaussianBlur stdDeviation="10"/>
  </filter>
  <filter id="ink" x="-5%" y="-5%" width="110%" height="110%">
    <feColorMatrix in="SourceGraphic" type="saturate" values="0.65" result="c"/>
    <feMorphology in="SourceAlpha" operator="dilate" radius="1.3" result="d"/>
    <feFlood flood-color="#3B2412"/><feComposite in2="d" operator="in" result="o"/>
    <feMerge result="m"><feMergeNode in="o"/><feMergeNode in="c"/></feMerge>
    <feTurbulence type="fractalNoise" baseFrequency="0.06" numOctaves="2" seed="9" result="n"/>
    <feDisplacementMap in="m" in2="n" scale="2.5"/>
  </filter>
  <radialGradient id="burn" cx="0.5" cy="0.5" r="0.75">
    <stop offset="0.6" stop-color="#8A5A2B" stop-opacity="0"/><stop offset="1" stop-color="#6B3F1A" stop-opacity="0.55"/></radialGradient>
  <linearGradient id="edgeL" x1="0" x2="1"><stop offset="0" stop-color="#6B3F1A" stop-opacity="0.45"/><stop offset="1" stop-color="#6B3F1A" stop-opacity="0"/></linearGradient>
  <linearGradient id="edgeR" x1="1" x2="0"><stop offset="0" stop-color="#6B3F1A" stop-opacity="0.45"/><stop offset="1" stop-color="#6B3F1A" stop-opacity="0"/></linearGradient>
  <pattern id="brick" width="40" height="20" patternUnits="userSpaceOnUse"><path d="M0 0 H40 M0 10 H40 M20 0 V10 M0 10 V20" stroke="#000" stroke-width="2"/></pattern>`;

const stains = (seed, w, h, n) => {
  const r = rng(seed); let s = '';
  for (let i = 0; i < n; i++) s += `<circle cx="${r() * w}" cy="${r() * h}" r="${20 + r() * 70}" fill="#8A5A2B" opacity="${0.03 + r() * 0.05}" filter="url(#water)"/>`;
  return s;
};

const mapSvg = () => `<svg xmlns="http://www.w3.org/2000/svg" width="${W * SCALE}" height="${H * SCALE}" viewBox="0 0 ${W} ${H}">
  <defs>${parchmentDefs}</defs>
  <rect width="${W}" height="${H}" fill="#2A1A0E"/>
  <rect x="4" y="4" width="${W - 8}" height="${H - 8}" rx="10" fill="#EAD7AA"/>
  <rect x="4" y="4" width="${W - 8}" height="${H - 8}" rx="10" fill="#fff" filter="url(#paper)" opacity="0.7"/>
  ${stains(7, W, H, 40)}
  <rect x="4" y="4" width="40" height="${H - 8}" fill="url(#edgeL)"/><rect x="${W - 44}" y="4" width="40" height="${H - 8}" fill="url(#edgeR)"/>
  <rect x="4" y="4" width="${W - 8}" height="${H - 8}" rx="10" fill="url(#burn)" opacity="0.6"/>
  <rect x="14" y="14" width="${W - 28}" height="${H - 28}" rx="6" fill="none" stroke="#5A3A22" stroke-width="3"/>
  <rect x="20" y="20" width="${W - 40}" height="${H - 40}" rx="4" fill="none" stroke="#5A3A22" stroke-width="1.2"/>
  ${map()}
</svg>`;

// Pedaço de papel rasgado que cobre um lugar ainda não alcançado (760x384 no jogo).
const hiddenSvg = () => {
  const w = 760, h = 384, r = rng(77);
  let d = 'M0 10';
  for (let x = 0; x <= w; x += 16) d += ` L${x} ${6 + r() * 14}`;
  for (let y = 0; y <= h; y += 16) d += ` L${w - r() * 8} ${y}`;
  for (let x = w; x >= 0; x -= 16) d += ` L${x} ${h - 6 - r() * 14}`;
  for (let y = h; y >= 0; y -= 16) d += ` L${r() * 8} ${y}`;
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${w * 2}" height="${h * 2}" viewBox="0 0 ${w} ${h}">
    <defs>${parchmentDefs}<filter id="sh"><feDropShadow dx="0" dy="4" stdDeviation="4" flood-color="#2A1A0E" flood-opacity="0.5"/></filter></defs>
    <path d="${d} Z" fill="#D8C08E" filter="url(#sh)"/>
    <path d="${d} Z" fill="#fff" filter="url(#paper)" opacity="0.8"/>
    ${stains(78, w, h, 10)}
    <path d="${d} Z" fill="none" stroke="#7A5A3A" stroke-width="2" stroke-dasharray="6 5"/>
    <text class="t" x="${w / 2}" y="${h / 2 + 50}" text-anchor="middle" font-size="150" fill="#7A5A3A" opacity="0.22">?</text>
    <text class="t" x="${w / 2}" y="${h / 2 + 96}" text-anchor="middle" font-size="24" fill="#5A3A22" opacity="0.85">Este pedaço do mapa ainda está escondido</text>
  </svg>`;
};

// Marcos das fases, 172x172 (aparecem em 86x86).
const node = (kind) => {
  const c = 86; let s = '';
  if (kind === 'concluida') {
    let d = '';
    for (let i = 0; i <= 64; i++) { const a = i / 64 * Math.PI * 2, rr = 76 + (i % 4 < 2 ? 4 : -2); d += `${i ? 'L' : 'M'}${c + Math.cos(a) * rr} ${c + Math.sin(a) * rr} `; }
    s = `<path d="${d}Z" fill="#9E2F26"/><circle cx="${c}" cy="${c}" r="58" fill="none" stroke="#6E1C16" stroke-width="5"/>
      <ellipse cx="${c - 22}" cy="${c - 30}" rx="20" ry="10" fill="#fff" opacity="0.18" transform="rotate(-30 ${c - 22} ${c - 30})"/>`;
  } else if (kind === 'atual') {
    s = `<defs><radialGradient id="g" cx="0.4" cy="0.35" r="0.7"><stop offset="0" stop-color="#FFF0A8"/><stop offset="0.6" stop-color="#F2C94C"/><stop offset="1" stop-color="#B8860B"/></radialGradient></defs>
      <circle cx="${c}" cy="${c}" r="84" fill="#FFE48A" opacity="0.35"/>
      <circle cx="${c}" cy="${c}" r="74" fill="url(#g)" stroke="#7A5A10" stroke-width="5"/>
      <circle cx="${c}" cy="${c}" r="60" fill="none" stroke="#9A7410" stroke-width="3" stroke-dasharray="4 6"/>`;
  } else if (kind === 'disponivel') {
    s = `<circle cx="${c}" cy="${c}" r="74" fill="#F6EBCF" stroke="#5A3A22" stroke-width="6"/>
      <circle cx="${c}" cy="${c}" r="62" fill="none" stroke="#5A3A22" stroke-width="2"/>`;
  } else {
    s = `<circle cx="${c}" cy="${c}" r="72" fill="#BFAE8C" stroke="#8A7A5E" stroke-width="5" stroke-dasharray="10 7"/>
      <circle cx="${c}" cy="${c}" r="72" fill="#5A4A3A" opacity="0.12"/>`;
  }
  return `<svg xmlns="http://www.w3.org/2000/svg" width="172" height="172" viewBox="0 0 172 172">${s}</svg>`;
};

(async () => {
  const b = await chromium.launch();
  const p = await b.newPage({ viewport: { width: Math.ceil(W * SCALE), height: Math.ceil(H * SCALE) } });
  const shot = async (svg, file, w, h, opts = {}) => {
    await p.setContent(`<html><body style="margin:0;background:transparent">${svg}</body></html>`);
    await p.screenshot({ path: path.join(out, file), clip: { x: 0, y: 0, width: w, height: h }, ...opts });
    console.log(file);
  };
  await shot(mapSvg(), 'pergaminho.jpg', W * SCALE, H * SCALE, { type: 'jpeg', quality: 86 });
  await shot(hiddenSvg(), 'regiao_oculta.png', 1520, 768, { omitBackground: true });
  for (const k of ['concluida', 'atual', 'disponivel', 'bloqueada']) await shot(node(k), `fase_${k}.png`, 172, 172, { omitBackground: true });
  await b.close();
})();
