#!/usr/bin/env pwsh

# Set variable
$isAction = $null -ne $Env:GITHUB_WORKSPACE
$userAgent = $Env:USER_AGENT

Function Write-None {
    Write-Host ""
}

function New-WebSession {
    param(
        [hashtable]$Cookies,
        [Uri]$For
    )

    $newSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()

    foreach($entry in $Cookies.GetEnumerator()){
        $cookie = [System.Net.Cookie]::new($entry.Name, $entry.Value)
        if($For){
            $newSession.Cookies.Add([uri]::new($For, '/'), $cookie)
        }
        else{
            $newSession.Cookies.Add($cookie)
        }
    }

    return $newSession
}

function Test-Binary {
    param(
        [string]$Binary,
        [Switch]$isModule
    )
    
    if ($isModule) {
        Write-Host "Checking if $Binary module installed"
        if (-Not (Get-Module -Name "$Binary")) {
            Write-Host "$Binary is not installed"
            Write-Host "Installing $Binary locally"
            Install-Module -Name "$Binary" -Scope CurrentUser
        }
    } else {
        Write-Host "Checking if $Binary is installed"
        if (-Not (Get-Command -Name "$Binary" -ErrorAction SilentlyContinue)) {
            Write-Host "$Binary is not installed"
            Write-Host "Please to install latest version of $Binary"
            Exit 1
        }
    }
    Write-Host "$Binary is installed" -ForegroundColor Green

    <#
    .SYNOPSIS
    Test if the binary is installed on the system.
    #>
}

Write-None
# Set output encoding to UTF-8
Write-Host "Setting output encoding to UTF-8" -ForegroundColor Green
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Test-Binary -Binary pip

Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted

# check if the script run from GitHub Actions
if ($isAction) {
    Write-Host "Script running from GitHub Actions"
} else {
    Write-Host "Script running locally"
}

# check if Set-PSEnv is installed
Write-None
Test-Binary -Binary Set-PSEnv -isModule

# check if PSGraphQL module is installed
Write-None
Test-Binary -Binary PSGraphQL -isModule

Write-None
Write-Host "Importing dotEnv file"
if (-Not($isAction)) {
    if (Test-Path -Path ".env") {
        Write-Host ".env file exists" -ForegroundColor Green
        Set-PsEnv
        Write-Host ".env file imported" -ForegroundColor Green
    } else {
        Write-None
        Write-Host ".env file does not exist, creating..." -ForegroundColor Red
        Copy-Item -Path ".env.example" -Destination ".env"
        Write-Host "Please to edit .env from your preferred text editor first and rerun the script." -ForegroundColor Red
        exit 1 # User requires to manually configure the file
    }
}

Import-Module "./Modules/Format-Json.psm1"

############################
# FUNCTIONS FOR EACH SITES #
############################

Function Get-AniListBackup {
    Write-None
    Write-Host "Creating directory for AniList"
    New-Item -ItemType Directory -Force -Path ./aniList

    Write-None
    Write-Host "Exporting AniList anime list"
    $aniListUsername = $Env:ANILIST_USERNAME
    $aniListUri = "https://graphql.anilist.co"
    $alAnimeBody = '
    query($name: String!){
        MediaListCollection(userName: $name, type: ANIME){
            lists{
                name
                isCustomList
                isSplitCompletedList
                entries{
                    ... mediaListEntry
                }
            }
        }
        User(name: $name){
            name
            id
            mediaListOptions{
                scoreFormat
            }
        }
    }

    fragment mediaListEntry on MediaList{
        mediaId
        status
        progress
        repeat
        notes
        priority
        hiddenFromStatusLists
        customLists
        advancedScores
        startedAt{
            year
            month
            day
        }
        completedAt{
            year
            month
            day
        }
        updatedAt
        createdAt
        media{
            idMal
            title{romaji native english}
        }
        score
    }
    '

    $alMangaBody = '
    query($name: String!){
        MediaListCollection(userName: $name, type: MANGA){
            lists{
                name
                isCustomList
                isSplitCompletedList
                entries{
                    ... mediaListEntry
                }
            }
        }
        User(name: $name){
            name
            id
            mediaListOptions{
                scoreFormat
            }
        }
    }

    fragment mediaListEntry on MediaList{
        mediaId
        status
        progress
        progressVolumes
        repeat
        notes
        priority
        hiddenFromStatusLists
        customLists
        advancedScores
        startedAt{
            year
            month
            day
        }
        completedAt{
            year
            month
            day
        }
        updatedAt
        createdAt
        media{
            idMal
            title{romaji native english}
        }
        score
    }
    '

    $alVariableRaw = '
    {
        "name": "anonymous"
    }
    '

    $alVariableFix = $alVariableRaw -replace "anonymous", $aniListUsername

    Invoke-GraphQLQuery -Uri $aniListUri -Query $alAnimeBody -Variable $alVariableFix -Raw > ./aniList/animeList.json

    Write-None
    Write-Host "Exporting AniList manga list"
    Invoke-GraphQLQuery -Uri $aniListUri -Query $alMangaBody -Variable $alVariableFix -Raw > ./aniList/mangaList.json
}

Function Get-AnimePlanetBackup {
    Write-None
    Write-Host "Creating directory for Anime-Planet"
    New-Item -ItemType Directory -Force -Path ./animePlanet

    Write-None
    Write-Host "Exporting Anime-Planet anime list"
    $apUsername = $Env:ANIMEPLANET_USERNAME
    $headers = @{
        Origin = "https://malscraper.azurewebsites.net";
        Referer = "https://malscraper.azurewebsites.net/";
    }
    Invoke-WebRequest -Uri "https://malscraper.azurewebsites.net/scrape" -UserAgent $userAgent -Headers $headers -Body "username=$apUsername&listtype=animeplanetanime&update_on_import=on" -Method Post -ContentType "application/x-www-form-urlencoded" -OutFile "./animePlanet/animeList.xml"

    Write-None
    Write-Host "Exporting Anime-Planet manga list"
    Invoke-WebRequest -Uri "https://malscraper.azurewebsites.net/scrape" -UserAgent $userAgent -Headers $headers -Body "username=$apUsername&listtype=animeplanetmanga&update_on_import=on" -Method Post -ContentType "application/x-www-form-urlencoded" -OutFile "./animePlanet/mangaList.xml"
}

Function Get-AnnictBackup {
    Write-None
    Write-Host "Creating directory for Annict"
    New-Item -ItemType Directory -Force -Path ./annict

    Write-None
    Write-Host "Exporting Annict anime list"

    $annictUri = "https://api.annict.com/graphql"
    $annictQuery = '
    query {
        viewer {
            username
            name
            id
            annictId
            watchingCount
            watchedCount
            wannaWatchCount
            onHoldCount
            stopWatchingCount
            recordsCount
            libraryEntries {
                edges {
                    node {
                        id
                        status {
                            state
                            createdAt
                        }
                        work {
                            title
                            titleEn
                            titleKana
                            titleRo
                            malAnimeId
                            annictId
                            id
                            seasonYear
                            seasonName
                            episodes {
                                edges {
                                    node {
                                        id
                                        title
                                        annictId
                                        number
                                        viewerDidTrack
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    '
    $annictHashTable = @{ "Authorization" = "Bearer $($Env:ANNICT_PERSONAL_ACCESS_TOKEN)" }
    Invoke-GraphQLQuery -Uri $annictUri -Query $annictQuery -Headers $annictHashTable -Raw > ./annict/animeList.json
}

Function Get-KitsuBackup {
    Write-None
    Write-Host "Creating directory for Kitsu"
    New-Item -ItemType Directory -Force -Path ./kitsu

    Write-None
    Write-Host "Exporting Kitsu anime list"
    $kitsuEmail = $Env:KITSU_EMAIL
    $kitsuPassword = [uri]::EscapeDataString("$Env:KITSU_PASSWORD")
    $kitsuParameters = @{
        grant_type = "password";
        username = $kitsuEmail;
        password = $kitsuPassword;
    }

    $kitsuAccessToken = (Invoke-WebRequest -Method Post -Body $kitsuParameters -Uri https://kitsu.io/api/oauth/token).Content | ConvertFrom-Json

    Invoke-WebRequest -Uri "https://kitsu.io/api/edge/library-entries/_xml?access_token=$($kitsuAccessToken.access_token)&kind=anime" -OutFile ./kitsu/animeList.xml

    Write-None
    Write-Host "Exporting Kitsu manga list"
    Invoke-WebRequest -Uri "https://kitsu.io/api/edge/library-entries/_xml?access_token=$($kitsuAccessToken.access_token)&kind=manga" -OutFile ./kitsu/mangaList.xml
}

Function Get-MangaUpdatesBackup {
    Write-None
    Write-Host "Creating directory for Baka-Updates' MangaUpdates"
    New-Item -ItemType Directory -Force -Path ./mangaUpdates

    Write-None
    Write-Host "Configuring session cookie"
    $muSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession

    $muCookie = New-Object System.Net.Cookie
    $muCookie.Name = "secure_session"
    $muCookie.Value = $Env:MANGAUPDATES_SESSION
    $muCookie.Domain = "www.mangaupdates.com"

    $muSession.Cookies.Add($muCookie);

    Write-Host "Exporting Baka-Updates' MangaUpdates list"
    Invoke-WebRequest -Method Get -WebSession $muSession -Uri "https://www.mangaupdates.com/mylist.html?act=export&list=complete" -OutFile "./mangaUpdates/completed.tsv"
    Invoke-WebRequest -Method Get -WebSession $muSession -Uri "https://www.mangaupdates.com/mylist.html?act=export&list=hold" -OutFile "./mangaUpdates/onHold.tsv"
    Invoke-WebRequest -Method Get -WebSession $muSession -Uri "https://www.mangaupdates.com/mylist.html?act=export&list=read" -OutFile "./mangaUpdates/currentlyReading.tsv"
    Invoke-WebRequest -Method Get -WebSession $muSession -Uri "https://www.mangaupdates.com/mylist.html?act=export&list=unfinished" -OutFile "./mangaUpdates/dropped.tsv"
    Invoke-WebRequest -Method Get -WebSession $muSession -Uri "https://www.mangaupdates.com/mylist.html?act=export&list=wish" -OutFile "./mangaUpdates/planToRead.tsv"

    $readmeValue = @"
This is a backup of your MangaUpdates list.
File naming on this folder is following MyAnimeList's naming convention:
| File Name            | On MangaUpdates |
| -------------------- | --------------- |
| completed.tsv        | Complete        |
| currentlyReading.tsv | Read            |
| dropped.tsv          | Unfinished      |
| onHold.tsv           | Hold            |
| planToRead.tsv       | Wish            |
"@

    New-Item -ItemType File -Path "./mangaUpdates/README" -Value $readmeValue
}

Function Get-MyAnimeListBackup {
    Write-None
    Write-Host "Creating directory for MyAnimeList"
    New-Item -ItemType Directory -Force -Path ./myAnimeList

    Write-None
    Write-Host "Exporting MyAnimeList anime list"
    $malUsername = $Env:MAL_USERNAME
    $headers = @{
        Origin = "https://malscraper.azurewebsites.net";
        Referer = "https://malscraper.azurewebsites.net/";
    }

    Invoke-WebRequest -Uri "https://malscraper.azurewebsites.net/scrape" -UserAgent $userAgent -Headers $headers -Body "username=$malUsername&listtype=anime&update_on_import=on" -Method Post -ContentType "application/x-www-form-urlencoded" -OutFile "./myAnimeList/animeList.xml"

    Write-None
    Write-Host "Exporting MyAnimeList manga list"
    Invoke-WebRequest -Uri "https://malscraper.azurewebsites.net/scrape" -UserAgent $userAgent -Headers $headers -Body "username=$malUsername&listtype=manga&update_on_import=on" -Method Post -ContentType "application/x-www-form-urlencoded" -OutFile "./myAnimeList/mangaList.xml"
}

Function Get-NotifyMoeBackup {
    Write-None
    Write-Host "Creating directory for Notify.moe"
    New-Item -ItemType Directory -Force -Path ./notifyMoe

    Write-None
    Write-Host "Exporting Notify.moe anime list"
    $notifyNickname = $Env:NOTIFYMOE_NICKNAME 

    # get csv
    Invoke-WebRequest -Method Get -Uri "https://notify.moe/+$($notifyNickname)/animelist/export/csv" -OutFile ./notifyMoe/animeList.csv
    # get json
    Invoke-WebRequest -Method Get -Uri "https://notify.moe/+$($notifyNickname)/animelist/export/json" -OutFile ./notifyMoe/animeList.json
    # get txt
    Invoke-WebRequest -Method Get -Uri "https://notify.moe/+$($notifyNickname)/animelist/export/txt" -OutFile ./notifyMoe/animeList.txt
}

Function Get-ShikimoriBackup {
    Write-None
    Write-Host "Creating directory for Shikimori"
    New-Item -ItemType Directory -Force -Path ./shikimori
    
    Write-None
    Write-Host "Exporting Shikimori anime list"
    $shikiKawaiSession = $Env:SHIKIMORI_KAWAI_SESSION
    $shikiUsername = $Env:SHIKIMORI_USERNAME
    $shikiSession = New-WebSession -Cookies @{
        "kawai_session" = $shikiKawaiSession
    } -For "https://shikimori.one/"
    Invoke-WebRequest -Uri "https://shikimori.one/$($shikiUsername)/list_export/animes.json" -Method Get -UserAgent $userAgent -Session $shikiSession -OutFile ./shikimori/animeList.json
    Invoke-WebRequest -Uri "https://shikimori.one/$($shikiUsername)/list_export/animes.xml" -Method Get -UserAgent $userAgent -Session $shikiSession -OutFile ./shikimori/animeList.xml

    Write-None
    Write-Host "Exporting Shikimori manga list"
    Invoke-WebRequest -Uri "https://shikimori.one/$($shikiUsername)/list_export/mangas.json" -Method Get -UserAgent $userAgent -Session $shikiSession -OutFile ./shikimori/mangaList.json
    Invoke-WebRequest -Uri "https://shikimori.one/$($shikiUsername)/list_export/mangas.xml" -Method Get -UserAgent $userAgent -Session $shikiSession -OutFile ./shikimori/mangaList.xml
}

Function Get-SimklBackup {
    Write-None
    Write-Host "Creating directory for Simkl"
    New-Item -ItemType Directory -Force -Path ./simkl
    
    Write-None
    Write-Host "Exporting SIMKL list"
    $simklClientId = $Env:SIMKL_CLIENT_ID
    $simklAccessToken = $Env:SIMKL_ACCESS_TOKEN

    Invoke-WebRequest -Method Get -ContentType "application/json" -Headers @{
        "Authorization" = "Bearer $($simklAccessToken)";
        "simkl-api-key" = $($simklClientId);
    } -Uri "https://api.simkl.com/sync/all-items/?episode_watched_at=yes" -OutFile "./simkl/data.json"
}

Function Get-TraktBackup {
    Write-None
    Write-Host "Creating directory for Trakt"
    New-Item -ItemType Directory -Force -Path ./trakt
    
    $traktUsername = $Env:TRAKT_USERNAME

    Write-None
    Write-Host "Exporting Trakt.tv data"
    # Code is based on https://github.com/seanbreckenridge/traktexport/blob/master/traktexport/__init__.py
    
    if (Get-Command -Name "traktexport" -ErrorAction SilentlyContinue) {
        Write-Host "Trakt Exporter Python Module is installed"
    } else {
        Write-Host "Installing Trakt Exporter Python Module"
        pip install traktexport
    }
    
    Write-Host "Configuring config file"
    
    $traktExportJson = "{`"CLIENT_ID`": `"$($Env:TRAKT_CLIENT_ID)`", `"CLIENT_SECRET`": `"$($Env:TRAKT_CLIENT_SECRET)`", `"OAUTH_TOKEN`": `"$($Env:TRAKT_OAUTH_TOKEN)`", `"OAUTH_REFRESH`": `"$($Env:TRAKT_OAUTH_REFRESH)`", `"OAUTH_EXPIRES_AT`": $($Env:TRAKT_OAUTH_EXPIRY)}"
    
    # Check if linux or windows
    if ($Env:XDG_DATA_HOME) {
        $dataDir = $Env:XDG_DATA_HOME
    } elseif ($isWindows) {
        $dataDir = "~/.traktexport"
    } else {
        $dataDir = "~/.local/share"
    }
    
    # Check if file exist
    if (Test-Path -Path "$dataDir/traktexport.json" -PathType Leaf) {
        Write-Host "Config file exists" -ForegroundColor Green
    } else {
        Write-Host "Config file does not exist" -ForegroundColor Red
        Write-Host "Creating config file" -ForegroundColor Yellow
        New-Item -Path "$dataDir/traktexport.json" -Force -ItemType File -Value $traktExportJson
    }
    
    traktexport export $traktUsername | Out-File "./trakt/data.json"
}

# Check each Environment Variable if filled, if not skip
if ($Env:ANILIST_USERNAME) { Get-AniListBackup }
if ($Env:ANIMEPLANET_USERNAME) { Get-AnimePlanetBackup }
if ($Env:ANNICT_PERSONAL_ACCESS_TOKEN) { Get-AnnictBackup }
if ($Env:KITSU_EMAIL) { Get-KitsuBackup }
if ($Env:MANGAUPDATES_SESSION) { Get-MangaUpdatesBackup }
if ($Env:MAL_USERNAME){ Get-MyAnimeListBackup }
if ($Env:NOTIFYMOE_NICKNAME) { Get-NotifyMoeBackup }
if ($Env:SHIKIMORI_KAWAI_SESSION) { Get-ShikimoriBackup }
if ($Env:SIMKL_CLIENT_ID) { Get-SimklBackup }
if ($Env:TRAKT_USERNAME) { Get-TraktBackup }

Write-None
Write-Host "Format JSON files"
Get-ChildItem -Path "*" -Filter "*.json" -File  -Recurse | ForEach-Object {
    Write-Host "Formatting $($_)"
    Format-Json -Json (Get-Content $_ -Raw).trim() -Indentation 2 -ErrorAction SilentlyContinue | Out-File -FilePath $_
}