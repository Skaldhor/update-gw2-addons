param([switch]$Elevated)
# --- declaring variables ---

# path to the GW2 folder "bin64"
$GW2Path = "C:\Program Files\Guild Wars 2\bin64"

# path to the folder that is/will be containing "GW2TacO.exe"
$TacOPath = "D:\path\to\GW2TacO"

# turn checking for updates on ($true) or off ($false)
$checkForUpdates = $true

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
$currentScriptVersion = "v1.6"

# setting the ProgressPreference to SilentlyContinue because downloads would take much longer (because of the displayed progress bar)
$ProgressPreference = 'SilentlyContinue'



# ---------------------------
# defining functions
# ---------------------------


function Check-Update{
    $url = ((Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/Skaldhor/update-gw2-addons/releases/latest").Links | Where href -like “/Skaldhor/update-gw2-addons/releases/tag/*”)[0].href
    $array = $url.Split("/")
    $actualVersion = $array[($array.Length - 1)]
    if($currentScriptVersion -ne $actualVersion){Write-Output "Update available, creating message box..."; Update-Box}
    else{Write-Output "Script is at the latest version."}
}

function Download-ArcDPS{
    Write-Output "Downloading: https://www.deltaconnected.com/arcdps/x64/d3d9.dll `nto:          $GW2Path\d3d9.dll `n"
    Invoke-WebRequest -Uri "https://www.deltaconnected.com/arcdps/x64/d3d9.dll" -OutFile "$GW2Path\d3d9.dll"
}

function Download-GithubDLL($url, $path){
    $download = ("https://github.com" + ((Invoke-WebRequest -UseBasicParsing -Uri $url).Links | Where href -like "*.dll")[0].href)
    Write-Output "Downloading: $download `nto:          $path `n"
    Invoke-WebRequest -Uri $download -OutFile $path
}

function Download-GithubZIP($url, $path){
    [array]$downloads = ((Invoke-WebRequest -UseBasicParsing -Uri $url).Links | Where href -like "*.zip" | Where href -notlike "*archive*").href
    if($downloads.Length -eq 1){$download = ("https://github.com" + $downloads)}
    else{$download = ("https://github.com" + ($downloads -notmatch "^https://*")[0])}
    Write-Output "Downloading: $download `nto:          $path `n"
    Invoke-WebRequest -Uri $download -OutFile $path
}

function Download-GW2Radial{
    Download-GithubZIP "https://github.com/Friendly0Fire/GW2Radial/releases/latest" "$GW2Path\GW2Radial.zip"
    Expand-Archive -Path "$GW2Path\GW2Radial.zip" -DestinationPath "$GW2Path\GW2Radial-temp"
    $dll = (Get-ChildItem -Path "$GW2Path\GW2Radial-temp" -Recurse -Include "*.dll")[0]
    Move-Item -Path $dll -Destination "$GW2Path\d3d9_chainload.dll" -Force
    Remove-Item -Path "$GW2Path\GW2Radial-temp" -Recurse
    Remove-Item -Path "$GW2Path\GW2Radial.zip"
}

function Download-TacO{
    Download-GithubZIP "https://github.com/BoyC/GW2TacO/releases/latest" "$TacOPath\taco-temp.zip"
    Expand-Archive -Path "$TacOPath\taco-temp.zip" -DestinationPath "$TacOPath" -Force
    Remove-Item -Path "$TacOPath\taco-temp.zip"
}

function Download-TacO-Marker{
    $marker = ((Invoke-WebRequest -UseBasicParsing -Uri "http://tekkitsworkshop.net/index.php/gw2-taco/download").Links | Where href -like “*all-in-one”).href
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
    $schtaskUser = Get-WmiObject -Class win32_computersystem | % Username
    $schtaskTime = (Get-Date).AddMinutes(1).ToShortTimeString()
    $schtaskName = "update-gw2-addons-temp"
    $schtaskCommand = "powershell.exe -ExecutionPolicy bypass -File $tempScriptPath"
    schtasks /create /tn $schtaskName /sc once /tr $schtaskCommand /st $schtaskTime /ru $schtaskUser /f

    # wait for task scheduler to execute the temp script (worst case 60 seconds + buffer)
    sleep 90

    # delete temp script and scheduled task
    if((Test-Path $tempScriptPath) -eq $true){Remove-Item $tempScriptPath}
    schtasks /delete /tn $schtaskName /f
}



# ---------------------------
# installing/updating addons
# ---------------------------


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
    Download-GW2Radial
}
if(($installGW2Radial -eq $true) -and ($installArcDPS -eq $false)){
    Download-GW2Radial
    if((Test-Path "$GW2Path\d3d9_chainload.dll") -eq $true){Remove-Item "$GW2Path\d3d9_chainload.dll"}
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
    Check-Update
}