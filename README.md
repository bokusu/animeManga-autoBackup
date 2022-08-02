<!-- cSpell:words Kitsu Shikimori Trakt Annict Bangumi kawai Darek Goodreads USERID pwsh choco MANGAUPDATES ANILIST NOTIFYMOE traktexport POSIX USERPROFILE SIMKL Nautiljon Otak Otaku -->
<!-- markdownlint-disable MD033 -->

<!-- omit in toc -->
# Anime Manga Auto Backup

[![The MIT License](https://img.shields.io/badge/license-MIT-orange.svg?style=for-the-badge)](LICENSE) [![PowerShell](https://img.shields.io/badge/Made_With-PowerShell-blue.svg?style=for-the-badge)](http://github.com/powershell/powershell)

Automatically (and also manually) backup your anime and manga libraries from [several anime, manga, TV shows, movies, and books tracking sites](#backup-from-x-site). Made possible with PowerShell Core.

<!-- omit in toc -->
## Table of Contents

* [About](#about)
* [Features and To Do](#features-and-to-do)
  * [Legends](#legends)
  * [Backup from `x` site](#backup-from-x-site)
* [Getting Started](#getting-started)
  * [Prerequisites](#prerequisites)
  * [Setting Environment Variables](#setting-environment-variables)
    * [Based on where you run](#based-on-where-you-run)
      * [For Local Machine](#for-local-machine)
      * [For GitHub Actions](#for-github-actions)
    * [Variables Instruction](#variables-instruction)
* [Usage](#usage)
  * [On Local Machine](#on-local-machine)
  * [On GitHub Actions](#on-github-actions)

## About

"Anime Manga Auto Backup" is my personal take to automate process in back-up your anime and manga libraries, automatically using worker like GitHub Actions or execute manually from your machine, from MyAnimeList.net, Kitsu, AniList, Annict, Baka-Updates Manga, Shikimori, SIMKL, and Trakt. I use [PowerShell Core](https://github.com/powershell/powershell) to write the script because it is cross-platform and easy to use.

This project **requires you to set the library/list as public** as most API used in this projects are from 3rd party. You can check table below to see the library/list you need to set as public:

|           Sites | Requires to set as public |  Method  | Description                                                                   |
| --------------: | :-----------------------: | :------: | ----------------------------------------------------------------------------- |
|         AniList |          **Yes**          |  `API`   | Uses limited access public scope with AniList GraphQL API                     |
|          Annict |            No             |  `API`   | User can generate Personal Access Token from account                          |
|    Baka-Updates |            No             | `COOKIE` | Uses `secure_session` cookie saved browser                                    |
|           Kitsu |          **Yes**          |  `3PA`   | Uses MAL Exporter from Azure Website                                          |
| MyAnimeList.net |          **Yes**          |  `3PA`   | Uses MAL Exporter from Azure Website                                          |
|      Notify.moe |            No             |  `API`   | Uses official API                                                             |
|       Shikimori |            No             | `COOKIE` | Uses `_kawai_session` cookie saved browser                                    |
|           SIMKL |            No             |  `API`   | Uses official API. However we strongly recommend you to use their VIP feature |
|           Trakt |            No             |  `API`   | Uses `traktexport` Python package/module                                      |

***Note:***\
`API` Official API, `3PA` 3rd Party API, `COOKIE` Cookie Auth Bypass

I am not responsible and liable for warranty for any damage caused by using this project.

## Features and To Do

### Legends

* [x] : Available
* [ ] : Not Available

### Backup from `x` site

* [x] AniList
* [x] Annict
* [x] Baka-Updates
* [x] Kitsu
* [x] MyAnimeList
* [x] Notify.moe
* [x] Shikimori
* [x] SIMKL
* [x] Trakt
* [ ] AniDB &mdash; *Probably won't integrated as they uses different API method, and very niche site*
* [ ] Anime-Planet
* [ ] AniSearch
* [ ] Bangumi.tv
* [ ] Goodreads &mdash; *Export feature is not instantaneous, and yet they closed Public API*
* [ ] IMDb &mdash; *Failed to bypass using cookie method; API paid*
* [ ] LiveChart.me &mdash; *Doable using cookie bypass*
* [ ] Nautiljon &mdash; *No export feature and no API access*
* [ ] Otak Otaku &mdash; *No export feature and no API access*
* [ ] The Movie DB

## Getting Started

These instructions will get you a copy of the project up and running on your local machine or using GitHub Actions.

### Prerequisites

**NOTE**\
If you are running this script using workers, skip the instructions, and straightly jump to next section.

Before starting the script, you need to install the following packages:

* `choco` for Windows user, or `brew` for Mac user
* `curl`
* `git`
* `pwsh` version >= 7.0.0
* `python` version >= 3.7

You also need to fork the repository before cloning the repo to your local machine OR initializing the repository with GitHub Actions.

### Setting Environment Variables

#### Based on where you run

##### For Local Machine

1. Duplicate the `.env.example` file and rename to `.env` file.
2. Follow the instructions in [# Variables Instructions](#variables-instructions) to set the variables.
   * If you did not registered to some site, leave the value empty.

##### For GitHub Actions

1. Open repo settings.
2. On the left sidebar, find "**Secrets**" and click **Actions**.
3. Click <kbd>New repository secret</kbd> button.
4. Follow the instructions in [# Variables Instructions](#variables-instructions) to set the variables.
   * The text in `this box` mean a name, and Value is the key/cookie.
   * Repeat this step for all the variables listed in the instruction.
   * If you did not registered to some site, leave the value empty.

#### Variables Instruction

* `ANILIST_USERNAME`\
  Your AniList username.
* `ANNICT_PERSONAL_ACCESS_TOKEN`\
  Your Annict Personal Access Token. You can generate one from your account via [Application Settings](https://en.annict.com/settings/apps).
* `KITSU_USERID`\
  Your Kitsu user ID. To get it, open your Kitsu profile, right click on your display/profile picture, and click "Open in new tab".

  Your ID is right after `avatar/`.

  For example:

  ```py
  https://media.kitsu.io/users/avatars/000000/large.jpeg
                                       ^^^^^^
  ```

  `000000` is the ID.
* `MAL_USERNAME`\
  Your MyAnimeList username.
* `MANGAUPDATES_SESSION`\
  Your Baka-Updates session cookie. To get it, tap F12 or "Inspect Page" when right-clicking the site, open "Storage" tab, and click "Cookies" of the site.

  Find a name of the cookie that starts with `secure_session` and copy the value.
* `NOTIFYMOE_NICKNAME`\
  Your Notify.moe nickname/username, string should be `Upper-first case`. <!-- The script will automatically generate user ID from this nickname. -->
* `SIMKL_ACCESS_TOKEN`\
  Your SIMKL access token. To get it, please fill your `SIMKL_CLIENT_ID` and init/run [`./Get-SimklAuth.ps1`](Get-SimklAuth.ps1), then follow the instructions.
* `SIMKL_CLIENT_ID`\
  Your SIMKL Client ID. To get it, [create new app on SIMKL](https://simkl.com/settings/developer/new/), and set for redirection URI to `urn:ietf:wg:oauth:2.0:oob`.
* `SHIKIMORI_KAWAI_SESSION`\
  Your Shikimori session cookie. To get it, tap F12 or "Inspect Page" when right-clicking the site, open "Storage" tab, and click "Cookies" of the site.

  Find a name of the cookie that starts with `_kawai_session` and copy the value.
* `TRAKT_CLIENT_ID`\
  Your Trakt Client ID. To get it, go to [Trakt](https://trakt.tv/oauth/applications) and click "Create New Application". Set `urn:ietf:wg:oauth:2.0:oob` as `Redirect URIs`.
* `TRAKT_CLIENT_SECRET`\
  Your Trakt Client Secret.
* `TRAKT_OAUTH_EXPIRY`, `TRAKT_OAUTH_REFRESH`, `TRAKT_OAUTH_TOKEN`\
  Your Trakt credential saved by `traktexport` Python module.

  To get it, run `traktexport init <username>` with `<username>` is your Trakt username, if not installed, run `pip install traktexport` from terminal.\
  Follow instructions from the module, pasting in your Client ID/Secret from the Trakt dashboard, going to the link and pasting the generated pin back into the terminal.\
  After init done, run `type .traktexport\traktexport.json` in `~`/`%USERPROFILE%` directory on Windows or `cat ~/.local/share/traktexport.json` on POSIX system (Linux/macOS) to copy the credential.
* `TRAKT_USERNAME`\
  Your Trakt username.
* `USER_AGENT`\
  Your user agent.

## Usage

### On Local Machine

1. Open Command Prompt/Terminal, type `pwsh`.
2. Change directory to the directory where you cloned the project.
3. Type `./script.ps1`, and let the script run by itself.

### On GitHub Actions

1. Open Actions tab.
2. Opt in the feature to enable.
3. Done.

**NOTE**\
The script will automatically run at 0:00 AM UTC every Sunday, or you can trigger manually from dispatch.
