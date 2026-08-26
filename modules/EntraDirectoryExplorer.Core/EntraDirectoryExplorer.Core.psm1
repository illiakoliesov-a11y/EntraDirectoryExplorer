Set-StrictMode -Version Latest

$script:ModuleRoot = $PSScriptRoot
$script:GraphApiRoot = 'https://graph.microsoft.com/v1.0'
$script:GraphAuthenticationVersion = [version]'2.35.0'
$script:RequiredScopes = @(
    'User.Read.All'
    'Group.Read.All'
    'GroupMember.Read.All'
    'Device.Read.All'
)

Get-ChildItem -Path (Join-Path $script:ModuleRoot 'Private') -Filter '*.ps1' |
    Sort-Object Name |
    ForEach-Object { . $_.FullName }

Get-ChildItem -Path (Join-Path $script:ModuleRoot 'Public') -Filter '*.ps1' |
    Sort-Object Name |
    ForEach-Object { . $_.FullName }

Export-ModuleMember -Function @(
    'Connect-EntraDirectory'
    'Disconnect-EntraDirectory'
    'Get-EntraConnectionContext'
    'Test-EntraConnection'
    'Get-EntraUserSearchPage'
    'Get-EntraUserById'
    'Get-EntraUserManager'
    'Get-EntraUserRegisteredDevicePage'
    'Get-EntraUserMembershipPage'
    'Get-EntraUserDirectGroupIds'
    'Get-EntraGroupSearchPage'
    'Get-EntraGroupById'
    'Get-EntraGroupMemberPage'
    'Get-EntraDeviceSearchPage'
    'Get-EntraDeviceById'
    'Get-EntraDeviceRegisteredOwnerPage'
    'Get-EntraDeviceRegisteredUserPage'
    'Get-EntraDeviceMembershipPage'
)
