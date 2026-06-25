$release = Invoke-RestMethod -Uri "https://api.github.com/repos/Zeann3th/StressPilotV3/releases/latest"
$tagName = $release.tag_name
Write-Output "Latest backend release tag is $tagName"

$asset = $release.assets | Where-Object { $_.name -like "*.jar" } | Select-Object -First 1
if ($null -eq $asset) {
    Write-Error "Could not find any .jar asset in the latest release."
    exit 1
}

$downloadUrl = $asset.browser_download_url
Write-Output "Downloading backend jar from: $downloadUrl"

if (!(Test-Path "assets/core")) {
    New-Item -ItemType Directory -Path "assets/core" | Out-Null
}

Invoke-WebRequest -Uri $downloadUrl -OutFile "assets/core/app.jar"
Write-Output "Backend jar placed successfully at assets/core/app.jar"
