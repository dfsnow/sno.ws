// Mini-script to move hearts in text to the ::marker pseudo-element
document.querySelector('article').classList.add('js-enabled')
document.querySelector('article span.heart').classList.add('js-enabled')
var lis = document.querySelectorAll('article.js-enabled ul li')
    oldHTML = 'innerHTML',
    newHTML = '';

[].forEach.call(lis, function (a) {
    if (a[oldHTML].includes('♥') & CSS.supports('selector(::marker)')) {
        a.className = 'with-heart';
        newHTML = a[oldHTML].replace('♥', '');
        a[oldHTML] = newHTML;
    } else if (a[oldHTML].includes('♥')) {
        newHTML = a[oldHTML].replace('♥', '<span class="heart">♥</span>');
        a[oldHTML] = newHTML;
    }
});
