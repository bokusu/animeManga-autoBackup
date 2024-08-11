# This script will try to snapshot all the supported sites of the repo
#   although some will be broken due to heavily dependent on the
#   external resources.

# This script is not meant to be run directly, but rather to be
#   included in other scripts.

$links = @(
    "https://anilist.co",
    "https://annict.com",
    "https://en.annict.com",
    # "https://annict.jp", # .jp tld now redirects to .com instead
    "https://bgm.tv",
    "https://kaize.io",
    "https://kitsu.app",
    "https://mangadex.org",
    "https://mangaupdates.com",
    "https://myanimelist.net",
    "https://otakotaku.com",
    "https://shikimori.one",
    "https://simkl.com",
    "https://trakt.tv",
    "https://vndb.org",
    "https://www.anime-planet.com"
)

ForEach ($uri in $links) {
    If ($Global:maxApi -gt 15) {
        Write-Host "Wayback Machine API limit reached, sleep for 5 minutes and 30 seconds" -ForegroundColor Red
        Start-Sleep -Seconds 330
        [int]$Global:maxApi = 0
    }

    Write-Host "`e[2k`r`e[34mSending`e[0m $Uri `e[34mto Wayback Machine`e[0m" -NoNewline
    If ($IsLinux -or $IsMacOS) {
        $wbResult = python3 ./Modules/waybackSnapshot.py -u $Uri
    }
    Else {
        $wbResult = python ./Modules/waybackSnapshot.py -u $Uri
    }
    Switch -Regex ($wbResult) {
        "^https?://web.archive.org/web" {
            Write-Host "`e[2k`r`e[32mSent`e[0m $Uri `e[32mto Wayback Machine as`e[0m $wbResult`e[32m. Continue in 2 seconds" -NoNewline
            Start-Sleep -Seconds 2
        }
        Default {
            Write-Host "`e[2k`r`e[31mThere's unknown error when we tried to submit`e[0m $Uri `e[31mto Wayback Machine. Continue in 2 seconds" -NoNewline
            Start-Sleep -Seconds 2
        }
    }

    [int]$Global:maxApi += 1
}
