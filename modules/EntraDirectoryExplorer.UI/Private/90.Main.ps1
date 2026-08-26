function Initialize-AppState {
    $script:State = @{
        User = [pscustomobject]@{
            Selected = $null
            DirectGroupIds = New-Object 'System.Collections.Generic.HashSet[string]'
            SearchPaging = New-PagingState -PageSize 25
            DevicePaging = New-PagingState -PageSize 25
            GroupPaging = New-PagingState -PageSize 50
        }
        Group = [pscustomobject]@{
            Selected = $null
            SearchPaging = New-PagingState -PageSize 25
            MemberPaging = New-PagingState -PageSize 50
        }
        Device = [pscustomobject]@{
            Selected = $null
            SearchPaging = New-PagingState -PageSize 25
            OwnerPaging = New-PagingState -PageSize 25
            UserPaging = New-PagingState -PageSize 25
            GroupPaging = New-PagingState -PageSize 50
        }
    }
}

function Set-ConnectionUiState {
    [CmdletBinding()]
    param([Parameter(Mandatory)][bool]$Connected)

    $script:Ui.Tabs.Enabled = $Connected
    $script:Ui.ConnectButton.Enabled = -not $Connected
    $script:Ui.DisconnectButton.Enabled = $Connected

    if ($Connected) {
        $context = Get-EntraConnectionContext
        $account = if ($null -ne $context) { [string]$context.Account } else { 'Microsoft Graph' }
        Set-AppStatus -Text "Connected as $account"
    }
    else {
        Set-AppStatus -Text 'Not connected.'
    }
}

function Connect-App {
    Invoke-UiOperation -Status 'Connecting to Microsoft Entra ID...' -Action {
        [void](Connect-EntraDirectory)
        Set-ConnectionUiState -Connected $true
    }
}

function Disconnect-App {
    Invoke-UiOperation -Status 'Disconnecting...' -Action {
        Disconnect-EntraDirectory
        Set-ConnectionUiState -Connected $false
    }
}

function New-MainForm {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Entra Directory Explorer'
    $form.Size = New-Object System.Drawing.Size(1380, 850)
    $form.MinimumSize = New-Object System.Drawing.Size(1100, 720)
    $form.StartPosition = 'CenterScreen'

    $toolbar = New-Object System.Windows.Forms.FlowLayoutPanel
    $toolbar.Dock = 'Top'
    $toolbar.Height = 42
    $toolbar.FlowDirection = 'LeftToRight'
    $toolbar.WrapContents = $false
    $toolbar.Padding = New-Object System.Windows.Forms.Padding(7)

    $connect = New-Object System.Windows.Forms.Button
    $connect.Text = 'Connect to Entra ID'
    $connect.AutoSize = $true
    $connect.Add_Click({ Connect-App })

    $disconnect = New-Object System.Windows.Forms.Button
    $disconnect.Text = 'Disconnect'
    $disconnect.AutoSize = $true
    $disconnect.Enabled = $false
    $disconnect.Add_Click({ Disconnect-App })

    $status = New-Object System.Windows.Forms.Label
    $status.Text = 'Not connected.'
    $status.AutoSize = $true
    $status.Padding = New-Object System.Windows.Forms.Padding(14, 6, 0, 0)

    [void]$toolbar.Controls.Add($connect)
    [void]$toolbar.Controls.Add($disconnect)
    [void]$toolbar.Controls.Add($status)

    $tabs = New-Object System.Windows.Forms.TabControl
    $tabs.Dock = 'Fill'
    $tabs.Enabled = $false

    $script:Ui.Form = $form
    $script:Ui.ConnectButton = $connect
    $script:Ui.DisconnectButton = $disconnect
    $script:Ui.StatusLabel = $status
    $script:Ui.Tabs = $tabs

    [void]$tabs.TabPages.Add((New-UserPage))
    [void]$tabs.TabPages.Add((New-GroupPage))
    [void]$tabs.TabPages.Add((New-DevicePage))

    $layout = New-Object System.Windows.Forms.TableLayoutPanel
    $layout.Dock = 'Fill'
    $layout.ColumnCount = 1
    $layout.RowCount = 2
 
    [void]$layout.RowStyles.Add(
        (New-Object System.Windows.Forms.RowStyle('Absolute', 42))
    )
    [void]$layout.RowStyles.Add(
        (New-Object System.Windows.Forms.RowStyle('Percent', 100))
    )
 
    $toolbar.Dock = 'Fill'
    $tabs.Dock = 'Fill'
 
    [void]$layout.Controls.Add($toolbar, 0, 0)
    [void]$layout.Controls.Add($tabs, 0, 1)
    [void]$form.Controls.Add($layout)

    $form.Add_FormClosed({
        if (Test-EntraConnection) {
            Disconnect-EntraDirectory
        }
    })

    return $form
}

function Start-EntraDirectoryExplorerApplication {
    [CmdletBinding()]
    param()

    Initialize-AppState
    $form = New-MainForm

    if (Test-EntraConnection) {
        Set-ConnectionUiState -Connected $true
    }

    [void]$form.ShowDialog()
}
