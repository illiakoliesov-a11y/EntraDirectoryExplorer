function Assert-EntraPageSize {
    [CmdletBinding()]
    param([Parameter(Mandatory)][int]$PageSize)

    if ($PageSize -lt 1 -or $PageSize -gt 999) {
        throw 'PageSize must be between 1 and 999.'
    }
}

function ConvertTo-GraphSearchTerm {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Value)

    return $Value.Trim().Replace('\', '\\').Replace('"', '\"')
}

function ConvertTo-ODataStringLiteral {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Value)

    return $Value.Trim().Replace("'", "''")
}

function New-EntraGraphUri {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Path,
        [System.Collections.IDictionary]$Query
    )

    $normalizedPath = $Path.TrimStart('/')
    $uri = '{0}/{1}' -f $script:GraphApiRoot, $normalizedPath

    if ($null -eq $Query -or $Query.Count -eq 0) {
        return $uri
    }

    $parts = foreach ($key in $Query.Keys) {
        $value = $Query[$key]
        if ($null -ne $value -and [string]$value -ne '') {
            '{0}={1}' -f [uri]::EscapeDataString([string]$key), [uri]::EscapeDataString([string]$value)
        }
    }

    return '{0}?{1}' -f $uri, ($parts -join '&')
}

function Get-EntraResponseProperty {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$Response,
        [Parameter(Mandatory)][string]$Name
    )

    if ($Response -is [System.Collections.IDictionary]) {
        return $Response[$Name]
    }

    $property = $Response.PSObject.Properties[$Name]
    if ($null -ne $property) {
        return $property.Value
    }

    return $null
}

function Resolve-EntraPageUri {
    [CmdletBinding()]
    param(
        [string]$NextLink,
        [Parameter(Mandatory)][scriptblock]$InitialUriFactory
    )

    if (-not [string]::IsNullOrWhiteSpace($NextLink)) {
        $parsed = $null
        if (-not [uri]::TryCreate($NextLink, [UriKind]::Absolute, [ref]$parsed)) {
            throw 'The Microsoft Graph nextLink is not a valid absolute URI.'
        }

        if ($parsed.Scheme -ne 'https' -or $parsed.Host -ne 'graph.microsoft.com') {
            throw 'The Microsoft Graph nextLink points to an unexpected host.'
        }

        return $NextLink
    }

    return & $InitialUriFactory
}

function Invoke-EntraGraphPage {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Uri)

    $headers = @{ ConsistencyLevel = 'eventual' }
    $response = Invoke-MgGraphRequest -Method GET -Uri $Uri -Headers $headers -OutputType PSObject -ErrorAction Stop
    $rawItems = Get-EntraResponseProperty -Response $response -Name 'value'
    $nextLink = Get-EntraResponseProperty -Response $response -Name '@odata.nextLink'
    $totalCount = Get-EntraResponseProperty -Response $response -Name '@odata.count'

    $items = @()
    if ($null -ne $rawItems) {
        $items = @($rawItems)
    }

    [pscustomobject]@{
        Items = $items
        NextLink = if ([string]::IsNullOrWhiteSpace([string]$nextLink)) { $null } else { [string]$nextLink }
        TotalCount = $totalCount
        RequestUri = $Uri
    }
}

function Invoke-EntraGraphObject {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Uri)

    Invoke-MgGraphRequest -Method GET -Uri $Uri -OutputType PSObject -ErrorAction Stop
}

function Get-EntraAllItems {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$InitialUri)

    $items = New-Object System.Collections.Generic.List[object]
    $next = $InitialUri

    while (-not [string]::IsNullOrWhiteSpace($next)) {
        $page = Invoke-EntraGraphPage -Uri $next
        foreach ($item in $page.Items) {
            $items.Add($item)
        }
        $next = $page.NextLink
    }

    return $items.ToArray()
}

function Resolve-EntraDirectoryObjects {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][AllowEmptyCollection()][object[]]$Items,
        [Parameter(Mandatory)][ValidateSet('users', 'devices')][string]$EntitySet,
        [Parameter(Mandatory)][string]$Select
    )

    if ($Items.Count -eq 0) { return @() }

    $resolved = New-Object System.Collections.Generic.List[object]
    $batchUri = '{0}/{1}' -f $script:GraphApiRoot, '$batch'

    for ($offset = 0; $offset -lt $Items.Count; $offset += 20) {
        $lastIndex = [Math]::Min($offset + 19, $Items.Count - 1)
        $requests = New-Object System.Collections.Generic.List[object]

        for ($index = $offset; $index -le $lastIndex; $index++) {
            $objectId = Get-EntraEntityIdPathSegment -Id ([string]$Items[$index].id)
            $relativeUri = '/{0}/{1}?%24select={2}' -f `
                $EntitySet,
                $objectId,
                [uri]::EscapeDataString($Select)

            $requests.Add([ordered]@{
                id = [string]$index
                method = 'GET'
                url = $relativeUri
            })
        }

        $payload = @{ requests = $requests.ToArray() } | ConvertTo-Json -Depth 8 -Compress
        $batchResponse = Invoke-MgGraphRequest `
            -Method POST `
            -Uri $batchUri `
            -Body $payload `
            -ContentType 'application/json' `
            -OutputType PSObject `
            -ErrorAction Stop

        $responses = @(Get-EntraResponseProperty -Response $batchResponse -Name 'responses')
        $responseById = @{}
        foreach ($response in $responses) {
            $responseById[[string]$response.id] = $response
        }

        for ($index = $offset; $index -le $lastIndex; $index++) {
            $response = $responseById[[string]$index]
            if ($null -eq $response) {
                throw "Microsoft Graph batch response $index is missing."
            }

            $status = [int]$response.status
            if ($status -lt 200 -or $status -ge 300) {
                $body = Get-EntraResponseProperty -Response $response -Name 'body'
                $errorObject = if ($null -ne $body) {
                    Get-EntraResponseProperty -Response $body -Name 'error'
                }
                else { $null }
                $message = if ($null -ne $errorObject) {
                    Get-EntraResponseProperty -Response $errorObject -Name 'message'
                }
                else { 'Unknown batch error.' }
                throw "Microsoft Graph batch item $index failed with HTTP ${status}: $message"
            }

            $resolved.Add((Get-EntraResponseProperty -Response $response -Name 'body'))
        }
    }

    return $resolved.ToArray()
}

function Resolve-EntraPageItems {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$Page,
        [Parameter(Mandatory)][ValidateSet('users', 'devices')][string]$EntitySet,
        [Parameter(Mandatory)][string]$Select
    )

    [pscustomobject]@{
        Items = @(Resolve-EntraDirectoryObjects -Items @($Page.Items) -EntitySet $EntitySet -Select $Select)
        NextLink = $Page.NextLink
        TotalCount = $Page.TotalCount
        RequestUri = $Page.RequestUri
    }
}

function Get-EntraEntityIdPathSegment {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Id)

    if ([string]::IsNullOrWhiteSpace($Id)) {
        throw 'A Microsoft Entra object ID is required.'
    }

    return [uri]::EscapeDataString($Id.Trim())
}
