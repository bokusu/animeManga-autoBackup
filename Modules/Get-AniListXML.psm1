Function Get-AniListXML {
    <#
    .SYNOPSIS
    An export tool for Anilist to import to MyAnimeList.

    .DESCRIPTION
    This script will generate an XML file to import to MyAnimeList.

    .PARAMETER Username
    The username of the Anilist account.

    .PARAMETER Type
    The type of data to export. Can be anime or manga.

    .PARAMETER Silent
    If this is set, the script will not show any output.

    .PARAMETER ShowProgress
    If this is set, the script will show a progress bar.

    .PARAMETER OutFile
    The output file.

    .EXAMPLE
    Get-AniListXML -Username "nattadasu" -Type "anime" -OutFile ".\AniList.xml"

    .NOTES
    General notes
    #>
    Param (
        [Parameter(Mandatory=$true)]
        [String]$Username,
        [String]$CustomList,
        [String]$OutFile,
        [String]$Type="anime",
        [Switch]$ShowProgress,
        [Switch]$Silent
    )

    Function Write-Banner {
        Write-Host @"
┏━━ AniList to MAL ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ An export tool for Anilist to import to MyAnimeList.          ┃
┃ Enter your username, and this will generate an XML file       ┃
┃ to import here: https://myanimelist.net/import.php            ┃
┃ Made by Natsu Tadama (https://nttds.my.id)                    ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
"@
    }

    If (!$Silent) {
        Write-Banner
    }

    If (!$CustomList) {
        $complete = $False
    } 

    Function Get-AniListData {
        $query = '
        query ($username: String, $type: MediaType) {
            MediaListCollection(userName: $username, type: $type) {
                lists {
                    name
                    entries {
                        id
                        status
                        score(format: POINT_10)
                        progress
                        notes
                        repeat
                        media {
                            chapters
                            volumes
                            idMal
                            episodes
                            title { romaji }
                        }
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
                    }
                    name
                    isCustomList
                    isSplitCompletedList
                    status
                }
            }
        }
        '
    }
}