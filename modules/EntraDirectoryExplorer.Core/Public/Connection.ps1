function Connect-EntraDirectory {
    [CmdletBinding()]
    param()

    if (-not (Get-Module -Name Microsoft.Graph.Authentication)) {
        $graphModule = Get-Module -ListAvailable -Name Microsoft.Graph.Authentication |
            Where-Object { $_.Version -eq $script:GraphAuthenticationVersion } |
            Select-Object -First 1
        if ($null -eq $graphModule) {
            throw "Microsoft.Graph.Authentication $script:GraphAuthenticationVersion is required. Run Install-Dependencies.ps1."
        }
        Import-Module $graphModule.Path -ErrorAction Stop
    }
    Connect-MgGraph -Scopes $script:RequiredScopes -ErrorAction Stop | Out-Null
    return Get-EntraConnectionContext
}

function Disconnect-EntraDirectory {
    [CmdletBinding()]
    param()

    if (Test-EntraConnection) {
        Disconnect-MgGraph | Out-Null
    }
}

function Get-EntraConnectionContext {
    [CmdletBinding()]
    param()

    Get-MgContext -ErrorAction SilentlyContinue
}

function Test-EntraConnection {
    [CmdletBinding()]
    param()

    $context = Get-EntraConnectionContext
    return ($null -ne $context -and -not [string]::IsNullOrWhiteSpace([string]$context.Account))
}
