#requires -Version 5.1

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

if ($PSVersionTable.Platform -and $PSVersionTable.Platform -ne 'Win32NT') {
    throw 'Entra Directory Explorer uses Windows Forms and must be run on Windows.'
}

$requiredGraphVersion = [version]'2.35.0'
$graphModule = Get-Module -ListAvailable -Name Microsoft.Graph.Authentication |
    Where-Object { $_.Version -eq $requiredGraphVersion } |
    Select-Object -First 1

if ($null -eq $graphModule) {
    throw @'
Microsoft.Graph.Authentication 2.35.0 is not installed.
Run .\Install-Dependencies.ps1 once, then start this script again.
'@
}

try {
    Import-Module $graphModule.Path -Force -ErrorAction Stop
}
catch {
    throw "Microsoft.Graph.Authentication 2.35.0 could not be loaded. Start the app with Start-EntraDirectoryExplorer.cmd. Details: $($_.Exception.Message)"
}

$uiModule = Join-Path $PSScriptRoot 'modules/EntraDirectoryExplorer.UI/EntraDirectoryExplorer.UI.psd1'
Import-Module $uiModule -Force
Start-EntraDirectoryExplorerApplication
