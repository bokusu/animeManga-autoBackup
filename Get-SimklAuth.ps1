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

Write-Host "Get SIMKL Auth Key"

$simklApi = "https://api.simkl.com/oauth/pin"
$clientId = "?client_id=$Env:SIMKL_CLIENT_ID"

$simklRequestJson = (Invoke-WebRequest -Uri $simklApi$clientId -Method Get -ContentType "application/json").Content | ConvertFrom-Json

$userCode = $simklRequestJson.user_code

Write-Host @"
Hello there, $($Env:USERNAME)! 👋
We have generated you a code/PIN to authenticate with SIMKL. Please to input it on https://simkl.com/pin/

Your PIN is:
$userCode

We also automatically open your browser to the SIMKL website.

We'll wait your response 😉
"@

Start-Process "https://simkl.com/pin/$userCode"

$expiredIn = $simklRequestJson.expires_in
$interval = $simklRequestJson.interval
$loopMax = $expiredIn / $interval

# Do a loop waiting for response from SIMKL if authenticated
for ($i = 0; $i -lt $loopMax; $i++) {
    $simklAuth = (Invoke-WebRequest -Uri "$simklApi/$userCode$clientId" -Method Get -ContentType "application/json").Content | ConvertFrom-Json
    if ($simklAuth.result -eq 'ok') {
        Write-Host "Your Access Token is $($simklAuth.access_token)"
        break
    }
    Write-Host "Waiting for SIMKL authentication..."
    Start-Sleep -Seconds $interval
}