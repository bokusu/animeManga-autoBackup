$version = "0.0.1"
$isAction = $null -ne $Env:GITHUB_WORKSPACE

# Update Repository from Template Repository
Write-Host "Update repo from template"
Write-Host "Version $version"

# Grab the template repo JSON
$templateAuthorName = "nattadasu"
$templateRepoName = "animeManga-autoBackup"
$templateRepo = "$templateAuthorName/$templateRepoName"
$templateUri = "https://api.github.com/repos/$templateRepo"
$templateContent = (Invoke-WebRequest -Uri $templateUri -Method Get -ContentType "application/json").Content | ConvertFrom-Json
$templateLastUpdate = Get-Date -Date $templateContent.pushed_at -UFormat "%s"

$localClone = git config --get remote.origin.url
# If format is git@github.com
If ($localClone -Match "^git@github.com") {
    # Split the url into the user and repo
    $localClone = $localClone.Split("/")
    $localAuthorName = $localClone[0] -Replace "git@github.com:", ""
    $localRepoName = $localClone[1] -Replace "\.git$", ""
} Else {
    # Split the url from https://github.com/nattadasu/animeManga-autoBackup to nattadasu/animeManga-autoBackup
    $localClone = $localClone.Split("/")
    $localAuthorName = $localClone[3]
    $localRepoName = $localClone[4] -Replace "\.git$", ""
}

$localLastUpdate = git log -1 --format="%ct"

If ($templateRepo -eq "$localAuthorName/$localRepoName") {
    Write-Host "Repo is a template"
    Exit
} Else {
    Write-Host "Checking if template repo is newer than local repo"
    If ($templateLastUpdate -gt $localLastUpdate) {
        Write-Host "Template repo is newer than local repo"
        Write-Host "Updating local repo"
        $gitUrl = "https://github.com/$templateRepo"
        git clone $gitUrl update

        Remove-Item -Path "./update/.git" -Recurse -Force -Verbose
        Remove-Item -Path "./update/Update-Repository.ps1" -Force

        Copy-Item -Path "./update/*" -Destination "./" -Recurse -Force -Verbose

        Remove-Item -Path "./update" -Recurse -Verbose -Force
    } Else {
        Write-Host "Local repo is newer than template repo"
        Exit
    }
}

<#
if ($isAction) {
    $mailAddress = "$($Env:GITHUB_ACTOR)@noreply.users.github.com"
    $name = "$($Env:GITHUB_ACTOR)"

    git config user.email $mailAddress
    git config user.name $name
}
#>

If (!($isAction)) {
    git add .

    $templateCommits = (Invoke-WebRequest -Uri "$templateUri/commits" -Method Get -ContentType "application/json").Content | ConvertFrom-Json
    $latestCommit = $templateCommits[0].sha
    git commit -m "Update script based on $latestCommit"
    git push
}
