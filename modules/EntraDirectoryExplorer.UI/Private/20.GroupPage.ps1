function New-GroupPage {
    $tab = New-Object System.Windows.Forms.TabPage
    $tab.Text = 'Groups'
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
    $left.RowCount = 2
    $left.ColumnCount = 1
    [void]$left.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute', 285)))
    [void]$left.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Percent', 100)))

    $searchBox = New-Object System.Windows.Forms.GroupBox
    $searchBox.Text = 'Search groups'
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
    $searchResults = New-ListView -Columns ([ordered]@{ 'Name' = 180; 'Type' = 125; 'Description' = 155 })
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

    $details = New-DetailsBox -Title 'Group details' -Fields ([ordered]@{
        DisplayName = 'Name'
        Id = 'Object ID'
        Kind = 'Type'
        Description = 'Description'
        Mail = 'E-mail'
        MailEnabled = 'Mail enabled'
        SecurityEnabled = 'Security enabled'
        Dynamic = 'Dynamic'
        ProcessingState = 'Rule state'
    })

    [void]$left.Controls.Add($searchBox, 0, 0)
    [void]$left.Controls.Add($details.Group, 0, 1)
    [void]$split.Panel1.Controls.Add($left)

    $membersBox = New-Object System.Windows.Forms.GroupBox
    $membersBox.Text = 'Members'
    $membersBox.Dock = 'Fill'
    $membersLayout = New-Object System.Windows.Forms.TableLayoutPanel
    $membersLayout.Dock = 'Fill'
    $membersLayout.RowCount = 3
    $membersLayout.ColumnCount = 1
    [void]$membersLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute', 40)))
    [void]$membersLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Percent', 100)))
    [void]$membersLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle('Absolute', 38)))

    $toolbar = New-Object System.Windows.Forms.FlowLayoutPanel
    $toolbar.Dock = 'Fill'
    $toolbar.FlowDirection = 'LeftToRight'
    $toolbar.WrapContents = $false
    $typeLabel = New-Object System.Windows.Forms.Label
    $typeLabel.Text = 'Member type:'
    $typeLabel.AutoSize = $true
    $typeLabel.Padding = New-Object System.Windows.Forms.Padding(3, 8, 0, 0)
    $type = New-Object System.Windows.Forms.ComboBox
    $type.DropDownStyle = 'DropDownList'
    $type.Width = 110
    [void]$type.Items.AddRange(@('Users', 'Groups', 'Devices'))
    $type.SelectedIndex = 0
    $transitive = New-Object System.Windows.Forms.CheckBox
    $transitive.Text = 'Include nested members'
    $transitive.AutoSize = $true
    $transitive.Padding = New-Object System.Windows.Forms.Padding(8, 6, 0, 0)
    $refresh = New-Object System.Windows.Forms.Button
    $refresh.Text = 'Refresh'
    $refresh.AutoSize = $true
    [void]$toolbar.Controls.Add($typeLabel)
    [void]$toolbar.Controls.Add($type)
    [void]$toolbar.Controls.Add($transitive)
    [void]$toolbar.Controls.Add($refresh)

    $members = New-ListView -Columns ([ordered]@{ 'Name' = 220; 'Identifier' = 235; 'Details' = 255; 'State' = 95 })
    $memberPager = New-Pager
    [void]$membersLayout.Controls.Add($toolbar, 0, 0)
    [void]$membersLayout.Controls.Add($members, 0, 1)
    [void]$membersLayout.Controls.Add($memberPager.Panel, 0, 2)
    [void]$membersBox.Controls.Add($membersLayout)
    [void]$split.Panel2.Controls.Add($membersBox)
    [void]$tab.Controls.Add($split)

    $script:Ui.GroupNameInput = $nameInput
    $script:Ui.GroupSearchResults = $searchResults
    $script:Ui.GroupSearchPager = $searchPager
    $script:Ui.GroupDetails = $details.Controls
    $script:Ui.GroupMemberType = $type
    $script:Ui.GroupTransitive = $transitive
    $script:Ui.GroupMembers = $members
    $script:Ui.GroupMemberPager = $memberPager

    $buttons.SearchButton.Add_Click({ Invoke-GroupSearchPage -Direction 'First' })
    $buttons.ClearButton.Add_Click({ Clear-GroupPage })
    $searchResults.Add_DoubleClick({ Select-GroupFromSearchResults })
    $searchPager.PreviousButton.Add_Click({ Invoke-GroupSearchPage -Direction 'Previous' })
    $searchPager.NextButton.Add_Click({ Invoke-GroupSearchPage -Direction 'Next' })
    $memberPager.PreviousButton.Add_Click({ Invoke-GroupMemberPage -Direction 'Previous' })
    $memberPager.NextButton.Add_Click({ Invoke-GroupMemberPage -Direction 'Next' })
    $type.Add_SelectedIndexChanged({
        if ($null -ne $script:State.Group.Selected) { Invoke-GroupMemberPage -Direction 'First' }
    })
    $transitive.Add_CheckedChanged({
        if ($null -ne $script:State.Group.Selected) { Invoke-GroupMemberPage -Direction 'First' }
    })
    $refresh.Add_Click({ Invoke-GroupMemberPage -Direction 'Refresh' })
    $members.Add_DoubleClick({ Open-SelectedGroupMember })
    $nameInput.Add_KeyDown({
        param($sender, $eventArgs)
        if ($eventArgs.KeyCode -eq [System.Windows.Forms.Keys]::Enter) {
            Invoke-GroupSearchPage -Direction 'First'
            $eventArgs.SuppressKeyPress = $true
        }
    })

    return $tab
}

function Update-GroupSearchPage {
    [CmdletBinding()]
    param([ValidateSet('First', 'Next', 'Previous', 'Refresh')][string]$Direction)

    $paging = $script:State.Group.SearchPaging
    $target = Get-PagingTarget -Paging $paging -Direction $Direction
    $result = Get-EntraGroupSearchPage `
        -DisplayName $script:Ui.GroupNameInput.Text `
        -PageSize $paging.PageSize `
        -NextLink $target

    Complete-PagingMove -Paging $paging -Direction $Direction -Result $result
    Set-ListViewRows -ListView $script:Ui.GroupSearchResults -Items @($result.Items) -Columns {
        param($group)
        @($group.displayName, (Get-GroupKind $group), $group.description)
    }
    Update-Pager -Paging $paging -Pager $script:Ui.GroupSearchPager
    Set-AppStatus -Text ('Found {0} group(s) on this page.' -f @($result.Items).Count)
}

function Invoke-GroupSearchPage {
    [CmdletBinding()]
    param([ValidateSet('First', 'Next', 'Previous', 'Refresh')][string]$Direction = 'First')

    Invoke-UiOperation -Status 'Searching groups...' -Action { Update-GroupSearchPage -Direction $Direction }
}

function Select-GroupFromSearchResults {
    $group = Get-SelectedListObject -ListView $script:Ui.GroupSearchResults
    if ($null -eq $group) { return }
    Open-GroupObject -Group $group
}

function Open-GroupObject {
    [CmdletBinding()]
    param([Parameter(Mandatory)]$Group)

    Invoke-UiOperation -Status 'Loading group details...' -Action {
        $detail = Get-EntraGroupById -GroupId ([string]$Group.id)
        $script:State.Group.Selected = $detail
        $isDynamic = (@($detail.groupTypes) -contains 'DynamicMembership')

        Set-DetailValues -Controls $script:Ui.GroupDetails -Values @{
            DisplayName = $detail.displayName
            Id = $detail.id
            Kind = Get-GroupKind $detail
            Description = $detail.description
            Mail = $detail.mail
            MailEnabled = $detail.mailEnabled
            SecurityEnabled = $detail.securityEnabled
            Dynamic = $isDynamic
            ProcessingState = $detail.membershipRuleProcessingState
        }

        $script:Ui.GroupNameInput.Text = [string]$detail.displayName
        Update-GroupMemberPage -Direction 'First'
        Set-AppStatus -Text ('Loaded {0}.' -f $detail.displayName)
    }
}

function Update-GroupMemberPage {
    [CmdletBinding()]
    param([ValidateSet('First', 'Next', 'Previous', 'Refresh')][string]$Direction)

    if ($null -eq $script:State.Group.Selected) { return }
    $paging = $script:State.Group.MemberPaging
    $target = Get-PagingTarget -Paging $paging -Direction $Direction
    $memberType = [string]$script:Ui.GroupMemberType.SelectedItem
    $params = @{
        GroupId = [string]$script:State.Group.Selected.id
        MemberType = $memberType
        Transitive = $script:Ui.GroupTransitive.Checked
        PageSize = $paging.PageSize
        NextLink = $target
    }
    $result = Get-EntraGroupMemberPage @params

    Complete-PagingMove -Paging $paging -Direction $Direction -Result $result
    Set-ListViewRows -ListView $script:Ui.GroupMembers -Items @($result.Items) -Columns {
        param($member)
        switch ($memberType) {
            'Users' {
                @(
                    $member.displayName
                    $member.userPrincipalName
                    $member.jobTitle
                    $(if ([bool]$member.accountEnabled) { 'Enabled' } else { 'Disabled' })
                )
            }
            'Groups' {
                @($member.displayName, $member.mail, $member.description, (Get-GroupKind $member))
            }
            'Devices' {
                @(
                    $member.displayName
                    $member.deviceId
                    ('{0} {1} | {2}' -f $member.operatingSystem, $member.operatingSystemVersion, $member.model)
                    $(if ([bool]$member.isManaged) { 'Managed' } else { 'Unmanaged' })
                )
            }
        }
    }
    Update-Pager -Paging $paging -Pager $script:Ui.GroupMemberPager
}

function Invoke-GroupMemberPage {
    [CmdletBinding()]
    param([ValidateSet('First', 'Next', 'Previous', 'Refresh')][string]$Direction)

    Invoke-UiOperation -Status 'Loading group members...' -Action {
        Update-GroupMemberPage -Direction $Direction
        Set-AppStatus -Text 'Group members loaded.'
    }
}

function Open-SelectedGroupMember {
    $member = Get-SelectedListObject -ListView $script:Ui.GroupMembers
    if ($null -eq $member) { return }

    switch ([string]$script:Ui.GroupMemberType.SelectedItem) {
        'Users' {
            $script:Ui.Tabs.SelectedIndex = 0
            Open-UserObject -User $member
        }
        'Groups' { Open-GroupObject -Group $member }
        'Devices' {
            $script:Ui.Tabs.SelectedIndex = 2
            Open-DeviceObject -Device $member
        }
    }
}

function Clear-GroupPage {
    $script:Ui.GroupNameInput.Clear()
    $script:Ui.GroupSearchResults.Items.Clear()
    $script:Ui.GroupMembers.Items.Clear()
    Clear-DetailValues -Controls $script:Ui.GroupDetails
    $script:State.Group.Selected = $null
    Reset-PagingState -Paging $script:State.Group.SearchPaging
    Reset-PagingState -Paging $script:State.Group.MemberPaging
    Update-Pager -Paging $script:State.Group.SearchPaging -Pager $script:Ui.GroupSearchPager
    Update-Pager -Paging $script:State.Group.MemberPaging -Pager $script:Ui.GroupMemberPager
    Set-AppStatus -Text 'Group page cleared.'
}
