function New-UserPage {
    $tab = New-Object System.Windows.Forms.TabPage
    $tab.Text = 'Users'
    $tab.Padding = New-Object System.Windows.Forms.Padding(6)

    $split = New-Object System.Windows.Forms.SplitContainer
    $split.Dock = 'Fill'
    $split.Orientation = 'Vertical'
    $split.Size = New-Object System.Drawing.Size(1050, 700)
    $split.Panel1MinSize = 420
    $split.Panel2MinSize = 450
    $split.SplitterDistance = 500

    $left = New-Object System.Windows.Forms.TableLayoutPanel
    $left.Dock = 'Fill'
    $left.RowCount = 3
    $left.ColumnCount = 1
    [void]$left.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute', 235)))
    [void]$left.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute', 270)))
    [void]$left.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Percent', 100)))

    $searchBox = New-Object System.Windows.Forms.GroupBox
    $searchBox.Text = 'Search users'
    $searchBox.Dock = 'Fill'

    $searchLayout = New-Object System.Windows.Forms.TableLayoutPanel
    $searchLayout.Dock = 'Fill'
    $searchLayout.ColumnCount = 2
    $searchLayout.RowCount = 5
    [void]$searchLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle('Absolute', 105)))
    [void]$searchLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle('Percent', 100)))
    [void]$searchLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute', 28)))
    [void]$searchLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute', 28)))
    [void]$searchLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute', 34)))
    [void]$searchLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Percent', 100)))
    [void]$searchLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute', 38)))

    $upnLabel = New-Object System.Windows.Forms.Label
    $upnLabel.Text = 'UPN'
    $upnLabel.Dock = 'Fill'
    $upnLabel.TextAlign = 'MiddleLeft'
    $upnInput = New-Object System.Windows.Forms.TextBox
    $upnInput.Dock = 'Fill'

    $nameLabel = New-Object System.Windows.Forms.Label
    $nameLabel.Text = 'Display name'
    $nameLabel.Dock = 'Fill'
    $nameLabel.TextAlign = 'MiddleLeft'
    $nameInput = New-Object System.Windows.Forms.TextBox
    $nameInput.Dock = 'Fill'

    $buttons = New-SearchButtonRow
    $searchResults = New-ListView -Columns ([ordered]@{ 'Name' = 180; 'UPN' = 255 })
    $searchPager = New-Pager

    [void]$searchLayout.Controls.Add($upnLabel, 0, 0)
    [void]$searchLayout.Controls.Add($upnInput, 1, 0)
    [void]$searchLayout.Controls.Add($nameLabel, 0, 1)
    [void]$searchLayout.Controls.Add($nameInput, 1, 1)
    [void]$searchLayout.Controls.Add($buttons.Panel, 0, 2)
    $searchLayout.SetColumnSpan($buttons.Panel, 2)
    [void]$searchLayout.Controls.Add($searchResults, 0, 3)
    $searchLayout.SetColumnSpan($searchResults, 2)
    [void]$searchLayout.Controls.Add($searchPager.Panel, 0, 4)
    $searchLayout.SetColumnSpan($searchPager.Panel, 2)
    [void]$searchBox.Controls.Add($searchLayout)

    $details = New-DetailsBox -Title 'User details' -Fields ([ordered]@{
        DisplayName = 'Name'
        UserPrincipalName = 'UPN'
        Mail = 'E-mail'
        JobTitle = 'Title'
        Department = 'Department'
        OfficeLocation = 'Office'
        Manager = 'Manager'
        BusinessPhone = 'Phone'
        AccountEnabled = 'Enabled'
    })

    $deviceBox = New-Object System.Windows.Forms.GroupBox
    $deviceBox.Text = 'Registered devices'
    $deviceBox.Dock = 'Fill'
    $deviceLayout = New-Object System.Windows.Forms.TableLayoutPanel
    $deviceLayout.Dock = 'Fill'
    $deviceLayout.RowCount = 2
    $deviceLayout.ColumnCount = 1
    [void]$deviceLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Percent', 100)))
    [void]$deviceLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute', 38)))
    $devices = New-ListView -Columns ([ordered]@{ 'Name' = 145; 'Model' = 115; 'OS' = 80; 'Last sign-in' = 125 })
    $devicePager = New-Pager
    [void]$deviceLayout.Controls.Add($devices, 0, 0)
    [void]$deviceLayout.Controls.Add($devicePager.Panel, 0, 1)
    [void]$deviceBox.Controls.Add($deviceLayout)

    [void]$left.Controls.Add($searchBox, 0, 0)
    [void]$left.Controls.Add($details.Group, 0, 1)
    [void]$left.Controls.Add($deviceBox, 0, 2)
    [void]$split.Panel1.Controls.Add($left)

    $groupBox = New-Object System.Windows.Forms.GroupBox
    $groupBox.Text = 'Group memberships'
    $groupBox.Dock = 'Fill'
    $groupLayout = New-Object System.Windows.Forms.TableLayoutPanel
    $groupLayout.Dock = 'Fill'
    $groupLayout.RowCount = 3
    $groupLayout.ColumnCount = 1
    [void]$groupLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute', 36)))
    [void]$groupLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Percent', 100)))
    [void]$groupLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute', 38)))

    $groupToolbar = New-Object System.Windows.Forms.FlowLayoutPanel
    $groupToolbar.Dock = 'Fill'
    $groupToolbar.FlowDirection = 'LeftToRight'
    $groupToolbar.WrapContents = $false
    $directOnly = New-Object System.Windows.Forms.CheckBox
    $directOnly.Text = 'Direct memberships only'
    $directOnly.AutoSize = $true
    $directOnly.Padding = New-Object System.Windows.Forms.Padding(4, 6, 0, 0)
    $refreshGroups = New-Object System.Windows.Forms.Button
    $refreshGroups.Text = 'Refresh'
    $refreshGroups.AutoSize = $true
    [void]$groupToolbar.Controls.Add($directOnly)
    [void]$groupToolbar.Controls.Add($refreshGroups)

    $groups = New-ListView -Columns ([ordered]@{ 'Group' = 220; 'Description' = 360; 'Type' = 120; 'Relation' = 75 })
    $groupPager = New-Pager
    [void]$groupLayout.Controls.Add($groupToolbar, 0, 0)
    [void]$groupLayout.Controls.Add($groups, 0, 1)
    [void]$groupLayout.Controls.Add($groupPager.Panel, 0, 2)
    [void]$groupBox.Controls.Add($groupLayout)
    [void]$split.Panel2.Controls.Add($groupBox)

    [void]$tab.Controls.Add($split)

    $script:Ui.UserUpnInput = $upnInput
    $script:Ui.UserNameInput = $nameInput
    $script:Ui.UserSearchResults = $searchResults
    $script:Ui.UserSearchPager = $searchPager
    $script:Ui.UserDetails = $details.Controls
    $script:Ui.UserDevices = $devices
    $script:Ui.UserDevicePager = $devicePager
    $script:Ui.UserGroups = $groups
    $script:Ui.UserGroupPager = $groupPager
    $script:Ui.UserDirectOnly = $directOnly

    $buttons.SearchButton.Add_Click({ Invoke-UserSearchPage -Direction 'First' })
    $buttons.ClearButton.Add_Click({ Clear-UserPage })
    $searchResults.Add_DoubleClick({ Select-UserFromSearchResults })
    $searchPager.PreviousButton.Add_Click({ Invoke-UserSearchPage -Direction 'Previous' })
    $searchPager.NextButton.Add_Click({ Invoke-UserSearchPage -Direction 'Next' })
    $devicePager.PreviousButton.Add_Click({ Invoke-UserDevicePage -Direction 'Previous' })
    $devicePager.NextButton.Add_Click({ Invoke-UserDevicePage -Direction 'Next' })
    $groupPager.PreviousButton.Add_Click({ Invoke-UserGroupPage -Direction 'Previous' })
    $groupPager.NextButton.Add_Click({ Invoke-UserGroupPage -Direction 'Next' })
    $directOnly.Add_CheckedChanged({
        if ($null -ne $script:State.User.Selected) { Invoke-UserGroupPage -Direction 'First' }
    })
    $refreshGroups.Add_Click({ Invoke-UserGroupPage -Direction 'Refresh' })
    $devices.Add_DoubleClick({ Open-DeviceFromUserPage })
    $groups.Add_DoubleClick({ Open-GroupFromUserPage })
    $details.Controls['Mail'].Add_DoubleClick({ Open-UserMail })
    $details.Controls['BusinessPhone'].Add_DoubleClick({ Open-UserPhone })
    $nameInput.Add_KeyDown({
        param($sender, $eventArgs)
        if ($eventArgs.KeyCode -eq [System.Windows.Forms.Keys]::Enter) {
            Invoke-UserSearchPage -Direction 'First'
            $eventArgs.SuppressKeyPress = $true
        }
    })

    return $tab
}

function Update-UserSearchPage {
    [CmdletBinding()]
    param([ValidateSet('First', 'Next', 'Previous', 'Refresh')][string]$Direction)

    $paging = $script:State.User.SearchPaging
    $target = Get-PagingTarget -Paging $paging -Direction $Direction
    $result = Get-EntraUserSearchPage `
        -DisplayName $script:Ui.UserNameInput.Text `
        -UserPrincipalName $script:Ui.UserUpnInput.Text `
        -PageSize $paging.PageSize `
        -NextLink $target

    Complete-PagingMove -Paging $paging -Direction $Direction -Result $result
    Set-ListViewRows -ListView $script:Ui.UserSearchResults -Items @($result.Items) -Columns {
        param($user)
        @($user.displayName, $user.userPrincipalName)
    }
    Update-Pager -Paging $paging -Pager $script:Ui.UserSearchPager
    Set-AppStatus -Text ('Found {0} user(s) on this page.' -f @($result.Items).Count)
}

function Invoke-UserSearchPage {
    [CmdletBinding()]
    param([ValidateSet('First', 'Next', 'Previous', 'Refresh')][string]$Direction = 'First')

    Invoke-UiOperation -Status 'Searching users...' -Action { Update-UserSearchPage -Direction $Direction }
}

function Select-UserFromSearchResults {
    $user = Get-SelectedListObject -ListView $script:Ui.UserSearchResults
    if ($null -eq $user) { return }
    Open-UserObject -User $user
}

function Open-UserObject {
    [CmdletBinding()]
    param([Parameter(Mandatory)]$User)

    Invoke-UiOperation -Status 'Loading user details...' -Action {
        $detail = Get-EntraUserById -UserId ([string]$User.id)
        $manager = Get-EntraUserManager -UserId ([string]$detail.id)
        $script:State.User.Selected = $detail
        $script:State.User.DirectGroupIds.Clear()
        foreach ($groupId in @(Get-EntraUserDirectGroupIds -UserId ([string]$detail.id))) {
            [void]$script:State.User.DirectGroupIds.Add([string]$groupId)
        }

        Set-DetailValues -Controls $script:Ui.UserDetails -Values @{
            DisplayName = $detail.displayName
            UserPrincipalName = $detail.userPrincipalName
            Mail = $detail.mail
            JobTitle = $detail.jobTitle
            Department = $detail.department
            OfficeLocation = $detail.officeLocation
            Manager = if ($null -ne $manager) { $manager.displayName } else { '' }
            BusinessPhone = if (@($detail.businessPhones).Count -gt 0) { $detail.businessPhones[0] } else { '' }
            AccountEnabled = $detail.accountEnabled
        }

        $script:Ui.UserNameInput.Text = [string]$detail.displayName
        $script:Ui.UserUpnInput.Text = [string]$detail.userPrincipalName
        Update-UserDevicePage -Direction 'First'
        Update-UserGroupPage -Direction 'First'
        Set-AppStatus -Text ('Loaded {0}.' -f $detail.displayName)
    }
}

function Update-UserDevicePage {
    [CmdletBinding()]
    param([ValidateSet('First', 'Next', 'Previous', 'Refresh')][string]$Direction)

    if ($null -eq $script:State.User.Selected) { return }
    $paging = $script:State.User.DevicePaging
    $target = Get-PagingTarget -Paging $paging -Direction $Direction
    $result = Get-EntraUserRegisteredDevicePage `
        -UserId ([string]$script:State.User.Selected.id) `
        -PageSize $paging.PageSize `
        -NextLink $target

    Complete-PagingMove -Paging $paging -Direction $Direction -Result $result
    Set-ListViewRows -ListView $script:Ui.UserDevices -Items @($result.Items) -Columns {
        param($device)
        @(
            $device.displayName
            $device.model
            $device.operatingSystem
            (Format-GraphDateTime $device.approximateLastSignInDateTime)
        )
    }
    Update-Pager -Paging $paging -Pager $script:Ui.UserDevicePager
}

function Invoke-UserDevicePage {
    [CmdletBinding()]
    param([ValidateSet('First', 'Next', 'Previous', 'Refresh')][string]$Direction)

    Invoke-UiOperation -Status 'Loading registered devices...' -Action {
        Update-UserDevicePage -Direction $Direction
        Set-AppStatus -Text 'Registered devices loaded.'
    }
}

function Update-UserGroupPage {
    [CmdletBinding()]
    param([ValidateSet('First', 'Next', 'Previous', 'Refresh')][string]$Direction)

    if ($null -eq $script:State.User.Selected) { return }
    $paging = $script:State.User.GroupPaging
    $target = Get-PagingTarget -Paging $paging -Direction $Direction
    $params = @{
        UserId = [string]$script:State.User.Selected.id
        PageSize = $paging.PageSize
        NextLink = $target
        DirectOnly = $script:Ui.UserDirectOnly.Checked
    }
    $result = Get-EntraUserMembershipPage @params

    Complete-PagingMove -Paging $paging -Direction $Direction -Result $result
    Set-ListViewRows -ListView $script:Ui.UserGroups -Items @($result.Items) -Columns {
        param($group)
        $relation = if ($script:State.User.DirectGroupIds.Contains([string]$group.id)) { 'Direct' } else { 'Nested' }
        @($group.displayName, $group.description, (Get-GroupKind $group), $relation)
    }
    Update-Pager -Paging $paging -Pager $script:Ui.UserGroupPager
}

function Invoke-UserGroupPage {
    [CmdletBinding()]
    param([ValidateSet('First', 'Next', 'Previous', 'Refresh')][string]$Direction)

    Invoke-UiOperation -Status 'Loading group memberships...' -Action {
        Update-UserGroupPage -Direction $Direction
        Set-AppStatus -Text 'Group memberships loaded.'
    }
}

function Open-DeviceFromUserPage {
    $device = Get-SelectedListObject -ListView $script:Ui.UserDevices
    if ($null -eq $device) { return }
    $script:Ui.Tabs.SelectedIndex = 2
    Open-DeviceObject -Device $device
}

function Open-GroupFromUserPage {
    $group = Get-SelectedListObject -ListView $script:Ui.UserGroups
    if ($null -eq $group) { return }
    $script:Ui.Tabs.SelectedIndex = 1
    Open-GroupObject -Group $group
}

function Open-UserMail {
    $mail = $script:Ui.UserDetails['Mail'].Text.Trim()
    if (-not [string]::IsNullOrWhiteSpace($mail)) {
        Start-Process -FilePath ('mailto:{0}' -f $mail)
    }
}

function Open-UserPhone {
    $phone = $script:Ui.UserDetails['BusinessPhone'].Text.Trim()
    if (-not [string]::IsNullOrWhiteSpace($phone)) {
        Start-Process -FilePath ('tel:{0}' -f $phone)
    }
}

function Clear-UserPage {
    $script:Ui.UserUpnInput.Clear()
    $script:Ui.UserNameInput.Clear()
    $script:Ui.UserSearchResults.Items.Clear()
    $script:Ui.UserDevices.Items.Clear()
    $script:Ui.UserGroups.Items.Clear()
    Clear-DetailValues -Controls $script:Ui.UserDetails
    $script:State.User.Selected = $null
    $script:State.User.DirectGroupIds.Clear()
    Reset-PagingState -Paging $script:State.User.SearchPaging
    Reset-PagingState -Paging $script:State.User.DevicePaging
    Reset-PagingState -Paging $script:State.User.GroupPaging
    Update-Pager -Paging $script:State.User.SearchPaging -Pager $script:Ui.UserSearchPager
    Update-Pager -Paging $script:State.User.DevicePaging -Pager $script:Ui.UserDevicePager
    Update-Pager -Paging $script:State.User.GroupPaging -Pager $script:Ui.UserGroupPager
    Set-AppStatus -Text 'User page cleared.'
}
