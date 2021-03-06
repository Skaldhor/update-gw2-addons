# --- declaring variables ---

# path to the GW2 folder "bin64"
$GW2Path = "C:\Program Files\Guild Wars 2\bin64"

# path to the folder containing "GW2TacO.exe"
$TacOPath = "D:\path\to\GW2TacO"

# turn installing/updating of individual addons on ($true) or off ($false)
# addons turned off are automatically deleted, except for TacO (in case you have custom markers), however Tekkit's markers will be deleted
$installArcDPS = $true
$installArcDPSBoonTable = $true
$installArcDPSKillproofPlugin = $true
$installArcDPSMechanicsLog = $true
$installArcDPSUnofficialExtras = $true
$installTacO = $true
$installTekkitMarkersForTacO = $true
$installGW2Radial = $true


# --- script ---

# defining functions
function Download-GithubDLL($url, $path) {
    $download = ("https://github.com" + ((Invoke-WebRequest -UseBasicParsing -Uri $url).Links | Where href -like “*.dll”)[0].href)
    Write-Output "Downloading $download to $path"
    Invoke-WebRequest -Uri $download -OutFile $path
}

function Download-GithubZIP($url, $path) {
    $download = ("https://github.com" + ((Invoke-WebRequest -UseBasicParsing -Uri $url).Links | Where href -like “*.zip” | Where href -notlike "*archive*")[0].href)
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


# installing/updating addons

# setting the ProgressPreference to SilentlyContinue because downloads would take much longer (because of the displayed progress bar)
$ProgressPreference = 'SilentlyContinue'

# install/uninstall ArcDPS
if($installArcDPS -eq $true){
    Download-ArcDPS
}
if($installArcDPS -eq $false){
    if((Test-Path "$GW2Path\d3d9.dll") -eq $true){Remove-Item "$GW2Path\d3d9.dll"}
}

# install/uninstall ArcDPS Boon Table
if(($installArcDPSBoonTable -eq $true) -and ($installArcDPS -eq $true)){
    Download-GithubDLL "https://github.com/knoxfighter/GW2-ArcDPS-Boon-Table/releases/latest" "$GW2Path\d3d9_arcdps_table.dll"
}
if(($installArcDPSBoonTable -eq $false) -or ($installArcDPS -eq $false)){
    if((Test-Path "$GW2Path\d3d9_arcdps_table.dll") -eq $true){Remove-Item "$GW2Path\d3d9_arcdps_table.dll"}
}

# install/uninstall ArcDPS Killproof Plugin
if(($installArcDPSKillproofPlugin -eq $true) -and ($installArcDPS -eq $true)){
    Download-GithubDLL "https://github.com/knoxfighter/arcdps-killproof.me-plugin/releases/latest" "$GW2Path\d3d9_arcdps_killproof_me.dll"
}
if(($installArcDPSKillproofPlugin -eq $false) -or ($installArcDPS -eq $false)){
    if((Test-Path "$GW2Path\d3d9_arcdps_killproof_me.dll") -eq $true){Remove-Item "$GW2Path\d3d9_arcdps_killproof_me.dll"}
}

# install/uninstall ArcDPS Mechanics Log
if(($installArcDPSMechanicsLog -eq $true) -and ($installArcDPS -eq $true)){
    Download-GithubDLL "https://github.com/knoxfighter/GW2-ArcDPS-Mechanics-Log/releases/latest" "$GW2Path\d3d9_arcdps_mechanics.dll"
}
if(($installArcDPSMechanicsLog -eq $false) -or ($installArcDPS -eq $false)){
    if((Test-Path "$GW2Path\d3d9_arcdps_mechanics.dll") -eq $true){Remove-Item "$GW2Path\d3d9_arcdps_mechanics.dll"}
}

# install/uninstall ArcDPS Unofficial Extras
if(($installArcDPSUnofficialExtras -eq $true) -and ($installArcDPS -eq $true)){
    Download-GithubDLL "https://github.com/Krappa322/arcdps_unofficial_extras_releases/releases/latest" "$GW2Path\arcdps_unofficial_extras.dll"
}
if(($installArcDPSUnofficialExtras -eq $false) -or ($installArcDPS -eq $false)){
    if((Test-Path "$GW2Path\arcdps_unofficial_extras.dll") -eq $true){Remove-Item "$GW2Path\arcdps_unofficial_extras.dll"}
}

# install/uninstall TacO
if($installTacO -eq $true){
    Download-TacO
}

# install/uninstall Tekkit markers for TacO
if(($installTekkitMarkersForTacO -eq $true) -and ($installTacO -eq $true)){
    Download-TacO-Marker
}
if($installTekkitMarkersForTacO -eq $false){
    if((Test-Path "$TacOPath\POIs\tw_ALL_IN_ONE.taco") -eq $true){Remove-Item "$TacOPath\POIs\tw_ALL_IN_ONE.taco"}
}

# install/uninstall GW2Radial
if(($installGW2Radial -eq $true) -and ($installArcDPS -eq $true)){
    Download-GithubZIP "https://github.com/Friendly0Fire/GW2Radial/releases/latest" "$GW2Path\GW2Radial.zip"
    Expand-Archive -Path "$GW2Path\GW2Radial.zip" -DestinationPath "$GW2Path"
    Move-Item -Path "$GW2Path\gw2radial\gw2addon_gw2radial.dll" -Destination "$GW2Path\d3d9_chainload.dll" -Force
    Remove-Item -Path "$GW2Path\gw2radial" -Recurse
    Remove-Item -Path "$GW2Path\GW2Radial.zip"
}
if(($installGW2Radial -eq $true) -and ($installArcDPS -eq $false)){
    Download-GithubZIP "https://github.com/Friendly0Fire/GW2Radial/releases/latest" "$GW2Path\GW2Radial.zip"
    Expand-Archive -Path "$GW2Path\GW2Radial.zip" -DestinationPath "$GW2Path"
    Move-Item -Path "$GW2Path\gw2radial\gw2addon_gw2radial.dll" -Destination "$GW2Path\d3d9.dll" -Force
    Remove-Item -Path "$GW2Path\gw2radial" -Recurse
    Remove-Item -Path "$GW2Path\GW2Radial.zip"
    if((Test-Path "$GW2Path\d3d9_chainload.dll") -eq $true){Remove-Item "$GW2Path\d3d9_chainload.dll"}
}
if(($installGW2Radial -eq $false) -and ($installArcDPS -eq $true)){
    if((Test-Path "$GW2Path\d3d9_chainload.dll") -eq $true){Remove-Item "$GW2Path\d3d9_chainload.dll"}
}
if(($installGW2Radial -eq $false) -and ($installArcDPS -eq $false)){
    if((Test-Path "$GW2Path\d3d9.dll") -eq $true){Remove-Item "$GW2Path\d3d9.dll"}
    if((Test-Path "$GW2Path\d3d9_chainload.dll") -eq $true){Remove-Item "$GW2Path\d3d9_chainload.dll"}
}