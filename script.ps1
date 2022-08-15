#!/usr/bin/env pwsh

# Set variable
$isAction = $null -ne $Env:GITHUB_WORKSPACE

function Write-None {
    Write-Host ""
}

Write-None
# Set output encoding to UTF-8
Write-Host "Setting output encoding to UTF-8" -ForegroundColor Green
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Check prerequisites

if (Get-Command -Name "curl" -ErrorAction SilentlyContinue) {
    Write-Host "curl is installed"
} else {
    Write-Host "curl is not installed"
    Write-Host "Installing curl"
    if ($isWindows) {
        choco install curl
    } elseif ($isLinux) {
        sudo apt install curl
    } elseif ($isMac) {
        brew install curl
    } else {
        Write-Host "Unsupported OS"
        Exit 1
    }
}

if (Get-Command -Name "pip" -ErrorAction SilentlyContinue) {
    Write-Host "pip is installed"
} else {
    Write-Host "pip is not installed"
    Write-Host "Installing pip"
    if ($isWindows) {
        choco install python
    } elseif ($isLinux) {
        sudo apt install python3-pip
    } elseif ($isMac) {
        Write-Host "Please to install Python 3 manually" -ForegroundColor Red
        Exit 1
    } else {
        Write-Host "Unsupported OS"
        Exit 1
    }
}

Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted 

Write-None
# check if the script run from GitHub Actions
if ($isAction) {
    Write-Host "Script running from GitHub Actions"
} else {
    Write-Host "Script running locally"
}

Write-None
Write-Host "Checking if PS-SetEnv is installed"
if (-Not (Get-Module -Name "Set-PsEnv")) {
    Write-Host "Set-PsEnv is not installed"
    Write-Host "Installing Set-PsEnv locally"
    Install-Module -Name "Set-PsEnv" -Scope CurrentUser
}
Write-Host "Set-PsEnv is installed" -ForegroundColor Green

# check if PSGraphQL module is installed
Write-None
Write-Host "Checking if PSGraphQL is installed"
if (-Not (Get-Module -Name "PSGraphQL")) {
    Write-Host "PSGraphQL is not installed" -ForegroundColor Red
    Write-Host "Installing PSGraphQL"
    Install-Module -Name "PSGraphQL" -Scope CurrentUser
}
Write-Host "PSGraphQL is installed" -ForegroundColor Green

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

# Create directory
Write-None
Write-Host "Creating directory"
New-Item -ItemType Directory -Force -Path ./aniList
New-Item -ItemType Directory -Force -Path ./annict
New-Item -ItemType Directory -Force -Path ./kitsu
New-Item -ItemType Directory -Force -Path ./mangaUpdates
New-Item -ItemType Directory -Force -Path ./myAnimeList
New-Item -ItemType Directory -Force -Path ./notifyMoe
New-Item -ItemType Directory -Force -Path ./shikimori
New-Item -ItemType Directory -Force -Path ./simkl
New-Item -ItemType Directory -Force -Path ./trakt

# Download MyAnimeList Anime List with MALScraper

$malUsername = $Env:MAL_USERNAME
$userAgent = $Env:USER_AGENT

Write-None
Write-Host "Exporting MyAnimeList anime list"
curl -X POST -d "username=$malUsername&listtype=anime&update_on_import=on" -H "Origin: https://malscraper.azurewebsites.net" -H "Referrer: https://malscraper.azurewebsites.net/" -A "$userAgent" https://malscraper.azurewebsites.net/scrape > ./myAnimeList/animeList.xml

Write-None
Write-Host "Exporting MyAnimeList manga list"
curl -X POST -d "username=$malUsername&listtype=manga&update_on_import=on" -H "Origin: https://malscraper.azurewebsites.net" -H "Referrer: https://malscraper.azurewebsites.net/" -A "$userAgent" https://malscraper.azurewebsites.net/scrape > ./myAnimeList/mangaList.xml

$kitsuUserId = $Env:KITSU_USERID

Write-None
Write-Host "Exporting Kitsu anime list"
curl -X POST -d "username=$kitsuUserId&listtype=kitsuanime&update_on_import=on" -H "Origin: https://malscraper.azurewebsites.net" -H "Referrer: https://malscraper.azurewebsites.net/" -A "$userAgent" https://malscraper.azurewebsites.net/scrape > ./kitsu/animeList.xml

Write-None
Write-Host "Exporting Kitsu manga list"
curl -X POST -d "username=$kitsuUserId&listtype=kitsumanga&update_on_import=on" -H "Origin: https://malscraper.azurewebsites.net" -H "Referrer: https://malscraper.azurewebsites.net/" -A "$userAgent" https://malscraper.azurewebsites.net/scrape > ./kitsu/mangaList.xml

$aniListUsername = $Env:ANILIST_USERNAME
$aniListUri = "https://graphql.anilist.co"

Write-None
Write-Host "Exporting AniList anime list"
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

$shikiSession = $Env:SHIKIMORI_KAWAI_SESSION
$shikiUsername = $Env:SHIKIMORI_USERNAME

Write-None
Write-Host "Exporting Shikimori anime list"
curl -X GET --cookie "_kawai_session=$shikiSession" -A "$userAgent" https://shikimori.one/$($shikiUsername)/list_export/animes.json > ./shikimori/animeList.json
curl -X GET --cookie "_kawai_session=$shikiSession" -A "$userAgent" https://shikimori.one/$($shikiUsername)/list_export/animes.xml > ./shikimori/animeList.xml

Write-None
Write-Host "Exporting Shikimori manga list"
curl -X GET --cookie "_kawai_session=$shikiSession" -A "$userAgent" https://shikimori.one/$($shikiUsername)/list_export/mangas.json > ./shikimori/mangaList.json
curl -X GET --cookie "_kawai_session=$shikiSession" -A "$userAgent" https://shikimori.one/$($shikiUsername)/list_export/mangas.xml > ./shikimori/mangaList.xml

Write-None
Write-Host "Exporting Notify.moe anime list"
$notifyNickname = $Env:NOTIFYMOE_NICKNAME 
<#
$notifyId = (curl -X GET -H "Content-Type: application/json" https://notify.moe/api/nicktouser/$notifyNickname | ConvertFrom-Json).userId
curl -X GET -H "Content-Type: application/json" https://notify.moe/api/animelist/$notifyId > ./notifyMoe/animeList.json
#>

# get csv
curl -X GET https://notify.moe/+$notifyNickname/animelist/export/csv > ./notifyMoe/animeList.csv
# get json
curl -X GET https://notify.moe/+$notifyNickname/animelist/export/json > ./notifyMoe/animeList.json
# get txt
curl -X GET https://notify.moe/+$notifyNickname/animelist/export/txt > ./notifyMoe/animeList.txt

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

Write-None
Write-Host "Exporting SIMKL list"
$simklClientId = $Env:SIMKL_CLIENT_ID
$simklAccessToken = $Env:SIMKL_ACCESS_TOKEN
curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $($simklAccessToken)" -H "simkl-api-key: $($simklClientId)" "https://api.simkl.com/sync/all-items/?episode_watched_at=yes" > ./simkl/data.json


Write-None
Write-Host "Exporting Baka-Updates' MangaUpdates list"

$muSession = $Env:MANGAUPDATES_SESSION

curl -X GET --cookie "secure_session=$muSession" -A "$userAgent" "https://www.mangaupdates.com/mylist.html?act=export&list=wish" > ./mangaUpdates/planToRead.csv
curl -X GET --cookie "secure_session=$muSession" -A "$userAgent" "https://www.mangaupdates.com/mylist.html?act=export&list=read" > ./mangaUpdates/currentlyReading.csv
curl -X GET --cookie "secure_session=$muSession" -A "$userAgent" "https://www.mangaupdates.com/mylist.html?act=export&list=complete" > ./mangaUpdates/completed.csv
curl -X GET --cookie "secure_session=$muSession" -A "$userAgent" "https://www.mangaupdates.com/mylist.html?act=export&list=unfinished" > ./mangaUpdates/dropped.csv
curl -X GET --cookie "secure_session=$muSession" -A "$userAgent" "https://www.mangaupdates.com/mylist.html?act=export&list=hold" > ./mangaUpdates/onHold.csv

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
}'
$annictHashTable = @{ "Authorization" = "Bearer $($Env:ANNICT_PERSONAL_ACCESS_TOKEN)" }
Invoke-GraphQLQuery -Uri $annictUri -Query $annictQuery -Headers $annictHashTable -Raw > ./annict/animeList.json

Write-None
Write-Host "Format JSON files"
Get-ChildItem -Path "*" -Filter "*.json" -File  -Recurse | ForEach-Object {
    Write-Host "Formatting $($_)"
    Format-Json -Json (Get-Content $_ -Raw).trim() -Indentation 2 -ErrorAction SilentlyContinue | Out-File -FilePath $_
}