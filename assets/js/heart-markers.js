// Mini-script to move hearts in text to the ::marker pseudo-element
document.querySelector("article").classList.add("js-enabled");

var isSafari = /^((?!chrome|android).)*safari/i.test(navigator.userAgent);
var useMarker = CSS.supports("selector(::marker)");
var lis = document.querySelectorAll("article.js-enabled ul li");

if (useMarker & !isSafari) {
    lis.forEach(function(e) {
        if (e.contains(e.querySelector("svg"))) {
            e.classList.add("with-heart");
            e.querySelectorAll('svg').forEach(s => s.remove())
        } else {
            e.classList.add("no-heart");
        };
    });
};
