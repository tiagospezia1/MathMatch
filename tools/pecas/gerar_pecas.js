// Gera as peças de madeira do tabuleiro e a bandeja:
//   assets/imagens/pecas/peca_01.png ... peca_12.png, casa_vazia.png
//   assets/imagens/interface/fundo_tabuleiro.png
// Cada peça é um bloquinho de madeira com um símbolo pintado no canto (para quem não distingue
// bem as cores). O número é escrito por cima pelo jogo, na mesma cor do símbolo (game.gd, TILE_INK).
// Uso: node gerar_pecas.js <pasta de saída>
const { chromium } = require('/opt/node-tools/node_modules/playwright');
const path = require('path');

const out = process.argv[2];
const S = 128;

// Mesmas cores de TILE_INK em scripts/game.gd.
const INK = ['#C0392B', '#1F5FAD', '#1E8449', '#7D3C98', '#D35400', '#B03A7A',
  '#138D90', '#9A7D0A', '#2C3E8C', '#5B7F1A', '#6E2C00', '#2E2E2E'];

// Símbolos simples, desenhados num quadrado de 0 a 24.
const SYMBOLS = [
  '<circle cx="12" cy="12" r="10"/>',
  '<rect x="3" y="3" width="18" height="18" rx="2"/>',
  '<path d="M12 2 L22 21 L2 21 Z"/>',
  '<path d="M12 1 L15 9 L23 9 L16.5 14 L19 22 L12 17 L5 22 L7.5 14 L1 9 L9 9 Z"/>',
  '<path d="M12 21 C 2 14, 1 7, 6 4 C 9 2.5, 11 4, 12 6 C 13 4, 15 2.5, 18 4 C 23 7, 22 14, 12 21 Z"/>',
  '<path d="M12 1 L22 12 L12 23 L2 12 Z"/>',
  '<path d="M12 1.5 L21.5 7 L21.5 17 L12 22.5 L2.5 17 L2.5 7 Z"/>',
  '<path d="M15 2 A10 10 0 1 0 22 16 A8 8 0 1 1 15 2 Z"/>',
  '<path d="M8.5 2 H15.5 V8.5 H22 V15.5 H15.5 V22 H8.5 V15.5 H2 V8.5 H8.5 Z"/>',
  '<path d="M3 21 C 3 9, 10 3, 22 2 C 21 14, 15 21, 3 21 Z"/>',
  '<path d="M12 1.5 C 17 9, 20 12.5, 20 15.5 A8 8 0 0 1 4 15.5 C 4 12.5, 7 9, 12 1.5 Z"/>',
  '<circle cx="12" cy="6" r="4.5"/><circle cx="18" cy="12" r="4.5"/><circle cx="12" cy="18" r="4.5"/><circle cx="6" cy="12" r="4.5"/><circle cx="12" cy="12" r="3.5"/>',
];

const defs = `<defs>
  <linearGradient id="face" x1="0" y1="0" x2="0.3" y2="1">
    <stop offset="0" stop-color="#F0CF98"/><stop offset="1" stop-color="#D9AE6E"/></linearGradient>
  <linearGradient id="side" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#A9743C"/><stop offset="1" stop-color="#7E5225"/></linearGradient>
  <filter id="grain" x="0" y="0" width="100%" height="100%">
    <feTurbulence type="fractalNoise" baseFrequency="0.012 0.22" numOctaves="3" seed="SEED"/>
    <feColorMatrix values="0 0 0 0 0.45  0 0 0 0 0.27  0 0 0 0 0.10  0 0 0 1.4 -0.55"/>
    <feComposite in2="SourceGraphic" operator="in"/>
  </filter>
  <filter id="soft"><feGaussianBlur stdDeviation="1.2"/></filter>
</defs>`;

const tile = (i) => `<svg xmlns="http://www.w3.org/2000/svg" width="${S}" height="${S}" viewBox="0 0 ${S} ${S}">
  ${defs.replace('SEED', 3 + i * 7)}
  <ellipse cx="64" cy="122" rx="56" ry="5" fill="#000" opacity="0.25" filter="url(#soft)"/>
  <rect x="5" y="9" width="118" height="114" rx="16" fill="url(#side)"/>
  <rect x="5" y="4" width="118" height="108" rx="16" fill="url(#face)"/>
  <rect x="5" y="4" width="118" height="108" rx="16" fill="#fff" filter="url(#grain)"/>
  <rect x="7.5" y="6.5" width="113" height="103" rx="14" fill="none" stroke="#FFF3D6" stroke-opacity="0.7" stroke-width="3"/>
  <rect x="5" y="4" width="118" height="108" rx="16" fill="none" stroke="#6B4320" stroke-width="2"/>
  <g transform="translate(13 12) scale(1.15)" fill="${INK[i]}" opacity="0.92">${SYMBOLS[i]}</g>
</svg>`;

const empty = `<svg xmlns="http://www.w3.org/2000/svg" width="${S}" height="${S}" viewBox="0 0 ${S} ${S}">
  <defs><radialGradient id="hole" cx="0.5" cy="0.4" r="0.7">
    <stop offset="0" stop-color="#3A2414"/><stop offset="1" stop-color="#22140A"/></radialGradient></defs>
  <rect x="8" y="8" width="112" height="112" rx="16" fill="url(#hole)"/>
  <rect x="8" y="8" width="112" height="112" rx="16" fill="none" stroke="#1A0E06" stroke-width="4"/>
  <path d="M14 116 H114" stroke="#7E5225" stroke-opacity="0.5" stroke-width="3"/>
</svg>`;

// Bandeja de madeira escura com filete dourado. 64x64, fatiada pelo jogo com margem de 16.
const tray = `<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64">
  <rect x="0" y="0" width="64" height="64" rx="14" fill="#5A3A22"/>
  <rect x="1.5" y="1.5" width="61" height="61" rx="13" fill="none" stroke="#C99A1E" stroke-width="3"/>
  <rect x="7" y="7" width="50" height="50" rx="8" fill="#3B2414"/>
  <rect x="7" y="7" width="50" height="50" rx="8" fill="none" stroke="#2A170B" stroke-width="2"/>
</svg>`;

(async () => {
  const b = await chromium.launch();
  const p = await b.newPage({ viewport: { width: S, height: S } });
  const shot = async (svg, file, w = S, h = S) => {
    await p.setContent(`<html><body style="margin:0;background:transparent">${svg}</body></html>`);
    await p.screenshot({ path: path.join(out, file), omitBackground: true, clip: { x: 0, y: 0, width: w, height: h } });
    console.log(file);
  };
  for (let i = 0; i < 12; i++) await shot(tile(i), `peca_${String(i + 1).padStart(2, '0')}.png`);
  await shot(empty, 'casa_vazia.png');
  await shot(tray, 'fundo_tabuleiro.png', 64, 64);
  await b.close();
})();
