<!-- cSpell:words ANILIST ANIMEPLANET Annict Automail Bangumi choco Darek Goodreads Importability kawai Kitsu MALXML MANGAUPDATES Nautiljon NOTIFYMOE Otak Otaku POSIX pwsh Shikimori SIMKL Trakt traktexport USERID USERPROFILE VNDB -->
<!-- markdownlint-disable MD033 MD034 MD028 -->

<!-- omit in toc -->
# Anime Manga Auto Backup

[![The MIT License](https://img.shields.io/badge/license-MIT-orange.svg?style=for-the-badge)](LICENSE) [![PowerShell](https://img.shields.io/badge/Made_With-PowerShell-blue.svg?style=for-the-badge)](http://github.com/powershell/powershell) [![Discord](https://img.shields.io/discord/589128995501637655?label=Discord&color=%235865F2&logo=discord&logoColor=%23FFFFFF&style=for-the-badge)](https://discord.gg/UKvMEZvaXc)

Automatically (and also manually) backup your anime and manga libraries from [several anime, manga, TV shows, movies, and books tracking sites](#backup-from-x-site). Made possible with PowerShell Core.

> **Warning**
>
> This project requires PowerShell Core 7 or higher.
>
> Please download the latest version from [here](https://github.com/PowerShell/PowerShell/releases), or write this command for Windows 10 and higher on command prompt or Windows PowerShell:\
> `winget install --id Microsoft.PowerShell -e`

<!-- omit in toc -->
## Table of Contents

* [About](#about)
* [Features and To Do](#features-and-to-do)
  * [Legends](#legends)
  * [Backup from `x` site](#backup-from-x-site)
* [Files Generated and Importability](#files-generated-and-importability)
* [Getting Started](#getting-started)
  * [Prerequisites](#prerequisites)
    * [Required softwares/packages for locally run the script](#required-softwarespackages-for-locally-run-the-script)
    * [Run the script by service worker (GitHub Actions)](#run-the-script-by-service-worker-github-actions)
  * [Setting Environment Variables](#setting-environment-variables)
    * [Based on where you run](#based-on-where-you-run)
      * [For Local Machine](#for-local-machine)
        * [Automated](#automated)
        * [Manual](#manual)
      * [For GitHub Actions](#for-github-actions)
* [Variable Keys](#variable-keys)
  * [AniList](#anilist)
  * [Anime-Planet](#anime-planet)
  * [Annict](#annict)
  * [Baka-Updates' Manga Section (MangaUpdates)](#baka-updates-manga-section-mangaupdates)
  * [Bangumi](#bangumi)
  * [Kaize.io](#kaizeio)
  * [Kitsu](#kitsu)
  * [MangaDex](#mangadex)
  * [MyAnimeList](#myanimelist)
  * [Notify.moe](#notifymoe)
  * [Otak Otaku](#otak-otaku)
  * [SIMKL](#simkl)
  * [Shikimori](#shikimori)
  * [Trakt](#trakt)
  * [Visual Novel Database (VNDB)](#visual-novel-database-vndb)
* [Configurations](#configurations)
  * [Network](#network)
  * [Repository](#repository)
  * [Schedule](#schedule)
* [Usage](#usage)
  * [On Local Machine](#on-local-machine)
  * [On GitHub Actions](#on-github-actions)
    * [If the repo is forked](#if-the-repo-is-forked)
    * [If the repo is generated from template](#if-the-repo-is-generated-from-template)

## About

"Anime Manga Auto Backup" is my personal take to automate process in back-up your anime and manga libraries, automatically using worker like GitHub Actions or execute manually from your machine, from MyAnimeList.net, Kitsu, AniList, Annict, Baka-Updates Manga, Shikimori, Anime-Planet, Notify.moe, SIMKL, and Trakt. I use [PowerShell Core](https://github.com/powershell/powershell) to write the script because it is cross-platform and easy to use.

This project **requires you to set the library/list as public** as most API used in this projects are from 3rd party and **User Agent string may required to be filled in environment variable** for the backup progress works.

## Supported Sites

> **Note**
>
> For better readability, any sites that is does not have specific requirements are marked with `-` (dash).

> **Warning**
>
> I am not responsible and liable for warranty for any damage caused by using this project.

| Site Name                                    | Country of Origin    | Languages                                           | Media Type to Backup         |                         FOSS\*                         | Supported |     Method      | Public? |  UA\*?  | PAT\*?  | Notes                                                                                 |
| :------------------------------------------- | :------------------- | :-------------------------------------------------- | :--------------------------- | :----------------------------------------------------: | :-------: | :-------------: | :-----: | :-----: | :-----: | :------------------------------------------------------------------------------------ |
| [AniList](https://anilist.co)                | United Kingdom       | English                                             | Anime, Manga                 |                           -                            |     ✅     |      `API`      |    -    |    -    |    -    |                                                                                       |
| [Anime-Planet](https://www.anime-planet.com) | United States        | English                                             | Anime, Manga                 |                           -                            |     ✅     |      `3PA`      | **Yes** | **Yes** |    -    | Uses MAL Exporter from Azure Website                                                  |
| [Annict](https://annict.com)                 | Japan                | Japanese, English                                   | Anime                        |    [**Yes**](https://github.com/kiraka/annict-web)     |     ✅     |      `API`      |    -    |    -    | **Yes** | User can generate Personal Access Token from account                                  |
| [Baka-Updates](https://www.mangaupdates.com) | United States†       | English                                             | Manga                        |                           -                            |     ✅     |      `API`      |    -    |    -    |    -    | Logging in with API,<br>but CSV/TSV export is undocumented API path                   |
| [Bangumi](https://bgm.tv)                    | China                | Chinese                                             | Anime, Manga, Games, TV Show |     [**Yes**](https://github.com/bangumi/frontend)     |     ✅     |      `API`      |    -    |    -    | **Yes** |                                                                                       |
| [Kaize.io](https://kaize.io)                 | Switzerland†         | English                                             | Anime, Manga                 |                           -                            |     ✅     |    `SCRAPE`     | **Yes** |    -    |    -    | Scrapes user's profile page and lists                                                 |
| [Kitsu](https://kitsu.io)                    | United States        | *Multiple languages*                                | Anime, Manga                 | [**Yes**](https://github.com/hummingbird-me/kitsu-web) |     ✅     |      `API`      |    -    |    -    |    -    |                                                                                       |
| [MangaDex](https://mangadex.org)             | Vietnam†             | English                                             | Manga                        |                           -                            |     ✅     |      `API`      |    -    |    -    |    -    | Will be deprecated soon,<br>2FA-enabled account and OAuth not supported               |
| [MyAnimeList](https://myanimelist.net)       | United States, Japan | English                                             | Anime, Manga                 |                           -                            |     ✅     |      `3PA`      | **Yes** | **Yes** |    -    | Uses MAL Exporter from Azure Website                                                  |
| [Notify.moe](https://notify.moe)             | Korea, Japan         | English                                             | Anime                        | [**Yes**](https://github.com/animenotifier/notify.moe) |     ✅     |      `API`      | **Yes** |    -    |    -    |                                                                                       |
| [Otak Otaku](https://otakotaku.com)          | Indonesia            | Indonesian, Japanese                                | Anime                        |                           -                            |     ✅     |      `API`      | **Yes** | **Yes** |    -    | Uses official undocumented API endpoint                                               |
| [Shikimori](https://shikimori.one)           | Russia               | Russian, English                                    | Anime, Manga                 |   [**Yes**](https://github.com/shikimori/shikimori)    |     ✅     |    `COOKIE`     |    -    | **Yes** |    -    | Uses `_kawai_session` cookie saved on browser                                         |
| [SIMKL](https://simkl.com)                   | United States        | English                                             | TV Show, Movie, Anime        |                           -                            |     ✅     |      `API`      |    -    |    -    |    -    |                                                                                       |
| [Trakt](https://trakt.tv)                    | United States        | English                                             | TV Show, Movie               |                           -                            |     ✅     |      `API`      |    -    |    -    |    -    | Uses `traktexport` Python package/module                                              |
| [VNDB](https://vndb.org)                     | The Netherlands†     | English                                             | Visual Novel (Game)          |     [**Yes**](https://code.blicky.net/yorhel/vndb)     |     ✅     | `API`, `SCRAPE` |    -    | **Yes** | **Yes** | Uses `vndb_auth` cookie saved on browser for XML,<br>JSON uses official API via Token |
|                                              |                      |                                                     |                              |                                                        |           |                 |         |         |         |                                                                                       |
| [9Anime](https://9anime.to)                  | United States†       | English                                             | Anime                        |                           -                            |     🚫     |    `COOKIE`     |    -    | **Yes** |    -    | Unable to bypass security measures put by dev                                         |
| [AniDB](https://anidb.net)                   | Germany†             | English                                             | Anime                        |    [**Yes**](https://git.anidb.net/public/projects)    |     💻     |      `API`      |    -    |    -    |    -    | Currently looking on how to fetch user's MyList safely                                |
| [aniSearch](https://anisearch.com)           | Germany              | German, English, Spanish, French, Italian, Japanese | Anime, Manga, Live Action    |                           -                            |     🔔     |    `SCRAPE`     |    -    |    -    |    -    | Scrapes user's profile page and lists                                                 |
| [Goodreads](https://goodreads.com)           | United States        | English                                             | Book                         |                           -                            |     🔔     |    `SCRAPE`     |    -    |    -    |    -    |                                                                                       |
| [IMDb](https://imdb.com)                     | United States        | English                                             | Movie, TV Show               |                           -                            |     🔔     |    `SCRAPE`     |    -    |    -    |    -    |                                                                                       |
| [LiveChart.me](https://livechart.me)         | United States†       | English                                             | Anime                        |                           -                            |     🚫     |    `SCRAPE`     |    -    |    -    |    -    | Cannot bypass Cloudflare "DDoS protection"/"I'm under attack" mode                    |
| [MyDramaList](https://mydramalist.com)       | United States†       | English                                             | Drama                        |                           -                            |     🔔     |    `SCRAPE`     |    -    |    -    |    -    |                                                                                       |
| [Nautiljon](https://nautiljon.com)           | France               | French                                              | Anime, Manga, Drama          |                           -                            |     🔔     |    `SCRAPE`     |    -    |    -    |    -    |                                                                                       |
| [The Movie Database](https://themoviedb.org) | United States        | English                                             | Movie, TV Show               |                           -                            |     🔔     |      `API`      |    -    |    -    |    -    |                                                                                       |s

<!-- omit in toc -->
### Notes

All column header with `?` in the end means that the site may or may not require it.

* †: Based on IP or ICANN Domain Lookup; as the site did not write contact address on their terms of services and privacy policy, or does not have both.
* \* FOSS: Free and Open Source Software
* \* UA: User Agent
* \* PAT: Personal Access Token
* `Method` Legends:
  * `API`: Uses official API from the site; Python/PowerShell module also fall in this category if it uses official endpoint
  * `3PA`: Uses 3rd party API from other site.
  * `COOKIE`: Uses official (undocumented) API from the site, and cookie may required to be used as authentication (not to be confused with `PAT`)
  * `SCRAPE`: Scrapes user's lists directly from HTML if the site does not have API endpoint, uses Python.
* `Supported` Legends:
  * ✅ : Available
  * 🚫 : Not Available
  * 🔔 : Planned
  * ⌛ : In Development
  * 💻 : Technical difficulty, usually due to pagination or need to scrape XML/HTML table and does not have capability to do so.

## Files Generated and Importability

| Sites Name   | File Saved As                       | MALXML Support | Can Be Imported Back? | Description                                                                                                                    |
| ------------ | ----------------------------------- | -------------- | --------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| AniList      | `.json`, **`.xml`**                 | Yes            | Yes                   | You need to use [Automail] to import back to AniList in JSON, or import to MyAnimeList using XML                               |
| Anime-Planet | **`.xml`**                          | Yes            | Limited               | Backup file is formatted as MyAnimeList XML, some entry might not restored if MAL did not list it                              |
| Annict       | `.json`                             | No             | No                    | There is no official import/export feature                                                                                     |
| Baka-Updates | `.tsv`                              | No             | No                    | There is no official import/export feature                                                                                     |
| Bangumi      | `.json`                             | No             | No                    | There is no official import/export feature                                                                                     |
| Kaize        | `.json`, **`.xml`**                 | Yes            | Yes                   | `.xml` export only available for anime list, `.json` is not importable                                                         |
| Kitsu        | **`.xml`**, `.json`                 | Yes            | Yes                   | YOnly `.xml` can be imported back to MyAnimeList or other that supports MAL XML                                                |
| MangaDex     | `.json`, `.yaml`, **`.xml`**        | Yes            | No                    | Only `.xml` can be imported back to MyAnimeList or other that supports MAL XML                                                 |
| MyAnimeList  | **`.xml`**                          | Yes            | Yes                   | You can reimport back to MyAnimeList                                                                                           |
| Notify.moe   | `.json`, `.csv`, `.txt`, **`.xml`** | Yes            | Limited               | Only `.xml` can be imported back to MyAnimeList or other that supports MAL XML. Reimporting requires MAL, Kitsu, or AL account |
| Otak Otaku   | `.json`, **`.xml`**                 | Yes            | Yes                   | Only `.xml` can be used to import to MyAnimeList and other sites. To reimport back to Otak Otaku, archive `.xml` as `.gz`      |
| Shikimori    | `.json`, **`.xml`**                 | Yes            | Yes                   | You can reimport back to Shikimori or import to MyAnimeList using XML                                                          |
| SIMKL        | `.json`, `.zip`, `.csv`, **`.xml`** | Yes            | Yes                   | Use https://simkl.com/apps/import/json/ and upload ZIP file to import back. `.csv` can be imported on other sites              |
| Trakt        | `.json`                             | No             | No                    | There is no official import/export feature                                                                                     |
| VNDB         | `.json`, `.xml`                     | No             | No                    | There is no official import/export feature                                                                                     |

* **MALXML** in this table refers to a XML format used by MyAnimeList, and is used by some sites to import/export data.
  * Please to check import feature availability on each site. We can not guarantee if the site supports MALXML format by default.

## Features

* [x] Cross-compatible for Windows, Linux, and macOS
* [x] Backup anime/manga list from supported sites
* [x] Backup anime/manga list as MAL XML format, if supported
* [x] Built-in Environment file generator if `.env` file is not found
* [x] Automatically backup by schedule (only for automated method: GitHub Actions)
* [x] Automatically update the script weekly (only for automated method: GitHub Actions)
* [x] Configurable backup and update schedule (only for automated method: GitHub Actions)
* [ ] Global statistic for all sites you have backup
* [ ] Import backup to other sites

## Getting Started

These instructions will get you a copy of the project up and running on your local machine or using GitHub Actions.

### Prerequisites

#### Required softwares/packages for locally run the script

Before starting the script, you need to install the following packages:

* `curl` as fallback for several sites that requires cookies. Native method using `Invoke-WebRequest` sometime failed to append cookies on requests.
* `git`
* PowerShell Core (`pwsh`) version >= 7.0.0
* `python` version >= 3.7

You also need to fork the repository before cloning the repo to your local machine.

#### Run the script by service worker (GitHub Actions)

* [Fork the repository](https://github.com/nattadasu/animeManga-autoBackup/fork) OR [generate new repository using this repository](https://github.com/nattadasu/animeManga-autoBackup/generate)
  * Basically the differences are such:
    |                | Forked                     | Generated from Template                                      |
    | -------------- | :------------------------- | :----------------------------------------------------------- |
    | Commit History | Follows upstream (dirty)   | No previous commit history (clean)                           |
    | GitHub Actions | Disabled by default        | Enabled by default                                           |
    | Update         | Yes                        | Yes, however user requires to generate personal access token |
    | Visibility     | You can not set to Private | You can set to Private                                       |
* Follow instructions on [# For GitHub Actions](#for-github-actions) to set the secrets.

  > **Warning**
  >
  > Do not ever modify [`.env.example`](.env.example) if you did not want your credential revealed by public.
* Follow instruction on [# On GitHub Actions](#on-github-actions) to initialize/run GitHub Actions.

### Setting Environment Variables

#### Based on where you run

##### For Local Machine

###### Automated

* Run from working directory:

  ```ps1
  ./Modules/Environment-Generator.ps1
  ```

* Or, start `./script.ps1`, as the script will run generator automatically if `.env`file can not be found.

###### Manual

1. Duplicate the `.env.example` file and rename to `.env` file.
2. Follow the instructions in [# Variable Keys](#variable-keys) to set the variables.
   * If you did not registered to some site, leave the value empty.

##### For GitHub Actions

1. Open repo settings.
2. On the left sidebar, find "**Secrets**" and click **Actions**.
3. Click <kbd>New repository secret</kbd> button.
4. Follow the instructions in [# Variables Keys](#variable-keys) to set the variables.
   * The text on `code block` in the instruction mean a name, and Value is the key/cookie.
   * Repeat this step for all the variables listed in the instruction.
   * If you did not registered to some site, leave the value empty.

## Variable Keys

### AniList

**Website**: https://anilist.co

<!-- omit in toc -->
#### `ANILIST_USERNAME`

Your AniList username.

<!-- omit in toc -->
#### `ANILIST_CLIENT_ID`

Your AniList Client ID. You can generate one from your account via [Developer Settings](https://anilist.co/settings/developer).

<!-- omit in toc -->
#### `ANILIST_CLIENT_SECRET`

Your AniList Client Secret. You can generate one from your account via [Developer Settings](https://anilist.co/settings/developer).

<!-- omit in toc -->
#### `ANILIST_REDIRECT_URI`

Your AniList Redirect URI. Must be `https://anilist.co/api/v2/oauth/pin`.

<!-- omit in toc -->
#### `ANILIST_ACCESS_TOKEN`, `ANILIST_OAUTH_REFRESH`, `ANILIST_OAUTH_EXPIRES`

Your AniList Access Token, Refresh Token and Expires.

To get them, please fill your `ANILIST_CLIENT_ID`, `ANILIST_CLIENT_SECRET` and `ANILIST_REDIRECT_URI` in your ENV file and init/run [`./Modules/Get-AniListAuth.ps1`](./Modules/Get-AniListAuth.ps1), then follow the instructions.

### Anime-Planet

**Website**: https://anime-planet.com

> **Warning**
>
> This method requires [# User Agent](#network) configured properly

<!-- omit in toc -->
#### `ANIMEPLANET_USERNAME`

Your Anime-Planet username.

### Annict

**Website**: https://annict.com | https://en.annict.com | https://annict.jp

<!-- omit in toc -->
#### `ANNICT_PERSONAL_ACCESS_TOKEN`

Your Annict Personal Access Token. You can generate one from your account via [Application Settings](https://en.annict.com/settings/apps).

### Baka-Updates' Manga Section (MangaUpdates)

**Website**: https://mangaupdates.com

> **Warning**
>
> This method requires [# User Agent](#network) configured properly

<!-- omit in toc -->
#### `MANGAUPDATES_SESSION`

> **Warning**
>
> This environment variable/secret is deprecated, use [# `MANGAUPDATES_USERNAME`](#mangaupdates_username) and [# `MANGAUPDATES_PASSWORD`](#mangaupdates_password)

Your Baka-Updates session cookie. To get it, tap F12 or "Inspect Page" when right-clicking the site, open "Storage" tab, and click "Cookies" of the site.

Find a name of the cookie that starts with `secure_session` and copy the value.

<!-- omit in toc -->
#### `MANGAUPDATES_USERNAME`

Your Baka-Updates username used to login.

<!-- omit in toc -->
#### `MANGAUPDATES_PASSWORD`

Your Baka-Updates password used to login.

### Bangumi

**Website**: https://bgm.tv

<!-- omit in toc -->
#### `BANGUMI_PERSONAL_ACCESS_TOKEN`

Your Bangumi Personal Access Token. You can generate one from your account via [Token Generator](https://next.bgm.tv/demo/access-token).

<!-- omit in toc -->
#### `BANGUMI_PAT_EXPIRY`

Your Bangumi Personal Access Token expiry date in `yyyy-MM-dd` format.

<!-- omit in toc -->
#### `BANGUMI_USERNAME`

Your Bangumi username.

### Kaize.io

**Website**: https://kaize.io

<!-- omit in toc -->
#### `KAIZE_USERNAME`

Your Kaize.io username, located on the URL of your profile page.

Example:

```text
https://kaize.io/username
                 ^^^^^^^^
```

### Kitsu

**Website**: https://kitsu.io

<!-- omit in toc -->
#### `KITSU_EMAIL`

Your Kitsu email used to login.

<!-- omit in toc -->
#### `KITSU_PASSWORD`

Your Kitsu password used to login.

### MangaDex

**Website**: https://mangadex.org

> **Warning**
>
> This method (login via <u>raw password</u>) would be deprecated in future!
> There is no ETA to implement OAuth2 using OpenID.
> See more regarding to the issue at [MangaDex Announcement Discord Server (#api-changelog)](https://discord.com/channels/833598287574990850/850131706022461440/1050086432011731034).

> **Warning**
>
> 2FA-enabled account is not supported!

<!-- omit in toc -->
#### `MANGADEX_USERNAME`

Your MangaDex username.

<!-- omit in toc -->
#### `MANGADEX_PASSWORD`

Your MangaDex password.

### MyAnimeList

**Website**: https://myanimelist.net

> **Warning**
>
> This method requires [# User Agent](#network) configured properly

<!-- omit in toc -->
#### `MAL_USERNAME`

Your MyAnimeList username.

### Notify.moe

**Website**: https://notify.moe

<!-- omit in toc -->
#### `NOTIFYMOE_NICKNAME`

Your Notify.moe nickname/username, string should be `Upper-first case`.

### Otak Otaku

**Website**: https://otakotaku.com

> **Warning**
>
> This method requires [# User Agent](#network) configured properly

<!-- omit in toc -->
#### `OTAKOTAKU_USERNAME`

Your Otak Otaku username.

### SIMKL

**Website**: https://simkl.com

<!-- omit in toc -->
#### `SIMKL_ACCESS_TOKEN`

Your SIMKL access token. To get it, please fill your `SIMKL_CLIENT_ID` and init/run [`./Get-SimklAuth.ps1`](./Modules/Get-SimklAuth.ps1), then follow the instructions.

<!-- omit in toc -->
#### `SIMKL_CLIENT_ID`

Your SIMKL Client ID. To get it, [create new app on SIMKL](https://simkl.com/settings/developer/new/), and set for redirection URI to `urn:ietf:wg:oauth:2.0:oob`.

### Shikimori

**Website**: https://shikimori.one

> **Warning**
>
> This method requires [# User Agent](#network) configured properly

<!-- omit in toc -->
#### `SHIKIMORI_KAWAI_SESSION`

Your Shikimori session cookie. To get it, tap F12 or "Inspect Page" when right-clicking the site, open "Storage" tab, and click "Cookies" of the site.

Find a name of the cookie that starts with `_kawai_session` and copy the value.

### Trakt

**Website**: https://trakt.tv

<!-- omit in toc -->
#### `TRAKT_CLIENT_ID`

Your Trakt Client ID. To get it, go to [Trakt](https://trakt.tv/oauth/applications) and click "Create New Application". Set `urn:ietf:wg:oauth:2.0:oob` as `Redirect URIs`.

<!-- omit in toc -->
#### `TRAKT_CLIENT_SECRET`

Your Trakt Client Secret.

<!-- omit in toc -->
#### `TRAKT_OAUTH_EXPIRY`, `TRAKT_OAUTH_REFRESH`, `TRAKT_OAUTH_TOKEN`

Your Trakt credential saved by `traktexport` Python module.

To get it, run `traktexport init <username>` with `<username>` is your Trakt username, if not installed, run `pip install traktexport` from terminal.

Follow instructions from the module, pasting in your Client ID/Secret from the Trakt dashboard, going to the link and pasting the generated pin back into the terminal.

After init done, run `type .traktexport\traktexport.json` in `~`/`%USERPROFILE%` directory on Windows or `cat ~/.local/share/traktexport.json` on POSIX system (Linux/macOS) to copy the credential.

<!-- omit in toc -->
#### `TRAKT_USERNAME`

Your Trakt username.

### Visual Novel Database (VNDB)

**Website**: https://vndb.org

> **Warning**
>
> This method requires [# User Agent](#network) configured properly

<!-- omit in toc -->
#### `VNDB_AUTH`

Your VNDB session cookie. To get it, tap F12 or "Inspect Page" when right-clicking the site, open "Storage" tab, and click "Cookies" of the site.

  Find a name of the cookie that starts with `vndb_auth` and copy the value.

<!-- omit in toc -->
#### `VNDB_UID`

Your VNDB user ID. To get it, click on any links that stated with "My" or your username, and copy the fragment of your URL that is started with letter "u" and ID number after it.

  For example:

  ```py
  https://vndb.org/u123456/ulist?vnlist=1
                   ^^^^^^^
  ```

  `u12345` is your UID.

<!-- omit in toc -->
#### `VNDB_TOKEN`

Your VNDB token. To grab VNDB Personal Access Token, Go to your profile, click on `Edit` tab, and click on `Application` tab.

Click on `New token` button, set application name, check **Access to my list (including private items)**, and click `Submit` button below.

Copy the token from textbox and paste it below.

The token should be 38 characters long.

## Configurations

The script allows user modify additional configurations. The configurations saved in `.env` file for local, and GitHub's Repository Secrets for automated process using GitHub Actions.

Below are the keys of allowed configurations

### Network

<!-- omit in toc -->
#### `USER_AGENT`

> **Warning**
>
> This key is required for
> [# Anime-Planet](#anime-planet),
> [# Baka-Updates' Manga Section (MangaUpdates)](#baka-updates-manga-section-mangaupdates),
> [# MyAnimeList](#myanimelist),
> [# Otak Otaku](#otak-otaku),
> [# Shikimori](#shikimori),
> [# Visual Novel Database (VNDB)](#visual-novel-database-vndb)

Your user agent. This field is required for some sites. You can get your current user agent from [WhatIsMyBrowser.com](https://www.whatismybrowser.com/detect/what-is-my-user-agent/)

### Repository

<!-- omit in toc -->
#### `MINIFY_JSON`

**Default Config**: `False`\
**Options**: `False`, `True`

Minify a JSON file for less storage space, not recommended if the file was intended to be checked manually or using `git diff`.

<!-- omit in toc -->
#### `REPO_PAT`

> **Warning**
>
> Required for GitHub Actions

Your GitHub Personal Access Token to update repo from [Settings / Developer Settings / Personal Access Tokens](https://github.com/settings/tokens/new). Enable `workflow` option and set expiration date more than a month.

However, you are not needed to add `REPO_PAT` in your Environment File if you run the script locally.

### Schedule

<!-- omit in toc -->
#### `BACKUP_FREQ`

**Default Config**: `0 0 * * SUN`

Tell GitHub Actions to do backup at the time scheduled, formatted in CRON.

<!-- omit in toc -->
#### `UPDATE_FREQ`

**Default Config**: `0 0 * * *`

Tell GitHub Actions to check and update scripts and several components, formatted in CRON.

## Usage

### On Local Machine

1. Open Command Prompt/Terminal, type `pwsh`.
2. Change directory to the directory where you cloned the project.
3. Type `./script.ps1`, and let the script run by itself.

### On GitHub Actions

#### If the repo is forked

1. Open Actions tab.
2. Opt in the feature to enable.
3. Done.

#### If the repo is generated from template

* Done. Basically, the Action is enabled by default.

> **Note**
>
> The script will automatically run at 0:00 AM UTC every Sunday, or you can trigger manually from dispatch.

<!-- Links -->
[Automail]: https://greasyfork.org/en/scripts/370473-automail
