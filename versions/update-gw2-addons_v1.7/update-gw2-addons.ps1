param([switch]$Elevated) # do not change this line, it is needed for the elevated rights check
# --- declaring variables ---

# path to the GW2 folder "bin64"
$GW2Path = "C:\Program Files\Guild Wars 2\bin64"

# path to the folder that is/will be containing "GW2TacO.exe"
$TacOPath = "D:\path\to\GW2TacO"

# turn checking for updates on ($true) or off ($false)
$checkForUpdates = $true

# turn installing/updating of individual addons on ($true) or off ($false)
# addons turned off are automatically deleted, except for TacO (in case you have custom markers), however Tekkit's markers will be deleted
# you should only enable ArcDPSMountTool OR GW2Radial
$installArcDPS = $true
$installArcDPSBoonTable = $true
$installArcDPSBuildPad = $true
$installArcDPSHealingStats = $true
$installArcDPSKillproofPlugin = $true
$installArcDPSMechanicsLog = $true
$installArcDPSMountTool = $true
$installArcDPSUnofficialExtras = $true
$installTacO = $true
$installTekkitMarkersForTacO = $true
$installGW2Radial = $true


# --- script ---
# do not change below this line


# starting script with elevated rights, so a scheduled task can be created, if necessary
function Test-Admin{
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
if((Test-Admin) -eq $false){
    if($Elevated){}
    else{
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    }
    exit
}



# ---------------------------
# global variables
# ---------------------------


# this script's version
$currentScriptVersion = "v1.7"

# setting the ProgressPreference to SilentlyContinue because downloads would take much longer (because of the displayed progress bar)
$ProgressPreference = 'SilentlyContinue'



# ---------------------------
# defining functions
# ---------------------------


function Update-Script{
    $url = ((Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/Skaldhor/update-gw2-addons/releases/latest").Links | Where-Object href -like “/Skaldhor/update-gw2-addons/releases/tag/*”)[0].href
    $array = $url.Split("/")
    $actualVersion = $array[($array.Length - 1)]
    if($currentScriptVersion -ne $actualVersion){Write-Output "Update available, creating message box..."; Update-Box}
    else{Write-Output "Script is at the latest version."}
}

function Get-ArcDPS{
    Write-Output "Downloading: https://www.deltaconnected.com/arcdps/x64/d3d9.dll `nto:          $GW2Path\d3d9.dll `n"
    Invoke-WebRequest -Uri "https://www.deltaconnected.com/arcdps/x64/d3d9.dll" -OutFile "$GW2Path\d3d9.dll"
}

function Get-GithubDLL($url, $path){
    $download = ("https://github.com" + ((Invoke-WebRequest -UseBasicParsing -Uri $url).Links | Where-Object href -like "*.dll")[0].href)
    Write-Output "Downloading: $download `nto:          $path `n"
    Invoke-WebRequest -Uri $download -OutFile $path
}

function Get-GithubZIP($url, $path){
    [array]$downloads = ((Invoke-WebRequest -UseBasicParsing -Uri $url).Links | Where-Object href -like "*.zip" | Where-Object href -notlike "*archive*").href
    if($downloads.Length -eq 1){$download = ("https://github.com" + $downloads)}
    else{$download = ("https://github.com" + ($downloads -notmatch "^https://*")[0])}
    Write-Output "Downloading: $download `nto:          $path `n"
    Invoke-WebRequest -Uri $download -OutFile $path
}

function Get-GW2Radial{
    Get-GithubZIP "https://github.com/Friendly0Fire/GW2Radial/releases/latest" "$GW2Path\GW2Radial.zip"
    Expand-Archive -Path "$GW2Path\GW2Radial.zip" -DestinationPath "$GW2Path\GW2Radial-temp"
    $dll = (Get-ChildItem -Path "$GW2Path\GW2Radial-temp" -Recurse -Include "*.dll")[0]
    Move-Item -Path $dll -Destination "$GW2Path\d3d9_chainload.dll" -Force
    Remove-Item -Path "$GW2Path\GW2Radial-temp" -Recurse
    Remove-Item -Path "$GW2Path\GW2Radial.zip"
}

function Get-TacO{
    Get-GithubZIP "https://github.com/BoyC/GW2TacO/releases/latest" "$TacOPath\taco-temp.zip"
    Expand-Archive -Path "$TacOPath\taco-temp.zip" -DestinationPath "$TacOPath" -Force
    Remove-Item -Path "$TacOPath\taco-temp.zip"
}

function Get-TacO-Marker{
    $marker = ((Invoke-WebRequest -UseBasicParsing -Uri "http://tekkitsworkshop.net/index.php/gw2-taco/download").Links | Where-Object href -like “*all-in-one”).href
    $download = "http://tekkitsworkshop.net" + $marker[0]
    Write-Output "Downloading: $download `nto:          $TacOPath\POIs\tw_ALL_IN_ONE.taco `n"
    Invoke-WebRequest -Uri $download -OutFile "$TacOPath\POIs\tw_ALL_IN_ONE.taco"
}

function Update-Box{
    # build separate temp script that will run in user context, so the messagebox is visible
    $tempScriptPath = "$env:TEMP\update-gw2-addons-temp.ps1"
    $tempScript = "
    Add-Type -AssemblyName System.Windows.Forms
    `$title = ""Update for script 'update-gw2-addons' available!""
    `$text = ""Update for script 'update-gw2-addons' available! `n`nYour current version: " + $currentScriptVersion + "`nLatest version: " + $actualVersion + "`n`nWould you like to open the Download-Website of the latest version?""
    `$box = [System.Windows.Forms.MessageBox]::Show(`$text, `$title, 4, 'Information')
    if(`$box -eq 'Yes'){Write-Output 'Opening website...'; Start-Process 'https://github.com/Skaldhor/update-gw2-addons/releases/latest'}
    elseif(`$box -eq 'No'){Write-Output 'Do not open website...'}
    "
    if((Test-Path $tempScriptPath) -eq $true){Remove-Item $tempScriptPath}
    Add-Content -Path $tempScriptPath -Value $tempScript

    # create a scheduled task that will run the temp script in user context
    $schtaskUser = Get-WmiObject -Class win32_computersystem | ForEach-Object Username
    $schtaskTime = (Get-Date).AddMinutes(1).ToShortTimeString()
    $schtaskName = "update-gw2-addons-temp"
    $schtaskCommand = "powershell.exe -ExecutionPolicy bypass -File $tempScriptPath"
    schtasks /create /tn $schtaskName /sc once /tr $schtaskCommand /st $schtaskTime /ru $schtaskUser /f

    # wait for task scheduler to execute the temp script (worst case 60 seconds + buffer)
    Start-Sleep 90

    # delete temp script and scheduled task
    if((Test-Path $tempScriptPath) -eq $true){Remove-Item $tempScriptPath}
    schtasks /delete /tn $schtaskName /f
}



# ---------------------------
# installing/updating addons
# ---------------------------


# install/uninstall ArcDPS
if($installArcDPS -eq $true){
    Get-ArcDPS
}
if($installArcDPS -eq $false){
    if((Test-Path "$GW2Path\d3d9.dll") -eq $true){Remove-Item "$GW2Path\d3d9.dll"}
}

# install/uninstall ArcDPS Boon Table
if(($installArcDPSBoonTable -eq $true) -and ($installArcDPS -eq $true)){
    Get-GithubDLL "https://github.com/knoxfighter/GW2-ArcDPS-Boon-Table/releases/latest" "$GW2Path\d3d9_arcdps_table.dll"
}
if(($installArcDPSBoonTable -eq $false) -or ($installArcDPS -eq $false)){
    if((Test-Path "$GW2Path\d3d9_arcdps_table.dll") -eq $true){Remove-Item "$GW2Path\d3d9_arcdps_table.dll"}
}

# install/uninstall ArcDPS BuildPad Plugin
if(($installArcDPSBuildPad -eq $true) -and ($installArcDPS -eq $true)){
    Invoke-WebRequest -Uri "https://buildpad.gw2archive.eu/versions/latest" -OutFile "$GW2Path\d3d9_arcdps_buildpad.dll"
}
if(($installArcDPSBuildPad -eq $false) -or ($installArcDPS -eq $false)){
    if((Test-Path "$GW2Path\d3d9_arcdps_buildpad.dll") -eq $true){Remove-Item "$GW2Path\d3d9_arcdps_buildpad.dll"}
}

# install/uninstall ArcDPS Healing Stats Plugin
if(($installArcDPSHealingStats -eq $true) -and ($installArcDPS -eq $true)){
    Get-GithubDLL "https://github.com/Krappa322/arcdps_healing_stats/releases/latest" "$GW2Path\arcdps_healing_stats.dll"
}
if(($installArcDPSHealingStats -eq $false) -or ($installArcDPS -eq $false)){
    if((Test-Path "$GW2Path\arcdps_healing_stats.dll") -eq $true){Remove-Item "$GW2Path\arcdps_healing_stats.dll"}
}

# install/uninstall ArcDPS Killproof Plugin
if(($installArcDPSKillproofPlugin -eq $true) -and ($installArcDPS -eq $true)){
    Get-GithubDLL "https://github.com/knoxfighter/arcdps-killproof.me-plugin/releases/latest" "$GW2Path\d3d9_arcdps_killproof_me.dll"
}
if(($installArcDPSKillproofPlugin -eq $false) -or ($installArcDPS -eq $false)){
    if((Test-Path "$GW2Path\d3d9_arcdps_killproof_me.dll") -eq $true){Remove-Item "$GW2Path\d3d9_arcdps_killproof_me.dll"}
}

# install/uninstall ArcDPS Mechanics Log
if(($installArcDPSMechanicsLog -eq $true) -and ($installArcDPS -eq $true)){
    Get-GithubDLL "https://github.com/knoxfighter/GW2-ArcDPS-Mechanics-Log/releases/latest" "$GW2Path\d3d9_arcdps_mechanics.dll"
}
if(($installArcDPSMechanicsLog -eq $false) -or ($installArcDPS -eq $false)){
    if((Test-Path "$GW2Path\d3d9_arcdps_mechanics.dll") -eq $true){Remove-Item "$GW2Path\d3d9_arcdps_mechanics.dll"}
}

# install/uninstall ArcDPS Mount Tool Plugin
if(($installArcDPSMountTool -eq $true) -and ($installArcDPS -eq $true)){
    Get-GithubDLL "https://github.com/jiangyi0923/GW2_arcdps_MountTool/releases/latest" "$GW2Path\d3d9_arcdps_MountTool.dll"
}
if(($installArcDPSMountTool -eq $false) -or ($installArcDPS -eq $false)){
    if((Test-Path "$GW2Path\d3d9_arcdps_MountTool.dll") -eq $true){Remove-Item "$GW2Path\d3d9_arcdps_MountTool.dll"}
}

# install/uninstall ArcDPS Unofficial Extras
if(($installArcDPSUnofficialExtras -eq $true) -and ($installArcDPS -eq $true)){
    Get-GithubDLL "https://github.com/Krappa322/arcdps_unofficial_extras_releases/releases/latest" "$GW2Path\arcdps_unofficial_extras.dll"
}
if(($installArcDPSUnofficialExtras -eq $false) -or ($installArcDPS -eq $false)){
    if((Test-Path "$GW2Path\arcdps_unofficial_extras.dll") -eq $true){Remove-Item "$GW2Path\arcdps_unofficial_extras.dll"}
}

# install/uninstall TacO
if($installTacO -eq $true){
    Get-TacO
}

# install/uninstall Tekkit markers for TacO
if(($installTekkitMarkersForTacO -eq $true) -and ($installTacO -eq $true)){
    Get-TacO-Marker
}
if($installTekkitMarkersForTacO -eq $false){
    if((Test-Path "$TacOPath\POIs\tw_ALL_IN_ONE.taco") -eq $true){Remove-Item "$TacOPath\POIs\tw_ALL_IN_ONE.taco"}
}

# install/uninstall GW2Radial
if(($installGW2Radial -eq $true) -and ($installArcDPS -eq $true)){
    Get-GW2Radial
}
if(($installGW2Radial -eq $true) -and ($installArcDPS -eq $false)){
    Get-GW2Radial
    if((Test-Path "$GW2Path\d3d9_chainload.dll") -eq $true){Rename-Item "$GW2Path\d3d9_chainload.dll" -NewName "d3d9.dll"}
}
if(($installGW2Radial -eq $false) -and ($installArcDPS -eq $true)){
    if((Test-Path "$GW2Path\d3d9_chainload.dll") -eq $true){Remove-Item "$GW2Path\d3d9_chainload.dll"}
}
if(($installGW2Radial -eq $false) -and ($installArcDPS -eq $false)){
    if((Test-Path "$GW2Path\d3d9.dll") -eq $true){Remove-Item "$GW2Path\d3d9.dll"}
    if((Test-Path "$GW2Path\d3d9_chainload.dll") -eq $true){Remove-Item "$GW2Path\d3d9_chainload.dll"}
}

# check for updates for this script
if($checkForUpdates -eq $true){
    Update-Script
}