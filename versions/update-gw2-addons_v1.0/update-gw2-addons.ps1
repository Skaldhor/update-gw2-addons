function Download-GithubDLL($url, $path) {
    $download = ("https://github.com" + ((Invoke-WebRequest -UseBasicParsing -Uri $url).Links | Where href -like “*.dll”).href)
    Write-Output "Downloading... `n$download `nto `n$path `n"
    Invoke-WebRequest -Uri $download -OutFile $path
}

function Download-GithubZIP($url, $path) {
    $download = ("https://github.com" + ((Invoke-WebRequest -UseBasicParsing -Uri $url).Links | Where href -like “*.zip” | Where href -notlike "*archive*").href)
    Write-Output "Downloading... `n$download `nto `n$path `n"
    Invoke-WebRequest -Uri $download -OutFile $path
}

function Download-ArcDPS{
    Write-Output "Downloading... `nhttps://www.deltaconnected.com/arcdps/x64/d3d9.dll `nto `n$GW2Path\d3d9.dll `n"
    Invoke-WebRequest -Uri "https://www.deltaconnected.com/arcdps/x64/d3d9.dll" -OutFile "$GW2Path\d3d9.dll"
}

function Download-TacO-Marker{
    $marker = ((Invoke-WebRequest -UseBasicParsing -Uri "http://tekkitsworkshop.net/index.php/gw2-taco/download").Links | Where href -like “*all-in-one”).href
    $download = "http://tekkitsworkshop.net" + $marker[0]
    Write-Output "Downloading... `n$download `nto `n$TacOPath\tw_ALL_IN_ONE.taco `n"
    Invoke-WebRequest -Uri $download -OutFile "$TacOPath\tw_ALL_IN_ONE.taco"
}

$ProgressPreference = 'SilentlyContinue'
$GW2Path = "C:\Program Files\Guild Wars 2\bin64"
$TacOPath = "D:\path\to\GW2TacO\POIs"

# Download ArcDPS Boon Table
Download-GithubDLL "https://github.com/knoxfighter/GW2-ArcDPS-Boon-Table/releases/latest" "$GW2Path\d3d9_arcdps_table.dll"

# Download ArcDPS Mechanics Log
Download-GithubDLL "https://github.com/knoxfighter/GW2-ArcDPS-Mechanics-Log/releases/latest" "$GW2Path\d3d9_arcdps_mechanics.dll"

# Download ArcDPS Killproof Plugin
Download-GithubDLL "https://github.com/knoxfighter/arcdps-killproof.me-plugin/releases/latest" "$GW2Path\d3d9_arcdps_killproof_me.dll"

# Download ArcDPS
Download-ArcDPS

# Download Tekkit markers for TacO
Download-TacO-Marker

# Download GW2Radial
Download-GithubZIP "https://github.com/Friendly0Fire/GW2Radial/releases/latest" "$GW2Path\GW2Radial.zip"
Expand-Archive -Path "$GW2Path\GW2Radial.zip" -DestinationPath "$GW2Path\temp-radial"
Move-Item -Path "$GW2Path\temp-radial\d3d9.dll" -Destination "$GW2Path\d3d9_chainload.dll" -Force
Remove-Item -Path "$GW2Path\temp-radial" -Force -Recurse
Remove-Item -Path "$GW2Path\GW2Radial.zip"

# temp for alpha version
Invoke-WebRequest -Uri "https://github.com/Friendly0Fire/GW2Radial/releases/download/v2.0.0-alpha/gw2addon_gw2radial-2.0.0.zip" -OutFile "$GW2Path\GW2Radial.zip"
Expand-Archive -Path "$GW2Path\GW2Radial.zip" -DestinationPath "$GW2Path\temp-radial"
Move-Item -Path "$GW2Path\temp-radial\gw2addon_gw2radial.dll" -Destination "$GW2Path\d3d9_chainload.dll" -Force
Remove-Item -Path "$GW2Path\temp-radial" -Force -Recurse
Remove-Item -Path "$GW2Path\GW2Radial.zip"