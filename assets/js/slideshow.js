// 写真の切り替え（トップページの「活動内容」で使う）。
//
// HTML の形:
//   <div class="local-slideshow" data-interval="6000">   ← data-interval は切り替えの間隔（ミリ秒）
//     <div class="local-slide active"><img ...></div>
//     <div class="local-slide"><img ...></div>
//     <div class="local-dots"></div>                      ← ここに点（ボタン）を作る
//   </div>
//
// - 一定時間ごとに次の写真へ進む。点・左右キー・スワイプでも切り替えられる
// - カーソルを載せている間と、キーボードで操作している間は、自動では進めない
// - OS で「視差効果を減らす」を設定している人には、自動では進めない
// - 写真が1枚だけなら何もしない（点も出さない）

const SWIPE_DISTANCE = 40; // これ以上横に動かしたらスワイプとみなす（px）
const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');

document.querySelectorAll('.local-slideshow').forEach(slideshow => {
  const slides = [...slideshow.querySelectorAll('.local-slide')];
  const dotsBox = slideshow.querySelector('.local-dots');
  if (slides.length < 2 || !dotsBox) return;

  const interval = Number(slideshow.dataset.interval) || 5000;
  let current = Math.max(0, slides.findIndex(slide => slide.classList.contains('active')));
  let timer = null;

  const dots = slides.map((_, i) => {
    const dot = document.createElement('button');
    dot.type = 'button';
    dot.className = 'dot';
    dot.setAttribute('aria-label', `${i + 1}枚目を表示`);
    dot.addEventListener('click', () => {
      show(i);
      restart();
    });
    dotsBox.appendChild(dot);
    return dot;
  });

  function show(n) {
    current = (n + slides.length) % slides.length; // 最後の次は最初へ、最初の前は最後へ
    slides.forEach((slide, i) => slide.classList.toggle('active', i === current));
    dots.forEach((dot, i) => dot.classList.toggle('active', i === current));
  }

  function stop() {
    clearInterval(timer);
    timer = null;
  }

  function restart() {
    stop();
    if (!reducedMotion.matches) {
      timer = setInterval(() => show(current + 1), interval);
    }
  }

  // キーボードでも操作できるようにする
  slideshow.tabIndex = 0;
  slideshow.setAttribute('role', 'region');
  slideshow.setAttribute('aria-label', '画像スライドショー');
  slideshow.addEventListener('keydown', event => {
    if (event.key === 'ArrowLeft') show(current - 1);
    else if (event.key === 'ArrowRight') show(current + 1);
    else return;
    event.preventDefault();
  });

  slideshow.addEventListener('mouseenter', stop);
  slideshow.addEventListener('mouseleave', restart);
  slideshow.addEventListener('focusin', stop);
  slideshow.addEventListener('focusout', restart);

  // スワイプ（指とペン。マウスのドラッグでは切り替えない）
  let startX = null;
  let startY = null;
  slideshow.addEventListener('pointerdown', event => {
    if (event.pointerType === 'mouse') return;
    startX = event.clientX;
    startY = event.clientY;
    stop();
  });
  slideshow.addEventListener('pointerup', event => {
    if (startX === null) return;
    const moveX = event.clientX - startX;
    const moveY = event.clientY - startY;
    startX = null;
    if (Math.abs(moveX) >= SWIPE_DISTANCE && Math.abs(moveX) > Math.abs(moveY)) {
      show(current + (moveX < 0 ? 1 : -1));
    }
    restart();
  });
  slideshow.addEventListener('pointercancel', () => {
    startX = null;
    restart();
  });

  reducedMotion.addEventListener('change', restart);

  show(current);
  restart();
});
