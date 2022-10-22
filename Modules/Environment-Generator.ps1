#!/usr/bin/env pwsh

# Ignore Warning from Script Analyzer
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    <#Category#>'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Ignore unused variable warning'
)]

[CmdletBinding()]
Param(
    [Switch]$GenerateEnvExample
)


# Check if the script run from GitHub Action
$isAction = $Null -ne $Env:GITHUB_WORKSPACE

Function Write-Header {
    Param(
        [Parameter(Mandatory = $True)]
        [String]$Message,
        [ValidateSet(
            'Black', 'Blue', 'Cyan',
            'DarkBlue', 'DarkCyan', 'DarkGray',
            'DarkGreen', 'DarkMagenta', 'DarkRed',
            'DarkYellow', 'Gray', 'Green',
            'Magenta', 'Red', 'White',
            'Yellow'
        )
        ]
        [String]$ForegroundColor = "Blue",
        [ValidateSet(
            'Black', 'Blue', 'Cyan',
            'DarkBlue', 'DarkCyan', 'DarkGray',
            'DarkGreen', 'DarkMagenta', 'DarkRed',
            'DarkYellow', 'Gray', 'Green',
            'Magenta', 'Red', 'White',
            'Yellow'
        )
        ]
        [String]$BackgroundColor,
        [String]$Separator = "="
    )

    $total = $Message.Length
    $total = [Int]$total
    $bar = "$($Separator)" * $total
    If (!($BackgroundColor)) {
        Write-Host $Message -ForegroundColor $ForegroundColor
        Write-Host $bar -ForegroundColor $ForegroundColor
    }
    Else {
        Write-Host $Message -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
        Write-Host $bar -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
    }
}

Function Write-GettingStarted {
    Clear-Host

    Write-Verbose -Message "[$(Get-Date)] Write Getting Started message to host"

    Write-Host "Hello! Welcome to Environment Generator" -ForegroundColor Green
    Write-Host "`nThis script will help you to fill the .env file safely."
    Write-Host "Please follow the instruction carefully to avoid any unknown issue.`n"

    Read-Host -Prompt "Press any key to continue"
}

Function Get-CookieHelp {
    Param(
        [array]$CookiesName,
        [uri]$Uri
    )

    Write-Host @"

To get cookie value, open $($Uri) on your browser and login to your account.
Then open "Developer Tool" by clicking F12 or Ctrl+Shift+I, and click on Application tab.
On Application tab sidebar, click Cookies, and click on $($Uri).

Copy each value$(If ($CookiesName.Count -gt 1) { 's' }) ($($CookiesName -Join ", ")) that will be asked in upcoming prompt.

"@
}

# AniList

Function Read-AniList {
    Clear-Host
    Write-Header -Message "AniList" -ForegroundColor Cyan
    $initAniList = Read-Host -Prompt "Do you want to backup AniList  (Anime, Manga)? [Y/n]"
    If (!($initAniList)) {
        $initAniList = "Y"
    }

    If ($initAniList -eq "Y") {
        $Global:alUname = Read-Host -Prompt "`nYour AniList Username"
    }
}

Function Read-AnimePlanet {
    Clear-Host
    Write-Header -Message "Anime-Planet" -ForegroundColor Blue
    $initAnimePlanet = Read-Host -Prompt "Do you want to backup Anime-Planet (Anime, Manga)? [Y/n]"
    If (!($initAnimePlanet)) {
        $initAnimePlanet = "Y"
    }

    If ($initAnimePlanet -eq "Y") {
        $Global:apUname = Read-Host -Prompt "`nYour Anime-Planet Username"
    }
}

Function Read-Annict {
    Clear-Host
    Write-Header -Message "Annict (アニクト)" -ForegroundColor Red
    $initAnnict = Read-Host -Prompt "!!WIP!! Do you want to backup Annict (Anime)? [Y/n]"
    If (!($initAnnict)) {
        $initAnnict = "Y"
    }

    If ($initAnnict -eq "Y") {
        $newTokenUri = 'https://en.annict.com/settings/apps'
        Write-Host @"
`nAnnict requires you to use Personal Access Token to be able to get your data from server.
You can get PAT via this link (we will also open the website for you): $($newTokenUri)

To generate, click [+ Generate new token] button on Personal Access Token section, select scopes as "Read Only", and write description as your Backup Repo Name
"@

        Write-Host "`nLaunching Annict website" -ForegroundColor Yellow
        Start-Process $newTokenUri
        $Global:acPAT = Read-Host -Prompt "Please paste the code genrated from website (on green box)"
    }
}

Function Read-Bangumi {
    Clear-Host
    Write-Header -Message "Bangumi" -ForegroundColor Red
    $initBangumi = Read-Host -Prompt "Do you want to backup your Bangumi (Anime, Manga, Games, TV-Movies)? [Y/n]"
    If (!($initBangumi)) {
        $initBangumi = "Y"
    }

    If ($initBangumi -eq "Y") {
        $newTokenUri = "https://next.bgm.tv/demo/access-token"
        Write-Host @"
`nBangumi requires you to use Personal Access Token to be able to get your data from server.
You can get PAT via this link (we will also open the website for you): $($newTokenUri)

To generate, click "创建个人令牌" link (or click this URL: $($newTokenUri)/create). In 名称 text input (first input), fill your Backup Repo Name, and select 365天 (365 days, 1 year) in 有效期 dropdown input (second input).
"@
        Write-Host "`nLaunching Bangumi Token portal website" -ForegroundColor Yellow
        Start-Process $newTokenUri
        $Global:bgmPAT = Read-Host -Prompt "`nPlease paste the code genrated from website"
    }
}

Function Read-Kitsu {
    Clear-Host
    Write-Header -Message "Kitsu" -ForegroundColor DarkMagenta
    $initKitsu = Read-Host -Prompt "Do you want to backup Kitsu (Anime, Manga)? [Y/n]"

    If (!($initKitsu)) {
        $initKitsu = "Y"
    }

    If ($initKitsu -eq "Y") {
        $Global:ktMail = Read-Host -Prompt "`nYour Kitsu E-mail address"
        $Global:ktPass = Read-Host -Prompt "Your Kitsu Password" -MaskInput
    }
}

Function Read-MangaDex {
    Clear-Host
    Write-Header -Message "MangaDex" -ForegroundColor DarkRed
    $initMangaDex = Read-Host -Prompt "Do you want to backup MangaDex (Anime, Manga)? [Y/n]"

    If (!($initMangaDex)) {
        $initMangaDex = "Y"
    }

    If ($initMangaDex -eq "Y") {
        $Global:mdMail = Read-Host -Prompt "`nYour MangaDex E-mail address"
        $Global:mdPass = Read-Host -Prompt "Your MangaDex Password" -MaskInput
    }
}

Function Read-MangaUpdates {
    Clear-Host
    Write-Header -Message "Baka-Updates' Manga (MangaUpdates)" -ForegroundColor Gray
    $initMangaUpdate = Read-Host -Prompt "Do you want to backup MangaUpdates (Manga)? [Y/n]"

    If (!($initMangaUpdate)) {
        $initMangaUpdate = "Y"
    }

    If ($initMangaUpdate -eq 'Y') {
        Get-CookieHelp -Uri "https://www.mangaupdates.com" -CookiesName "secure_session"
        $Global:muSession = Read-Host -Prompt "secure_session value" -MaskInput
    }
}
Function Read-MyAnimeList {
    Clear-Host
    Write-Header -Message "MyAnimeList" -ForegroundColor DarkBlue
    $initMyAnimeList = Read-Host -Prompt "Do you want to backup MyAnimeList (Anime, Manga)? [Y/n]"

    If (!($initMyAnimeList)) {
        $initMyAnimeList = "Y"
    }

    If ($initMyAnimeList -eq "Y") {
        $Global:malUname = Read-Host -Prompt "`nYour MyAnimeList username"
    }
}

Function Read-NotifyMoe {
    Clear-Host
    Write-Header -Message "Notify.moe" -ForegroundColor Magenta

    $initNotifyMoe = Read-Host -Prompt "Do you want to backup Notify.moe (Anime)? [Y/n]"
    If (!($initNotifyMoe)) {
        $initNotifyMoe = "Y"
    }

    If ($initNotifyMoe -eq "Y") {
        $Global:nmNick = Read-Host -Prompt "`nYour Notify.moe nickname (First-case sensitive)"
    }
}

Function Read-OtakOtaku {
    Clear-Host
    Write-Header -Message "Otak Otaku" -ForegroundColor Red
    $initOtakOtaku = Read-Host -Prompt "Do you want to backup Otak Otaku (Anime)? [Y/n]"

    If (!($initOtakOtaku)) {
        $initOtakOtaku = "Y"
    }

    If ($initOtakOtaku -eq "Y") {
        $Global:ooUname = Read-Host -Prompt "`nYour Otak Otaku username"
    }
}

Function Read-Shikimori {
    Clear-Host
    Write-Header -Message "Shikimori" -ForegroundColor DarkCyan
    $initShikimori = Read-Host -Prompt "Do you want to backup Shikimori (Anime, Manga)? [Y/n]"

    If (!($initShikimori)) {
        $initShikimori = "Y"
    }

    If ($initShikimori -eq "Y") {
        Get-CookieHelp -Uri "https://shikimori.one" -CookiesName "__kawai_session"
        $Global:shUname = Read-Host -Prompt "`nYour Shikimori username"
        $Global:shKawaiSession = Read-Host -Prompt "__kawai_session value" -MaskInput
    }
}

Function Read-Simkl {
    Clear-Host
    Write-Header -Message "SIMKL" -ForegroundColor Gray
    $initSimkl = Read-Host -Prompt "Do you want to backup SIMKL (Anime)? [Y/n]"

    If (!($initSimkl)) {
        $initSimkl = "Y"
    }

    If ($initSimkl -eq "Y") {
        Write-Host "`nPlease go to https://simkl.com/settings/apps and create a new app`n"
        $Global:skClient = Read-Host -Prompt "`nYour SIMKL Client ID"

        ./Modules/Get-SimklAuth.ps1 -ClientId $skClient

        $Global:skToken = Read-Host -Prompt "Your SIMKL Auth Token" -MaskInput
    }
}

Function Read-Trakt {
    Clear-Host
    Write-Header -Message "Trakt" -ForegroundColor Red

    $initTrakt = Read-Host -Prompt "Do you want to backup Trakt (TV Shows, Movies)? [Y/n]"

    If (!($initTrakt)) {
        $initTrakt = "Y"
    }

    If ($initTrakt -eq "Y") {
        Write-Host @"
`nPlease go to https://trakt.tv/oauth/applications and create a new app
Use urn:ietf:wg:oauth:2.0:oob as the redirect uri

Follow the instructions to get your Client ID and Client Secret
"@
        $traktUname = Read-Host -Prompt "`nYour Trakt username"
        traktexport auth $traktUname

        If ($Env:XDG_DATA_HOME) {
            $dataDir = $Env:XDG_DATA_HOME
        }
        ElseIf ($isWindows) {
            $dataDir = "~/.traktexport"
        }
        Else {
            $dataDir = "~/.local/share"
        }

        Try {
            $traktConfig = Get-Content -Path "$($dataDir)/traktexport.json" -Raw | ConvertFrom-Json
            $Global:trClient = $traktConfig.CLIENT_ID
            $Global:trSecret = $traktConfig.CLIENT_SECRET
            $Global:trToken = $traktConfig.OAUTH_TOKEN
            $Global:trRefresh = $traktConfig.OAUTH_REFRESH
            $Global:trExpiry = $traktConfig.OAUTH_EXPIRY
            $Global:trUname = $traktUname
        }
        Catch {
            Write-Error "Unable to read Trakt config file"
            Exit
        }
    }
}

Function Read-VisualNovelDatabase {
    Clear-Host
    Write-Header -Message "Visual Novel Database" -ForegroundColor DarkBlue

    $initVNDB = Read-Host -Prompt "Do you want to backup Visual Novel Database (Visual Novels)? [Y/n]"

    If (!($initVNDB)) {
        $initVNDB = "Y"
    }

    If ($initVNDB -eq "Y") {
        Get-CookieHelp -Uri "https://vndb.org" -CookiesName "vndb_auth"
        $Global:vnUid = Read-Host -Prompt "`nYour Visual Novel Database User ID"
        $Global:vnAuth = Read-Host -Prompt "vndb_auth value" -MaskInput
    }
}

# ------------------------

Function Read-UserConfig {
    Clear-Host
    Write-Header -Message "Script Configurator"

    Write-Header -Message "GitHub Repository Personal Access Token" -Separator "-" -ForegroundColor Gray
    $initGitHubPAT = Read-Host -Prompt "Do you want to automatically update the script using GitHub Actions? [Y/n]"
    $Global:repoPAT = ""
    If (!($initGitHubPAT)) {
        $initGitHubPAT = "Y"
    }
    If ($initGitHubPAT -eq "Y") {
        @"
Open [Settings / Developer Settings / Personal Access Tokens](https://github.com/settings/tokens/new). Enable \[workflow\] option and set expiration date more than a month.
"@ | Show-Markdown
        $Global:repoPAT = Read-Host -Prompt "Your GitHub Personal Access Token" -MaskInput
    }

    Write-Header -Message "JSON Minifier" -Separator "-" -ForegroundColor Gray
    $initMinify = Read-Host -Prompt "Do you want to minify the JSON files? [Y/n]"
    $Global:minify = "False"
    If (!($initMinify)) {
        $initMinify = "Y"
    }
    If ($initMinify -eq "Y") {
        $Global:minify = "True"
    }

    Write-Header -Message "User Agent" -Separator "-" -ForegroundColor Gray
    If ($malUname -or $muSession -or $shKawaiSession -or $vnAuth -or $apUname -or $ooUname) {
        Write-Host "We require a custom User Agent to access some of the sites: MyAnimeList, MangaUpdates, Shikimori, Visual Novel Database, Anime-Planet, and Otak Otaku"
        $initUserAgent = "Y"
    }
    Else {
        $initUserAgent = Read-Host -Prompt "Do you want to use a custom User Agent? This might be required once if you want to backup to: MyAnimeList, MangaUpdates, Shikimori, Visual Novel Database, Anime-Planet, and Otak Otaku [Y/n]"
        If (!($initUserAgent)) {
            $initUserAgent = "Y"
        }
    }
    If ($initUserAgent -eq "Y") {
        "You can get your current user agent from [WhatIsMyBrowser.com](https://www.whatismybrowser.com/detect/what-is-my-user-agent/)" | Show-Markdown
        $Global:uAgent = Read-Host -Prompt "Your custom User Agent"
    }

    Write-Header -Message "Backup Frequency" -ForegroundColor Grey -Separator "-"
    $initBkupFreq = Read-Host -Prompt "Do you want to change backup frequency from each Sunday, 0:00 AM UTC to else? [Y/n]"
    If (!($initBkupFreq)) {
        $initBkupFreq = "Y"
    }
    $Global:schedBackupFreq = "0 0 * * SUN"
    If ($initBkupFreq -eq "Y") {
        $Global:schedBackupFreq = Read-Host -Prompt "Backup frequency (in CRON format)"
    }

    Write-Header -Message "Script Update Frequency" -ForegroundColor Grey -Separator "-"
    $initUpdateFreq = Read-Host -Prompt "Do you want to change script update frequency from each day, 0:00 AM UTC to else? [Y/n]"
    If (!($initUpdateFreq)) {
        $initUpdateFreq = "Y"
    }
    $Global:schedUpdateFreq = "0 0 * * *"
    If ($initUpdateFreq -eq "Y") {
        $Global:schedUpdateFreq = Read-Host -Prompt "Script update frequency (in CRON format)"
    }
}

# ########################

If (!($GenerateEnvExample)) {
    Write-GettingStarted
    #-------------------
    Read-AniList
    Read-AnimePlanet
    Read-Annict
    Read-MangaUpdates
    # Read-Bangumi
    Read-Kitsu
    Read-MangaDex
    Read-MyAnimeList
    Read-NotifyMoe
    Read-OtakOtaku
    Read-Shikimori
    Read-Simkl
    Read-Trakt
    Read-VisualNovelDatabase
    #-------------------
    Read-UserConfig
}

$envData = ""

If ($isAction -or $GenerateEnvExample) {
    $envPath = "./.env.example"
}
Else {
    $envPath = "./.env.test"
    $envData += "# Generated on $(Get-Date) $((Get-TimeZone).Id)`n`n"
}

Write-Verbose -Message "[$(Get-Date)] Generating $envPath"

$envData += @"
# Accounts
# ========
ANILIST_USERNAME=$($alUname)

ANIMEPLANET_USERNAME=$($apUname)

ANNICT_PERSONAL_ACCESS_TOKEN=$($acPAT)

BANGUMI_PERSONAL_ACCESS_TOKEN=$($bgmPAT)

# Not app specific, key available on https://kitsu.docs.apiary.io/#introduction/authentication/app-registration
# Unused till upcoming implementation
KITSU_CLIENT_ID=dd031b32d2f56c990b1425efe6c42ad847e7fe3ab46bf1299f05ecd856bdb7dd
KITSU_CLIENT_SECRET=54d7307928f63414defd96399fc31ba847961ceaecef3a5fd93144e960c0e151
KITSU_EMAIL=$($ktMail)
KITSU_PASSWORD=$($ktPass)

MAL_USERNAME=$($malUname)

MANGADEX_USERNAME=$($mdMail)
MANGADEX_PASSWORD=$($mdPass)

MANGAUPDATES_SESSION=$($muSession)

NOTIFYMOE_NICKNAME=$($nmNick)

OTAKOTAKU_USERNAME=$($ooUname)

SHIKIMORI_KAWAI_SESSION=$($shKawaiSession)
SHIKIMORI_USERNAME=$($shUname)

SIMKL_ACCESS_TOKEN=$($skToken)
SIMKL_CLIENT_ID=$($skClient)

TRAKT_CLIENT_ID=$($trClient)
TRAKT_CLIENT_SECRET=$($trSecret)
TRAKT_OAUTH_EXPIRY=$($trExpiry)
TRAKT_OAUTH_REFRESH=$($trRefresh)
TRAKT_OAUTH_TOKEN=$($trToken)
TRAKT_USERNAME=$($trUname)

VNDB_AUTH=$($vnAuth)
# UID should be started with U as prefix
# Example: U12345
VNDB_UID=$($vnUid)

# Configs
# =======
BACKUP_FREQ=$($schedBackupFreq)
MINIFY_JSON=$($jsonMinify)
REPO_PAT=$($repoPAT)
UPDATE_FREQ=$($schedUpdateFreq)
USER_AGENT=$($uAgent)
"@

$envData | Out-File -Path $envPath -Encoding utf8 -Force

Exit
