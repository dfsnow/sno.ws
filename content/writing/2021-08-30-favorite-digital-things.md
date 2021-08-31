+++
title = "Favorite digital things"
date = "2021-08-30"
recommended = "false"
+++

_Last updated 2021-08-30_



## Blogs

---

## Posts

---

## Software

Favorite things I use every day

### Android

- [AdGuard](https://adguard.com/en/adguard-android/overview.html) - System-wide adblocking via DNS 
- [Authy](https://authy.com/) - MFA with a nice UI and built-in backups
- [Brew Timer](https://play.google.com/store/apps/details?id=com.apptivity.brewtimer&hl=en_US&gl=US) - Coffee brewing timer for V60/Aeropress
- [Citymapper](https://citymapper.com/?lang=en) - Public transit maps and routing
- [Down Dog](https://www.downdogapp.com/) - Home yoga and HIIT
- [Niagara Launcher](https://play.google.com/store/apps/details?id=bitpit.launcher&hl=en_US&gl=US) - ♥ Minimalist, fast, well-designed launcher
- [StreetComplete](https://github.com/streetcomplete/StreetComplete) - Simple open-source OpenStreetMap data editor
- [SwiftKey](https://play.google.com/store/apps/details?id=com.touchtype.swiftkey&hl=en_US&gl=US) - The best Android keyboard, especially for multi-language support
- [YouTube (Vanced)](https://vancedapp.com/) - YouTube client without ads and annoyances

### Web

- [Chrome](https://www.google.com/chrome/) - Still the fastest browser with the best dev tools
- [Todoist](https://todoist.com/) - ♥ To-do list I've used for over a decade, my favorite app
- [Bitwarden](https://bitwarden.com/) - Open-source password manager, nice CLI integration
- [YNAB](https://www.youneedabudget.com/) - Straightfoward budgeting with bank integration

### Mac

- Transmit
- IINA
- Alfred
- Self-control

### Windows

- Windows Terminal (WSL 2)
- VS Code

### Chrome extensions

- ♥ uBlock Origin
- Earth View
- Bitwarden
- Toolkit for YNAB

### Data 

- sqlite
- postgres
- PostGIS
- QGIS
- Arrow/Parquet
- ZFS

### CLI tools

- hugo
- jq
- ♥ fzf
- ripgrep
- ♥ neovim
- datamash
- stow
- tmux
- pbzip2
- sharp
- ffmpeg

### R packages

<!-- mini script to move hearts to list item bullet if supported -->
<script>
    document.querySelector("article").classList.add('js-enabled')
    var lis = document.querySelectorAll('article.js-enabled ul li')
        oldHTML = 'innerHTML',
        newHTML = '';

    [].forEach.call(lis, function (a) {
        if (a[oldHTML].includes('♥') & CSS.supports('selector(::marker)')) { 
            a.className = 'with-heart';
            newHTML = a[oldHTML].replace('♥', '');
            a[oldHTML] = newHTML;
        };
    });
</script>

<style>
    .js-enabled ul li.with-heart::marker {
      content: '♥  ';  
    }
</style>

