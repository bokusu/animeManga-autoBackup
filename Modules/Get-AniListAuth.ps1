#!/usr/bin/env pwsh
#Requires -Version 7.0

[CmdletBinding()]
Param(
    [string]$ClientId,
    [string]$ClientSecret,
    [string]$RedirectUri = "https://anilist.co/api/v2/oauth/pin",
    [switch]$NoLaunchBrowser,
    [switch]$JsonTokenResult
)

If (!($ClientId)) {
    If (!(Get-Package -Name "Set-PsEnv")) {
        Write-Host "Installing Set-PsEnv" -ForegroundColor Red
        Install-Module Set-PsEnv
    } Else {
        Write-Host "Set-PsEnv is already installed"
    }

    Set-PsEnv

    $ClientId = $Env:ANILIST_CLIENT_ID
    $ClientSecret = $Env:ANILIST_CLIENT_SECRET
    $RedirectUri = $Env:ANILIST_REDIRECT_URI
}

Write-Host "Get AniList Auth Key" -ForegroundColor Green

$apiEndpoint = "https://anilist.co/api/v2/"
$authEndpoint = "$($apiEndpoint)oauth/authorize"
$tokenEndpoint = "$($apiEndpoint)oauth/token"

$clientIdParam = "client_id=$ClientId"
$clientSecretParam = "client_secret=$ClientSecret"
# Encode URI for redirect_uri to HTTP safe
$redirectUriParam = [System.Web.HttpUtility]::UrlEncode($RedirectUri)
$redirectUriParam = "redirect_uri=$redirectUriParam"
$responseParam = "response_type=code"

$getAuthCode = "$($authEndpoint)?$($clientIdParam)&$($redirectUriParam)&$($responseParam)"

Write-Host @"
Hello there, $($Env:USERNAME)! 👋

To authenticate with AniList, we need to open your browser to the AniList website.

Authentication URL:
$getAuthCode
$(if (!$NoLaunchBrowser) { "
We also automatically open your browser to the AniList login page." } )

We'll wait your response 😉
"@

If (!($NoLaunchBrowser)) {
    Start-Process $getAuthCode
}

# Loop Read-Host if user didn't input the code
Do {
    $authCode = Read-Host "Please input the code from the AniList website"
} While (!$authCode)

$jsonReq = @{
    grant_type = 'authorization_code'
    client_id = $ClientId
    client_secret = $ClientSecret
    redirect_uri = $RedirectUri
    code = $authCode
}

$tokenUri = "$($tokenEndpoint)?$($clientIdParam)&$($clientSecretParam)&$($redirectUriParam)"

$token = (Invoke-WebRequest -Uri $tokenUri -Method Post -ContentType "application/json" -Headers @{ Accept = 'application/json' } -Body ($jsonReq | ConvertTo-Json) -UseBasicParsing).Content
$now = Get-Date -UFormat %s

$token = ConvertFrom-Json $token
$token.expires_in = $token.expires_in + $now

Write-Host "Received Access Token!"

If ($JsonTokenResult) {
    Write-Host "`n`nPlease copy this value to Env generator script:"
    Write-Host ($token | ConvertTo-Json -Depth 2)
} Else {
    Write-Host "`n`nPlease copy this value to your ENV file:`n"
    Write-Host "ANILIST_ACCESS_TOKEN=" -ForegroundColor Blue -NoNewline
    Write-Host $token.access_token
    Write-Host "ANILIST_OAUTH_REFRESH=" -ForegroundColor Blue -NoNewline
    Write-Host $token.refresh_token
    Write-Host "ANILIST_OAUTH_EXPIRY=" -ForegroundColor Blue -NoNewline
    Write-Host $token.expires_in
}
