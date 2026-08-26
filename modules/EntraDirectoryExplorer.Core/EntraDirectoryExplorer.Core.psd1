@{
    RootModule = 'EntraDirectoryExplorer.Core.psm1'
    ModuleVersion = '1.0.0'
    GUID = '54e35d94-810c-4ba9-b156-e23949a9d1e9'
    Author = 'Illia Koliesov'
    Description = 'Microsoft Graph data-access and paging layer for Entra ID Search.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
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
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('EntraID', 'MicrosoftGraph', 'WinForms')
            ProjectUri = 'https://learn.microsoft.com/graph/'
        }
    }
}
