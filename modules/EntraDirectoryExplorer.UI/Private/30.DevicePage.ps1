function New-DevicePage {
    $tab = New-Object System.Windows.Forms.TabPage
    $tab.Text = 'Devices'
    $tab.Padding = New-Object System.Windows.Forms.Padding(6)

    $split = New-Object System.Windows.Forms.SplitContainer
    $split.Dock = 'Fill'
    $split.Orientation = 'Vertical'
    $split.Size = New-Object System.Drawing.Size(1050, 700)
    $split.Panel1MinSize = 480
    $split.Panel2MinSize = 420
    $split.SplitterDistance = 560

    $left = New-Object System.Windows.Forms.TableLayoutPanel
    $left.Dock = 'Fill'
    $left.RowCount = 2
    $left.ColumnCount = 1
    [void]$left.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute', 285)))
    [void]$left.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Percent', 100)))

    $searchBox = New-Object System.Windows.Forms.GroupBox
    $searchBox.Text = 'Search devices'
    $searchBox.Dock = 'Fill'
    $searchLayout = New-Object System.Windows.Forms.TableLayoutPanel
    $searchLayout.Dock = 'Fill'
    $searchLayout.ColumnCount = 2
    $searchLayout.RowCount = 4
    [void]$searchLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle('Absolute', 105)))
    [void]$searchLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle('Percent', 100)))
    [void]$searchLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute', 30)))
    [void]$searchLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute', 36)))
    [void]$searchLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Percent', 100)))
    [void]$searchLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute', 38)))

    $nameLabel = New-Object System.Windows.Forms.Label
    $nameLabel.Text = 'Display name'
    $nameLabel.Dock = 'Fill'
    $nameLabel.TextAlign = 'MiddleLeft'
    $nameInput = New-Object System.Windows.Forms.TextBox
    $nameInput.Dock = 'Fill'
    $buttons = New-SearchButtonRow
    $searchResults = New-ListView -Columns ([ordered]@{ 'Name' = 190; 'OS' = 105; 'Model' = 205 })
    $searchPager = New-Pager

    [void]$searchLayout.Controls.Add($nameLabel, 0, 0)
    [void]$searchLayout.Controls.Add($nameInput, 1, 0)
    [void]$searchLayout.Controls.Add($buttons.Panel, 0, 1)
    $searchLayout.SetColumnSpan($buttons.Panel, 2)
    [void]$searchLayout.Controls.Add($searchResults, 0, 2)
    $searchLayout.SetColumnSpan($searchResults, 2)
    [void]$searchLayout.Controls.Add($searchPager.Panel, 0, 3)
    $searchLayout.SetColumnSpan($searchPager.Panel, 2)
    [void]$searchBox.Controls.Add($searchLayout)

    $details = New-DetailsBox -Title 'Device details' -Fields ([ordered]@{
        DisplayName = 'Name'
        Id = 'Object ID'
        DeviceId = 'Device ID'
        OperatingSystem = 'Operating system'
        OperatingSystemVersion = 'OS version'
        Model = 'Model'
        Manufacturer = 'Manufacturer'
        TrustType = 'Trust type'
        IsManaged = 'Managed'
        IsCompliant = 'Compliant'
        AccountEnabled = 'Enabled'
        LastSignIn = 'Last sign-in'
        RegistrationDate = 'Registered'
    })

    [void]$left.Controls.Add($searchBox, 0, 0)
    [void]$left.Controls.Add($details.Group, 0, 1)
    [void]$split.Panel1.Controls.Add($left)

    $relations = New-Object System.Windows.Forms.TabControl
    $relations.Dock = 'Fill'

    $ownersTab = New-Object System.Windows.Forms.TabPage
    $ownersTab.Text = 'Registered owners'
    $ownersLayout = New-Object System.Windows.Forms.TableLayoutPanel
    $ownersLayout.Dock = 'Fill'
    $ownersLayout.RowCount = 2
    $ownersLayout.ColumnCount = 1
    [void]$ownersLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Percent', 100)))
    [void]$ownersLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute', 38)))
    $owners = New-ListView -Columns ([ordered]@{ 'Name' = 205; 'UPN' = 275; 'Title' = 155 })
    $ownerPager = New-Pager
    [void]$ownersLayout.Controls.Add($owners, 0, 0)
    [void]$ownersLayout.Controls.Add($ownerPager.Panel, 0, 1)
    [void]$ownersTab.Controls.Add($ownersLayout)

    $usersTab = New-Object System.Windows.Forms.TabPage
    $usersTab.Text = 'Registered users'
    $usersLayout = New-Object System.Windows.Forms.TableLayoutPanel
    $usersLayout.Dock = 'Fill'
    $usersLayout.RowCount = 2
    $usersLayout.ColumnCount = 1
    [void]$usersLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Percent', 100)))
    [void]$usersLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute', 38)))
    $users = New-ListView -Columns ([ordered]@{ 'Name' = 205; 'UPN' = 275; 'Title' = 155 })
    $userPager = New-Pager
    [void]$usersLayout.Controls.Add($users, 0, 0)
    [void]$usersLayout.Controls.Add($userPager.Panel, 0, 1)
    [void]$usersTab.Controls.Add($usersLayout)

    $groupsTab = New-Object System.Windows.Forms.TabPage
    $groupsTab.Text = 'Group memberships'
    $groupsLayout = New-Object System.Windows.Forms.TableLayoutPanel
    $groupsLayout.Dock = 'Fill'
    $groupsLayout.RowCount = 3
    $groupsLayout.ColumnCount = 1
    [void]$groupsLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute', 38)))
    [void]$groupsLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Percent', 100)))
    [void]$groupsLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute', 38)))
    $groupsToolbar = New-Object System.Windows.Forms.FlowLayoutPanel
    $groupsToolbar.Dock = 'Fill'
    $groupsToolbar.WrapContents = $false
    $directOnly = New-Object System.Windows.Forms.CheckBox
    $directOnly.Text = 'Direct memberships only'
    $directOnly.AutoSize = $true
    $directOnly.Padding = New-Object System.Windows.Forms.Padding(4, 6, 0, 0)
    $refreshGroups = New-Object System.Windows.Forms.Button
    $refreshGroups.Text = 'Refresh'
    $refreshGroups.AutoSize = $true
    [void]$groupsToolbar.Controls.Add($directOnly)
    [void]$groupsToolbar.Controls.Add($refreshGroups)
    $groups = New-ListView -Columns ([ordered]@{ 'Group' = 220; 'Type' = 135; 'Description' = 330 })
    $groupPager = New-Pager
    [void]$groupsLayout.Controls.Add($groupsToolbar, 0, 0)
    [void]$groupsLayout.Controls.Add($groups, 0, 1)
    [void]$groupsLayout.Controls.Add($groupPager.Panel, 0, 2)
    [void]$groupsTab.Controls.Add($groupsLayout)

    [void]$relations.TabPages.Add($ownersTab)
    [void]$relations.TabPages.Add($usersTab)
    [void]$relations.TabPages.Add($groupsTab)
    [void]$split.Panel2.Controls.Add($relations)
    [void]$tab.Controls.Add($split)

    $script:Ui.DeviceNameInput = $nameInput
    $script:Ui.DeviceSearchResults = $searchResults
    $script:Ui.DeviceSearchPager = $searchPager
    $script:Ui.DeviceDetails = $details.Controls
    $script:Ui.DeviceOwners = $owners
    $script:Ui.DeviceOwnerPager = $ownerPager
    $script:Ui.DeviceUsers = $users
    $script:Ui.DeviceUserPager = $userPager
    $script:Ui.DeviceGroups = $groups
    $script:Ui.DeviceGroupPager = $groupPager
    $script:Ui.DeviceDirectOnly = $directOnly

    $buttons.SearchButton.Add_Click({ Invoke-DeviceSearchPage -Direction 'First' })
    $buttons.ClearButton.Add_Click({ Clear-DevicePage })
    $searchResults.Add_DoubleClick({ Select-DeviceFromSearchResults })
    $searchPager.PreviousButton.Add_Click({ Invoke-DeviceSearchPage -Direction 'Previous' })
    $searchPager.NextButton.Add_Click({ Invoke-DeviceSearchPage -Direction 'Next' })
    $ownerPager.PreviousButton.Add_Click({ Invoke-DeviceOwnerPage -Direction 'Previous' })
    $ownerPager.NextButton.Add_Click({ Invoke-DeviceOwnerPage -Direction 'Next' })
    $userPager.PreviousButton.Add_Click({ Invoke-DeviceUserPage -Direction 'Previous' })
    $userPager.NextButton.Add_Click({ Invoke-DeviceUserPage -Direction 'Next' })
    $groupPager.PreviousButton.Add_Click({ Invoke-DeviceGroupPage -Direction 'Previous' })
    $groupPager.NextButton.Add_Click({ Invoke-DeviceGroupPage -Direction 'Next' })
    $directOnly.Add_CheckedChanged({
        if ($null -ne $script:State.Device.Selected) { Invoke-DeviceGroupPage -Direction 'First' }
    })
    $refreshGroups.Add_Click({ Invoke-DeviceGroupPage -Direction 'Refresh' })
    $owners.Add_DoubleClick({ Open-UserFromDeviceOwners })
    $users.Add_DoubleClick({ Open-UserFromDeviceUsers })
    $groups.Add_DoubleClick({ Open-GroupFromDevicePage })
    $nameInput.Add_KeyDown({
        param($sender, $eventArgs)
        if ($eventArgs.KeyCode -eq [System.Windows.Forms.Keys]::Enter) {
            Invoke-DeviceSearchPage -Direction 'First'
            $eventArgs.SuppressKeyPress = $true
        }
    })

    return $tab
}

function Update-DeviceSearchPage {
    [CmdletBinding()]
    param([ValidateSet('First', 'Next', 'Previous', 'Refresh')][string]$Direction)

    $paging = $script:State.Device.SearchPaging
    $target = Get-PagingTarget -Paging $paging -Direction $Direction
    $result = Get-EntraDeviceSearchPage `
        -DisplayName $script:Ui.DeviceNameInput.Text `
        -PageSize $paging.PageSize `
        -NextLink $target

    Complete-PagingMove -Paging $paging -Direction $Direction -Result $result
    Set-ListViewRows -ListView $script:Ui.DeviceSearchResults -Items @($result.Items) -Columns {
        param($device)
        @($device.displayName, $device.operatingSystem, $device.model)
    }
    Update-Pager -Paging $paging -Pager $script:Ui.DeviceSearchPager
    Set-AppStatus -Text ('Found {0} device(s) on this page.' -f @($result.Items).Count)
}

function Invoke-DeviceSearchPage {
    [CmdletBinding()]
    param([ValidateSet('First', 'Next', 'Previous', 'Refresh')][string]$Direction = 'First')

    Invoke-UiOperation -Status 'Searching devices...' -Action { Update-DeviceSearchPage -Direction $Direction }
}

function Select-DeviceFromSearchResults {
    $device = Get-SelectedListObject -ListView $script:Ui.DeviceSearchResults
    if ($null -eq $device) { return }
    Open-DeviceObject -Device $device
}

function Open-DeviceObject {
    [CmdletBinding()]
    param([Parameter(Mandatory)]$Device)

    Invoke-UiOperation -Status 'Loading device details...' -Action {
        $detail = Get-EntraDeviceById -DeviceId ([string]$Device.id)
        $script:State.Device.Selected = $detail
        Set-DetailValues -Controls $script:Ui.DeviceDetails -Values @{
            DisplayName = $detail.displayName
            Id = $detail.id
            DeviceId = $detail.deviceId
            OperatingSystem = $detail.operatingSystem
            OperatingSystemVersion = $detail.operatingSystemVersion
            Model = $detail.model
            Manufacturer = $detail.manufacturer
            TrustType = $detail.trustType
            IsManaged = $detail.isManaged
            IsCompliant = $detail.isCompliant
            AccountEnabled = $detail.accountEnabled
            LastSignIn = Format-GraphDateTime $detail.approximateLastSignInDateTime
            RegistrationDate = Format-GraphDateTime $detail.registrationDateTime
        }
        $script:Ui.DeviceNameInput.Text = [string]$detail.displayName
        Update-DeviceOwnerPage -Direction 'First'
        Update-DeviceUserPage -Direction 'First'
        Update-DeviceGroupPage -Direction 'First'
        Set-AppStatus -Text ('Loaded {0}.' -f $detail.displayName)
    }
}

function Update-DeviceOwnerPage {
    [CmdletBinding()]
    param([ValidateSet('First', 'Next', 'Previous', 'Refresh')][string]$Direction)

    if ($null -eq $script:State.Device.Selected) { return }
    $paging = $script:State.Device.OwnerPaging
    $target = Get-PagingTarget -Paging $paging -Direction $Direction
    $result = Get-EntraDeviceRegisteredOwnerPage `
        -DeviceId ([string]$script:State.Device.Selected.id) `
        -PageSize $paging.PageSize `
        -NextLink $target

    Complete-PagingMove -Paging $paging -Direction $Direction -Result $result
    Set-ListViewRows -ListView $script:Ui.DeviceOwners -Items @($result.Items) -Columns {
        param($user)
        @($user.displayName, $user.userPrincipalName, $user.jobTitle)
    }
    Update-Pager -Paging $paging -Pager $script:Ui.DeviceOwnerPager
}

function Invoke-DeviceOwnerPage {
    [CmdletBinding()]
    param([ValidateSet('First', 'Next', 'Previous', 'Refresh')][string]$Direction)

    Invoke-UiOperation -Status 'Loading device owners...' -Action {
        Update-DeviceOwnerPage -Direction $Direction
        Set-AppStatus -Text 'Device owners loaded.'
    }
}

function Update-DeviceUserPage {
    [CmdletBinding()]
    param([ValidateSet('First', 'Next', 'Previous', 'Refresh')][string]$Direction)

    if ($null -eq $script:State.Device.Selected) { return }
    $paging = $script:State.Device.UserPaging
    $target = Get-PagingTarget -Paging $paging -Direction $Direction
    $result = Get-EntraDeviceRegisteredUserPage `
        -DeviceId ([string]$script:State.Device.Selected.id) `
        -PageSize $paging.PageSize `
        -NextLink $target

    Complete-PagingMove -Paging $paging -Direction $Direction -Result $result
    Set-ListViewRows -ListView $script:Ui.DeviceUsers -Items @($result.Items) -Columns {
        param($user)
        @($user.displayName, $user.userPrincipalName, $user.jobTitle)
    }
    Update-Pager -Paging $paging -Pager $script:Ui.DeviceUserPager
}

function Invoke-DeviceUserPage {
    [CmdletBinding()]
    param([ValidateSet('First', 'Next', 'Previous', 'Refresh')][string]$Direction)

    Invoke-UiOperation -Status 'Loading registered users...' -Action {
        Update-DeviceUserPage -Direction $Direction
        Set-AppStatus -Text 'Registered users loaded.'
    }
}

function Update-DeviceGroupPage {
    [CmdletBinding()]
    param([ValidateSet('First', 'Next', 'Previous', 'Refresh')][string]$Direction)

    if ($null -eq $script:State.Device.Selected) { return }
    $paging = $script:State.Device.GroupPaging
    $target = Get-PagingTarget -Paging $paging -Direction $Direction
    $result = Get-EntraDeviceMembershipPage `
        -DeviceId ([string]$script:State.Device.Selected.id) `
        -DirectOnly:$script:Ui.DeviceDirectOnly.Checked `
        -PageSize $paging.PageSize `
        -NextLink $target

    Complete-PagingMove -Paging $paging -Direction $Direction -Result $result
    Set-ListViewRows -ListView $script:Ui.DeviceGroups -Items @($result.Items) -Columns {
        param($group)
        @($group.displayName, (Get-GroupKind $group), $group.description)
    }
    Update-Pager -Paging $paging -Pager $script:Ui.DeviceGroupPager
}

function Invoke-DeviceGroupPage {
    [CmdletBinding()]
    param([ValidateSet('First', 'Next', 'Previous', 'Refresh')][string]$Direction)

    Invoke-UiOperation -Status 'Loading device group memberships...' -Action {
        Update-DeviceGroupPage -Direction $Direction
        Set-AppStatus -Text 'Device group memberships loaded.'
    }
}

function Open-UserFromDeviceOwners {
    $user = Get-SelectedListObject -ListView $script:Ui.DeviceOwners
    if ($null -eq $user) { return }
    $script:Ui.Tabs.SelectedIndex = 0
    Open-UserObject -User $user
}

function Open-UserFromDeviceUsers {
    $user = Get-SelectedListObject -ListView $script:Ui.DeviceUsers
    if ($null -eq $user) { return }
    $script:Ui.Tabs.SelectedIndex = 0
    Open-UserObject -User $user
}

function Open-GroupFromDevicePage {
    $group = Get-SelectedListObject -ListView $script:Ui.DeviceGroups
    if ($null -eq $group) { return }
    $script:Ui.Tabs.SelectedIndex = 1
    Open-GroupObject -Group $group
}

function Clear-DevicePage {
    $script:Ui.DeviceNameInput.Clear()
    $script:Ui.DeviceSearchResults.Items.Clear()
    $script:Ui.DeviceOwners.Items.Clear()
    $script:Ui.DeviceUsers.Items.Clear()
    $script:Ui.DeviceGroups.Items.Clear()
    Clear-DetailValues -Controls $script:Ui.DeviceDetails
    $script:State.Device.Selected = $null
    Reset-PagingState -Paging $script:State.Device.SearchPaging
    Reset-PagingState -Paging $script:State.Device.OwnerPaging
    Reset-PagingState -Paging $script:State.Device.UserPaging
    Reset-PagingState -Paging $script:State.Device.GroupPaging
    Update-Pager -Paging $script:State.Device.SearchPaging -Pager $script:Ui.DeviceSearchPager
    Update-Pager -Paging $script:State.Device.OwnerPaging -Pager $script:Ui.DeviceOwnerPager
    Update-Pager -Paging $script:State.Device.UserPaging -Pager $script:Ui.DeviceUserPager
    Update-Pager -Paging $script:State.Device.GroupPaging -Pager $script:Ui.DeviceGroupPager
    Set-AppStatus -Text 'Device page cleared.'
}
