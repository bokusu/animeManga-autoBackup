#!/usr/bin/env pwsh

If (Get-Command -Name "pipreqs" -ErrorAction SilentlyContinue) {
    Write-Host "pipreqs Python Module is installed"
} Else {
    Write-Host "Installing pipreqs Python Module"
    pip install pipreqs
}

Write-Host "Running pipreqs"
pipreqs --force --mode no-pin .
# Append the following to the end of the requirements.txt file:
$pipReqs = @(
    "traktexport",
    "wheel"
)

Write-Host "Appending pipreqs requirements to requirements.txt"
ForEach ($pipReq in $pipReqs) {
    Write-Host "Appending $pipReq"
    $pipReq >> requirements.txt
}

# Sort the requirements.txt file alphabetically ascending
Write-Host "Sorting requirements.txt"
$reqContent = Get-Content -Path ./requirements.txt -Raw
