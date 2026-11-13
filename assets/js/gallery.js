// 活動記録一覧（gallery.html）の、タグでの絞り込みとページ送り。
//
// 記事カードは最初から全部 HTML に入っていて、ここでは hidden 属性で出し入れするだけ。
// 絞り込み中のタグは URL の ?tag= に入れる。記事ページなどのタグのリンクも、この形で飛んでくる。

const PER_PAGE = 12; // 1ページに出す記事の数

const cards = [...document.querySelectorAll('.post-item')];
const filterButtons = [...document.querySelectorAll('#tag-filter .tag-chip')];
const prevButton = document.getElementById('prev-page');
const nextButton = document.getElementById('next-page');
const indicator = document.getElementById('page-indicator');

// URL の ?tag= を読む。存在しないタグなら絞り込まない
const knownTags = filterButtons.map(button => button.dataset.tag);
let tag = new URLSearchParams(location.search).get('tag');
if (!knownTags.includes(tag)) tag = null;
let page = 1;

// いまのタグとページに合わせて、カード・タグの色・ページ送りを表示し直す
function render() {
  const matching = cards.filter(card => !tag || card.dataset.tags.split(',').includes(tag));
  const lastPage = Math.ceil(matching.length / PER_PAGE);
  const shown = matching.slice((page - 1) * PER_PAGE, page * PER_PAGE);
  cards.forEach(card => { card.hidden = !shown.includes(card); });

  document.querySelectorAll('.tag-chip[data-tag]').forEach(chip => {
    chip.classList.toggle('is-active', chip.dataset.tag === tag);
  });

  indicator.textContent = lastPage ? `${page} / ${lastPage}` : '記事がありません';
  prevButton.disabled = page <= 1;
  nextButton.disabled = page >= lastPage;
}

function selectTag(newTag) {
  tag = newTag === tag ? null : newTag; // 同じタグをもう一度押すと解除
  page = 1;

  const url = new URL(location.href);
  if (tag) url.searchParams.set('tag', tag);
  else url.searchParams.delete('tag');
  history.replaceState(null, '', url);

  render();
}

function turnPage(step) {
  page += step;
  render();
  window.scrollTo({ top: 0, behavior: 'smooth' });
}

// 上のタグボタンと、カードの中のタグ（リンク）のどちらを押しても、ページを移らずその場で絞り込む
document.addEventListener('click', event => {
  const chip = event.target.closest('.tag-chip[data-tag]');
  if (!chip) return;
  event.preventDefault();
  selectTag(chip.dataset.tag);
});
prevButton.addEventListener('click', () => turnPage(-1));
nextButton.addEventListener('click', () => turnPage(1));

render();
