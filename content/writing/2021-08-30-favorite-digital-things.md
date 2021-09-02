+++
title = "Favorite digital things"
date = "2021-08-30"
shorturl = "digital-things"
recommended = "false"
+++




## Blogs

- https://macwright.com/
- https://jvns.ca/
- https://cassidoo.co/
- https://jeremymaluf.com/things/
- https://www.joelsimon.net/
- https://beaugunderson.com/
- https://juliasilge.com/
- https://josh.works/
- https://www.mattkeeter.com/projects/
- http://danluu.com/
- https://rebeccawilliams.us/
- https://blog.cleverelephant.ca/
- https://www.akshayagrawal.com/
- https://tjukanov.org/


---

## Posts

---

## Software

- lean toward fast, self-contained, does one thing well
- Final list after about 10 years of dev
- Not exhaustive, but pretty close

### Android

- [AdGuard](https://adguard.com/en/adguard-android/overview.html) - System-wide adblocking via DNS 
- [Authy](https://authy.com/) - MFA with a nice UI and built-in backups
- [Brew Timer](https://play.google.com/store/apps/details?id=com.apptivity.brewtimer&hl=en_US&gl=US) - Coffee brewing timer for V60/Aeropress
- [Citymapper](https://citymapper.com/?lang=en) - Public transit maps and routing
- [Down Dog](https://www.downdogapp.com/) - Procedurally-generated at-home yoga and HIIT
- [Niagara Launcher](https://play.google.com/store/apps/details?id=bitpit.launcher&hl=en_US&gl=US) - ♥ Minimalist, fast, well-designed launcher
- [StreetComplete](https://github.com/streetcomplete/StreetComplete) - Easy-to-use, open-source OpenStreetMap data editor
- [YouTube (Vanced)](https://vancedapp.com/) - YouTube client without ads and annoyances

### Web

- [Bitwarden](https://bitwarden.com/) - Open-source password manager. Great CLI integration
- [Chrome](https://www.google.com/chrome/) - Browser with good devtools ¯\\\_(ツ)\_/¯
- [Todoist](https://todoist.com/) - ♥ To-do list I've used for over a decade. My favorite app
- [YNAB](https://www.youneedabudget.com/) - Straightforward budgeting with bank integration

### Mac

- [Alfred](https://www.alfredapp.com/) - Customizable Spotlight alternative with great plugins
- [IINA](https://github.com/iina/iina) - Minimal Mac-only alternative to VLC
- [SelfControl](https://selfcontrolapp.com/) - Uncircumventable distracting site blocker
- [Transmit](https://panic.com/transmit/) - Fast, versatile file transfer utility

### Windows

- [VS Code](https://code.visualstudio.com/) - Big IDE for when neovim or RStudio don't cut it
- [Windows Terminal + WSL 2](https://docs.microsoft.com/en-us/windows/wsl/install-win10) - ♥ Linux virtualization on Windows that just works

### Chrome extensions

- [uBlock Origin](https://github.com/gorhill/uBlock) - Best wide-spectrum blocker. Fast, lightweight, can block all JS
- [Earth View](https://chrome.google.com/webstore/detail/earth-view-from-google-ea/bhloflhklmhfpedakmangadcdofhnnoh) - Pretty satellite pictures for your new tab page
- [Toolkit for YNAB](https://github.com/toolkit-for-ynab/toolkit-for-ynab) - QoL and reporting improvements for YNAB

### Other 

- [LightGBM](https://github.com/microsoft/LightGBM) - Incredible tree-based ML framework. Better than xgboost
- [Parquet](https://parquet.apache.org/) - Fast, space-efficient columnar storage format
- [Postgres](https://www.postgresql.org/) - Preferred RDBMS for any project with structured data
- [PostGIS](https://postgis.net/) - Spatial data extension for Postgres
- [RStudio](https://www.rstudio.com/) - Great IDE specifically for R (and now some Python)
- [Wireguard](https://www.wireguard.com/) - Miracle VPN. Crazy fast and easy-to-use
- [ZFS](https://zfsonlinux.org/) - Filesystem for storage pooling and management

### CLI tools

- [datamash](https://www.gnu.org/software/datamash/) - Sort, group by, summarize, transpose, etc. in the command line 
- [ffmpeg](https://ffmpeg.org/) - Multimedia toolkit for just about everything
- [fzf](https://github.com/junegunn/fzf) - ♥ Blazingly fast fuzzy finding. Why `cd` when you can `Alt-C`?
- [hugo](https://gohugo.io/) - Simple, self-contained static site builder. Used to make this site
- [neovim](https://github.com/neovim/neovim) - Text editor of choice. Config and plugins also work with vim
- [ripgrep](https://github.com/BurntSushi/ripgrep) - ♥ `grep` but better. Search every file in a directory in milliseconds
- [stow](https://www.gnu.org/software/stow/manual/stow.html) - Symlink, config, and dotfiles management
- [tmux](https://github.com/tmux/tmux) - Terminal multiplexer + keep remote terminal sessions alive 
- [zstd](https://github.com/facebook/zstd) - Compression algorithm of choice. Replaced bzip2 as a favorite

### R packages

- [data.table](https://github.com/Rdatatable/data.table) - ♥ Impossible data manipulation magic. Faster than everything else 
- [dplyr](https://dplyr.tidyverse.org/) - Clear, intuitive data munging that plays well with other libraries
- [lubridate](https://lubridate.tidyverse.org/) - Intuitive, consistent date-time handling. Save yourself from footguns
- [ggplot2](https://ggplot2.tidyverse.org/) - _The_ plotting lib for R. Blows matplotlib (and many others) out of the water
- [renv](https://rstudio.github.io/renv/) - Wonderful environment/package manager for R (finally)
- [sf](https://r-spatial.github.io/sf/) - Geospatial manipulation, maps, and geometry features
- [tidycensus](https://walker-data.com/tidycensus/) - Useful interface for the Census API
- [tidytransit](https://github.com/r-transit/tidytransit) - GTFS feed reader. Make [trains go brrr](https://sno.ws/transit-maps)

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

_Last updated 2021-08-30_
