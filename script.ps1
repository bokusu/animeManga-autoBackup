#!/usr/bin/env pwsh

# Set variable
$isAction = $null -ne $Env:GITHUB_WORKSPACE

# Check prerequisites

if (Get-Command -Name "curl" -ErrorAction SilentlyContinue) {
    Write-Host "curl is installed"
} else {
    Write-Host "curl is not installed"
    Write-Host "Installing curl"
    if ($isWindows) {
        choco feature enable -n allowGlobalConfirmation
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

if (Get-Command -Name "jq" -ErrorAction SilentlyContinue) {
    Write-Host "jq is installed"
} else {
    Write-Host "jq is not installed"
    Write-Host "Installing jq"
    if ($isWindows) {
        choco install jq
    } elseif ($isLinux) {
        sudo apt install jq
    } elseif ($isMac) {
        brew install jq
    } else {
        Write-Host "Unsupported OS"
        Exit 1
    }
}

Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted 

# check if the script run from GitHub Actions
if ($isAction) {
    Write-Host "Script running from GitHub Actions"
} else {
    Write-Host "Script running locally"
}

Write-Host "Checking if PS-SetEnv is installed"
if (-Not (Get-Module -Name "Set-PsEnv")) {
    Write-Host "Set-PsEnv is not installed"
    Write-Host "Installing Set-PsEnv locally"
    Install-Module -Name "Set-PsEnv" -Scope CurrentUser
}
Write-Host "PS-SetEnv is installed"

# check if PSGraphQL module is installed
Write-Host "Checking if PSGraphQL is installed"
if (-Not (Get-Module -Name "PSGraphQL")) {
    Write-Host "PSGraphQL is not installed"
    Write-Host "Installing PSGraphQL"
    Install-Module -Name "PSGraphQL" -Scope CurrentUser
}
Write-Host "PSGraphQL is installed"

Write-Host "Importing dotEnv file"
if ($isAction) {
$envData = @"
ANILIST_USERNAME=$Env:ANILIST_USERNAME
KITSU_USERID=$Env:KITSU_USERID
MAL_USERNAME=$Env:MAL_USERNAME
MANGAUPDATES_SESSION=$Env:MANGAUPDATES_SESSION
SHIKIMORI_KAWAI_SESSION=$Env:SHIKIMORI_KAWAI_SESSION
SHIKIMORI_USERNAME=$Env:SHIKIMORI_USERNAME
TRAKT_USERNAME=$Env:TRAKT_USERNAME
USER_AGENT=$Env:USER_AGENT
"@
$envData > ./.env
} else {
    if (Test-Path -Path ".env") {
        Write-Host ".env file exists" -ForegroundColor Green
    } else {
        Write-Host ".env file does not exist, creating..." -ForegroundColor Red
        Copy-Item -Path ".env.example" -Destination ".env"
        Write-Host "Please to edit .env from your preferred text editor first and rerun the script." -ForegroundColor Red
        exit 1 # User requires to manually configure the file
    }
}

Set-PsEnv

# Create directory
Write-Host "Creating directory"
New-Item -ItemType Directory -Force -Path ./aniList
New-Item -ItemType Directory -Force -Path ./kitsu
New-Item -ItemType Directory -Force -Path ./mangaUpdates
New-Item -ItemType Directory -Force -Path ./myAnimeList
New-Item -ItemType Directory -Force -Path ./shikimori
New-Item -ItemType Directory -Force -Path ./trakt

# Download MyAnimeList Anime List with MALScraper

$malUsername = $Env:MAL_USERNAME
$userAgent = $Env:USER_AGENT

Write-Host "Exporting MyAnimeList anime list"
curl -X POST -d "username=$malUsername&listtype=anime&update_on_import=on" -H "Origin: https://malscraper.azurewebsites.net" -H "Referrer: https://malscraper.azurewebsites.net/" -A "$userAgent" https://malscraper.azurewebsites.net/scrape > ./myAnimeList/animeList.xml

Write-Host "Exporting MyAnimeList manga list"
curl -X POST -d "username=$malUsername&listtype=manga&update_on_import=on" -H "Origin: https://malscraper.azurewebsites.net" -H "Referrer: https://malscraper.azurewebsites.net/" -A "$userAgent" https://malscraper.azurewebsites.net/scrape > ./myAnimeList/mangaList.xml

$kitsuUserId = $Env:KITSU_USERID

Write-Host "Exporting Kitsu anime list"
curl -X POST -d "username=$kitsuUserId&listtype=kitsuanime&update_on_import=on" -H "Origin: https://malscraper.azurewebsites.net" -H "Referrer: https://malscraper.azurewebsites.net/" -A "$userAgent" https://malscraper.azurewebsites.net/scrape > ./kitsu/animeList.xml

Write-Host "Exporting Kitsu manga list"
curl -X POST -d "username=$kitsuUserId&listtype=kitsumanga&update_on_import=on" -H "Origin: https://malscraper.azurewebsites.net" -H "Referrer: https://malscraper.azurewebsites.net/" -A "$userAgent" https://malscraper.azurewebsites.net/scrape > ./kitsu/mangaList.xml

$aniListUsername = $Env:ANILIST_USERNAME
$aniListUri = "https://graphql.anilist.co"

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

Wrote-Host "Exporting AniList manga list"
Invoke-GraphQLQuery -Uri $aniListUri -Query $alMangaBody -Variable $alVariableFix -Raw > ./aniList/mangaList.json

$shikiSession = $Env:SHIKIMORI_KAWAI_SESSION
$shikiUsername = $Env:SHIKIMORI_USERNAME

Write-Host "Exporting Shikimori anime list"
curl -X GET --cookie "_kawai_session=$shikiSession" -A "$userAgent" https://shikimori.one/$($shikiUsername)/list_export/animes.json > ./shikimori/animeList.json
curl -X GET --cookie "_kawai_session=$shikiSession" -A "$userAgent" https://shikimori.one/$($shikiUsername)/list_export/animes.xml > ./shikimori/animeList.xml

Write-Host "Exporting Shikimori manga list"
curl -X GET --cookie "_kawai_session=$shikiSession" -A "$userAgent" https://shikimori.one/$($shikiUsername)/list_export/mangas.json > ./shikimori/mangaList.json
curl -X GET --cookie "_kawai_session=$shikiSession" -A "$userAgent" https://shikimori.one/$($shikiUsername)/list_export/mangas.xml > ./shikimori/mangaList.xml

$traktUsername = $Env:TRAKT_USERNAME

Write-Host "Exporting Trakt.tv watch history"
Invoke-WebRequest -Uri "https://darekkay.com/service/trakt/trakt.php?username=$traktUsername" -OutFile "./trakt/trakt.zip"
Expand-Archive -Path "./trakt/trakt.zip" -DestinationPath "./trakt/"
Remove-Item -Path "./trakt/*.json" -Force # Delete old data
Get-ChildItem -Path "./trakt/" -Filter "*.txt" | ForEach-Object {$_ | Rename-Item -NewName $_.Name.Replace('txt', 'json')}
Remove-Item -Path "./trakt/trakt.zip" -Force

Write-Host "Exporting Baka-Updates' MangaUpdates list"

$muSession = $Env:MANGAUPDATES_SESSION

curl -X GET --cookie "secure_session=$muSession" -A "$userAgent" "https://www.mangaupdates.com/mylist.html?act=export&list=wish" > ./mangaUpdates/planToRead.csv
curl -X GET --cookie "secure_session=$muSession" -A "$userAgent" "https://www.mangaupdates.com/mylist.html?act=export&list=read" > ./mangaUpdates/currentlyReading.csv
curl -X GET --cookie "secure_session=$muSession" -A "$userAgent" "https://www.mangaupdates.com/mylist.html?act=export&list=complete" > ./mangaUpdates/completed.csv
curl -X GET --cookie "secure_session=$muSession" -A "$userAgent" "https://www.mangaupdates.com/mylist.html?act=export&list=unfinished" > ./mangaUpdates/dropped.csv
curl -X GET --cookie "secure_session=$muSession" -A "$userAgent" "https://www.mangaupdates.com/mylist.html?act=export&list=hold" > ./mangaUpdates/onHold.csv