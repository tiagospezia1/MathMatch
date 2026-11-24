// Gera o fundo da partida de cada lugar: assets/imagens/fundos/lugar_1.png ... lugar_6.png
// Cada fundo é uma cena noturna ilustrada em SVG (feita aqui, sem imagens de terceiros),
// escurecida para o tabuleiro continuar sendo o centro da tela.
// Uso: node gerar_fundos.js <pasta de saída>
const { chromium } = require('/opt/node-tools/node_modules/playwright');
const path = require('path');

const W = 1488, H = 700; // tamanho da cena; ela fica embaixo de um céu quadrado de 1488x1488
const SIZE = 1200; // tamanho do PNG final
const out = process.argv[2];

const D = require('./desenhos.js');
const { rng, sky, stars, moon, hill, fruitTree, house, crate, ship, lighthouse, pine, bigTree, hive, honeycomb, bee, bunting, table, clockTower, gear, rooftops, stall, palace } = D;

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

const skyTop = ['#1B2A4A', '#14203D', '#132A2A', '#2A1F3D', '#151A33', '#24183A'];

(async () => {
  const b = await chromium.launch();
  const p = await b.newPage({ viewport: { width: SIZE, height: SIZE } });
  for (let i = 0; i < scenes.length; i++) {
    D.setSize(W, W);
    const upperStars = stars(100 + i, 60);
    D.setSize(W, H);
    const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${SIZE}" height="${SIZE}" viewBox="0 0 ${W} ${W}">
      <defs><linearGradient id="veil" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stop-color="#0B1120" stop-opacity="0.35"/>
          <stop offset="1" stop-color="#0B1120" stop-opacity="0.55"/></linearGradient></defs>
      <rect width="${W}" height="${W}" fill="${skyTop[i]}"/>${upperStars}
      <g transform="translate(0 ${W - H})">${scenes[i]()}</g>
      <rect width="${W}" height="${W}" fill="url(#veil)"/>
    </svg>`;
    await p.setContent(`<html><body style="margin:0;background:#000">${svg}</body></html>`);
    await p.screenshot({ path: path.join(out, `lugar_${i + 1}.png`), clip: { x: 0, y: 0, width: SIZE, height: SIZE } });
    console.log('lugar', i + 1);
  }
  await b.close();
})();
