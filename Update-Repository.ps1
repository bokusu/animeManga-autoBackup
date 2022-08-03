$version = "0.0.1"
$isAction = $null -ne $Env:GITHUB_WORKSPACE

function Push-Git {
    if ($isAction) {
        $mailAddress = "$($Env:GITHUB_ACTOR)@noreply.users.github.com"
        $name = "$($Env:GITHUB_ACTOR)"

        git config user.email $mailAddress
        git config user.name $name
    }
    git push
}

# Update Repository from Template Repository
Write-Host "Update repo from template"
Write-Host "Version $version"

# Grab the template repo JSON
$templateAuthorName = "nattadasu"
$templateRepoName = "animeManga-autoBackup"
$templateRepo = "$templateAuthorName/$templateRepoName"
$templateUri = "https://api.github.com/repos/$templateRepo"
$templateContent = (Invoke-WebRequest -Uri $templateUri -Method Get -ContentType "application/json").Content | ConvertFrom-Json
$templateDefaultBranch = $templateContent.default_branch
$templateLastUpdate = Get-Date -Date $templateContent.pushed_at -UFormat "%s"

$localClone = git config --get remote.origin.url
# if format is git@github.com
if ($localClone -match "^git@github.com") {
    # Split the url into the user and repo
    $localClone = $localClone.Split("/")
    $localAuthorName = $localClone[0] -replace "git@github.com:", ""
    $localRepoName = $localClone[1] -replace "\.git$", ""
} else {
    # Split the url from https://github.com/nattadasu/animeManga-autoBackup to nattadasu/animeManga-autoBackup
    $localClone = $localClone.Split("/")
    $localAuthorName = $localClone[3]
    $localRepoName = $localClone[4]
}

$localRepo = "$localAuthorName/$localRepoName"
$localUri = "https://api.github.com/repos/$localRepo"
$localContent = (Invoke-WebRequest -Uri $localUri -Method Get -ContentType "application/json").Content | ConvertFrom-Json
$localLastUpdate = Get-Date -Date $localContent.pushed_at -UFormat "%s"
$localDefaultBranch = $localContent.default_branch

if ($templateRepo -eq "$localAuthorName/$localRepoName") {
    Write-Host "Repo is a template"
    Exit
} else {
    Write-Host "Checking if template repo is newer than local repo"
    if ($templateLastUpdate -gt $localLastUpdate) {
        Write-Host "Template repo is newer than local repo"
        Write-Host "Updating local repo"
        git remote add upstream "https://github.com/$templateRepo"
        git remote -v
        git fetch upstream
        git checkout $localDefaultBranch
        git merge upstream/$templateDefaultBranch
        Push-Git
    } else {
        Write-Host "Local repo is newer than template repo"
    }
}