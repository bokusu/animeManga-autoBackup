# This script will try to snapshot all the supported sites of the repo
#   although some will be broken due to heavily dependent on the
#   external resources.

# This script is not meant to be run directly, but rather to be
#   included in other scripts.

$links = @(
    "https://anilist.co",
    "https://annict.com",
    "https://en.annict.com",
    "https://annict.jp",
    "https://bgm.tv",
    "https://kaize.io",
    "https://kitsu.io",
    "https://mangadex.net",
    "https://mangaupdates.com",
    "https://myanimelist.net",
    "https://otakotaku.com",
    "https://shikimori.one",
    "https://simkl.com",
    "https://trakt.com",
    "https://vndb.org",
    "https://www.anime-planet.com"
)

ForEach ($uri in $links) {
    If ($Global:maxApi -gt 15) {
        Write-Host "Wayback Machine API limit reached, sleep for 5 minutes and 30 seconds" -ForegroundColor Red
        Start-Sleep -Seconds 330
        [int]$Global:maxApi = 0
    }

    Write-Host "Snapshotting $uri"
    If ($IsLinux -or $IsMacOS) {
        python3 ./Modules/waybackSnapshot.py -u $uri
    }
    Else {
        python ./Modules/waybackSnapshot.py -u $uri
    }

    [int]$Global:maxApi += 1
}
