#requires -Version 5.1

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$requiredGraphVersion = '2.35.0'

if (-not (Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction SilentlyContinue)) {
    Install-PackageProvider -Name NuGet -Scope CurrentUser -Force | Out-Null
}

Install-Module Microsoft.Graph.Authentication `
    -Repository PSGallery `
    -Scope CurrentUser `
    -RequiredVersion $requiredGraphVersion `
    -Force `
    -AllowClobber

Write-Host "Microsoft.Graph.Authentication $requiredGraphVersion installed." -ForegroundColor Green
Write-Host 'Start the app with .\Start-EntraDirectoryExplorer.cmd.' -ForegroundColor Green
