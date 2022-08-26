$isAction = $null -ne $Env:GITHUB_WORKSPACE
if (-Not($isAction)) {
    if (!(Get-Module -Name "Set-PsEnv")) {
        Write-Host "Installing Set-PsEnv" -ForegroundColor Red
        Install-Module Set-PsEnv
    } else {
        Write-Host "Set-PsEnv is already installed"
    }
}

Set-PsEnv

Write-Host "Get AniList Token"

$aniListApi = "https://anilist.co/api/v2"
$aniListClientId = $ENV:ANILIST_CLIENT_ID
$aniListClientSecret = $ENV:ANILIST_CLIENT_SECRET
$aniListRedirectUri = $ENV:ANILIST_REDIRECT_URI

# Encode Redirect Uri to URL safe HTTP
$encodedRedirectUri = [System.Net.WebUtility]::UrlEncode($aniListRedirectUri)

$authUri = "$aniListApi/oauth/authorize?client_id=$aniListClientId&redirect_uri=$encodedRedirectUri&response_type=code"

Write-Host @"
Hello there, $($Env:USERNAME)! 👋
To generate a token key, please open the following URL in your browser:

$authUri

We also automatically open your browser to the URL.

We'll wait your response 😉
"@

Start-Process $authUri

$authCode = Read-Host -Prompt "Please enter the code you received in your browser"

$body = @{
    "grant_type" = "authorization_code";
    "client_id" = "$aniListClientId";
    "client_secret" = "$aniListClientSecret";
    "redirect_uri" = "$aniListRedirectUri";
    "code" = "$authCode"
}
$response = (Invoke-WebRequest -Uri $aniListApi/oauth/token -Headers @{ Accept = "application/json"} -ContentType "application/json" -Method Post -Body $body).Content | ConvertFrom-Json
$accessToken = $response.access_token

Write-Host "Got AniList Token"
Write-Host "Your Code is:"
$accessToken