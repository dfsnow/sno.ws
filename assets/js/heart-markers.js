// Mini-script to move hearts in text to the ::marker pseudo-element
document.querySelector("article").classList.add("js-enabled");

var isSafari = /^((?!chrome|android).)*safari/i.test(navigator.userAgent);
var lis = document.querySelectorAll("article.js-enabled ul li");

lis.forEach(function(e) {
    if (e.contains(e.querySelector("svg"))) {
        e.classList.add("with-heart");
        e.querySelectorAll('svg').forEach(s => s.remove())
        if (isSafari) {
            e.classList.add("safari-marker");
        }
    } else {
        e.classList.add("no-heart");
        if (isSafari) {
            e.classList.add("safari-marker");
        }
    };
});
