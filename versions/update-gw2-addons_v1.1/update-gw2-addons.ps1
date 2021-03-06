# --- declaring variables ---

# path to the GW2 folder "bin64"
$GW2Path = "C:\Program Files\Guild Wars 2\bin64"
# path to the folder containing "GW2TacO.exe"
$TacOPath = "D:\path\to\GW2TacO"


# --- script ---

# defining functions
function Download-GithubDLL($url, $path) {
    $download = ("https://github.com" + ((Invoke-WebRequest -UseBasicParsing -Uri $url).Links | Where href -like “*.dll”).href)
    Write-Output "Downloading $download to $path"
    Invoke-WebRequest -Uri $download -OutFile $path
}

function Download-GithubZIP($url, $path) {
    $download = ("https://github.com" + ((Invoke-WebRequest -UseBasicParsing -Uri $url).Links | Where href -like “*.zip” | Where href -notlike "*archive*").href)
    Write-Output "Downloading $download to $path"
    Invoke-WebRequest -Uri $download -OutFile $path
}

function Download-ArcDPS{
    Write-Output "Downloading https://www.deltaconnected.com/arcdps/x64/d3d9.dll to $GW2Path\d3d9.dll"
    Invoke-WebRequest -Uri "https://www.deltaconnected.com/arcdps/x64/d3d9.dll" -OutFile "$GW2Path\d3d9.dll"
}

function Download-TacO{
    $download = (((Invoke-WebRequest -UseBasicParsing -Uri "http://www.gw2taco.com/").Links | Where href -like “*.zip”).href)[0]
    Write-Output "Downloading $download to $TacOPath\taco-temp.zip"
    Invoke-WebRequest -Uri $download -OutFile "$TacOPath\taco-temp.zip"
    Expand-Archive -Path "$TacOPath\taco-temp.zip" -DestinationPath "$TacOPath" -Force
    Remove-Item -Path "$TacOPath\taco-temp.zip"
}

function Download-TacO-Marker{
    $marker = ((Invoke-WebRequest -UseBasicParsing -Uri "http://tekkitsworkshop.net/index.php/gw2-taco/download").Links | Where href -like “*all-in-one”).href
    $download = "http://tekkitsworkshop.net" + $marker[0]
    Write-Output "Downloading $download to $TacOPath\POIs\tw_ALL_IN_ONE.taco"
    Invoke-WebRequest -Uri $download -OutFile "$TacOPath\POIs\tw_ALL_IN_ONE.taco"
}

# setting the ProgressPreference to SilentlyContinue because downloads would take much longer (because of the displayed progress bar)
$ProgressPreference = 'SilentlyContinue'

# download ArcDPS Boon Table
Download-GithubDLL "https://github.com/knoxfighter/GW2-ArcDPS-Boon-Table/releases/latest" "$GW2Path\d3d9_arcdps_table.dll"

# download ArcDPS Mechanics Log
Download-GithubDLL "https://github.com/knoxfighter/GW2-ArcDPS-Mechanics-Log/releases/latest" "$GW2Path\d3d9_arcdps_mechanics.dll"

# download ArcDPS Killproof Plugin
Download-GithubDLL "https://github.com/knoxfighter/arcdps-killproof.me-plugin/releases/latest" "$GW2Path\d3d9_arcdps_killproof_me.dll"

# download ArcDPS
Download-ArcDPS

# download TacO
Download-TacO

# download Tekkit markers for TacO
Download-TacO-Marker

# download GW2Radial
Download-GithubZIP "https://github.com/Friendly0Fire/GW2Radial/releases/latest" "$GW2Path\GW2Radial.zip"
Expand-Archive -Path "$GW2Path\GW2Radial.zip" -DestinationPath "$GW2Path\temp-radial"
Move-Item -Path "$GW2Path\temp-radial\d3d9.dll" -Destination "$GW2Path\d3d9_chainload.dll" -Force
Remove-Item -Path "$GW2Path\temp-radial" -Force -Recurse
Remove-Item -Path "$GW2Path\GW2Radial.zip"

<#
# temp for GW2Radial alpha version
Invoke-WebRequest -Uri "https://github.com/Friendly0Fire/GW2Radial/releases/download/v2.1.0-pre1/gw2radial.zip" -OutFile "$GW2Path\GW2Radial.zip"
Expand-Archive -Path "$GW2Path\GW2Radial.zip" -DestinationPath "$GW2Path\temp-radial"
Move-Item -Path "$GW2Path\temp-radial\gw2addon_gw2radial.dll" -Destination "$GW2Path\d3d9_chainload.dll" -Force
Remove-Item -Path "$GW2Path\temp-radial" -Force -Recurse
Remove-Item -Path "$GW2Path\GW2Radial.zip"
#>