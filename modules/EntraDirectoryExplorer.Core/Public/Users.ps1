function Get-EntraUserSearchPage {
    [CmdletBinding()]
    param(
        [string]$DisplayName,
        [string]$UserPrincipalName,
        [ValidateRange(1, 999)][int]$PageSize = 25,
        [string]$NextLink
    )

    Assert-EntraPageSize -PageSize $PageSize

    $uri = Resolve-EntraPageUri -NextLink $NextLink -InitialUriFactory {
        if ([string]::IsNullOrWhiteSpace($DisplayName) -and [string]::IsNullOrWhiteSpace($UserPrincipalName)) {
            throw 'Enter a display name or user principal name.'
        }

        $query = [ordered]@{
            '$select' = 'id,displayName,givenName,surname,mail,jobTitle,userPrincipalName,officeLocation,businessPhones,department,accountEnabled'
            '$top' = $PageSize
            '$count' = 'true'
            '$orderby' = 'displayName'
        }

        if (-not [string]::IsNullOrWhiteSpace($DisplayName)) {
            $search = ConvertTo-GraphSearchTerm -Value $DisplayName
            $query['$search'] = '"displayName:{0}"' -f $search
            [void]$query.Remove('$orderby')
        }

        if (-not [string]::IsNullOrWhiteSpace($UserPrincipalName)) {
            $upn = ConvertTo-ODataStringLiteral -Value $UserPrincipalName
            $query['$filter'] = "startsWith(userPrincipalName,'$upn')"
        }

        New-EntraGraphUri -Path 'users' -Query $query
    }

    Invoke-EntraGraphPage -Uri $uri
}

function Get-EntraUserById {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$UserId)

    $id = Get-EntraEntityIdPathSegment -Id $UserId
    $query = [ordered]@{
        '$select' = 'id,displayName,givenName,surname,mail,jobTitle,userPrincipalName,officeLocation,businessPhones,department,accountEnabled'
    }
    Invoke-EntraGraphObject -Uri (New-EntraGraphUri -Path "users/$id" -Query $query)
}

function Get-EntraUserManager {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$UserId)

    $id = Get-EntraEntityIdPathSegment -Id $UserId
    $query = [ordered]@{ '$select' = 'id,displayName,userPrincipalName,mail' }

    try {
        Invoke-EntraGraphObject -Uri (New-EntraGraphUri -Path "users/$id/manager/microsoft.graph.user" -Query $query)
    }
    catch {
        if ($_.Exception.Message -match '404|Request_ResourceNotFound') {
            return $null
        }
        throw
    }
}

function Get-EntraUserRegisteredDevicePage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$UserId,
        [ValidateRange(1, 999)][int]$PageSize = 25,
        [string]$NextLink
    )

    Assert-EntraPageSize -PageSize $PageSize
    $uri = Resolve-EntraPageUri -NextLink $NextLink -InitialUriFactory {
        $id = Get-EntraEntityIdPathSegment -Id $UserId
        $query = [ordered]@{
            '$select' = 'id'
            '$top' = $PageSize
            '$count' = 'true'
        }
        New-EntraGraphUri -Path "users/$id/registeredDevices" -Query $query
    }

    $page = Invoke-EntraGraphPage -Uri $uri
    Resolve-EntraPageItems `
        -Page $page `
        -EntitySet 'devices' `
        -Select 'id,deviceId,displayName,model,manufacturer,operatingSystem,operatingSystemVersion,approximateLastSignInDateTime,isManaged,isCompliant,trustType'
}

function Get-EntraUserMembershipPage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$UserId,
        [switch]$DirectOnly,
        [ValidateRange(1, 999)][int]$PageSize = 50,
        [string]$NextLink
    )

    Assert-EntraPageSize -PageSize $PageSize
    $uri = Resolve-EntraPageUri -NextLink $NextLink -InitialUriFactory {
        $id = Get-EntraEntityIdPathSegment -Id $UserId
        $relationship = if ($DirectOnly) { 'memberOf' } else { 'transitiveMemberOf' }
        $query = [ordered]@{
            '$select' = 'id,displayName,description,mail,mailEnabled,securityEnabled,groupTypes'
            '$top' = $PageSize
            '$count' = 'true'
        }
        New-EntraGraphUri -Path "users/$id/$relationship/microsoft.graph.group" -Query $query
    }

    Invoke-EntraGraphPage -Uri $uri
}

function Get-EntraUserDirectGroupIds {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$UserId)

    $id = Get-EntraEntityIdPathSegment -Id $UserId
    $query = [ordered]@{
        '$select' = 'id'
        '$top' = 999
        '$count' = 'true'
    }
    $uri = New-EntraGraphUri -Path "users/$id/memberOf/microsoft.graph.group" -Query $query

    return @(
        Get-EntraAllItems -InitialUri $uri |
            ForEach-Object { [string]$_.id }
    )
}
