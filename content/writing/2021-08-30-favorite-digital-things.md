+++
title = "Favorite digital things"
date = "2021-08-30"
shorturl = "digital-things"
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

- [Bitwarden](https://bitwarden.com/) - Open-source password manager. Nice CLI integration
- [Chrome](https://www.google.com/chrome/) - Still the fastest browser with the best dev tools
- [Todoist](https://todoist.com/) - ♥ To-do list I've used for over a decade, my favorite app
- [YNAB](https://www.youneedabudget.com/) - Straightfoward budgeting with bank integration

### Mac

- [Alfred](https://www.alfredapp.com/) - Customizable spotlight with great plugins
- [IINA](https://github.com/iina/iina) - Great mac alternative to VLC
- [SelfControl](https://selfcontrolapp.com/) - Edit /etc/hosts to block distracting sites
- [Transmit](https://panic.com/transmit/) - Fast file transfers with an awesome UI

### Windows

- [VS Code](https://code.visualstudio.com/) - IDE when neovim or RStudio don't cut it
- [Windows Terminal + WSL 2](https://docs.microsoft.com/en-us/windows/wsl/install-win10) - ♥ Linux virtualization on Windows that just works

### Chrome extensions

- [uBlock Origin](https://github.com/gorhill/uBlock) - The best wide-spectrum blocker around. Use it to block all JS
- [Earth View](https://chrome.google.com/webstore/detail/earth-view-from-google-ea/bhloflhklmhfpedakmangadcdofhnnoh) - Pretty satellite pictures for your new tab page
- [Toolkit for YNAB](https://github.com/toolkit-for-ynab/toolkit-for-ynab) - QoL and reporting improvements for YNAB

### Data 

- [LightGBM](https://github.com/microsoft/LightGBM) - Incredible tree-based ML framework. Better than xgboost
- [Parquet](https://parquet.apache.org/) - Fast, space-efficient columnar storage format
- [Postgres](https://www.postgresql.org/) - My preferred RDBMS for any project with structured data
- [PostGIS](https://postgis.net/) - Spatial data extension for Postgres
- [RStudio](https://www.rstudio.com/) - IDE specifically for R (and some Python)
- [SQLite](https://www.sqlite.org/) - 
- [ZFS](https://zfsonlinux.org/) - Filesystem for storage pooling and management

### CLI tools

- datamash
- ffmpeg
- fzf ♥
- hugo
- jq
- neovim ♥ 
- pbzip2
- ripgrep
- sharp
- stow
- tmux

### R packages

- dplyr
- lubridate
- data.table
- ggplot2
- tidycensus
- tidytransit
- purrr
- renv
- sf
- lightgbm

<!-- mini script to move hearts to list item bullet if JS supported -->
<script>
    document.querySelector('article').classList.add('js-enabled')
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
      color: darkred;
    }
</style>

