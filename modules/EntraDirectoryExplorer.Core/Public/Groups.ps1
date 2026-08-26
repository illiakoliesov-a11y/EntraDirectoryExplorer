function Get-EntraGroupSearchPage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$DisplayName,
        [ValidateRange(1, 999)][int]$PageSize = 25,
        [string]$NextLink
    )

    Assert-EntraPageSize -PageSize $PageSize
    $uri = Resolve-EntraPageUri -NextLink $NextLink -InitialUriFactory {
        if ([string]::IsNullOrWhiteSpace($DisplayName)) {
            throw 'Enter a group display name.'
        }

        $search = ConvertTo-GraphSearchTerm -Value $DisplayName
        $query = [ordered]@{
            '$search' = '"displayName:{0}"' -f $search
            '$select' = 'id,displayName,description,mail,mailEnabled,securityEnabled,groupTypes,membershipRule,membershipRuleProcessingState'
            '$top' = $PageSize
            '$count' = 'true'
        }
        New-EntraGraphUri -Path 'groups' -Query $query
    }

    Invoke-EntraGraphPage -Uri $uri
}

function Get-EntraGroupById {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$GroupId)

    $id = Get-EntraEntityIdPathSegment -Id $GroupId
    $query = [ordered]@{
        '$select' = 'id,displayName,description,mail,mailEnabled,securityEnabled,groupTypes,membershipRule,membershipRuleProcessingState'
    }
    Invoke-EntraGraphObject -Uri (New-EntraGraphUri -Path "groups/$id" -Query $query)
}

function Get-EntraGroupMemberPage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$GroupId,
        [ValidateSet('Users', 'Groups', 'Devices')][string]$MemberType = 'Users',
        [switch]$Transitive,
        [ValidateRange(1, 999)][int]$PageSize = 50,
        [string]$NextLink
    )

    Assert-EntraPageSize -PageSize $PageSize
    $uri = Resolve-EntraPageUri -NextLink $NextLink -InitialUriFactory {
        $id = Get-EntraEntityIdPathSegment -Id $GroupId
        $relationship = if ($Transitive) { 'transitiveMembers' } else { 'members' }

        switch ($MemberType) {
            'Users' {
                $cast = 'microsoft.graph.user'
                $select = 'id,displayName,userPrincipalName,mail,jobTitle,accountEnabled'
            }
            'Groups' {
                $cast = 'microsoft.graph.group'
                $select = 'id,displayName,description,mail,securityEnabled,groupTypes'
            }
            'Devices' {
                $cast = 'microsoft.graph.device'
                $select = 'id,deviceId,displayName,model,manufacturer,operatingSystem,operatingSystemVersion,isManaged,isCompliant,trustType'
            }
        }

        $query = [ordered]@{
            '$select' = $select
            '$top' = $PageSize
            '$count' = 'true'
        }
        New-EntraGraphUri -Path "groups/$id/$relationship/$cast" -Query $query
    }

    Invoke-EntraGraphPage -Uri $uri
}
