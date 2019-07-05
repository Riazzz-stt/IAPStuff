# ===========================================================================
# Author: [NDQ]Riaz
# Requirements: Steam Official Timeliens client Installed
# Requirements: IAP Installed
# Requirements: Powershell V2 or newer
# Usage: save as IAP-update.ps1 and run as below
# powershell.exe -executionpolicy bypass c:\pathtofile\IAP-update.ps1
# ===========================================================================

# Finding Steam Star Trek Timelines Install Location
$Timelines=Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | where { $_.DisplayName -like "Star Trek Timelines*"}
If ($Timelines.InstallLocation) {
	write-host  "Official Timelines Install Location: `"$($Timelines.InstallLocation)`"" -ForegroundColor green 
}Else{
	Write-Warning "Official Timelines Install Location file not found"
	write-host "Update Failed, review errors then press any key to continue ..."
	[void][System.Console]::ReadKey($true)
	exit
}

# Get Client_Version From Steam Install
if (Test-Path "$($Timelines.InstallLocation)\Timelines_Data\resources.assets"){
	$TimelinesVersion=Select-String -Pattern '(?<=CLIENT_VERSION:)(.+)' -path "$($Timelines.InstallLocation)\Timelines_Data\resources.assets"
	write-host  "Official Timelines Version: `"$($TimelinesVersion.Matches[0].Value)`"" -ForegroundColor green 
}Else{
	Write-Warning "Official Timelines `"resources.assets`" file not found"
	write-host "Update Failed, review errors then press any key to continue ..."
	[void][System.Console]::ReadKey($true)
	exit
}

# Finding IAmPicard App Install ID then lookups Install Location
$IAPid=Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | where { $_.DisplayName -like "Star Trek Timelines Crew Management*"}
If ($IAPid.PSChildName) {
	write-host "IAmPicard Install ID: `"$($IAPid.PSChildName)`"" -ForegroundColor green 
	$IAPver=Get-ItemProperty "HKCU:\Software\$($IAPid.PSChildName)"
	If ($IAPver.InstallLocation) {
		write-host "IAmPicard Install Location: `"$($IAPver.InstallLocation)`"" -ForegroundColor green 
	}Else{
	Write-Warning "IAmPicard Install Location not found"
	write-host "Update Failed, review errors then press any key to continue ..."
	[void][System.Console]::ReadKey($true)
	exit
	}
}Else{
	Write-Warning "IAmPicard Install ID not found"
	write-host "Update Failed, review errors then press any key to continue ..."
	[void][System.Console]::ReadKey($true)
	exit
}

# Set Location for bundle.js file
$bundle="$($IAPver.InstallLocation)\resources\app\dist\bundle.js"
if (Test-Path $bundle){
	write-host  "IAmPicard `"bundle.js`": `"$($bundle)`"" -ForegroundColor green
	(GC $bundle) -replace '(?<=CLIENT_VERSION=").*?(?=")', $TimelinesVersion.Matches[0].Value | SC $bundle
	write-host "IAmPicard updated with $($TimelinesVersion.Matches[0].Value) version string" -ForegroundColor green
}Else{	
	Write-Warning  "IAmPicard `"bundle.js`" file not found"
	write-host "Update Failed, review errors then press any key to continue ..."
	[void][System.Console]::ReadKey($true)
	exit
}