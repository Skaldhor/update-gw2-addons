# update-gw2-addons
This script will install/update/uninstall several Guild Wars 2 add-ons. Supported add-ons are:
1. [ArcDPS](https://www.deltaconnected.com/arcdps)
2. [ArcDPS Boon Table](https://github.com/knoxfighter/GW2-ArcDPS-Boon-Table)
3. [ArcDPS Killproof Plugin](https://github.com/knoxfighter/arcdps-killproof.me-plugin)
4. [ArcDPS Mechanics Log](https://github.com/knoxfighter/GW2-ArcDPS-Mechanics-Log)
5. [ArcDPS Unofficial Extras](https://github.com/Krappa322/arcdps_unofficial_extras_releases) (since v1.2)
6. [GW2Radial](https://github.com/Friendly0Fire/GW2Radial)
7. GW2TacO [Github](https://github.com/BoyC/GW2TacO) [Website](http://www.gw2taco.com/) (since v1.1)
8. [Tekkit markers for GW2TacO](http://tekkitsworkshop.net/index.php/gw2-taco/download)

## Installation
1. [download the .ps1 script](https://github.com/Skaldhor/update-gw2-addons/releases/latest)
2. edit the script, change the variables (install folder, desired add-ons) and save it
3. run the script manually or create a scheduled task to run the script automatically every day/reboot/whenever you want
4. when using task scheduler make sure to run the script with elevated rights and if you don't want to see the powershell window, select "run whether user is logged on or not" (you will still get a visible messeage box if an update is available (if you enabled checking for updates))