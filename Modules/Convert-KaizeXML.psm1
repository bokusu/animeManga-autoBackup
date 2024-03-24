Function Convert-KaizeToMal {
    [CmdletBinding()]
    Param(
        [String]$Path = "./kaize/animeList.json",
        [Switch]$IsManga
    )

    If ($IsManga) {
        Write-Error -Message "Sorry, but we do not support convertion for manga list at the moment." -ErrorAction Break
    }

    Write-Host "`nTrying to map Kaize slug to MAL ID using Natsu's Anime API mappings"
    $mapper = Invoke-RestMethod -Uri "http://animeapi.my.id/kaize.json"
    $loadAnime = Get-Content -Path $Path -Raw | ConvertFrom-Json
    $indexer = @()
    ForEach ($entry in $loadAnime) {
        $kzSlug = $entry.slug

        If (!($mapper.$kzSlug)) {
            Write-Error -Message "$($entry.name) ($($kzSlug)) relation in Natsu's Anime API mapping can not be found, skipping" -ErrorAction Continue
            $malId = $Null
        }
        Else {
            Write-Verbose -Message "Found $($entry.name) in Natsu's Anime API mapping, adding MAL ID"
            $malId = $mapper.$kzSlug.myAnimeList
        }

        # Replace null to 0000-00-00 on dates
        $startDate = Switch ($entry.startDate) {
            $Null { "0000-00-00" }
            Default { $entry.startDate }
        }
        $endDate = Switch ($entry.endDate) {
            $Null { "0000-00-00" }
            Default { $entry.endDate }
        }

        $indexer += [ordered]@{
            title         = $entry.name
            malId         = $malId
            kaizeSlug     = $kzSlug
            status        = Switch ($entry.status) {
                "completed" { "Completed"; $finished++ }
                "dropped" { "Dropped"; $dropped++ }
                "on-hold" { "On-Hold"; $paused++ }
                "plan-to-watch" { "Plan to Watch"; $planned++ }
                "watching" { "Watching"; $current++ }
                "plan-to-read" { "Plan to Read"; $planned++ }
                "reading" { "Reading"; $current++ }
            }
            score         = $entry.score
            progress      = If ($IsManga) { $entry.chapters } Else { $entry.episodes }
            volumes       = If ($IsManga) { $entry.volumes } Else { 0 }
            totalProgress = If ($IsManga) { $entry.totalChapters } Else { $entry.totalEpisodes }
            totalVolumes  = If ($IsManga) { $entry.totalVolumes } Else { 0 }
            startDate     = [String]$startDate
            endDate       = [String]$endDate
        }
    }
    # initialize variables
    $entries = ""; $total = $indexer.Count; $noEntry = ""
    $xml = "<?xml version=`"1.0`" encoding=`"UTF-8`" ?>`n<myanimelist>"
    ForEach ($entry in $indexer) {
        $commonMetadata = @"
<my_start_date>$($entry.startDate)</my_start_date>
        <my_finish_date>$($entry.endDate)</my_finish_date>
        <my_score>$($entry.score)</my_score>
        <my_status>$($entry.status)</my_status>
        <my_tags><![CDATA[]]></my_tags>
        <my_comments><![CDATA[]]></my_comments>
        <update_on_import>1</update_on_import>
"@
        $commonAnime = @"
<series_title><![CDATA[$($entry.title)]]></series_title>
        <series_episodes>$($entry.totalProgress)</series_episodes>
        <my_watched_episodes>$($entry.progress)</my_watched_episodes>
        <my_rewatching>0</my_rewatching>
        <my_rewatching_ep>0</my_rewatching_ep>
"@
        $commonManga = @"
<manga_title><![CDATA[$($entry.title)]]></manga_title>
        <manga_chapters>$($entry.totalProgress)</manga_chapters>
        <manga_volumes>$($entry.totalVolumes)</manga_volumes>
        <my_read_chapters>$($entry.progress)</my_read_chapters>
        <my_read_volumes>$($entry.volumes)</my_read_volumes>
        <my_times_read>0</my_times_read>
"@
        # Check if entry on Kaize has a MAL ID from mapping
        If ($entry.malId) {
            Write-Verbose -Message "Found MAL ID for $($entry.title), adding to XML"
            If (!$IsManga) {
                $entries += @"
`n    <anime>
        <series_animedb_id>$($entry.malId)</series_animedb_id>
        <!--series_kaize_slug><![CDATA[$($entry.kaizeSlug)]]></series_kaize_slug-->
        $commonAnime
        $commonMetadata
    </anime>
"@
            }
            Else {
                $entries += @"
`n    <manga>
        <mangadb_id>$($entry.malId)</mangadb_id>
        <!--manga_kaize_slug><![CDATA[$($entry.kaizeSlug)]]></manga_kaize_slug-->
        $commonManga
        $commonMetadata
    </manga>
"@
            }
        }
        Else {
            # Add entry as commented in XML
            Write-Verbose -Message "No MAL ID for $($entry.title), adding as commented entry"
            If (!$IsManga) {
                $entries += @"
`n    <!--anime>
        <series_kaize_slug><![CDATA[$($entry.kaizeSlug)]]></series_kaize_slug>
        $commonAnime
        $commonMetadata
    </anime-->
"@
                $noEntry += "`n        - [$($entry.kaizeSlug)] $($entry.title)"
            }
            Else {
                $entries += @"
`n    <!--manga>
        <manga_kaize_slug><![CDATA[$($entry.kaizeSlug)]]></manga_kaize_slug>
        $commonManga
        $commonMetadata
    </manga-->
"@
                $noEntry += "`n        - [$($entry.kaizeSlug)] $($entry.title)"
            }
        }
    }
    # Export XML
    If (!$IsManga) {
        $xml += @"
`n    <myinfo>
        <user_id></user_id>
        <user_export_type>1</user_export_type>
        <user_total_anime>$total</user_total_anime>
        <user_total_watching>$current</user_total_watching>
        <user_total_completed>$finished</user_total_completed>
        <user_total_onhold>$paused</user_total_onhold>
        <user_total_dropped>$dropped</user_total_dropped>
        <user_total_plantowatch>$planned</user_total_plantowatch>
    </myinfo>
"@
    }
    Else {
        $xml += @"
`n    <myinfo>
        <user_id></user_id>
        <user_export_type>2</user_export_type>
        <user_total_manga>$total</user_total_manga>
        <user_total_reading>$current</user_total_reading>
        <user_total_completed>$finished</user_total_completed>
        <user_total_onhold>$paused</user_total_onhold>
        <user_total_dropped>$dropped</user_total_dropped>
        <user_total_plantoread>$planned</user_total_plantoread>
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
        - [Kaize Slug] Title
        ========================================$($noEntry)
    -->

"@
    $xml += $entries
    $xml += "`n</myanimelist>"
    If (!$IsManga) {
        $xml | Out-File -FilePath "./kaize/animeList.xml" -Encoding utf8 -Force
    }
    Else {
        $xml | Out-File -FilePath "./kaize/mangaList.xml" -Encoding utf8 -Force
    }
}

Export-ModuleMember -Function Convert-KaizeToMal
