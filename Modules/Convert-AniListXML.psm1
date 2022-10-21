Function Convert-AniListXML {
    [CmdletBinding()]
    Param (
        [String]$Path = './aniList/animeList.json',
        [Switch]$isManga
    )

    $json = Get-Content $Path -Raw | ConvertFrom-Json
    $data = $json.data

    # Prepare dynamic variables
    $xml = "<?xml version=`"1.0`" encoding=`"UTF-8`" ?>`n<myanimelist>"
    $n = 0
    $malWatching = 0; $malReading = 0; $malCompleted = 0; $malOnHold = 0; $malDropped = 0; $malPlanToWatch = 0; $malPlanToRead = 0

    ForEach ($list in $data.MediaListCollection.lists) {
        If ($True -eq $list.isCustomList) {
            Write-Host "Skipping custom list: $($list.name)"
        }
        Else {
            ForEach ($entry in $list.entries) {
                $entryId = $entry.mediaId
                $title = $entry.media.title.romaji
                $score = [Math]::Floor($entry.score)
                $malID = If ($Null -eq $entry.media.idMal) { 0 } Else { $entry.media.idMal }
                $episodes = If ($Null -eq $entry.media.episodes) { 0 } Else { $entry.media.episodes }
                $chapters = If ($Null -eq $entry.media.chapters) { 0 } Else { $entry.media.chapters }
                $volumes = If ($Null -eq $entry.media.volumes) { 0 } Else { $entry.media.volumes }
                $progress = $entry.progress
                $progressVolumes = $entry.progressVolumes
                $startedDateRaw = If ($Null -eq $entry.startedAt.year) { "0000-00-00" } Else { "$($entry.startedAt.year)-$(($entry.startedAt.month).ToString('00'))-$(($entry.startedAt.day).ToString('00'))" }
                $startedDate = If (($startedDateRaw -eq "--") -or ($startedDateRaw -eq "")) { "0000-00-00" } Else { $startedDateRaw }
                $completedDateRaw = If ($Null -eq $entry.completedAt.year) { "0000-00-00" } Else { "$($entry.startedAt.year)-$(($entry.startedAt.month).ToString('00'))-$(($entry.startedAt.day).ToString('00'))" }
                $completedDate = If (($completedDateRaw -eq "--") -or ($completedDateRaw -eq "")) { "0000-00-00 " } Else { $completedDateRaw }
                $repeat = $entry.repeat
                $note = If ($Null -eq $entry.notes) { "" } Else { $entry.notes }
                Switch ($entry.status) {
                    "CURRENT" { If ($True -eq $isManga) { $status = "Reading" } Else { $status = "Watching" } }
                    "PLANNING" { If ($True -eq $isManga) { $status = "Plan to Read" } Else { $status = "Plan to Watch" } }
                    "COMPLETED" { $status = "Completed" }
                    "PAUSED" { $status = "On-Hold" }
                    "DROPPED" { $status = "Dropped" }
                }

                $commonXml = @"
<my_start_date>$($startedDate)</my_start_date>
        <my_finish_date>$($completedDate)</my_finish_date>
        <my_score>$($score)</my_score>
        <my_status>$($status)</my_status>
        <my_tags><![CDATA[$($note)]]></my_tags>
        <my_comments><![CDATA[$($note)]]></my_comments>
        <update_on_import>1</update_on_import>
"@
                $commonAnime = @"
<series_title><![CDATA[$($title)]]></series_title>
        <series_episodes>$($episodes)</series_episodes>
        <my_watched_episodes>$($progress)</my_watched_episodes>
        <my_rewatching>$($repeat)</my_rewatching>
        <my_rewatching_ep>0</my_rewatching_ep>
"@
                $commonManga = @"
<manga_title><![CDATA[$($title)]]></manga_title>
        <manga_chapters>$($chapters)</manga_chapters>
        <manga_volumes>$($volumes)</manga_volumes>
        <my_read_chapters>$($progress)</my_read_chapters>
        <my_read_volumes>$($progressVolumes)</my_read_volumes>
        <my_times_read>$($repeat)</my_times_read>
"@

                If ($malID -ne 0) {
                    Write-Verbose -Message "Convert $($title) to MALXML"
                    Switch ($entry.status) {
                        "CURRENT" { If ($True -eq $isManga) { $malReading++ } Else { $malWatching++ } }
                        "PLANNING" { If ($True -eq $isManga) { $malPlanToRead++ } Else { $malPlanToWatch++ } }
                        "COMPLETED" { $malCompleted++ }
                        "PAUSED" { $malOnHold++ }
                        "DROPPED" { $malDropped++ }
                    }
                    If ($False -eq $isManga) {
                        $aniListToMAL += @"
`n    <anime>
        <series_animedb_id>$($malID)</series_animedb_id>
        <!--series_anilist_id>$($entryId)</series_anilist_id-->
        $($commonAnime)
        $($commonXml)
    </anime>
"@
                    }
                    Else {
                        $aniListToMAL += @"
`n    <manga>
        <mangadb_id>$($malID)</mangadb_id>
        <!--manga_anilist_id>$($entryId)</manga_anilist_id-->
        $($commonManga)
        $($commonXml)
    </manga>
"@
                    }
                    $n++
                }
                Else {
                    Write-Verbose -Message "Skipping entry: $($title) - No MAL ID"
                    $noEntry += @"
`n        - [$($entryId)] $($title)
"@
                    If ($False -eq $isManga) {
                        $aniListToMAL += @"
`n    <!--anime>
        <series_anilist_id>$($entryId)</series_anilist_id>
        $($commonAnime)
        $($commonXml)
    </anime-->
"@
                    }
                    Else {
                        $aniListToMAL += @"
`n    <!--manga>
        <manga_anilist_id>$($entryId)</manga_anilist_id>
        $($commonManga)
        $($commonXml)
    </manga-->
"@
                    }
                    $n++
                }
            }
        }
    }
    Write-Host "Exporting to MAL XML"
    If ($True -eq $isManga) {
        $xml += @"
`n    <myinfo>
        <user_id></user_id>
        <user_export_type>2</user_export_type>
        <user_total_manga>$($malReading + $malPlanToRead + $malCompleted + $malOnHold + $malDropped)</user_total_manga>
        <!--user_total_anilist_manga>$($n)</user_total_anilist_manga-->
        <user_total_plantoread>$($malPlanToRead)</user_total_plantoread>
        <user_total_reading>$($malReading)</user_total_reading>
        <user_total_completed>$($malCompleted)</user_total_completed>
        <user_total_onhold>$($malOnHold)</user_total_onhold>
        <user_total_dropped>$($malDropped)</user_total_dropped>
    </myinfo>

"@
    }
    Else {
        $xml += @"
`n    <myinfo>
        <user_id></user_id>
        <user_export_type>1</user_export_type>
        <user_total_anime>$($malWatching + $malPlanToWatch + $malCompleted + $malOnHold + $malDropped)</user_total_anime>
        <!--user_total_anilist_anime>$($n)</user_total_anilist_anime-->
        <user_total_plantowatch>$($malPlanToWatch)</user_total_plantowatch>
        <user_total_watching>$($malWatching)</user_total_watching>
        <user_total_completed>$($malCompleted)</user_total_completed>
        <user_total_onhold>$($malOnHold)</user_total_onhold>
        <user_total_dropped>$($malDropped)</user_total_dropped>
    </myinfo>

"@
    }
    $xml += @"
`n    <!--
        Created by GitHub:nattadasu/animeManga-autoBackup
        Exported at $(Get-Date -Format "yyyy-MM-dd HH:mm:ss") $((Get-TimeZone).Id)
    -->

    <!--Unindexed Entry on MAL
        Format:
        - [AniList ID] Title
        ========================================$($noEntry)
    -->

"@
    $xml += $aniListToMAL
    $xml += "`n</myanimelist>"

    Write-Output $xml
}

Export-ModuleMember -Function Convert-AniListXML
