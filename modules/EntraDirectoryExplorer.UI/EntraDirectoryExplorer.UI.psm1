# Graph can omit null-valued optional properties, so UI binding intentionally uses
# StrictMode 1.0 (uninitialized variables) rather than treating absent properties
# as fatal errors.
Set-StrictMode -Version 1.0

$script:ModuleRoot = $PSScriptRoot
$coreManifest = Join-Path (Split-Path $script:ModuleRoot -Parent) 'EntraDirectoryExplorer.Core/EntraDirectoryExplorer.Core.psd1'
Import-Module $coreManifest -Force -ErrorAction Stop

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$script:Ui = @{}
$script:State = @{}

Get-ChildItem -Path (Join-Path $script:ModuleRoot 'Private') -Filter '*.ps1' |
    Sort-Object Name |
    ForEach-Object { . $_.FullName }

Export-ModuleMember -Function 'Start-EntraDirectoryExplorerApplication'
