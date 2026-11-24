const { chromium } = require('/opt/node-tools/node_modules/playwright');
const fs = require('fs');
const path = require('path');

const repo = '/home/user/MathMatch/assets/';
const out = process.argv[2];
const font = fs.readFileSync(repo + 'fontes/fonte.ttf').toString('base64');
const peca = (n) => 'data:image/png;base64,' + fs.readFileSync(repo + `imagens/pecas/peca_${String(n).padStart(2, '0')}.png`).toString('base64');

const css = `@font-face { font-family: Logo; src: url(data:font/ttf;base64,${font}); }
  body { margin: 0; background: transparent; }
  .t { font-family: Logo; font-weight: 700; }`;

// Brilho de 4 pontas.
const sparkle = (x, y, s, o = 1) => `<path transform="translate(${x} ${y}) scale(${s})" opacity="${o}" d="M0 -20 C 3 -5, 5 -3, 20 0 C 5 3, 3 5, 0 20 C -3 5, -5 3, -20 0 C -5 -3, -3 -5, 0 -20 Z" fill="#FFF3B0"/>`;

// Peça do jogo com número, levemente girada.
const tile = (n, x, y, rot, size = 96) => `<g transform="translate(${x} ${y}) rotate(${rot})">
  <image href="${peca(n)}" x="${-size / 2}" y="${-size / 2}" width="${size}" height="${size}"/>
  <text class="t" x="0" y="${size * 0.2}" text-anchor="middle" font-size="${size * 0.55}" fill="#fff" stroke="#1b1b1b" stroke-width="5" paint-order="stroke">${n}</text>
</g>`;

const logo = `
<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="560" viewBox="0 0 1200 560">
  <defs>
    <linearGradient id="gold" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#FFF0A8"/><stop offset="0.45" stop-color="#F7CE4F"/><stop offset="1" stop-color="#C98E16"/>
    </linearGradient>
    <linearGradient id="page" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#FBF5E6"/><stop offset="1" stop-color="#E7D9B8"/>
    </linearGradient>
    <radialGradient id="glow" cx="0.5" cy="0.5" r="0.5">
      <stop offset="0" stop-color="#FFE48A" stop-opacity="0.55"/><stop offset="1" stop-color="#FFE48A" stop-opacity="0"/>
    </radialGradient>
    <filter id="shadow" x="-10%" y="-10%" width="120%" height="140%">
      <feDropShadow dx="0" dy="9" stdDeviation="5" flood-color="#000" flood-opacity="0.55"/>
    </filter>
  </defs>

  <!-- brilho atrás do título -->
  <ellipse cx="600" cy="230" rx="560" ry="200" fill="url(#glow)"/>

  <!-- o Grande Livro dos Números, aberto -->
  <g filter="url(#shadow)">
    <path d="M150 400 Q 380 350 600 410 Q 820 350 1050 400 L 1062 470 Q 820 420 600 486 Q 380 420 138 470 Z" fill="#5A3A22" stroke="#2B1A0E" stroke-width="6" stroke-linejoin="round"/>
    <path d="M170 392 Q 385 330 600 392 L 600 470 Q 385 410 160 456 Z" fill="url(#page)" stroke="#5A3A22" stroke-width="5" stroke-linejoin="round"/>
    <path d="M1030 392 Q 815 330 600 392 L 600 470 Q 815 410 1040 456 Z" fill="url(#page)" stroke="#5A3A22" stroke-width="5" stroke-linejoin="round"/>
    <path d="M220 400 Q 400 360 570 404 M230 422 Q 400 384 570 426 M630 404 Q 800 360 980 400 M630 426 Q 800 384 970 422" fill="none" stroke="#CDBB93" stroke-width="4" stroke-linecap="round"/>
    <path d="M600 392 L 600 470" stroke="#5A3A22" stroke-width="6"/>
  </g>

  <!-- peças do jogo saindo do livro -->
  ${tile(3, 150, 105, -16, 84)}
  ${tile(5, 1055, 100, 14, 88)}
  ${tile(7, 960, 50, 22, 58)}

  <!-- título -->
  <g filter="url(#shadow)">
    <text class="t" x="600" y="330" text-anchor="middle" font-size="212" letter-spacing="2"
      fill="url(#gold)" stroke="#3B2412" stroke-width="16" stroke-linejoin="round" paint-order="stroke">MathMatch</text>
  </g>
  <text class="t" x="600" y="330" text-anchor="middle" font-size="212" letter-spacing="2" fill="none" stroke="#FFF6C9" stroke-width="2" opacity="0.6">MathMatch</text>

  <!-- fita com o subtítulo -->
  <g filter="url(#shadow)">
    <path d="M300 470 L 340 440 L 300 410 L 400 410 L 400 470 Z" fill="#7A2E1E" stroke="#3B140C" stroke-width="5" stroke-linejoin="round"/>
    <path d="M900 470 L 860 440 L 900 410 L 800 410 L 800 470 Z" fill="#7A2E1E" stroke="#3B140C" stroke-width="5" stroke-linejoin="round"/>
    <path d="M370 398 Q 600 430 830 398 L 830 470 Q 600 502 370 470 Z" fill="#A23B26" stroke="#3B140C" stroke-width="5" stroke-linejoin="round"/>
    <text class="t" x="600" y="461" text-anchor="middle" font-size="40" letter-spacing="5" fill="#FFF0C2">AS PÁGINAS ROUBADAS</text>
  </g>

  ${sparkle(60, 230, 1.2)}${sparkle(1140, 300, 1.1)}${sparkle(330, 60, 0.9, 0.9)}${sparkle(820, 60, 1.0)}${sparkle(1150, 180, 0.6, 0.8)}${sparkle(240, 170, 0.6, 0.8)}
</svg>`;

// Ícone do jogo (quadrado): o livro aberto com o "M" dourado.
const icon = `
<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <defs>
    <linearGradient id="gold" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#FFF0A8"/><stop offset="0.45" stop-color="#F7CE4F"/><stop offset="1" stop-color="#C98E16"/>
    </linearGradient>
    <linearGradient id="bg" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#1B2545"/><stop offset="1" stop-color="#0B1120"/></linearGradient>
    <linearGradient id="page" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#FBF5E6"/><stop offset="1" stop-color="#E7D9B8"/></linearGradient>
  </defs>
  <rect x="16" y="16" width="480" height="480" rx="96" fill="url(#bg)" stroke="#C98E16" stroke-width="14"/>
  <path d="M70 380 Q 160 340 256 380 Q 352 340 442 380 L 448 420 Q 352 390 256 430 Q 160 390 64 420 Z" fill="#5A3A22" stroke="#2B1A0E" stroke-width="6"/>
  <path d="M84 372 Q 170 330 256 372 L 256 420 Q 170 384 78 408 Z M428 372 Q 342 330 256 372 L 256 420 Q 342 384 434 408 Z" fill="url(#page)" stroke="#5A3A22" stroke-width="5"/>
  <text class="t" x="256" y="350" text-anchor="middle" font-size="330" fill="url(#gold)" stroke="#3B2412" stroke-width="16" stroke-linejoin="round" paint-order="stroke">M</text>
  ${tile(5, 400, 120, 16, 110)}
  ${sparkle(110, 110, 1.6)}${sparkle(150, 200, 0.7, 0.8)}
</svg>`;

(async () => {
  const b = await chromium.launch();
  for (const [name, svg, w, h] of [['logo', logo, 1200, 560], ['icone', icon, 512, 512]]) {
    const p = await b.newPage({ viewport: { width: w, height: h } });
    await p.setContent(`<html><head><style>${css}</style></head><body>${svg}</body></html>`);
    await p.waitForTimeout(300);
    await p.screenshot({ path: path.join(out, name + '.png'), omitBackground: true, clip: { x: 0, y: 0, width: w, height: h } });
    fs.writeFileSync(path.join(out, name + '.svg'), svg);
  }
  // Prévia sobre o fundo do menu.
  const bgimg = 'data:image/png;base64,' + fs.readFileSync(repo + 'imagens/fundos/fundo_menu.png').toString('base64');
  const lg = 'data:image/png;base64,' + fs.readFileSync(path.join(out, 'logo.png')).toString('base64');
  const ic = 'data:image/png;base64,' + fs.readFileSync(path.join(out, 'icone.png')).toString('base64');
  const p = await b.newPage({ viewport: { width: 1400, height: 700 } });
  await p.setContent(`<html><body style="margin:0;background:url(${bgimg}) center/cover;display:flex;align-items:center;gap:30px;padding:30px">
    <img src="${lg}" style="width:860px"><div style="display:flex;flex-direction:column;gap:20px;align-items:center"><img src="${ic}" style="width:256px"><img src="${ic}" style="width:64px"><img src="${lg}" style="width:300px"></div></body></html>`);
  await p.screenshot({ path: path.join(out, 'previa.png') });
  await b.close();
})();
