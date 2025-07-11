# yt-dlp-shell

> [!WARNING]
> This tool is a work in progress! It is not complate and will contain bugs.

## About

yt-dlp-shell is a shell script designed to be a cross platform CLI for yt-dlp, while also streamlining the process for users by automatically downloading their platforms binaries when possible and allowing the same instance of the script to be used across multiple platforms

## What can it do?

As of right now, yt-dlp-shell can check for existing installs of FFmpeg and yt-dlp on the users system, user provided binaries in /bin, downloaded binaries for the current platform in /bin, and if it cant find any of those it will download binaries for the correct platform the user is using. It can also check if the URL provided by the user is valid before proceeding further. 

## To-Do

WIP

## Credit

A huge thanks to [Mr. Mendelli](https://github.com/MrMendelli) for their work on [yt-dlp-CLI](https://github.com/MrMendelli/yt-dlp-CLI), from which this project draws huge inspiration from and hopes to make a more cross platform experience of.

Also thanks to [Vidar Holen](https://github.com/koalaman) and all the contributors of [shellcheck](https://github.com/koalaman/shellcheck) for their invaluable resource
