<!-- cSpell:words ANILIST ANIMEPLANET Annict Automail Bangumi choco Darek Goodreads Importability kawai Kitsu MANGAUPDATES Nautiljon NOTIFYMOE Otak Otaku POSIX pwsh Shikimori SIMKL Trakt traktexport USERID USERPROFILE VNDB -->
<!-- markdownlint-disable MD033 MD034 -->

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
* [Files Generated and Importability](#files-generated-and-importability)
* [Getting Started](#getting-started)
  * [Prerequisites](#prerequisites)
    * [Required softwares/packages for locally run the script](#required-softwarespackages-for-locally-run-the-script)
    * [Run the script by service worker (GitHub Actions)](#run-the-script-by-service-worker-github-actions)
  * [Setting Environment Variables](#setting-environment-variables)
    * [Based on where you run](#based-on-where-you-run)
      * [For Local Machine](#for-local-machine)
      * [For GitHub Actions](#for-github-actions)
    * [Variables Instruction](#variables-instruction)
* [Usage](#usage)
  * [On Local Machine](#on-local-machine)
  * [On GitHub Actions](#on-github-actions)
    * [If the repo is forked](#if-the-repo-is-forked)
    * [If the repo is generated from template](#if-the-repo-is-generated-from-template)

## About

"Anime Manga Auto Backup" is my personal take to automate process in back-up your anime and manga libraries, automatically using worker like GitHub Actions or execute manually from your machine, from MyAnimeList.net, Kitsu, AniList, Annict, Baka-Updates Manga, Shikimori, Anime-Planet, Notify.moe, SIMKL, and Trakt. I use [PowerShell Core](https://github.com/powershell/powershell) to write the script because it is cross-platform and easy to use.

This project **requires you to set the library/list as public** as most API used in this projects are from 3rd party and **User Agent string may required to be filled in environment variable** for the backup progress works. You can check table below to see the library/list you need to set as public:

|           Sites | Requires public |  Method  | Requires User Agent | Description                                                                   |
| --------------: | :-------------: | :------: | :-----------------: | ----------------------------------------------------------------------------- |
|         AniList |     **Yes**     |  `API`   |         No          | Uses limited access public scope with AniList GraphQL API                     |
|    Anime-Planet |     **Yes**     |  `3PA`   |       **Yes**       | Uses MAL Exporter from Azure Website                                          |
|          Annict |       No        |  `API`   |         No          | User can generate Personal Access Token from account                          |
|    Baka-Updates |       No        | `COOKIE` |       **Yes**       | Uses `secure_session` cookie saved on browser                                 |
|           Kitsu |       No        |  `API`   |         No          | Uses official API                                                             |
|        MangaDex |       No        |  `API`   |         No          | Uses official API                                                             |
| MyAnimeList.net |     **Yes**     |  `3PA`   |       **Yes**       | Uses MAL Exporter from Azure Website                                          |
|      Notify.moe |       No        |  `API`   |         No          | Uses official API                                                             |
|       Shikimori |       No        | `COOKIE` |       **Yes**       | Uses `_kawai_session` cookie saved on browser                                 |
|           SIMKL |       No        |  `API`   |         No          | Uses official API. However we strongly recommend you to use their VIP feature |
|           Trakt |       No        |  `API`   |         No          | Uses `traktexport` Python package/module                                      |
|            VNDB |       No        | `COOKIE` |       **Yes**       | Uses `vndb_auth` cookie saved on browser                                      |

***Note:***\
`API` Official API, `3PA` 3rd Party API, `COOKIE` Cookie Auth Bypass

> **Warning**
>
> I am not responsible and liable for warranty for any damage caused by using this project.

## Features and To Do

### Legends

* ✅ : Available
* 🚫 : Not Available
* ⌛ : In Development
* 💻 : Technical difficulty, usually due to pagination or need to scrape XML/HTML table and does not have capability to do so.

### Backup from `x` site

* ✅ AniList
* ✅ Anime-Planet
* ✅ Annict
* ✅ Baka-Updates
* ✅ Kitsu
* ✅ MangaDex
* ✅ MyAnimeList
* ✅ Notify.moe
* ✅ Shikimori
* ✅ SIMKL
* ✅ Trakt
* ✅ Visual Novel Database (VNDB)
* 🚫 9Anime &mdash; *Can not bypass security*
* 💻 AniDB &mdash; *Probably won't integrated as they uses different API method, and very niche site*
* 🚫 AniSearch &mdash; *Failed to bypass cookies, API access limited, requests only*
* 💻 Bangumi.tv &mdash; Pagination
* 🚫 Goodreads &mdash; *Export feature is not instantaneous, and yet they closed Public API*
* 🚫 IMDb &mdash; *Failed to bypass using cookie method; API paid*
* 💻 LiveChart.me &mdash; *Doable using cookie bypass, but has no capability to scrape HTML*
* 💻 Nautiljon &mdash; *No export feature and no API access*
* ⌛ Otak Otaku
* ⌛ The Movie DB

## Files Generated and Importability

| Sites Name   | File Saved As                   | MALXML Support | Can Be Imported Back? | Description                                                                                                                   |
| ------------ | ------------------------------- | -------------- | --------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| AniList      | `.json`, **`.xml`**                 | Yes            | Yes                   | You need to use [Automail] to import back to AniList in JSON, or  import to MyAnimeList using XML                             |
| Anime-Planet | **`.xml`**                          | Yes            | Limited               | Backup file is formatted as MyAnimeList XML, some entry might not restored if MAL did not list it                             |
| Annict       | `.json`                         | No             | No                    | There is no official import/export feature                                                                                    |
| Baka-Updates | `.tsv`                          | No             | No                    | There is no official import/export feature                                                                                    |
| Kitsu        | **`.xml`**                          | Yes            | Yes                   | You can reimport back to Kitsu or import to MyAnimeList                                                                       |
| MangaDex     | `.json`, `.yaml`, **`.xml`**        | Yes            | Limited               | Only `.xml` can be imported back to MyAnimeList or other that supports MAL XML. `.json` and `.yaml` are for internal use only |
| MyAnimeList  | **`.xml`**                          | Yes            | Yes                   | You can reimport back to MyAnimeList                                                                                          |
| Notify.moe   | `.json`, `.csv`, `.txt`, **`.xml`** | Yes            | Limited               | Only `.xml` can be imported back to MyAnimeList or other that supports MAL XML.                                               |
| Shikimori    | `.json`, **`.xml`**                 | Yes            | Yes                   | You can reimport back to Shikimori or import to MyAnimeList using XML                                                         |
| SIMKL        | `.json`, `.zip`, `.csv`, **`.xml`** | Yes            | Yes                   | Use https://simkl.com/apps/import/json/ and upload ZIP file to import back. `.csv` can be imported on other sites             |
| Trakt        | `.json`                         | No             | No                    | There is no official import/export feature                                                                                    |
| VNDB         | `.xml`                          | No             | No                    | There is no official import/export feature                                                                                    |

* **MALXML** in this table refers to a XML format used by MyAnimeList, and is used by some sites to import/export data.
  * Please to check import feature availability on each site. We can not guarantee if the site supports MALXML format by default.

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
    | Stability      | No, upstream               | Yes, because the snapshot basically is stable                |
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

1. Duplicate the `.env.example` file and rename to `.env` file.
2. Follow the instructions in [# Variables Instructions](#variables-instruction) to set the variables.
   * If you did not registered to some site, leave the value empty.

##### For GitHub Actions

1. Open repo settings.
2. On the left sidebar, find "**Secrets**" and click **Actions**.
3. Click <kbd>New repository secret</kbd> button.
4. Follow the instructions in [# Variables Instructions](#variables-instruction) to set the variables.
   * The text on `code block` in the instruction mean a name, and Value is the key/cookie.
   * Repeat this step for all the variables listed in the instruction.
   * If you did not registered to some site, leave the value empty.

#### Variables Instruction

* `ANILIST_USERNAME`\
  Your AniList username.
* `ANIMEPLANET_USERNAME`\
  Your Anime-Planet username.
* `ANNICT_PERSONAL_ACCESS_TOKEN`\
  Your Annict Personal Access Token. You can generate one from your account via [Application Settings](https://en.annict.com/settings/apps).
* `KITSU_EMAIL`\
  Your Kitsu email used to login.
* `KITSU_PASSWORD`\
  Your Kitsu password used to login.
<!-- * `KITSU_USERID`\
  Your Kitsu user ID. To get it, open your Kitsu profile, right click on your display/profile picture, and click "Open in new tab".

  In some cases, your ID is right after `avatar/` or after `user/`

  For example:

  ```py
  https://media.kitsu.io/users/avatars/000000/large.jpeg
                                       ^^^^^^
  ```

  If the url uses `users/avatars/` path, `000000` is the ID. However, if the path is:

  ```py
  https://media.kitsu.io/user/000000/avatar/[FILENAME]
                              ^^^^^^
  ```

  then `000000` is the ID. -->
* `MAL_USERNAME`\
  Your MyAnimeList username.
* `MANGADEX_USERNAME`\
  Your MangaDex username.
* `MANGADEX_PASSWORD`\
  Your MangaDex password.
* `MANGAUPDATES_SESSION`\
  Your Baka-Updates session cookie. To get it, tap F12 or "Inspect Page" when right-clicking the site, open "Storage" tab, and click "Cookies" of the site.

  Find a name of the cookie that starts with `secure_session` and copy the value.
* `NOTIFYMOE_NICKNAME`\
  Your Notify.moe nickname/username, string should be `Upper-first case`. <!-- The script will automatically generate user ID from this nickname. -->
* `REPO_PAT`\
  **Required for GitHub Actions**, your GitHub Personal Access Token to update repo from [Settings / Developer Settings / Personal Access Tokens](https://github.com/settings/tokens/new). Enable `workflow` option and set expiration date more than a month.

  However, you are not needed to add `REPO_PAT` in your Environment File if you run the script locally.
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
  Your user agent. This field is required for some sites. You can get your current user agent from [WhatIsMyBrowser.com](https://www.whatismybrowser.com/detect/what-is-my-user-agent/)
* `VNDB_AUTH`\
  Your VNDB session cookie. To get it, tap F12 or "Inspect Page" when right-clicking the site, open "Storage" tab, and click "Cookies" of the site.

  Find a name of the cookie that starts with `vndb_auth` and copy the value.
* `VNDB_UID`\
  Your VNDB user ID. To get it, click on any links that stated with "My" or your username, and copy the fragment of your URL that is started with letter "u" and ID number after it.

  For example:

  ```py
  https://vndb.org/u123456/ulist?vnlist=1
                   ^^^^^^^
  ```

  `u12345` is your UID.

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
