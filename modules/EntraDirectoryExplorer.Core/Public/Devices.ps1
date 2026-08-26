function Get-EntraDeviceSearchPage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$DisplayName,
        [ValidateRange(1, 999)][int]$PageSize = 25,
        [string]$NextLink
    )

    Assert-EntraPageSize -PageSize $PageSize
    $uri = Resolve-EntraPageUri -NextLink $NextLink -InitialUriFactory {
        if ([string]::IsNullOrWhiteSpace($DisplayName)) {
            throw 'Enter a device display name.'
        }

        $search = ConvertTo-GraphSearchTerm -Value $DisplayName
        $query = [ordered]@{
            '$search' = '"displayName:{0}"' -f $search
            '$select' = 'id,deviceId,displayName,model,manufacturer,operatingSystem,operatingSystemVersion,approximateLastSignInDateTime,isManaged,isCompliant,trustType,accountEnabled,registrationDateTime'
            '$top' = $PageSize
            '$count' = 'true'
        }
        New-EntraGraphUri -Path 'devices' -Query $query
    }

    Invoke-EntraGraphPage -Uri $uri
}

function Get-EntraDeviceById {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$DeviceId)

    $id = Get-EntraEntityIdPathSegment -Id $DeviceId
    $query = [ordered]@{
        '$select' = 'id,deviceId,displayName,model,manufacturer,operatingSystem,operatingSystemVersion,approximateLastSignInDateTime,isManaged,isCompliant,trustType,accountEnabled,registrationDateTime'
    }
    Invoke-EntraGraphObject -Uri (New-EntraGraphUri -Path "devices/$id" -Query $query)
}

function Get-EntraDeviceRegisteredOwnerPage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$DeviceId,
        [ValidateRange(1, 999)][int]$PageSize = 25,
        [string]$NextLink
    )

    Assert-EntraPageSize -PageSize $PageSize
    $uri = Resolve-EntraPageUri -NextLink $NextLink -InitialUriFactory {
        $id = Get-EntraEntityIdPathSegment -Id $DeviceId
        $query = [ordered]@{
            '$select' = 'id'
            '$top' = $PageSize
            '$count' = 'true'
        }
        New-EntraGraphUri -Path "devices/$id/registeredOwners" -Query $query
    }

    $page = Invoke-EntraGraphPage -Uri $uri
    Resolve-EntraPageItems `
        -Page $page `
        -EntitySet 'users' `
        -Select 'id,displayName,userPrincipalName,mail,jobTitle,accountEnabled'
}

function Get-EntraDeviceRegisteredUserPage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$DeviceId,
        [ValidateRange(1, 999)][int]$PageSize = 25,
        [string]$NextLink
    )

    Assert-EntraPageSize -PageSize $PageSize
    $uri = Resolve-EntraPageUri -NextLink $NextLink -InitialUriFactory {
        $id = Get-EntraEntityIdPathSegment -Id $DeviceId
        $query = [ordered]@{
            '$select' = 'id'
            '$top' = $PageSize
            '$count' = 'true'
        }
        New-EntraGraphUri -Path "devices/$id/registeredUsers" -Query $query
    }

    $page = Invoke-EntraGraphPage -Uri $uri
    Resolve-EntraPageItems `
        -Page $page `
        -EntitySet 'users' `
        -Select 'id,displayName,userPrincipalName,mail,jobTitle,accountEnabled'
}

function Get-EntraDeviceMembershipPage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$DeviceId,
        [switch]$DirectOnly,
        [ValidateRange(1, 999)][int]$PageSize = 50,
        [string]$NextLink
    )

    Assert-EntraPageSize -PageSize $PageSize
    $uri = Resolve-EntraPageUri -NextLink $NextLink -InitialUriFactory {
        $id = Get-EntraEntityIdPathSegment -Id $DeviceId
        $relationship = if ($DirectOnly) { 'memberOf' } else { 'transitiveMemberOf' }
        $query = [ordered]@{
            '$select' = 'id,displayName,description,mail,mailEnabled,securityEnabled,groupTypes'
            '$top' = $PageSize
            '$count' = 'true'
        }
        New-EntraGraphUri -Path "devices/$id/$relationship/microsoft.graph.group" -Query $query
    }

    Invoke-EntraGraphPage -Uri $uri
}
