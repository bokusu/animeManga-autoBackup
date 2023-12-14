<!-- cSpell:disable -->
<!-- markdownlint-disable MD013 MD033 MD034 MD028 -->

> <!-- omit in toc -->
> # Early Deprecation Notice
>
> This PowerShell script repository for backing up your data is about to be
> deprecated in favor of a newly rewritten Python executable module that you
> can install directly with PIP and that is much easier to update.
>
> At the time of this writing, the project is under development and does not
> have a production release date. Have a look at the [`hikaru-aegis`](https://github.com/Animanga-Initiative/hikaru-aegis)
> repo to see the progress.
>
> Once the module is completed, this repository will be archived, won't get
> updated and supported, and will have a deprecation note in your script's
> log. We will provide instructions for migrating in this repo and as well
> in `hikaru-aegis`.

<!-- omit in toc -->
# Anime Manga Auto Backup

[![The MIT License](https://img.shields.io/badge/license-MIT-orange.svg?style=for-the-badge)](LICENSE)
[![PowerShell](https://img.shields.io/badge/Made_With-PowerShell-blue.svg?style=for-the-badge)](http://github.com/powershell/powershell)
[![Discord](https://img.shields.io/discord/589128995501637655?label=Discord&color=%235865F2&logo=discord&logoColor=%23FFFFFF&style=for-the-badge)](https://discord.gg/UKvMEZvaXc)

Automatically (and also manually) backup your anime and manga libraries from
[several anime, manga, TV shows, movies, and books tracking sites](#supported-sites).
Made possible with PowerShell Core.

> **Warning**
>
> This project requires PowerShell Core 7 or higher.
>
> Please download the latest version from [here](https://github.com/PowerShell/PowerShell/releases),
> or write this command for Windows 10 and higher on command prompt or Windows PowerShell:\
> `winget install --id Microsoft.PowerShell -e`

<!-- omit in toc -->
## Table of Contents

* [About](#about)
* [Supported Sites](#supported-sites)
* [Files Generated and Importability](#files-generated-and-importability)
* [Features](#features)
  * [Wayback Machine Snapshot](#wayback-machine-snapshot)
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
  * [Wayback Machine Integration](#wayback-machine-integration)
* [Usage](#usage)
  * [On Local Machine](#on-local-machine)
  * [On GitHub Actions](#on-github-actions)
    * [If the repo is forked](#if-the-repo-is-forked)
    * [If the repo is generated from template](#if-the-repo-is-generated-from-template)

## About

"Anime Manga Auto Backup" is my personal take to automate process in back-up
your anime and manga libraries, automatically using worker like GitHub Actions
or execute manually from your machine, from MyAnimeList.net, Kitsu, AniList,
Annict, Baka-Updates Manga, Shikimori, Anime-Planet, Notify.moe, SIMKL, and
Trakt. I use [PowerShell Core](https://github.com/powershell/powershell) to
write the script because it is cross-platform and easy to use.

This project **requires you to set the library/list as public** as most API used
in this projects are from 3rd party and **User Agent string may required to be
filled in environment variable** for the backup progress works.

## Supported Sites

> **Note**
>
> For better readability, any sites that is does not have specific requirements
> are marked with `-` (dash).

> **Warning**
>
> I am not responsible and liable for warranty for any damage caused by using
> this project.

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
| [LiveChart.me](https://livechart.me)         | United States†       | English                                             | Anime                        |                           -                            |     🚫     |    `API`     |    -    |    -    |    -    | Cannot bypass Cloudflare "DDoS protection"/"I'm under attack" mode, whatever method is                    |
| [MyDramaList](https://mydramalist.com)       | United States†       | English                                             | Drama                        |                           -                            |     🔔     |    `SCRAPE`     |    -    |    -    |    -    |                                                                                       |
| [Nautiljon](https://nautiljon.com)           | France               | French                                              | Anime, Manga, Drama          |                           -                            |     🚫     |    `SCRAPE`     |    -    |    -    |    -    | Cannot bypass Cloudflare "DDoS protection"/"I'm under attack" mode                    |
| [The Movie Database](https://themoviedb.org) | United States        | English                                             | Movie, TV Show               |                           -                            |     🔔     |      `API`      |    -    |    -    |    -    |                                                                                       |

<!-- omit in toc -->
### Notes

All column header with `?` in the end means that the site may or may not require
it.

* †: Based on IP or ICANN Domain Lookup; as the site did not write contact
  address on their terms of services and privacy policy, or does not have both.
* \* FOSS: Free and Open Source Software
* \* UA: User Agent
* \* PAT: Personal Access Token
* `Method` Legends:
  * `API`: Uses official API from the site; Python/PowerShell module also fall
    in this category if it uses official endpoint
  * `3PA`: Uses 3rd party API from other site.
  * `COOKIE`: Uses official (undocumented) API from the site, and cookie may
    required to be used as authentication (not to be confused with `PAT`)
  * `SCRAPE`: Scrapes user's lists directly from HTML if the site does not have
    API endpoint, uses Python.
* `Supported` Legends:
  * ✅ : Available
  * 🚫 : Not Available
  * 🔔 : Planned
  * ⌛ : In Development
  * 💻 : Technical difficulty, usually due to pagination or need to scrape
    XML/HTML table and does not have capability to do so.

## Files Generated and Importability

> **Note**
>
> For better readability, any sites that is does not have capability are marked
> with `-` (dash).

| Site Name    | File Saved As                       | MALXML Support | Can Be Imported Back? | Description                                                                                                                 |
| ------------ | ----------------------------------- | :------------: | :-------------------: | --------------------------------------------------------------------------------------------------------------------------- |
| AniList      | `.json`, **`.xml`**                 |      Yes       |          Yes          | You need to use [Automail] to import back to AniList in JSON. XML can be used for AniList, MyAnimeList, or other            |
| Anime-Planet | **`.xml`**                          |      Yes       |        Limited        | Backup file is formatted as MyAnimeList XML, some entry might not restored if MAL did not list it                           |
| Annict       | `.json`                             |       -        |           -           | -                                                                                                                           |
| Baka-Updates | `.tsv`                              |       -        |           -           | -                                                                                                                           |
| Bangumi      | `.json`                             |       -        |           -           | -                                                                                                                           |
| Kaize        | `.json`, **`.xml`**                 |      Yes       |          Yes          | `.xml` export only available for anime list, `.json` is not importable                                                      |
| Kitsu        | **`.xml`**, `.json`                 |      Yes       |          Yes          | Only `.xml` can be imported back to MyAnimeList or other                                                                    |
| MangaDex     | `.json`, `.yaml`, **`.xml`**        |      Yes       |           -           | Only `.xml` can be imported back to MyAnimeList or other                                                                    |
| MyAnimeList  | **`.xml`**                          |      Yes       |          Yes          | You can reimport back to MyAnimeList                                                                                        |
| Notify.moe   | `.json`, `.csv`, `.txt`, **`.xml`** |      Yes       |        Limited        | Only `.xml` can be imported back to MyAnimeList or other. Reimporting requires MAL, Kitsu, or AL account                    |
| Otak Otaku   | `.json`, **`.xml`**                 |      Yes       |          Yes          | To reimport back to Otak Otaku, archive manually `.xml` as `.gz`, plain `.xml` only can be imported to MyAnimeList or other |
| Shikimori    | `.json`, **`.xml`**                 |      Yes       |          Yes          | You can reimport back to Shikimori using both formats or import to MyAnimeList and other sites using XML                    |
| SIMKL        | `.json`, `.zip`, `.csv`, **`.xml`** |      Yes       |          Yes          | Use https://simkl.com/apps/import/json/ and upload ZIP file to import back. `.csv` can be imported on other sites           |
| Trakt        | `.json`                             |       -        |           -           | -                                                                                                                           |
| VNDB         | `.json`, `.xml`                     |       -        |           -           | **Export as `.json` only for manual/local backup**, GitHub Actions can not invoke the request due to unknown error          |

* **MALXML** in this table refers to a XML format used by MyAnimeList, and is
  used by some sites to import/export data.
  * Please to check import feature availability on each site. We can not
    guarantee if the site supports MALXML format by default.

## Features

* [x] Cross-compatible for Windows, Linux, and macOS
* [x] Backup anime/manga list from supported sites
* [x] Backup anime/manga list as MAL XML format, if supported
* [x] Built-in Environment file generator if `.env` file is not found
* [x] Automatically backup by schedule (only for automated method: GitHub Actions)
* [x] Automatically update the script weekly (only for automated method: GitHub Actions)
* [x] Configurable backup and update schedule (only for automated method: GitHub
  Actions)
* [x] Save snapshots (profile, lists, statistics) of supported sites using
  [Wayback Machine](https://archive.org/web/).
* [ ] Global statistic for all sites you have backup
* [ ] Import backup to other sites

### Wayback Machine Snapshot

> **Warning**
>
> This method is **very slow** and might take hours to finish. Use with care.
> Recommended to run this only on your local machine.

This repo supports snapshotting your profile, lists, and even statistics of your
media progress in supported sites using Internet Archive's Wayback Machine,
thanks to [waybackpy](https://github.com/akamhy/waybackpy).

By enabling the snapshot support by changing value `WAYBACK_ENABLE` to `True`
means your profile from all snapshot-supported sites must be visible to public.

| Site Name    | Supported? | Notes                   | Coverage                                                 |
| ------------ | :--------: | ----------------------- | -------------------------------------------------------- |
| AniList      |     -      | Page was returned blank | -                                                        |
| Anime-Planet |    Yes     | -                       | Profile, anime, manga                                    |
| Annict       |    Yes     | -                       | Profile, anime                                           |
| Bangumi      |    Yes     | -                       | Profile, anime, manga, game, drama                       |
| Kaize        |    Yes     | -                       | Profile, anime, manga, stats, KP, badges                 |
| Kitsu        |    Yes     | -                       | Profile, anime, manga                                    |
| MangaDex     |     -      | User profile is private | -                                                        |
| MangaUpdates |    Yes     | -                       | Profile                                                  |
| MyAnimeList  |    Yes     | -                       | Profile, anime, manga. history                           |
| Notify.moe   |    Yes     | -                       | Profile, anime                                           |
| Otak Otaku   |    Yes     | -                       | Profile                                                  |
| Shikimori    |    Yes     | -                       | Profile, anime, manga, achievements                      |
| SIMKL        |    Yes     | -                       | Profile, anime, TV, movies, stats                        |
| Trakt        |    Yes     | -                       | Profile, stats, history, progress, collection, watchlist |
| VNDB         |    Yes     | -                       | Profile, games, wishlist                                 |

You also can contribute to Internet Archive's Wayback Machine to snapshot
homepage of supported sites on this repo by modifying `WAYBACK_SNAPMAINSITE`
variable on `.env` file to `True`.

## Getting Started

These instructions will get you a copy of the project up and running on your
local machine or using GitHub Actions.

### Prerequisites

#### Required softwares/packages for locally run the script

Before starting the script, you need to install the following packages:

* `curl` as fallback for several sites that requires cookies. Native method
  using `Invoke-WebRequest` sometime failed to append cookies on requests.
* `git`
* PowerShell Core (`pwsh`) version >= 7.0.0
* `python` version >= 3.7

You also need to fork the repository before cloning the repo to your local machine.

#### Run the script by service worker (GitHub Actions)

* [Fork the repository](https://github.com/nattadasu/animeManga-autoBackup/fork)
  OR [generate new repository using this repository](https://github.com/nattadasu/animeManga-autoBackup/generate)
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
  > Do not ever modify [`.env.example`](.env.example) if you did not want your
  > credential revealed by public.
* Follow instruction on [# On GitHub Actions](#on-github-actions) to
  initialize/run GitHub Actions.

### Setting Environment Variables

#### Based on where you run

##### For Local Machine

###### Automated

* Start `./script.ps1` as the script will run generator automatically if `.env`file can not be found.

* Or, run the generator directly from working directory:

  ```ps1
  ./Modules/Environment-Generator.ps1
  ```

###### Manual

1. Duplicate the `.env.example` file and rename to `.env` file.
2. Follow the instructions in [# Variable Keys](#variable-keys) to set the variables.
   * If you did not registered to some site, leave the value empty.

##### For GitHub Actions

1. Open repo settings.
2. On the left sidebar, find "**Secrets**" and click **Actions**.
3. Click <kbd>New repository secret</kbd> button.
4. Follow the instructions in [# Variables Keys](#variable-keys) to set the
   variables.
   * The text on `code block` in the instruction mean a name, and Value is
     the key/cookie.
   * Repeat this step for all the variables listed in the instruction.
   * If you did not registered to some site, leave the value empty.

## Variable Keys

### AniList

**Website**: https://anilist.co

| Variable Name           | Description                                                                                                                                     | Value Type                           | Example                                    |
| ----------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------ | ------------------------------------------ |
| `ANILIST_USERNAME`      | AniList username                                                                                                                                | String                               | `nattadasu`                                |
| `ANILIST_CLIENT_ID`     | AniList Client ID for API access.<br>You can generate one from your account via [Developer Settings](https://anilist.co/settings/developer)     | Integer                              | `1234`                                     |
| `ANILIST_CLIENT_SECRET` | AniList Client Secret for API access.<br>You can generate one from your account via [Developer Settings](https://anilist.co/settings/developer) | String, 40 characters case sensitive | `AB12cd34EF56gh78IJ90kl12MN34op56QR78st90` |
| `ANILIST_REDIRECT_URI`  | AniList Redirect URI for API access.<br>Must be `https://anilist.co/api/v2/oauth/pin`                                                           | String, URI                          | `https://anilist.co/api/v2/oauth/pin`      |
| `ANILIST_ACCESS_TOKEN`  | AniList Access Token to your account.<br>Must be generated by [`./Modules/Get-AniListAuth.ps1`](./Modules/Get-AniListAuth.ps1)                  | String, JWT format                   | `eyJ0...`                                  |
| `ANILIST_OAUTH_REFRESH` | AniList account refresh token<br>Must be generated by [`./Modules/Get-AniListAuth.ps1`](./Modules/Get-AniListAuth.ps1)                          | String                               | `def...`                                   |
| `ANILIST_OAUTH_EXPIRES` | AniList account refresh token expiration time<br>Must be generated by [`./Modules/Get-AniListAuth.ps1`](./Modules/Get-AniListAuth.ps1)          | Integer, Epoch/Unix timestamp        | `1234567890`                               |

* To get `ANILIST_ACCESS_TOKEN`, `ANILIST_OAUTH_REFRESH` and
  `ANILIST_OAUTH_EXPIRES`, you need to generate them first.

  To generate them, please fill your `ANILIST_CLIENT_ID`,
  `ANILIST_CLIENT_SECRET` and `ANILIST_REDIRECT_URI` in your ENV file and
  init/run [`./Modules/Get-AniListAuth.ps1`](./Modules/Get-AniListAuth.ps1),
  then follow the instructions.

### Anime-Planet

**Website**: https://anime-planet.com

> **Warning**
>
> This method requires [# User Agent](#network) configured properly

| Variable Name          | Description           | Value Type | Example     |
| ---------------------- | --------------------- | ---------- | ----------- |
| `ANIMEPLANET_USERNAME` | Anime-Planet username | String     | `nattadasu` |

### Annict

**Website**: https://annict.com | https://en.annict.com | https://annict.jp

| Variable Name                  | Description                                                                                                   | Value Type | Example                         |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------- | ---------- | ------------------------------- |
| `ANNICT_PERSONAL_ACCESS_TOKEN` | Annict Personal Access Token<br>Get the token via [Application Settings](https://en.annict.com/settings/apps) | String     | `f0O84r_Ba37h15I50u111yT3xt...` |

### Baka-Updates' Manga Section (MangaUpdates)

**Website**: https://mangaupdates.com

> **Warning**
>
> This method requires [# User Agent](#network) configured properly

| Variable Name           | Description           | Value Type | Example                  |
| ----------------------- | --------------------- | ---------- | ------------------------ |
| `MANGAUPDATES_USERNAME` | Baka-Updates username | String     | `nattadasu`              |
| `MANGAUPDATES_PASSWORD` | Baka-Updates password | String     | `5up3rS3Cure_-_P@sSwOrd` |

### Bangumi

**Website**: https://bgm.tv

| Variable Name                   | Description                                                                                                                                                                    | Value Type | Example                        |
| ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------- | ------------------------------ |
| `BANGUMI_PERSONAL_ACCESS_TOKEN` | Bangumi Personal Access Token<br>Token must be valid for 1 year (365天) maximum. Generate by [Token Generator](https://next.bgm.tv/demo/access-token) and click “查看所有令牌” | String     | `f0O84rBa37h15I50u111yT3xt...` |
| `BANGUMI_PAT_EXPIRY`            | Bangumi Personal Access Token expiry date in `yyyy-MM-dd` format                                                                                                               | String     | `2021-12-31`                   |
| `BANGUMI_USERNAME`              | Bangumi username                                                                                                                                                               | String     | `nattadasu`                    |

### Kaize.io

**Website**: https://kaize.io

| Variable Name    | Description       | Value Type | Example     |
| ---------------- | ----------------- | ---------- | ----------- |
| `KAIZE_USERNAME` | Kaize.io username | String     | `nattadasu` |

* Username can be obtained from the URL of your profile page.

  Example:

  ```text
  https://kaize.io/user/username
                        ^^^^^^^^
  ```

### Kitsu

**Website**: https://kitsu.io

| Variable Name    | Description    | Value Type | Example                  |
| ---------------- | -------------- | ---------- | ------------------------ |
| `KITSU_EMAIL`    | Kitsu email    | String     | `hello@nattadasu.my.id`  |
| `KITSU_PASSWORD` | Kitsu password | String     | `5up3rS3Cure_-_P@sSwOrd` |

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

| Variable Name       | Description       | Value Type | Example                  |
| ------------------- | ----------------- | ---------- | ------------------------ |
| `MANGADEX_USERNAME` | MangaDex username | String     | `nattadasu`              |
| `MANGADEX_PASSWORD` | MangaDex password | String     | `5up3rS3Cure_-_P@sSwOrd` |

### MyAnimeList

**Website**: https://myanimelist.net

> **Warning**
>
> This method requires [# User Agent](#network) configured properly

| Variable Name  | Description          | Value Type | Example     |
| -------------- | -------------------- | ---------- | ----------- |
| `MAL_USERNAME` | MyAnimeList username | String     | `nattadasu` |

### Notify.moe

**Website**: https://notify.moe

| Variable Name        | Description                                        | Value Type               | Example     |
| -------------------- | -------------------------------------------------- | ------------------------ | ----------- |
| `NOTIFYMOE_NICKNAME` | Notify nickname/username, must be upper-first case | String, Upper-first case | `Nattadasu` |

### Otak Otaku

**Website**: https://otakotaku.com

> **Warning**
>
> This method requires [# User Agent](#network) configured properly

| Variable Name        | Description         | Value Type | Example     |
| -------------------- | ------------------- | ---------- | ----------- |
| `OTAKOTAKU_USERNAME` | Otak Otaku username | String     | `nattadasu` |

### SIMKL

**Website**: https://simkl.com

| Variable Name        | Description                                                                                                                                      | Value Type            | Example                                                            |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------- | ------------------------------------------------------------------ |
| `SIMKL_CLIENT_ID`    | SIMKL Client ID, get it from [SIMKL Developer Settings](https://simkl.com/settings/developer/), with redirection URI `urn:ietf:wg:oauth:2.0:oob` | String, 64 characters | `AB12cd34EF56gh78IJ90kl12MN34op56QR78st90UV12wx34YZ56ab78cd90ef12` |
| `SIMKL_ACCESS_TOKEN` | SIMKL access token, `SIMKL_CLIENT_ID` must be filled, and run [`./Get-SimklAuth.ps1`](./Modules/Get-SimklAuth.ps1) to generate                   | String, 64 characters | `AB12cd34EF56gh78IJ90kl12MN34op56QR78st90UV12wx34YZ56ab78cd90ef12` |

### Shikimori

**Website**: https://shikimori.one

> **Warning**
>
> This method requires [# User Agent](#network) configured properly

| Variable Name             | Description                                           | Value Type          | Example                 |
| ------------------------- | ----------------------------------------------------- | ------------------- | ----------------------- |
| `SHIKIMORI_USERNAME`      | Shikimori username                                    | String              | `nattadasu`             |
| `SHIKIMORI_KAWAI_SESSION` | Shikimori session cookie under `_kawaii_session` name | String, URL encoded | `ABCD%3F51gsj021%20...` |

### Trakt

**Website**: https://trakt.tv

| Variable Name         | Description                                                                                                                                                               | Value Type                    | Example                                                            |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------- | ------------------------------------------------------------------ |
| `TRAKT_USERNAME`      | Trakt username                                                                                                                                                            | String                        | `nattadasu`                                                        |
| `TRAKT_CLIENT_ID`     | Trakt Client ID<br>To generate, go to [Trakt](https://trakt.tv/oauth/applications) and click "Create New Application". Set `urn:ietf:wg:oauth:2.0:oob` as `Redirect URIs` | String, 64 characters         | `AB12cd34EF56gh78IJ90kl12MN34op56QR78st90UV12wx34YZ56ab78cd90ef12` |
| `TRAKT_CLIENT_SECRET` | Trakt Client Secret                                                                                                                                                       | String, 64 characters         | `AB12cd34EF56gh78IJ90kl12MN34op56QR78st90UV12wx34YZ56ab78cd90ef12` |
| `TRAKT_OAUTH_EXPIRY`  | Trakt OAuth expiry generated by `traktexport` Python module                                                                                                               | Integer, Epoch/Unix timestamp | `1234567890`                                                       |
| `TRAKT_OAUTH_REFRESH` | Trakt OAuth refresh token generated by `traktexport` Python module                                                                                                        | String, 64 characters         | `AB12cd34EF56gh78IJ90kl12MN34op56QR78st90UV12wx34YZ56ab78cd90ef12` |
| `TRAKT_OAUTH_TOKEN`   | Trakt OAuth token generated by `traktexport` Python module                                                                                                                | String, 64 characters         | `AB12cd34EF56gh78IJ90kl12MN34op56QR78st90UV12wx34YZ56ab78cd90ef12` |

* To get `TRAKT_OAUTH_EXPIRY`, `TRAKT_OAUTH_REFRESH`, `TRAKT_OAUTH_TOKEN`, run
  `traktexport auth <username>` with `<username>` is your Trakt username, if not
  installed, run `pip install traktexport` from terminal.

  Follow instructions from the module, pasting in your Client ID/Secret from the
  Trakt dashboard, going to the link and pasting the generated pin back into the
  terminal.

  After init done, run `type .traktexport\traktexport.json` in
  `%USERPROFILE%`/`~` directory on Windows or
  `cat ~/.local/share/traktexport.json` on POSIX system (Linux/macOS) to copy
  the credential.

### Visual Novel Database (VNDB)

**Website**: https://vndb.org

> **Warning**
>
> This method requires [# User Agent](#network) configured properly

> **Warning**
>
> `VNDB_TOKEN`/JSON backup is only work for manual/local backup, not for
> automatic backup via GitHub Actions due to unknown error.

| Variable Name | Description                                                   | Value Type                  | Example                                          |
| ------------- | ------------------------------------------------------------- | --------------------------- | ------------------------------------------------ |
| `VNDB_UID`    | VNDB user ID                                                  | Integer                     | `u1234`                                          |
| `VNDB_AUTH`   | VNDB session cookie, used to export XML                       | String, 40 characters + UID | `AB12cd34EF56gh78IJ90kl12MN34op56QR78st90.u1234` |
| `VNDB_TOKEN`  | VNDB token for JSON export, only work for manual/local backup | String, 38 characters       | `abcd-3f9h1-jk1mn-0p9-r5tuv-wxyza-8cd3`          |

* To get `VNDB_UID`, click on any links that stated with "My" or your username,
  and copy the fragment of your URL that is started with letter "u" and
  ID number after it.

  For example:

  ```py
  https://vndb.org/u123456/ulist?vnlist=1
                   ^^^^^^^
  ```

* To get `VNDB_AUTH`, tap F12 or "Inspect Page" when right-clicking the site,
  open "Storage" tab, and click "Cookies" of the site.

  Find a name of the cookie that starts with `vndb_auth` and copy the value.

* To grab `VNDB_TOKEN`, Go to your profile, click on `Edit` tab, and click on
  `Application` tab.

  Click on `New token` button, set application name, check **Access to my list
  (including private items)**, and click `Submit` button below.

  Copy the token from textbox and paste it below.

  The token should be 38 characters long.

## Configurations

The script allows user modify additional configurations. The configurations
saved in `.env` file for local, and GitHub's Repository Secrets for automated
process using GitHub Actions.

Below are the keys of allowed configurations

### Network

| Variable Name | Description                                                                                                                                                | Required for                                                                                                   | Value Type | Example |
| ------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- | ---------- | ------- |
| `USER_AGENT`  | Your user agent. <br>You can get your current browser user agent from [WhatIsMyBrowser.com](https://www.whatismybrowser.com/detect/what-is-my-user-agent/) | Anime-Planet, MangaUpdates, MyAnimeList, Otak Otaku, Shikimori, VNDB, `WAYBACK_ENABLE`, `WAYBACK_SNAPMAINSITE` | String     | `...`   |

### Repository

| Variable Name | Description                                                                  | Required for              | Value Type                | Default | Example   |
| ------------- | ---------------------------------------------------------------------------- | ------------------------- | ------------------------- | ------- | --------- |
| `MINIFY_JSON` | Minify all JSON, not intended for use on manual inspection or Git `diff`     | -                         | Boolean (`True`, `False`) | `False` | `False`   |
| `REPO_PAT`    | GitHub Personal Access Token to update repo automatically via GitHub Actions | Automated: GitHub Actions | String                    | -       | `ghp_...` |

* `REPO_PAT` is your GitHub Personal Access Token to update repo from
  [Settings / Developer Settings / Personal Access Tokens](https://github.com/settings/tokens/new?scopes=workflow).
  Enable `workflow` option and set expiration date more than a month.

  However, you are not needed to add `REPO_PAT` in your Environment File if you
  run the script locally.

### Schedule

| Variable Name | Description                                                            | Required for              | Value Type   | Default       | Example       |
| ------------- | ---------------------------------------------------------------------- | ------------------------- | ------------ | ------------- | ------------- |
| `BACKUP_FREQ` | Tell GitHub Actions to do backup at the time scheduled                 | Automated: GitHub Actions | String, CRON | `0 0 * * SUN` | `0 0 * * SUN` |
| `UPDATE_FREQ` | Tell GitHub Actions to check and update scripts and several components | Automated: GitHub Actions | String, CRON | `0 0 * * *`   | `0 0 * * *`   |

### Wayback Machine Integration

| Variable Name          | Description                                                                                          | Required for | Value Type                | Default | Example |
| ---------------------- | ---------------------------------------------------------------------------------------------------- | ------------ | ------------------------- | ------- | ------- |
| `WAYBACK_ENABLE`       | Enable Wayback Machine feature to snapshot the site you're backing up. `USER_AGENT` required         | -            | Boolean (`True`, `False`) | `False` | `False` |
| `WAYBACK_SNAPMAINSITE` | Contribute Wayback Machine by snapshot the homepage of repo's supported sites. `USER_AGENT` required | -            | Boolean (`True`, `False`) | `False` | `False` |

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
> The script will automatically run at 0:00 AM UTC every Sunday, or you can
> trigger manually from dispatch.
>
> You can change this behavior by modifying `BACKUP_FREQ` in environment.

<!-- Links -->
[Automail]: https://greasyfork.org/en/scripts/370473-automail
