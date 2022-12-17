#!/usr/bin/env pwsh
#Requires -Version 7

# Add -Verbose
[CmdletBinding()]
Param()

# Set variable
$isAction = $null -ne $Env:GITHUB_WORKSPACE
[int]$getCurrentEpoch = Get-Date -UFormat '%s' -Millisecond 0

Function New-WebSession {
    Param(
        [Hashtable]$Cookies,
        [Uri]$For
    )

    $newSession = [Microsoft.PowerShell.Commands.WebRequestSession]::New()

    ForEach ($entry in $Cookies.GetEnumerator()) {
        $cookie = [System.Net.Cookie]::New($entry.Name, $entry.Value)
        If ($For) {
            $newSession.Cookies.Add([uri]::New($For, '/'), $cookie)
        }
        Else {
            $newSession.Cookies.Add($cookie)
        }
    }

    Return $newSession
}

Function Test-Binary {
    [CmdletBinding()]
    Param(
        [string]$Binary,
        [Switch]$isModule,
        [Switch]$isNuGet
    )

    If ($isModule) {
        Write-Host "`nChecking if $Binary module installed"
        If (-Not (Get-Package -Name "$Binary" -ErrorAction SilentlyContinue)) {
            Write-Host "$Binary is not installed"
            Write-Host "Installing $Binary locally"
            Install-Module -Name "$Binary" -Scope CurrentUser
        }
    }
    ElseIf ($isNuGet) {
        Write-Host "`nChecking if $Binary package is installed"
        If (-Not (Get-Package -Name "$Binary" -ErrorAction SilentlyContinue)) {
            Write-Host "$Binary is not installed"
            Write-Host "Installing $Binary locally"
            Install-Package "$Binary" -Scope CurrentUser -Source 'nuget.org'
        }
    }
    Else {
        Write-Host "`nChecking if $Binary is installed"
        If (-Not (Get-Command -Name "$Binary" -ErrorAction SilentlyContinue)) {
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

Function Add-Directory {
    Param(
        [string]$Path,
        [string]$Name
    )
    Write-Host "`nCreating directory for $Name"
    If (-Not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force
    }
}

Function Confirm-UserAgent {
    If ($null -eq $Env:USER_AGENT) {
        Write-Host "User agent is not set" -ForegroundColor Red
        Write-Host "Please set user agent variable to continue"
        Exit 1
    }
    Write-Host "User agent is set to $Env:USER_AGENT" -ForegroundColor Green
}

# Set output encoding to UTF-8
Write-Host "Setting output encoding to UTF-8" -ForegroundColor Green
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Test-Binary -Binary pip -ErrorAction Break
Write-Host "Installing required Python packages"
If ($IsLinux -Or $IsMacOS) {
    python3 -m pip install -r requirements.txt
}
Else {
    python -m pip install -r requirements.txt
}

If ((Get-PSRepository -Name PSGallery -ErrorAction SilentlyContinue).InstallationPolicy -ne 'Trusted') {
    Write-Verbose -Message "Configuring PSGallery to Trusted repo"
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
}
Else {
    Write-Verbose -Message "PSGallery set to trusted"
}

# check if the script run from GitHub Actions
If ($isAction) {
    Write-Host "Script running from GitHub Actions"
}
Else {
    Write-Host "Script running locally"
}

$PSRequiredPkgs = @(
    'PSGraphQL'
    'powershell-yaml'
)

If (!($isAction)) {
    $PSLocalPkgs = @(
        'Set-PSEnv'
    )
    ForEach ($pkg in $PSLocalPkgs) {
        $PSRequiredPkgs += $pkg
    }
}

ForEach ($pkg in $PSRequiredPkgs) {
    Test-Binary -Binary $pkg -isModule
}

Write-Host "`nImporting dotEnv file"
If (-Not($isAction)) {
    If (Test-Path -Path ".env") {
        Write-Host ".env file exists" -ForegroundColor Green
    }
    Else {
        Write-Host ".env file does not exist, creating..." -ForegroundColor Red
        ./Modules/Environment-Generator.ps1
    }
    Set-PsEnv
    Write-Host ".env file imported" -ForegroundColor Green
}

Import-Module "./Modules/Format-Json.psm1"
Import-Module "./Modules/Convert-AniListXML.psm1"
Import-Module "./Modules/Convert-KaizeXML.psm1"

############################
# FUNCTIONS FOR EACH SITES #
############################

Function Get-AniListBackup {
    Add-Directory -Path ./aniList -Name AniList

    $alExpiry = $Env:ANILIST_OAUTH_EXPIRY
    $getCurrentEpoch = (Get-Date -UFormat %s)

    If ($alExpiry -ge $getCurrentEpoch) {
        Write-Host @"
Your Trakt credential expired, please reinitialize by running:
./Modules/Get-AniListAuth.ps1
"@ -ForegroundColor Red
        Break
    }
    Else {
        Write-Host "`nExporting AniList anime list in JSON"
        $aniListUsername = $Env:ANILIST_USERNAME
        $aniListUri = "https://graphql.anilist.co"
        $alAnimeBody = @'
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
        episodes
        format
        countryOfOrigin
        duration
        seasonYear
        season
        duration
    }
    score
    private
}
'@

        $alMangaBody = @'
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
        volumes
        chapters
        format
        countryOfOrigin
    }
    score
    private
}
'@

        $alVariableFix = @{
            name = $aniListUsername
        } | ConvertTo-Json

        $alHead = @{
            Authorization = "Bearer $($Env:ANILIST_ACCESS_TOKEN)"
        }

        Invoke-GraphQLQuery -Uri $aniListUri -Query $alAnimeBody -Variable $alVariableFix -Raw -Headers $alHead | Out-File -Path ./aniList/animeList.json -Encoding utf8

        Write-Host "`nExporting AniList manga list in JSON"
        Invoke-GraphQLQuery -Uri $aniListUri -Query $alMangaBody -Variable $alVariableFix -Raw -Headers $alHead  | Out-File -Path ./aniList/mangaList.json -Encoding utf8

        Write-Host "`nExporting AniList anime list in XML"

        Convert-AniListXML -ErrorAction SilentlyContinue | Out-File -FilePath "./aniList/animeList.xml" -Encoding UTF8 -Force

        Write-Host "`nExporting AniList manga list in XML"
        Convert-AniListXML -isManga -Path './aniList/mangaList.json' -ErrorAction SilentlyContinue | Out-File -FilePath "./aniList/mangaList.xml" -Encoding UTF8 -Force
    }
}

Function Get-AnimePlanetBackup {
    Add-Directory -Path ./animePlanet -Name Anime-Planet

    Write-Host "`nExporting Anime-Planet anime list"
    $apUsername = $Env:ANIMEPLANET_USERNAME
    $headers = @{
        Origin  = "https://malscraper.azurewebsites.net";
        Referer = "https://malscraper.azurewebsites.net/";
    }
    Invoke-WebRequest -Uri "https://malscraper.azurewebsites.net/scrape" -UserAgent $userAgent -Headers $headers -Body "username=$apUsername&listtype=animeplanetanime&update_on_import=on" -Method Post -ContentType "application/x-www-form-urlencoded" -OutFile "./animePlanet/animeList.xml"

    Write-Host "`nExporting Anime-Planet manga list"
    Invoke-WebRequest -Uri "https://malscraper.azurewebsites.net/scrape" -UserAgent $userAgent -Headers $headers -Body "username=$apUsername&listtype=animeplanetmanga&update_on_import=on" -Method Post -ContentType "application/x-www-form-urlencoded" -OutFile "./animePlanet/mangaList.xml"
}

Function Get-AnnictBackup {
    Add-Directory -Path ./annict -Name Annict

    Write-Host "`nExporting Annict anime list"

    $annictUri = "https://api.annict.com/graphql"
    $annictQuery = @'
query {
    viewer {
        username
        name
        annictId
        watchingCount
        watchedCount
        wannaWatchCount
        onHoldCount
        stopWatchingCount
        recordsCount
        libraryEntries {
            nodes {
                work {
                    id
                    annictId
                    title
                    titleEn
                    titleKana
                    titleRo
                    malAnimeId
                    syobocalTid
                    seasonYear
                    seasonName
                    episodesCount
                    viewerStatusState
                }
            }
        }
    }
}
'@
    $annictHashTable = @{ "Authorization" = "Bearer $($Env:ANNICT_PERSONAL_ACCESS_TOKEN)" }
    Invoke-GraphQLQuery -Uri $annictUri -Query $annictQuery -Headers $annictHashTable -Raw > ./annict/animeList.json
}

Function Get-BangumiBackup {
    Add-Directory -Path ./bangumi -Name "Bangumi.tv"

    $bgmExpiry = $Env:BANGUMI_PAT_EXPIRY
    $bgmExpiry = [DateTime]::Parse($bgmExpiry)

    If ($bgmExpiry -ge (Get-Date)) {
        Write-Host "`nBangumi Personal Access Token has expired, please refresh it"
        Break
    }
    Else {

        Write-Host "`nChecking Bangumi lists"
        # $bgmPAT = $Env:BANGUMI_PERSONAL_ACCESS_TOKEN
        # $bgmUserDetail = Invoke-RestMethod -Method Get -Uri "https://api.bgm.tv/v0/me" -Headers @{ Authorization = "Bearer $($bgmPat)"}
        # $bgmUsername = $bgmUserDetail.username
        $bgmUsername = $Env:BANGUMI_USERNAME
        $bgmApiAddress = "https://api.bgm.tv/v0/users/$($bgmUsername)/collections"

        $bgmAuth = @{
            Authorization = "Bearer $($Env:BANGUMI_PERSONAL_ACCESS_TOKEN)"
        }
        $off0lim1 = "&limit=1&offset=0"

        # Grab total titles to scrape
        $bgmManTotal = (Invoke-RestMethod -Method Get -Uri "$($bgmApiAddress)?subject_type=1$off0lim1" -Headers $bgmAuth).total
        $bgmAniTotal = (Invoke-RestMethod -Method Get -Uri "$($bgmApiAddress)?subject_type=2$off0lim1" -Headers $bgmAuth).total
        $bgmGmeTotal = (Invoke-RestMethod -Method Get -Uri "$($bgmApiAddress)?subject_type=4$off0lim1" -Headers $bgmAuth).total
        $bgmDrmTotal = (Invoke-RestMethod -Method Get -Uri "$($bgmApiAddress)?subject_type=6$off0lim1" -Headers $bgmAuth).total

        $bgmMan = @(); $bgmAni = @(); $bgmGme = @(); $bgmDrm = @();
        # Start loop for manga
        For ($page = 0; $page -lt $bgmManTotal; $page += 50) {
            Write-Host "`r[$(($page / 50) + 1)/$([Math]::Ceiling($bgmManTotal / 50))] Scraping Manga List" -NoNewline
            $bgmLists = Invoke-RestMethod -Method Get -Uri "$($bgmApiAddress)?subject_type=1&limit=50&offset=$($page)" -Headers $bgmAuth
            $bgmMan += $bgmLists.data
        }

        # Check if there are any items in the list
        If ($bgmMan.Count -gt 0) {
            Write-Host "`nExporting Bangumi manga list"
            $bgmMan | ConvertTo-Json -Depth 10 | Out-File "./bangumi/mangaList.json"
        }

        # Start loop for anime
        For ($page = 0; $page -lt $bgmAniTotal; $page += 50) {
            Write-Host "`r[$(($page / 50) + 1)/$([Math]::Ceiling($bgmAniTotal / 50))] Scraping Anime List" -NoNewline
            $bgmLists = Invoke-RestMethod -Method Get -Uri "$($bgmApiAddress)?subject_type=2&limit=50&offset=$($page)" -Headers $bgmAuth
            $bgmAni += $bgmLists.data
        }

        # Check if there are any items in the list
        If ($bgmAni.Count -gt 0) {
            Write-Host "`nExporting Bangumi anime list"
            $bgmAni | ConvertTo-Json -Depth 10 | Out-File "./bangumi/animeList.json"
        }

        # Start loop for games
        For ($page = 0; $page -lt $bgmGmeTotal; $page += 50) {
            Write-Host "`r[$(($page / 50) + 1)/$([Math]::Ceiling($bgmGmeTotal / 50))] Scraping Game List" -NoNewline
            $bgmLists = Invoke-RestMethod -Method Get -Uri "$($bgmApiAddress)?subject_type=4&limit=50&offset=$($page)" -Headers $bgmAuth
            $bgmGme += $bgmLists.data
        }

        # Check if there are any items in the list
        If ($bgmGme.Count -gt 0) {
            Write-Host "`nExporting Bangumi game list"
            $bgmGme | ConvertTo-Json -Depth 10 | Out-File "./bangumi/gameList.json"
        }

        # Start loop for drama
        For ($page = 0; $page -lt $bgmDrmTotal; $page += 50) {
            Write-Host "`r[$(($page / 50) + 1)/$([Math]::Ceiling($bgmDrmTotal / 50))] Scraping Drama List" -NoNewline
            $bgmLists = Invoke-RestMethod -Method Get -Uri "$($bgmApiAddress)?subject_type=6&limit=50&offset=$($page)" -Headers $bgmAuth
            $bgmDrm += $bgmLists.data
        }

        # Check if there are any items in the list
        If ($bgmDrm.Count -gt 0) {
            Write-Host "`nExporting Bangumi drama list"
            $bgmDrm | ConvertTo-Json -Depth 10 | Out-File "./bangumi/dramaList.json"
        }
    }
}

Function Get-KaizeBackup {
    Add-Directory -Path ./kaize -Name "Kaize.io"
    Write-Host "`nInitializing backup script"

    $scriptPath = "./Modules/Get-KaizeBackup.py"

    $kaizeUsername = $Env:KAIZE_USERNAME

    $kzAnimePath = "./kaize/animeList.json"
    $kzMangaPath = "./kaize/mangaList.json"

    Invoke-WebRequest -Method Get -Uri "https://raw.githubusercontent.com/nattadasu/KaizeListExporter/main/main.py" -OutFile $scriptPath

    If ($IsLinux -or $IsMacOS) {
        python3 $scriptPath -u $kaizeUsername -t anime -o "$($kzAnimePath)"
        python3 $scriptPath -u $kaizeUsername -t manga -o "$($kzMangaPath)"
    }
    Else {
        python $scriptPath -u $kaizeUsername -t anime -o "$($kzAnimePath)"
        python $scriptPath -u $kaizeUsername -t manga -o "$($kzMangaPath)"
    }

    Remove-Item $scriptPath
}

Function Get-KitsuBackup {
    Add-Directory -Path ./kitsu -Name Kitsu

    Write-Host "`nExporting Kitsu anime list"
    $kitsuEmail = $Env:KITSU_EMAIL
    $kitsuPassword = [uri]::EscapeDataString("$Env:KITSU_PASSWORD")
    $kitsuParameters = @{
        grant_type = "password";
        username   = $kitsuEmail;
        password   = $kitsuPassword;
    }

    $kitsuAccessToken = (Invoke-WebRequest -Method Post -Body $kitsuParameters -Uri https://kitsu.io/api/oauth/token).Content | ConvertFrom-Json

    Invoke-WebRequest -Uri "https://kitsu.io/api/edge/library-entries/_xml?access_token=$($kitsuAccessToken.access_token)&kind=anime" -OutFile ./kitsu/animeList.xml

    Write-Host "`nExporting Kitsu manga list"
    Invoke-WebRequest -Uri "https://kitsu.io/api/edge/library-entries/_xml?access_token=$($kitsuAccessToken.access_token)&kind=manga" -OutFile ./kitsu/mangaList.xml

    Convert-KaizeToMal -ErrorAction SilentlyContinue | Out-File -FilePath "./kaize/animeList.xml" -Encoding UTF8 -Force
}

Function Get-MangaDexBackup {
    Write-Warning -Message "This method (login via raw password) would be deprecated in future!`nThere is no ETA to implement OAuth2 using OpenID.`n`nSee more regarding to the issue at [MangaDex Announcement Discord Server (#api-changelog)](https://discord.com/channels/833598287574990850/850131706022461440/1050086432011731034)."
    Add-Directory -Path ./mangaDex -Name "MangaDex"
    $mdUsername = $Env:MANGADEX_USERNAME
    $mdPassword = $Env:MANGADEX_PASSWORD
    $mdBody = @{
        "username" = $mdUsername
        "password" = $mdPassword
    } | ConvertTo-Json

    $mdAuth = (Invoke-WebRequest -Uri "https://api.mangadex.org/auth/login" -Headers @{ "Accept" = "application/json" } -Method POST -Body $mdBody -ContentType "application/json" -UseBasicParsing).Content | ConvertFrom-Json
    $mdSession = $mdAuth.token.session

    $mdHeaders = @{
        "Accept"        = "application/json"
        "Authorization" = "Bearer $mdSession"
    }

    # Grab User Follows
    $mdFollowsQuery = "https://api.mangadex.org/user/follows/manga?limit=1&offset=0"
    $mdFollows = ((Invoke-WebRequest -Uri $mdFollowsQuery -Headers $mdHeaders -UseBasicParsing).Content | ConvertFrom-Json)

    Write-Host ""
    $mdFollowsData = @()
    For ($i = 0; $i -lt $mdFollows.total; $i += 100) {
        Write-Host "`rGrabbing your manga follow lists, page ($([Math]::Floor(($i + 100) / 100))/$([Math]::Ceiling($mdFollows.total / 100)))" -NoNewLine
        $mdFollowsQuery = "https://api.mangadex.org/user/follows/manga?limit=100&offset=$($i)"
        $mdFollows = ((Invoke-WebRequest -Uri $mdFollowsQuery -Headers $mdHeaders -UseBasicParsing).Content | ConvertFrom-Json)
        $mdFollowsData += $mdFollows.data
    }

    # Used for debugging requests
    # $mdFollowsData | ConvertTo-Json -Depth 10 | Out-File ./mangaDex/mdex.json

    # Grab User Manga Status
    Write-Host "`n`nGrabbing reading statuses"
    $mdMangaStatusQuery = "https://api.mangadex.org/manga/status"
    $mdMangaStatus = ((Invoke-WebRequest -Uri $mdMangaStatusQuery -Headers $mdHeaders -UseBasicParsing).Content | ConvertFrom-Json).statuses

    # Grab User Rating
    $mangaData = @()
    $malReading = 0; $malCompleted = 0; $malOnHold = 0; $malDropped = 0; $malPlanToRead = 0

    Write-Host ""
    $n = 1
    ForEach ($manga in $mdFollowsData) {
        $mangaId = $manga.id
        $mangaTitle = If (($Null -eq $manga.attributes.title.en) -Or ($manga.attributes.title.en -eq '')) { If (($Null -eq $manga.attributes.title.ja) -Or ($manga.attributes.title.ja -eq '')) { $manga.attributes.title.'ja-ro' } Else { $manga.attributes.title.ja } } Else { $manga.attributes.title.en }
        $mangaVolumes = If (($Null -eq $manga.attributes.lastVolume) -Or ($manga.attributes.lastVolume -eq '')) { 0 } Else { $manga.attributes.lastVolume }
        $mangaChaptersLogic = If (($Null -eq $manga.attributes.lastChapter) -Or ($manga.attributes.lastChapter -eq '')) { 0 } Else { $manga.attributes.lastChapter }
        $mangaChapters = [Math]::ceiling($mangaChaptersLogic)
        Write-Host "`r[$($n)/$($mdFollowsData.Count)] Grabbing rating for $($mangaTitle) ($($mangaId))" -NoNewline
        $mdRatingQuery = "https://api.mangadex.org/rating?manga%5B%5D=$($mangaId)"
        $mdRating = ((Invoke-WebRequest -Uri $mdRatingQuery -Headers $mdHeaders -UseBasicParsing).Content | ConvertFrom-Json).ratings
        $mdScore = If (($Null -eq $mdRating.$mangaId.rating) -Or ($mdRating.$mangaId.rating -eq '')) { "0" } Else { $mdRating.$mangaId.rating }
        If ($mdMangaStatus.$mangaId -eq 'completed') {
            $mdReadVol = $mangaVolumes
            $mdReadCh = $mangaChapters
        }
        Else {
            $mdReadVol = 0
            $mdReadCh = 0
        }
        $rawData = [Ordered]@{
            id       = $mangaId
            title    = [String]$mangaTitle
            status   = $mdMangaStatus.$mangaId
            upstream = @{
                volume  = [int]$mangaVolumes
                chapter = [int]$mangaChaptersLogic
            }
            current  = @{
                volume  = [int]$mdReadVol
                chapter = [int]$mdReadCh
            }
            rating   = $mdScore
        }
        $mangaData += [PSCustomObject]$rawData
        Switch ($mdMangaStatus.$mangaId) {
            "reading" {
                $malReading++
                $malStatus = "Reading"
            }
            "completed" {
                $malCompleted++
                $malStatus = "Completed"
            }
            "on_hold" {
                $malOnHold++
                $malStatus = "On-Hold"
            }
            "dropped" {
                $malDropped++
                $malStatus = "Dropped"
            }
            "plan_to_read" {
                $malPlanToRead++
                $malStatus = "Plan to Read"
            }
        }

        $malCommons = @"
        <manga_title><![CDATA[$($mangaTitle)]]></manga_title>
        <manga_volumes>$($mangaVolumes)</manga_volumes>
        <manga_chapters>$($mangaChapters)</manga_chapters>
        <my_status>$($malStatus)</my_status>
        <my_score>$($mdScore)</my_score>
        <my_read_volumes>$($mdReadVol)</my_read_volumes>
        <my_read_chapters>$($mdReadCh)</my_read_chapters>
        <my_times_read>0</my_times_read>
        <my_reread_value>Low</my_reread_value>
        <my_start_date>0000-00-00</my_start_date>
        <my_finish_date>0000-00-00</my_finish_date>
        <update_on_import>1</update_on_import>
"@
        # Count MyAnimeList stats
        If ($Null -ne $manga.attributes.links.mal) {
            # Exporting Manga as MyAnimeList format
            $mdToMal += @"
`n    <manga>
        <manga_mangadb_id>$($manga.attributes.links.mal)</manga_mangadb_id>
        <!--mangadex_chapters_read>$($mangaChaptersLogic)</mangadex_chapters_read-->
$($malCommons)
    </manga>
"@
        }
        Else {
            $noEntry += @"
`n        - [$($mangaId)] $($mangaTitle)
"@
            $mdToMal += @"
`n    <!--manga>
        <manga_mangadexdb_id>$($mangaId)</manga_mangadexdb_id>
        <mangadex_chapters_read>$($mangaChaptersLogic)</mangadex_chapters_read>
$($malCommons)
    </manga-->
"@
        }
        $n++
    }

    $ReadMe = @"
This is a backup of your MangaDex account.
It contains your follows and your reading status.

However, due to MangaDex nature, we unable to determine the last chapter you read.

In this folder, you will get:
* mangaList-MALFormat.xml: A list of all your follows in MyAnimeList format, can be used to import to MyAnimeList or other services that support MyAnimeList format.
* mangaList.json: A list of all your follows, can not be used to import to other services.
* mangaList.yaml: YAML version of the above, can not be used to import to other services.
"@
    $ReadMe | Out-File -FilePath "./mangaDex/README.txt" -Encoding UTF8 -Force

    Write-Host "`n`nExporting MangaDex Follow List"
    $mangaData | ConvertTo-Yaml | Out-File -FilePath "./mangaDex/mangaList.yaml" -Encoding UTF8 -Force
    $mangaData | ConvertTo-Json | Out-File -FilePath "./mangaDex/mangaList.json" -Encoding UTF8 -Force

    Write-Host "Converting MangaDex Follow List to MyAnimeList XML format"
    $mdToMalXML = @"
<?xml version="1.0" encoding="UTF-8" ?>
<myanimelist>
    <myinfo>
        <user_id></user_id>
        <user_export_type>2</user_export_type>
        <user_total_manga>$($malReading + $malCompleted + $malOnHold + $malDropped + $malPlanToRead)</user_total_manga>
        <!--user_total_mangadex_manga>$($mdFollowsData.Count)</user_total_mangadex_manga-->
        <user_total_reading>$($malReading)</user_total_reading>
        <user_total_completed>$($malCompleted)</user_total_completed>
        <user_total_onhold>$($malOnHold)</user_total_onhold>
        <user_total_dropped>$($malDropped)</user_total_dropped>
        <user_total_plantoread>$($malPlanToRead)</user_total_plantoread>
    </myinfo>

    <!--
        Created by GitHub:nattadasu/animeManga-autoBackup
        Exported at $(Get-Date -Format "yyyy-MM-dd HH:mm:ss") $((Get-TimeZone).Id)
    -->

    <!--Unindexed Manga on MAL
        Please to check thoroughly as MangaDex is not always link MAL ID on their manga entry
        Format:
        - [MANGADEX MANGA UUID] Manga Title
        ========================================$($noEntry)
    -->

"@
    $mdToMalXML += $mdToMal
    $mdToMalXML += "`n</myanimelist>"

    $mdToMalXML | Out-File -FilePath "./mangaDex/mangaList-MALFormat.xml" -Encoding UTF8 -Force
}

Function Get-MangaUpdatesBackup {
    Add-Directory -Path ./mangaUpdates -Name "Baka Updates' Manga-Updates"

    # Check if user uses old method, if not, create access token
    If ($Env:MANGAUPDATES_USERNAME) {
        $muCredential = @{
            username = "$($Env:MANGAUPDATES_USERNAME)";
            password = "$($Env:MANGAUPDATES_PASSWORD)"
        } | ConvertTo-Json
        $muReqToken = (Invoke-WebRequest -Method Put -Uri "https://api.mangaupdates.com/v1/account/login" -Body $muCredential -ContentType "application/json").Content | ConvertFrom-Json
        $muToken = $muReqToken.context.session_token
    }
    Else {
        $muToken = $Env:MANGAUPDATES_SESSION
    }

    Write-Host "`nConfiguring session cookie"
    $muSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession

    $muCookie = New-Object System.Net.Cookie
    $muCookie.Name = "secure_session"
    $muCookie.Value = $muToken
    $muCookie.Domain = "www.mangaupdates.com"

    $muSession.Cookies.Add($muCookie);

    Write-Host "Exporting Baka-Updates' MangaUpdates list"

    # Add automated download
    $muLists = @(
        @{complete = "completed" }
        @{hold = "onHold" }
        @{read = "currentlyReading" }
        @{unfinished = "dropped" }
        @{wish = "planToRead" }
    )

    For ($loc = 0; $loc -lt 5; $loc++) {
        $muCat = $muLists[$loc].Keys
        $malCat = $muLists[$loc].Values
        Write-Host "Exporting $($muCat) list from MangaUpdates"
        $path = "./mangaUpdates/$($malCat).tsv"
        Invoke-WebRequest -Method Get -WebSession $muSession -Uri "https://www.mangaupdates.com/mylist.html?act=export&list=$($muCat)" -OutFile $path
        $csv = Get-Content -Path $path -Raw | ConvertFrom-Csv -Delimiter "`t"
        $csv | Select-Object -Property Series, Volume, Chapter, 'Date Changed', Rating | Export-Csv -Path $path -Delimiter `t -NoTypeInformation -Encoding utf8 -Force -UseQuotes AsNeeded
    }

    $readmeValue = @"
This is a backup of your MangaUpdates list.
By default, files were saved as `.tsv` files rather `.csv` to explicitly state to the program if the file uses tabs as a delimiter.
File naming on this folder is following MyAnimeList's naming convention:
| File Name            | On MangaUpdates |
| -------------------- | --------------- |
| completed.tsv        | Complete        |
| currentlyReading.tsv | Read            |
| dropped.tsv          | Unfinished      |
| onHold.tsv           | Hold            |
| planToRead.tsv       | Wish            |
"@
    $readmeValue | Out-File -FilePath ./mangaUpdates/README.txt
}

Function Get-MyAnimeListBackup {
    Add-Directory -Path ./myAnimeList -Name MyAnimeList

    Write-Host "`nExporting MyAnimeList anime list"
    $malUsername = $Env:MAL_USERNAME
    $headers = @{
        Origin  = "https://malscraper.azurewebsites.net";
        Referer = "https://malscraper.azurewebsites.net/";
    }

    Invoke-WebRequest -Uri "https://malscraper.azurewebsites.net/scrape" -UserAgent $userAgent -Headers $headers -Body "username=$malUsername&listtype=anime&update_on_import=on" -Method Post -ContentType "application/x-www-form-urlencoded" -OutFile "./myAnimeList/animeList.xml"

    Write-Host "`nExporting MyAnimeList manga list"
    Invoke-WebRequest -Uri "https://malscraper.azurewebsites.net/scrape" -UserAgent $userAgent -Headers $headers -Body "username=$malUsername&listtype=manga&update_on_import=on" -Method Post -ContentType "application/x-www-form-urlencoded" -OutFile "./myAnimeList/mangaList.xml"
}

Function Get-NotifyMoeBackup {
    Add-Directory -Path ./notifyMoe -Name "Notify.moe"

    Write-Host "`nExporting Notify.moe anime list"
    $notifyNickname = $Env:NOTIFYMOE_NICKNAME

    # get json
    Invoke-WebRequest -Method Get -Uri "https://notify.moe/+$($notifyNickname)/animelist/export/json" -OutFile ./notifyMoe/animeList.json

    $animeData = Get-Content -Path ./notifyMoe/animeList.json -Raw | ConvertFrom-Json

    [array]$animeCsv = @(); $animeTxt = ""; $animeIndex = ""
    $finished = 0; $dropped = 0; $current = 0; $planned = 0; $paused = 0; $n = 0
    ForEach ($entry in $animeData.items) {
        $n++
        Write-Host "`r[$($n)/$($animeData.items.Count)] Geting Data for (https://notify.moe/anime/$($entry.animeId))" -NoNewline
        $dbEntry = (Invoke-WebRequest -Method Get -Uri "https://notify.moe/api/anime/$($entry.animeId)").Content | ConvertFrom-Json
        ForEach ($service in $dbEntry.mappings) {
            If ($service.service -eq 'myanimelist/anime') {
                $malId = $service.serviceId
            }
        }
        $aniTitle = $dbEntry.title.canonical
        $overall = If (!($entry.rating.overall)) { 0 } Else { $entry.rating.overall }
        $story = If (!($entry.rating.story)) { 0 } Else { $entry.rating.story }
        $visual = If (!($entry.rating.visuals)) { 0 } Else { $entry.rating.visual }
        $soundtrack = If (!($entry.rating.soundtrack)) { 0 } Else { $entry.rating.soundtrack }
        $animeCsv += @{
            Id         = $entry.animeId
            Title      = $aniTitle
            Status     = $entry.status
            Episodes   = $entry.episodes
            Overall    = $overall
            Story      = $story
            Visual     = $visual
            Soundtrack = $soundtrack
            Rewatched  = $entry.rewatchCount
        }

        $animeTxt += @"
1. Title: $($aniTitle)\
   ID: ``$($entry.animeId)``\
   Status: $($entry.status)\
   Episodes: $($entry.episodes)\
   Overall: $($overall)\
   Story: $($story)\
   Visual: $($visual)\
   Soundtrack: $($soundtrack)\
   Rewatched: $($entry.rewatchCount)\
   Notes: $($entry.notes)`n`n
"@

        $status = Switch ($entry.status) {
            "completed" { "Completed"; $finished++ }
            "planned" { "Plan to Watch"; $planned++ }
            "watching" { "Watching"; $current++ }
            "dropped" { "Dropped"; $dropped++ }
            "hold" { "On-Hold"; $paused++ }
        }

        $commonXml = @"
<series_title><![CDATA[$($aniTitle)]]></series_title>
        <series_episodes>$($db.episodeCount)</series_episodes>
        <my_watched_episodes>$(If (!($anime.last_watched)) { "0" } Else{$anime.last_watched.Replace('E','')})</my_watched_episodes>
        <my_score>$([Math]::Floor($entry.rating.overall))</my_score>
        <my_status>$($status)</my_status>
        <my_start_date>0000-00-00</my_start_date>
        <my_finish_date>0000-00-00</my_finish_date>
        <my_tags><![CDATA[$($entry.notes)]]></my_tags>
        <my_comments><![CDATA[$($entry.notes)]]></my_comments>
        <update_on_import>1</update_on_import>
"@
        # Replace possibly breakable URL encoded Base64 for XML comment to original state
        $safeNotifyId = $entry.animeId -replace '-', '&#45;' -replace '_', '&#95;'
        $animeIndex += @"
`n    <anime>
        <series_animedb_id>$($malId)</series_animedb_id>
        <!--series_notify_id><![CDATA[$($safeNotifyId)]]></series_notify_id-->
        $($commonXml)
    </anime>
"@
    }

    $animeCsv | Select-Object -Property Id, Title, Status, Episodes, Overall, Story, Visual, Soundtrack, Rewatched | Export-Csv -UseQuotes AsNeeded -Path ./notifyMoe/animeList.csv -Encoding utf8 -Force
    "# Notify.moe Watchlist`n`n" + $animeTxt | Out-File ./notifyMoe/animeList.md -Encoding utf8 -Force
    $animeTxt -Replace '\\\n', "`n" -Replace '1. Title', 'Title' -Replace '   ', '' | Out-File ./notifyMoe/animeList.txt -Encoding utf8 -Force

    Write-Host "`nExporting Notify.moe watchlist to MAL-XML"
    $xmlData = @"
<?xml version="1.0" encoding="UTF-8" ?>
<myanimelist>
    <myinfo>
        <user_id></user_id>
        <user_export_type>1</user_export_type>
        <user_total_anime>$($n)</user_total_anime>
        <user_total_plantowatch>$($planned)</user_total_plantowatch>
        <user_total_watching>$($current)</user_total_watching>
        <user_total_completed>$($finished)</user_total_completed>
        <user_total_onhold>$($paused)</user_total_onhold>
        <user_total_dropped>$($dropped)</user_total_dropped>
    </myinfo>

    <!--
        Created by GitHub:nattadasu/animeManga-autoBackup
        Exported at $(Get-Date -Format "yyyy-MM-dd HH:mm:ss") $((Get-TimeZone).Id)
    -->

"@

    $xmlData += $animeIndex
    $xmlData += "`n</myanimelist>"

    $xmlData | Out-File ./notifyMoe/animeList.xml -Encoding utf8 -Force

}

Function Get-OtakOtakuBackup {
    Add-Directory -Path ./otakOtaku -Name "Otak Otaku"
    $otakUsername = $Env:OTAKOTAKU_USERNAME

    # Grabbing UID
    $getUserContent = (Invoke-WebRequest -Uri "https://otakotaku.com/user/$($otakUsername)").Content
    $findIdUser = [Regex]::Match($getUserContent, "var ID_USER = '[\d]+'").Value
    [int]$otakUid = [Regex]::Match($findIdUser, '[\d]+').Value

    # Checking total anime
    $totalAnimeJson = curl 'https://otakotaku.com/internal/score/anime_skor'  -H 'content-type: application/x-www-form-urlencoded; charset=UTF-8'  -H 'dnt: 1'  -H 'origin: https://otakotaku.com'  -H "referer: https://otakotaku.com/user/$($otakUsername)"  -H 'sec-fetch-dest: empty'  -H 'sec-fetch-mode: cors'  -H 'sec-fetch-site: same-origin'  -H 'sec-gpc: 1'  -H "user-agent: $($userAgent)" -H 'x-requested-with: XMLHttpRequest' --data-raw "id_user=$($otakUid)&order=waktu_simpan+desc&limit=1&index=0" --compressed --silent
    [int]$totalAnime = ($totalAnimeJson | ConvertFrom-Json).meta.total

    $animeData = @()
    For ($n = 0; $n -le $totalAnime; $n += 10) {
        Write-Host "`r[$(($n + 10) / 10)/$([Math]::Ceiling($totalAnime / 10))] Grabbing anime data from Otak Otaku" -NoNewline
        $animeJson = curl 'https://otakotaku.com/internal/score/anime_skor'  -H 'content-type: application/x-www-form-urlencoded; charset=UTF-8'  -H 'dnt: 1'  -H 'origin: https://otakotaku.com'  -H "referer: https://otakotaku.com/user/$($otakUsername)"  -H 'sec-fetch-dest: empty'  -H 'sec-fetch-mode: cors'  -H 'sec-fetch-site: same-origin'  -H 'sec-gpc: 1'  -H "user-agent: $($userAgent)" -H 'x-requested-with: XMLHttpRequest' --data-raw "id_user=$($otakUid)&order=waktu_simpan+desc&limit=10&index=$($n)" --compressed --silent
        $animeJson = ($animeJson | ConvertFrom-Json).data
        $animeData += $animeJson
    }
    $animeRaw = @{
        data = $animeData
        meta = @{
            total = [string]$totalAnime
        }
    }
    $animeRaw | ConvertTo-Json -Depth 10 | Out-File -FilePath "./otakOtaku/animeList.json" -Encoding UTF8 -Force

    # Create MAL compatible XML backup file
    $current = 0; $paused = 0; $dropped = 0; $completed = 0; $planned = 0; $arrItems = ""
    ForEach ($anime in $animeData) {
        $animeTitle = $anime.judul_anime
        $userProgress = $anime.progres
        [int]$userScore = If ($anime.skor -eq '-1') { 0 } Else { $anime.skor }
        $userStatus = Switch ($anime.slug_status_tonton) {
            'akan-ditonton' { 'Plan to Watch'; $planned++ }
            'ditunda' { 'On-Hold'; $paused++ }
            'sedang-ditonton' { 'Watching'; $current++ }
            'selesai-ditonton' { 'Completed'; $completed++ }
            'tidak-diselesaikan' { 'Dropped'; $dropped++ }
        }
        $userNotes = If ($Null -eq $anime.catatan) { '' } Else { $anime.catatan }
        $userTags = If ($Null -eq $anime.tag) { '' } Else { $anime.tag }
        $userStartedDate = If ($Null -eq $anime.tgl_mulai) { '0000-00-00' } Else { $anime.tanggal_mulai }
        $userEndedDate = If ($Null -eq $anime.tgl_selesai) { '0000-00-00' } Else { $anime.tanggal_selesai }
        $malId = $anime.mal_id_anime
        $otakuId = $anime.id_anime

        # Building array item
        $arrItems += @"
`n    <anime>
        <series_animedb_id>$($malId)</series_animedb_id>
        <!--series_otakotaku_id>$($otakuId)</series_otakotaku_id-->
        <series_title><![CDATA[$($animeTitle)]]></series_title>
        <my_watched_episodes>$($userProgress)</my_watched_episodes>
        <my_start_date>$($userStartedDate)</my_start_date>
        <my_finish_date>$($userEndedDate)</my_finish_date>
        <my_score>$($userScore)</my_score>
        <my_status>$($userStatus)</my_status>
        <my_tags><![CDATA[$($userTags)]]></my_tags>
        <my_comments><![CDATA[$($userNotes)]]></my_comments>
        <update_on_import>1</update_on_import>
    </anime>
"@
    }

    # Building XML
    $xmlData = @"
<?xml version="1.0" encoding="UTF-8"?>
<myanimelist>
    <myinfo>
        <user_id>$($animeData[0].id_user)</user_id>
        <user_name>$($otakUsername)</user_name>
        <user_export_type>1</user_export_type>
        <user_total_anime>$($totalAnime)</user_total_anime>
        <user_total_watching>$($current)</user_total_watching>
        <user_total_completed>$($completed)</user_total_completed>
        <user_total_onhold>$($paused)</user_total_onhold>
        <user_total_dropped>$($dropped)</user_total_dropped>
        <user_total_plantowatch>$($planned)</user_total_plantowatch>
    </myinfo>

    <!--
        Created by GitHub:nattadasu/animeManga-autoBackup
        Exported at $(Get-Date -Format "yyyy-MM-dd HH:mm:ss") $((Get-TimeZone).Id)
    -->

"@
    $xmlData += $arrItems
    $xmlData += "`n</myanimelist>"

    # Write XML to file
    $xmlData | Out-File -FilePath "./otakOtaku/animeList.xml" -Encoding utf8 -Force
}

Function Get-ShikimoriBackup {
    Add-Directory -Path ./shikimori -Name Shikimori

    Write-Host "`nExporting Shikimori anime list"
    $shikiKawaiSession = $Env:SHIKIMORI_KAWAI_SESSION
    $shikiUsername = $Env:SHIKIMORI_USERNAME
    $shikiSession = New-WebSession -Cookies @{
        "kawai_session" = $shikiKawaiSession
    } -For "https://shikimori.one/"
    Invoke-WebRequest -Uri "https://shikimori.one/$($shikiUsername)/list_export/animes.json" -Method Get -UserAgent $userAgent -Session $shikiSession -OutFile ./shikimori/animeList.json
    Invoke-WebRequest -Uri "https://shikimori.one/$($shikiUsername)/list_export/animes.xml" -Method Get -UserAgent $userAgent -Session $shikiSession -OutFile ./shikimori/animeList.xml

    Write-Host "`nExporting Shikimori manga list"
    Invoke-WebRequest -Uri "https://shikimori.one/$($shikiUsername)/list_export/mangas.json" -Method Get -UserAgent $userAgent -Session $shikiSession -OutFile ./shikimori/mangaList.json
    Invoke-WebRequest -Uri "https://shikimori.one/$($shikiUsername)/list_export/mangas.xml" -Method Get -UserAgent $userAgent -Session $shikiSession -OutFile ./shikimori/mangaList.xml
}

Function Get-SimklBackup {
    Add-Directory -Path ./simkl -Name SIMKL

    Write-Host "`nExporting SIMKL list"
    $simklClientId = $Env:SIMKL_CLIENT_ID
    $simklAccessToken = $Env:SIMKL_ACCESS_TOKEN

    Invoke-WebRequest -Method Get -ContentType "application/json" -Headers @{
        "Authorization" = "Bearer $($simklAccessToken)";
        "simkl-api-key" = $($simklClientId);
    } -Uri "https://api.simkl.com/sync/all-items/?episode_watched_at=yes" -OutFile "./simkl/data.json"

    # Create a zip file for SIMKL allows importing it back
    Write-Host "`nCreating SIMKL zip file"
    [System.IO.File]::ReadAllText("./simkl/data.json").Replace('/', '\/') | Out-File -FilePath ./simkl/SimklBackup.json -Encoding utf8 -Force
    Compress-Archive -Path ./simkl/SimklBackup.json -Destination ./simkl/SimklBackup.zip -CompressionLevel Optimal -Force
    Remove-Item -Path ./simkl/SimklBackup.json

    # Create another export format
    $simklJson = Get-Content -Path ./simkl/data.json -Raw | ConvertFrom-Json

    Write-Host "`nPreparing to convert SIMKL watchlist to CSV format"
    [array]$entries = @()
    # Convert to CSV format
    ForEach ($mov in $simklJson.movies) {
        Write-Verbose "Converting movie: $($mov.movie.title) ($($mov.movie.ids.simkl))"
        $movStatus = Switch ($mov.status) {
            'completed' { 'completed' }
            'hold' { 'on hold' }
            'watching' { 'watching' }
            'plantowatch' { 'plan to watch' }
            'notinteresting' { 'dropped' }
        }
        $entries += @{
            SIMKL_ID      = $mov.movie.ids.simkl
            Title         = $mov.movie.title
            Type          = 'movie'
            Year          = If (!($mov.movie.year)) { "0" } Else { $mov.movie.year }
            Watchlist     = $movStatus
            LastEpWatched = ''
            WatchedDate   = $mov.last_watched_at
            Rating        = If (!($mov.user_rating)) { "" } Else { $mov.user_rating }
            Memo          = ''
            TVDB          = If (!($mov.movie.ids.tvdb)) { "" } Else { $mov.movie.ids.tvdb }
            TMDB          = If (!($mov.movie.ids.tmdb)) { "" } Else { $mov.movie.ids.tmdb }
            IMDB          = If (!($mov.movie.ids.imdb)) { "" } Else { $mov.movie.ids.imdb }
            MAL_ID        = ''
        }
    }

    ForEach ($show in $simklJson.shows) {
        Write-Verbose -Message "Converting show: $($show.show.title) ($($show.show.ids.simkl))"
        $tvStatus = Switch ($show.status) {
            'completed' { 'completed' }
            'hold' { 'on hold' }
            'watching' { 'watching' }
            'plantowatch' { 'plan to watch' }
            'notinteresting' { 'dropped' }
        }
        $entries += @{
            SIMKL_ID      = $show.show.ids.simkl
            Title         = $show.show.title
            Type          = 'tv show'
            Year          = If (!($show.show.year)) { "0" } Else { $show.show.year }
            Watchlist     = $tvStatus
            LastEpWatched = If (!($show.last_watched)) { "" } Else { $show.last_watched.ToLower() }
            WatchedDate   = $show.last_watched_at
            Rating        = If (!($show.user_rating)) { "" } Else { $show.user_rating }
            Memo          = ''
            TVDB          = If (!($show.show.ids.tvdb)) { "" } Else { $show.show.ids.tvdb }
            TMDB          = If (!($show.show.ids.tmdb)) { "" } Else { $show.show.ids.tmdb }
            IMDB          = If (!($show.show.ids.imdb)) { "" } Else { $show.show.ids.imdb }
            MAL_ID        = ''
        }
    }

    $malCurrent = 0; $malPtw = 0; $malPause = 0; $malDrop = 0; $malFinish = 0; $aniCount = 0
    ForEach ($anime in $simklJson.anime) {
        Write-Verbose -Message "Converting anime: $($anime.show.title) ($($anime.show.ids.simkl))"
        $aniCount++
        Switch ($anime.status) {
            'completed' {
                $malStatus = 'Completed'
                $aniStatus = $malStatus.ToLower()
                $malFinish++
            }
            'hold' {
                $malStatus = 'On-Hold'
                $aniStatus = 'on hold'
                $malPause++
            }
            'watching' {
                $malStatus = 'Watching'
                $aniStatus = $malStatus.ToLower()
                $malCurrent++
            }
            'plantowatch' {
                $malStatus = 'Plan to Watch'
                $aniStatus = $malStatus.ToLower()
                $malPtw++
            }
            'notinteresting' {
                $malStatus = 'Dropped'
                $aniStatus = $malStatus.ToLower()
                $malDrop++
            }
        }
        $entries += @{
            SIMKL_ID      = $anime.show.ids.simkl
            Title         = $anime.show.title
            Type          = 'anime'
            Year          = If (!($anime.show.year)) { "0" } Else { $anime.show.year }
            Watchlist     = $aniStatus
            LastEpWatched = If (!($anime.last_watched)) { "" } Else { "s1" + $anime.last_watched.ToLower() }
            WatchedDate   = If (!($anime.last_watched_at)) { "" } Else { $anime.last_watched_at }
            Rating        = If (!($anime.user_rating)) { "" } Else { $anime.user_rating }
            Memo          = ''
            TVDB          = If (!($anime.show.ids.tvdb)) { "" } Else { $anime.show.ids.tvdb }
            TMDB          = If (!($anime.show.ids.tmdb)) { "" } Else { $anime.show.ids.tmdb }
            IMDB          = If (!($anime.show.ids.imdb)) { "" } Else { $anime.show.ids.imdb }
            MAL_ID        = If (!($anime.show.ids.mal)) { "" } Else { $anime.show.ids.mal }
        }

        $xmlCommonEntry = @"
<series_title><![CDATA[$($anime.show.title)]]></series_title>
        <series_episodes>$($anime.total_episodes_count)</series_episodes>
        <my_watched_episodes>$(If (!($anime.last_watched)) { "0" } Else{$anime.last_watched.Replace('E','')})</my_watched_episodes>
        <my_score>$(If (!($anime.user_rating)) {"0"} Else { $anime.user_rating })</my_score>
        <my_status>$($malStatus)</my_status>
        <my_start_date>0000-00-00</my_start_date>
        <my_finish_date>0000-00-00</my_finish_date>
        <update_on_import>1</update_on_import>
"@

        $xmlEntries += @"
`n    <anime>
        <series_animedb_id>$($anime.show.ids.mal)</series_animedb_id>
        <!--simkl_animedb_id>$($anime.show.ids.simkl)</simkl_animedb_id-->
        $($xmlCommonEntry)
    </anime>
"@
    }

    # Convert to CSV
    # Utilize ConvertTo-Json | ConvertFrom-Json to sanitize unwanted errors...
    #    when converting directly from hashtable to CSV
    Write-Host "`nExporting SIMKL watchlist to CSV"
    $entries | Select-Object -Property SIMKL_ID, Title, Type, Year, Watchlist, LastEpWatched, WatchedDate, Rating, Memo, TVDB, TMDB, IMDB, MAL_ID | Export-Csv -Path ./simkl/SimklBackup.csv -UseQuotes AsNeeded -Encoding utf8 -Force -NoTypeInformation

    Write-Host "`nExporting SIMKL watchlist to MAL-XML"
    $xmlData = @"
<?xml version="1.0" encoding="UTF-8" ?>
<myanimelist>
    <myinfo>
        <user_id></user_id>
        <user_export_type>1</user_export_type>
        <user_total_anime>$($aniCount)</user_total_anime>
        <user_total_plantowatch>$($malPtw)</user_total_plantowatch>
        <user_total_watching>$($malCurrent)</user_total_watching>
        <user_total_completed>$($malFinish)</user_total_completed>
        <user_total_onhold>$($malPause)</user_total_onhold>
        <user_total_dropped>$($malDrop)</user_total_dropped>
    </myinfo>

    <!--
        Created by GitHub:nattadasu/animeManga-autoBackup
        Exported at $(Get-Date -Format "yyyy-MM-dd HH:mm:ss") $((Get-TimeZone).Id)
    -->

"@
    $xmlData += $xmlEntries
    $xmlData += "`n</myanimelist>"

    $xmlData | Out-File -Path ./simkl/animeList.xml -Encoding utf8 -Force

    $readMe = @"
This folder contains your SIMKL backup in various formats.

* animeList.xml     : MAL-compatible XML format. Use this if you want strictly import only anime list.
* data.json         : JSON file fetched directly from SIMKL server.
* SimklBackup.csv   : CSV file format, suitable for importing the list to 3rd party.
* SimklBackup.zip   : contains JSON file od data.json. This format is expected to be used for reimporting list to SIMKL only.
"@

    #Remove legacy README file name
    If (Test-Path -Path ./simkl/README -ErrorAction SilentlyContinue) {
        Remove-Item -Path ./simkl/README
    }
    $readMe | Out-File -Path ./simkl/README.txt -Encoding utf8 -Force
}

Function Get-TraktBackup {
    Add-Directory -Path ./trakt -Name Trakt

    $traktUsername = $Env:TRAKT_USERNAME

    [int]$traktExpiry = $Env:TRAKT_OAUTH_EXPIRY

    $pyPath = If ($IsWindows) { "python" } Else { "python3" }

    If ($traktExpiry -lt $getCurrentEpoch) {
        Write-Host @"
Your Trakt credential expired, please reinitialize the token by typing following command:

$($pyPath) init $($traktUsername)
"@ -ForegroundColor Red
        Break
    }
    Else {
        Write-Host "`nExporting Trakt.tv data"

        Write-Host "Configuring config file"

        $traktExportJson = "{`"CLIENT_ID`": `"$($Env:TRAKT_CLIENT_ID)`", `"CLIENT_SECRET`": `"$($Env:TRAKT_CLIENT_SECRET)`", `"OAUTH_TOKEN`": `"$($Env:TRAKT_OAUTH_TOKEN)`", `"OAUTH_REFRESH`": `"$($Env:TRAKT_OAUTH_REFRESH)`", `"OAUTH_EXPIRES_AT`": $($Env:TRAKT_OAUTH_EXPIRY)}"

        # Check if linux or windows
        If ($Env:XDG_DATA_HOME) {
            $dataDir = $Env:XDG_DATA_HOME
        }
        ElseIf ($isWindows) {
            $dataDir = "~/.traktexport"
        }
        Else {
            $dataDir = "~/.local/share"
        }

        # Check if file exist
        If (Test-Path -Path "$dataDir/traktexport.json" -PathType Leaf) {
            Write-Host "Config file exists" -ForegroundColor Green
        }
        Else {
            Write-Host "Config file does not exist" -ForegroundColor Red
            Write-Host "Creating config file" -ForegroundColor Yellow
            New-Item -Path "$dataDir/traktexport.json" -Force -ItemType File -Value $traktExportJson
        }

        If ($IsLinux -or $IsMacOS) {
            python3 -m traktexport export $traktUsername | Out-File "./trakt/data.json" -Encoding utf8 -Force
        }
        Else {
            python -m traktexport export $traktUsername | Out-File "./trakt/data.json" -Encoding utf8 -Force
        }
    }

}

Function Get-VNDBBackup {
    Write-Host "`nChecking if curl is installed as fallback due to Invoke-WebRequest not working properly in handling cookies"
    Test-Binary -Binary curl

    Add-Directory -Path ./vndb -Name VNDB

    Write-Host "`nExporting VNDB game list in XML"
    $vndbUid = $Env:VNDB_UID
    $vndbAuth = $Env:VNDB_AUTH
    $vndbUrl = "https://vndb.org/$($vndbUid)/list-export/xml"

    curl -o ./vndb/gameList.xml  -X GET --cookie "vndb_auth=$($vndbAuth)" -A $userAgent $vndbUrl

    If ($Env:VNDB_TOKEN) {
        Write-Host "`nExporting VNDB game list in JSON"
        [string]$Token = $Env:VNDB_TOKEN

        # $user = (Invoke-WebMethod -Uri "https://api.vndb.org/kana/authinfo" -Au "Authorization: Token $Token" -ContentType "application/json" -Method Get).Content

        $user = curl https://api.vndb.org/kana/authinfo --header "Authorization: token $Token" | ConvertFrom-Json

        $userid = $user.id

        $rawRequests = @{
            user    = $userid
            fields  = "id, added, voted, lastmod, vote, started, finished, notes, labels.label, vn.id, vn.title, vn.alttitle, vn.olang, vn.platforms, vn.length"
            results = 100
            page    = 1
        }

        $json = @()

        For ($n = 1; $n -gt 0; $n++) {
            $requests = $rawRequests | ConvertTo-Json -Depth 2
            $result = curl https://api.vndb.org/kana/ulist --header "Content-Type: application/json; Authorization: token $Token" --data $requests | ConvertFrom-Json
            ForEach ($item in $result.results) {
                $order = [Ordered]@{
                    id           = $item.id
                    title        = $item.vn.title
                    altTitle     = $item.vn.alttitle
                    origin       = $item.vn.olang
                    # Convert UNIX timestamp to date to RFC 3339 format
                    dateAdded    = If ($item.added) { Get-Date -UnixTimeSeconds $item.added -UFormat "%Y-%m-%dT%H:%M:%SZ" } Else { $null }
                    dateVoted    = If ($item.voted) { Get-Date -UnixTimeSeconds $item.voted -UFormat "%Y-%m-%dT%H:%M:%SZ" } Else { $null }
                    lastModified = If ($item.lastmod) { Get-Date -UnixTimeSeconds $item.lastmod -UFormat "%Y-%m-%dT%H:%M:%SZ" } Else { $null }
                    score        = $item.vote / 10
                    started      = $item.started
                    finished     = $item.finished
                    notes        = $item.notes
                    labels       = $item.labels
                    platforms    = $item.vn.platforms
                    length       = $item.vn.length
                }
                $json += [PSCustomObject]$order
            }
            if ($True -eq $result.more) {
                $requests.page++
            }
            else {
                Break
            }
        }

        $json | ConvertTo-Json -Depth 99 | Out-File -FilePath .\vndb\gameList.json
    }
}

##########################
#       MAIN SCRIPT      #
##########################

If (!($isAction) -and $IsWindows -and (Get-Alias -Name curl -ErrorAction SilentlyContinue)) {
    Remove-Item Alias:curl
    Set-Alias curl "${env:SystemRoot}\System32\curl.exe"
}

# Skip if User Agent variable is not set when user filled ANIMEPLANET_USERNAME, MANGAUPDATES_SESSION, MAL_USERNAME, SHIKIMORI_KAWAI_SESSION, or VNDB_UID
If (($Env:ANIMEPLANET_USERNAME) -or ($Env:MANGAUPDATES_SESSION) -or ($Env:MANGAUPDATES_USERNAME) -or ($Env:MAL_USERNAME) -or ($Env:OTAKOTAKU_USERNAME) -or ($Env:SHIKIMORI_KAWAI_SESSION) -or ($Env:VNDB_UID)) {
    Confirm-UserAgent
}

$userAgent = $Env:USER_AGENT

If ($Env:ANILIST_USERNAME) { Get-AniListBackup }
If ($Env:ANIMEPLANET_USERNAME) { Get-AnimePlanetBackup }
If ($Env:ANNICT_PERSONAL_ACCESS_TOKEN) { Get-AnnictBackup }
If ($Env:BANGUMI_USERNAME) { Get-BangumiBackup }
If ($Env:KAIZE_USERNAME) { Get-KaizeBackup }
If ($Env:KITSU_EMAIL) { Get-KitsuBackup }
If ($Env:MANGAUPDATES_SESSION -or $Env:MANGAUPDATES_USERNAME) { Get-MangaUpdatesBackup }
If ($Env:MANGADEX_USERNAME) { Get-MangaDexBackup }
If ($Env:MAL_USERNAME) { Get-MyAnimeListBackup }
If ($Env:NOTIFYMOE_NICKNAME) { Get-NotifyMoeBackup }
If ($Env:OTAKOTAKU_USERNAME) { Get-OtakOtakuBackup }
If ($Env:SHIKIMORI_KAWAI_SESSION) { Get-ShikimoriBackup }
If ($Env:SIMKL_CLIENT_ID) { Get-SimklBackup }
If ($Env:TRAKT_USERNAME) { Get-TraktBackup }
If ($Env:VNDB_UID) { Get-VNDBBackup }

Write-Host "`nFormat JSON files"
Get-ChildItem -Path "*" -Filter "*.json" -File  -Recurse | ForEach-Object {
    $fileToFormat = $_
    Write-Host "Formatting $($fileToFormat)"
    Try {
        If ($Env:MINIFY_JSON -eq 'True') {
            Format-Json -Json (Get-Content $fileToFormat -Raw).trim() -Minify -ErrorAction SilentlyContinue | Out-File -FilePath $fileToFormat
        }
        Else {
            Format-Json -Json (Get-Content $fileToFormat -Raw).trim() -Indentation 2 -ErrorAction SilentlyContinue | Out-File -FilePath $fileToFormat
        }
    }
    Catch {
        Write-Error -Message "Unable to format $($fileToFormat): $($_)" -ErrorAction Continue
    }
}
