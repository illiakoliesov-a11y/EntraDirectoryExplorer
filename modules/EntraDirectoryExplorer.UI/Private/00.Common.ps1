function New-PagingState {
    [CmdletBinding()]
    param([ValidateRange(1, 999)][int]$PageSize = 25)

    [pscustomobject]@{
        History = New-Object 'System.Collections.Generic.Stack[string]'
        CurrentUri = $null
        NextUri = $null
        PageNumber = 0
        PageSize = $PageSize
        ItemCount = 0
        TotalCount = $null
    }
}

function Get-PagingTarget {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$Paging,
        [ValidateSet('First', 'Next', 'Previous', 'Refresh')][string]$Direction
    )

    switch ($Direction) {
        'First' { return $null }
        'Next' {
            if ([string]::IsNullOrWhiteSpace([string]$Paging.NextUri)) { return $null }
            return [string]$Paging.NextUri
        }
        'Previous' {
            if ($Paging.History.Count -eq 0) { return $null }
            return [string]$Paging.History.Peek()
        }
        'Refresh' { return [string]$Paging.CurrentUri }
    }
}

function Complete-PagingMove {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$Paging,
        [ValidateSet('First', 'Next', 'Previous', 'Refresh')][string]$Direction,
        [Parameter(Mandatory)]$Result
    )

    switch ($Direction) {
        'First' {
            $Paging.History.Clear()
            $Paging.PageNumber = 1
        }
        'Next' {
            if (-not [string]::IsNullOrWhiteSpace([string]$Paging.CurrentUri)) {
                $Paging.History.Push([string]$Paging.CurrentUri)
            }
            $Paging.PageNumber++
        }
        'Previous' {
            if ($Paging.History.Count -gt 0) {
                [void]$Paging.History.Pop()
            }
            $Paging.PageNumber = [Math]::Max(1, $Paging.PageNumber - 1)
        }
        'Refresh' {
            if ($Paging.PageNumber -eq 0) { $Paging.PageNumber = 1 }
        }
    }

    $Paging.CurrentUri = [string]$Result.RequestUri
    $Paging.NextUri = $Result.NextLink
    $Paging.ItemCount = @($Result.Items).Count
    # Directory APIs normally return @odata.count only on the first page.
    # Preserve that first-page value while navigating subsequent nextLinks.
    if ($Direction -eq 'First' -or $null -ne $Result.TotalCount) {
        $Paging.TotalCount = $Result.TotalCount
    }
}

function Reset-PagingState {
    [CmdletBinding()]
    param([Parameter(Mandatory)]$Paging)

    $Paging.History.Clear()
    $Paging.CurrentUri = $null
    $Paging.NextUri = $null
    $Paging.PageNumber = 0
    $Paging.ItemCount = 0
    $Paging.TotalCount = $null
}

function New-Pager {
    [CmdletBinding()]
    param()

    $panel = New-Object System.Windows.Forms.FlowLayoutPanel
    $panel.Dock = 'Fill'
    $panel.AutoSize = $true
    $panel.FlowDirection = 'LeftToRight'
    $panel.WrapContents = $false
    $panel.Padding = New-Object System.Windows.Forms.Padding(3)

    $back = New-Object System.Windows.Forms.Button
    $back.Text = 'Previous'
    $back.AutoSize = $true
    $back.Enabled = $false

    $label = New-Object System.Windows.Forms.Label
    $label.Text = 'No data'
    $label.AutoSize = $true
    $label.Padding = New-Object System.Windows.Forms.Padding(8, 7, 8, 0)

    $next = New-Object System.Windows.Forms.Button
    $next.Text = 'Next'
    $next.AutoSize = $true
    $next.Enabled = $false

    [void]$panel.Controls.Add($back)
    [void]$panel.Controls.Add($label)
    [void]$panel.Controls.Add($next)

    [pscustomobject]@{
        Panel = $panel
        PreviousButton = $back
        NextButton = $next
        Label = $label
    }
}

function Update-Pager {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$Paging,
        [Parameter(Mandatory)]$Pager
    )

    $Pager.PreviousButton.Enabled = ($Paging.History.Count -gt 0)
    $Pager.NextButton.Enabled = (-not [string]::IsNullOrWhiteSpace([string]$Paging.NextUri))

    if ($Paging.PageNumber -eq 0) {
        $Pager.Label.Text = 'No data'
        return
    }

    $start = (($Paging.PageNumber - 1) * $Paging.PageSize) + 1
    $end = $start + $Paging.ItemCount - 1
    if ($Paging.ItemCount -eq 0) {
        $start = 0
        $end = 0
    }

    if ($null -ne $Paging.TotalCount) {
        $Pager.Label.Text = 'Page {0}  |  {1}-{2} of {3}' -f $Paging.PageNumber, $start, $end, $Paging.TotalCount
    }
    else {
        $Pager.Label.Text = 'Page {0}  |  {1}-{2}' -f $Paging.PageNumber, $start, $end
    }
}

function New-DetailsBox {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Title,
        [Parameter(Mandatory)][System.Collections.IDictionary]$Fields
    )

    $group = New-Object System.Windows.Forms.GroupBox
    $group.Text = $Title
    $group.Dock = 'Fill'
    $group.Padding = New-Object System.Windows.Forms.Padding(8)

    $grid = New-Object System.Windows.Forms.TableLayoutPanel
    $grid.Dock = 'Fill'
    $grid.ColumnCount = 2
    $grid.RowCount = $Fields.Count
    [void]$grid.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle('Absolute', 105)))
    [void]$grid.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle('Percent', 100)))

    $controls = @{}
    $row = 0
    foreach ($key in $Fields.Keys) {
        $label = New-Object System.Windows.Forms.Label
        $label.Text = [string]$Fields[$key]
        $label.Dock = 'Fill'
        $label.TextAlign = 'MiddleLeft'

        $textbox = New-Object System.Windows.Forms.TextBox
        $textbox.ReadOnly = $true
        $textbox.Dock = 'Fill'
        $textbox.BackColor = [System.Drawing.SystemColors]::Window

        [void]$grid.Controls.Add($label, 0, $row)
        [void]$grid.Controls.Add($textbox, 1, $row)
        $controls[$key] = $textbox
        $row++
    }

    [void]$group.Controls.Add($grid)
    [pscustomobject]@{ Group = $group; Controls = $controls }
}

function New-ListView {
    [CmdletBinding()]
    param([Parameter(Mandatory)][System.Collections.IDictionary]$Columns)

    $list = New-Object System.Windows.Forms.ListView
    $list.Dock = 'Fill'
    $list.View = 'Details'
    $list.FullRowSelect = $true
    $list.HideSelection = $false
    $list.MultiSelect = $false
    $list.GridLines = $true

    foreach ($column in $Columns.Keys) {
        [void]$list.Columns.Add([string]$column, [int]$Columns[$column])
    }

    return $list
}

function Set-ListViewRows {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][System.Windows.Forms.ListView]$ListView,
        [Parameter(Mandatory)][AllowEmptyCollection()][object[]]$Items,
        [Parameter(Mandatory)][scriptblock]$Columns
    )

    $ListView.BeginUpdate()
    try {
        $ListView.Items.Clear()
        foreach ($source in $Items) {
            $values = @(& $Columns $source)
            if ($values.Count -eq 0) { continue }

            $row = New-Object System.Windows.Forms.ListViewItem ([string]$values[0])
            for ($index = 1; $index -lt $values.Count; $index++) {
                [void]$row.SubItems.Add([string]$values[$index])
            }
            $row.Tag = $source
            [void]$ListView.Items.Add($row)
        }
    }
    finally {
        $ListView.EndUpdate()
    }
}

function Get-SelectedListObject {
    [CmdletBinding()]
    param([Parameter(Mandatory)][System.Windows.Forms.ListView]$ListView)

    if ($ListView.SelectedItems.Count -eq 0) { return $null }
    return $ListView.SelectedItems[0].Tag
}

function ConvertTo-DisplayText {
    [CmdletBinding()]
    param($Value)

    if ($null -eq $Value) { return '' }
    if ($Value -is [bool]) { return $(if ($Value) { 'Yes' } else { 'No' }) }
    if ($Value -is [datetime] -or $Value -is [datetimeoffset]) {
        return ([datetimeoffset]$Value).ToLocalTime().ToString('dd.MM.yyyy HH:mm')
    }
    if ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [string]) {
        return (@($Value) -join ', ')
    }
    return [string]$Value
}

function Format-GraphDateTime {
    [CmdletBinding()]
    param($Value)

    if ($null -eq $Value -or [string]::IsNullOrWhiteSpace([string]$Value)) { return '' }
    $parsed = [datetimeoffset]::MinValue
    if ([datetimeoffset]::TryParse([string]$Value, [ref]$parsed)) {
        return $parsed.ToLocalTime().ToString('dd.MM.yyyy HH:mm')
    }
    return [string]$Value
}

function Get-GroupKind {
    [CmdletBinding()]
    param([Parameter(Mandatory)]$Group)

    $types = @($Group.groupTypes)
    if ($types -contains 'Unified') { return 'Microsoft 365' }
    if ([bool]$Group.securityEnabled -and [bool]$Group.mailEnabled) { return 'Mail-enabled security' }
    if ([bool]$Group.securityEnabled) { return 'Security' }
    if ([bool]$Group.mailEnabled) { return 'Distribution' }
    return 'Group'
}

function Set-DetailValues {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][System.Collections.IDictionary]$Controls,
        [Parameter(Mandatory)][System.Collections.IDictionary]$Values
    )

    foreach ($key in $Controls.Keys) {
        if ($Values.Contains($key)) {
            $Controls[$key].Text = ConvertTo-DisplayText $Values[$key]
        }
        else {
            $Controls[$key].Text = ''
        }
    }
}

function Clear-DetailValues {
    [CmdletBinding()]
    param([Parameter(Mandatory)][System.Collections.IDictionary]$Controls)

    foreach ($control in $Controls.Values) { $control.Text = '' }
}

function Set-AppStatus {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Text)

    $script:Ui.StatusLabel.Text = $Text
    [System.Windows.Forms.Application]::DoEvents()
}

function Show-AppError {
    [CmdletBinding()]
    param([Parameter(Mandatory)]$ErrorRecord)

    $message = $ErrorRecord.Exception.Message
    [void][System.Windows.Forms.MessageBox]::Show(
        $script:Ui.Form,
        $message,
        'Entra Directory Explorer',
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    )
    Set-AppStatus -Text 'Operation failed.'
}

function Invoke-UiOperation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Status,
        [Parameter(Mandatory)][scriptblock]$Action
    )

    $script:Ui.Form.UseWaitCursor = $true
    Set-AppStatus -Text $Status
    try {
        & $Action
    }
    catch {
        Show-AppError -ErrorRecord $_
    }
    finally {
        $script:Ui.Form.UseWaitCursor = $false
    }
}

function New-SearchButtonRow {
    [CmdletBinding()]
    param()

    $panel = New-Object System.Windows.Forms.FlowLayoutPanel
    $panel.Dock = 'Fill'
    $panel.AutoSize = $true
    $panel.FlowDirection = 'RightToLeft'

    $search = New-Object System.Windows.Forms.Button
    $search.Text = 'Search'
    $search.AutoSize = $true

    $clear = New-Object System.Windows.Forms.Button
    $clear.Text = 'Clear'
    $clear.AutoSize = $true

    [void]$panel.Controls.Add($search)
    [void]$panel.Controls.Add($clear)
    [pscustomobject]@{ Panel = $panel; SearchButton = $search; ClearButton = $clear }
}
