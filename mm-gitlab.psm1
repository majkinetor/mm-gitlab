# v0.031

function Initialize-GitLabSession {
    param(
        [string] $Url,
        [string] $Token
    )
    $script:GitLab = @{ Url = $Url; Token = $Token }
}

# https://docs.gitlab.com/ee/api/labels.html
function Get-GitLabLabel {
    param(
        [int] $ProjectId = $GL_ProjectId,
        [int] $Page = 1,
        [int] $PerPage = 100,
        [ref] $Count,
        [ref] $TotalPages,
        [string] $Search
    )

    $query = "page=${Page}&per_page=${PerPage}"
    $query += if ($Search) { "&search=" +  [uri]::EscapeDataString( $Search ) }
    $params = @{
        Endpoint = "projects/$ProjectId/labels?$query"
        ResponseHeadersVariable = 'script:_'
    }
    Send-Request $params
    if ($Count) { $Count.Value = [int] "$($script:_.'x-total')" }
    if ($TotalPages) { $TotalPages.Value = [int] "$($script:_.'x-total-pages')" }
}

# https://docs.gitlab.com/ee/api/labels.html#create-a-new-label
function New-GitlabLabel {
    param(
        [int] $ProjectId = $GL_ProjectId,
        [string] $Name,
        [string] $Description,
        [string] $Color = 'white',
        [int]    $Priority
    )

    $query = ""
    $query += if ($Name) { "&name=" +  [uri]::EscapeDataString( $Name ) }
    $query += if ($Description) { "&description=" + [uri]::EscapeDataString( $Description ) }
    $query += if ($Color) { "&color=" + [uri]::EscapeDataString( $Color ) }
    $query += if ($Priority) { "&priority=$Priority" }
    $query = $query.Substring(1)

    $params = @{
        Method = 'Post'
        Endpoint = "projects/$ProjectId/labels?$query"
    }
    Send-Request $params
}


# https://docs.gitlab.com/ee/api/labels.html#delete-a-label
function Remove-GitlabLabel {
    param(
        [int] $ProjectId = $GL_ProjectId,
        # ID or title of label
        [string] $LabelId
    )

    $params = @{
        Method = 'Delete'
        Endpoint = "projects/$ProjectId/labels/$LabelId"
    }
    Send-Request $params
}

# https://docs.gitlab.com/ee/api/issues.html#list-issues
function New-GitLabIssueFilter {
    [CmdletBinding()]
    param(
        [int[]]    $Iid,
        [int]      $AssigneeId,
        [string]   $AssigneeUsername,
        [int]      $AuthorId,
        [string]   $AuthorUsername,
        [datetime] $CreatedAfter,
        [datetime] $CreatedBefore,
        [datetime] $UpdatedAfter,
        [datetime] $UpdatedBefore,
        [string[]] $Labels,
        [ValidateSet('None', 'Any', 'Upcoming', 'Started')]
        [string]   $MilestoneId,
        # Case sensitive milestone name
        [string]   $Milestone,
        [string]   $Search
    )

    $res = @{ Query = @() }
    foreach ($k in $MyInvocation.MyCommand.Parameters.Keys) {
        if ($k -eq 'Verbose') { break }
        $value = Get-Variable $k | % Value
        if (!$value) {continue}
        if ($value -is [datetime]) { $value = $value.ToString("s") }
        if ($k -eq 'Labels') { $value = $value -join ',' }
        if ($k -eq 'Iid') { $k = 'iids[]'; $value = $Iid -join '&iids[]=' }

        $k = $k -creplace '(?<!^)[A-Z]',  "_`$0"  #convert title case to snake case
        $res.$k = $value
        $url_value = [uri]::EscapeDataString( $value )

        $res.Query += "{0}={1}" -f $k.ToLower(), $url_value
    }
    $res.Query = $res.Query -join '&'
    [PSCustomObject]$res
}

# https://docs.gitlab.com/ee/api/issues.html
function Get-GitLabIssue {
    [CmdletBinding()]
    param(
        [int] $ProjectId = $GL_ProjectId,
        [int] $Page = 1,
        [int] $PerPage = 100,
        [ref] $Count,
        [ref] $TotalPages,
        [PSCustomObject] $Filter,
        [int[]] $IId,

        [ValidateSet('asc', 'desc')]
        [string] $Sort = 'asc',

        [ValidateSet('all', 'opened', 'closed')]
        [string] $State = 'all',

        [switch] $With_Labels_Details
    )

    if ($Iid) { $Filter = New-GitLabIssueFilter -IId $IId }

    $query = "page=${Page}&per_page=${PerPage}&scope=all&sort=${Sort}&state=${State}"
    $query += if ($With_Labels_Details) { "&with_labels_details=$With_Labels_Details" }
    $query += if ($Filter) { "&$($Filter.Query)" }
    $params = @{
        Endpoint = "projects/$ProjectId/issues?$query"
        ResponseHeadersVariable = 'script:_'
    }
    $res = Send-Request $params
    if ($Count) { $Count.Value = [int] "$($script:_.'x-total')" }
    if ($TotalPages) { $TotalPages.Value = [int] "$($script:_.'x-total-pages')" }
    return $Iid.Count -eq 1 ? $res[0] : $res
}

#https://docs.gitlab.com/ee/api/milestones.html#list-project-milestones
function Get-GitlabMilestone {
    param(
        [int] $ProjectId = $GL_ProjectId,
        # Case sensitive full milestone title
        [string] $Title,
        [int[]] $Iid,

        [ValidateSet('all', 'active', 'closed')]
        [string] $State = 'all',

        [int] $Page = 1,
        [int] $PerPage = 100,
        [ref] $Count,
        [ref] $TotalPages
    )

    $query = "page=${Page}&per_page=${PerPage}&state=$State"
    $query += if ($Iid)   { '&iids[]=' + ($Iid -join '&iids[]=') }
    $query += if ($Title) { '&title=' + [uri]::EscapeDataString( $Title ) }
    $params = @{
        Endpoint =  "projects/$ProjectId/milestones?$query"
        ResponseHeadersVariable = 'script:_'
    }
    Send-Request $params
    if ($Count)      { $Count.Value = [int] "$($script:_.'x-total')" }
    if ($TotalPages) { $TotalPages.Value = [int] "$($script:_.'x-total-pages')" }
}

#https://docs.gitlab.com/ee/api/milestones.html#create-new-milestone
function New-GitLabMilestone {
    [CmdletBinding()]
    param(
        [int] $ProjectId = $GL_ProjectId,
        [string] $Title,
        [string] $Description,
        [datetime] $StartDate,
        [datetime] $DueDate
    )

    $query = 'title=' + [uri]::EscapeDataString( $Title )
    $query += if ($Description) { "&description=$Description" }
    $query += if ($StartDate) {"&start_date=" + $StartDate.ToString('s') }
    $query += if ($DueDate) {"&due_date=" + $DueDate.ToString('s') }

    $params = @{
        Method = 'Post'
        Endpoint =  "projects/$ProjectId/milestones?$query"
    }
    Send-Request $params
}

#https://docs.gitlab.com/api/issues/#edit-an-issue
function Set-GitLabIssue {
    param(
        [int]      $ProjectId = $GL_ProjectId,
        [int]      $IssueId,

        [int]      $MilestoneId = $GL_MilestoneId,
        [string]   $Title,
        [string]   $Description,
        [datetime] $DueDate
    )

    $query = ''
    $query += if ($MilestoneId) { "&milestone_id=$MilestoneId" }
    $query += if ($Title) { '&title=' + [uri]::EscapeDataString( $Title ) }
    $query += if ($Description) { "&description=$Description" }
    $query += if ($DueDate) {"&due_date=" + $DueDate.ToString('s') }
    $query = $query.Substring(1)

    $params = @{
        Method = 'Put'
        Endpoint = "projects/$ProjectId/issues/${IssueId}?${query}"
    }
    Send-Request $params
}

#https://docs.gitlab.com/ee/api/milestones.html#edit-milestone
function Set-GitlabMilestone {
    param(
        [int]      $ProjectId = $GL_ProjectId,
        [int]      $MilestoneId = $GL_MilestoneId,
        [string]   $Title,
        [string]   $Description,
        [datetime] $StartDate,
        [datetime] $DueDate,
        [ValidateSet('close', 'activate')]
        [string]   $StateEvent
    )

    $query = ''
    $query += if ($Title) { '&title=' + [uri]::EscapeDataString( $Title ) }
    $query += if ($Description) { "&description=$Description" }
    $query += if ($StartDate) {"&start_date=" + $StartDate.ToString('s') }
    $query += if ($DueDate) {"&due_date=" + $DueDate.ToString('s') }
    $query += if ($StateEvent) {"&state_event=$StateEvent"}
    $query = $query.Substring(1)

    $params = @{
        Method   = 'Put'
        Endpoint = "projects/$ProjectId/milestones/${MilestoneId}?${query}"
    }
    Send-Request $params
}

#https://docs.gitlab.com/ee/api/milestones.html#get-all-issues-assigned-to-a-single-milestone
function Get-GitlabMilestoneIssues {
    param(
        [int] $ProjectId = $GL_ProjectId,
        [int] $MilestoneId = $GL_MilestoneId,
        [int] $Page = 1,
        [int] $PerPage = 100,
        [ref] $Count,
        [ref] $TotalPages
    )

    $query = "page=${Page}&per_page=${PerPage}"
    $params = @{
        Endpoint = "projects/$ProjectId/milestones/$MilestoneId/issues?$query"
        ResponseHeadersVariable = 'script:_'
    }
    Send-Request $params
    if ($Count)      { $Count.Value = [int] "$($script:_.'x-total')" }
    if ($TotalPages) { $TotalPages.Value = [int] "$($script:_.'x-total-pages')" }
}

#https://docs.gitlab.com/ee/api/milestones.html#delete-project-milestone
function Remove-GitlabMilestone {
    param(
        [int] $ProjectId = $GL_ProjectId,
        [int] $MilestoneId = $GL_MilestoneId
    )

    $params = @{
        Method = 'Delete'
        Endpoint =  "projects/$ProjectId/milestones/$MilestoneId"
    }
    Send-Request $params
}

<#
.SYNOPSIS
    Helper function to get all pages from a paginator function
.EXAMPLE
    $all = Get-AllPages -Action "Get-GitlabProjectIssue" @{ Filter = New-GitlabIssueFilter -State closed } -ShowProgress
#>
function Get-AllPages {
    param (
        # Name of the paginator function. Function must support PerPage, Page and Count parameters
        [string] $Action,

        # Parameters to be passed to paginator action
        [HashTable] $ActionParams = @{},

        # Number of items to get per page
        [int] $PerPage = 100,

        # Number of milliseconds to sleep after API call
        [int] $SleepTimeMs = 150,

        # Show progress bar
        [switch] $ShowProgress
    )

    $all_data = @(); $page = 1; $count = $totalPages = 0;
    do {
        $all_data += $res = & $Action @ActionParams -PerPage $PerPage -Page $page -TotalPages ([ref]$totalPages) -Count ([ref]$Count)

        if ($ShowProgress) {
            Write-Progress -Activity "$($Action.Replace('Get-', '')) all pages" -Status "$page / $totalPages" -PercentComplete ($page*100/$totalPages)
        }

        $page++
        Start-Sleep -Milliseconds $SleepTimeMs
    } while ($res -and $all_data.Count -lt $count)
    $all_data
}

# Get GitLab project Id from the Namespace
function Get-GitLabProjectId([string] $Namespace) {
    function fixuri($uri){
        $UnEscapeDotsAndSlashes = 0x2000000
        $SimpleUserSyntax = 0x20000

        $type = $uri.GetType()
        $fieldInfo = $type.GetField("m_Syntax", ([System.Reflection.BindingFlags]::Instance -bor [System.Reflection.BindingFlags]::NonPublic))

        $uriParser = $fieldInfo.GetValue($uri)
        $typeUriParser = $uriParser.GetType().BaseType
        $fieldInfo = $typeUriParser.GetField("m_Flags", ([System.Reflection.BindingFlags]::Instance -bor [System.Reflection.BindingFlags]::NonPublic -bor [System.Reflection.BindingFlags]::FlattenHierarchy))
        $uriSyntaxFlags = $fieldInfo.GetValue($uriParser)

        $uriSyntaxFlags = $uriSyntaxFlags -band (-bnot $UnEscapeDotsAndSlashes)
        $uriSyntaxFlags = $uriSyntaxFlags -band (-bnot $SimpleUserSyntax)
        $fieldInfo.SetValue($uriParser, $uriSyntaxFlags)
    }

    Add-Type -AssemblyName System.Web
    $encoded_namespace = [System.Web.HttpUtility]::UrlEncode($Namespace)

    $project_uri = "projects/$encoded_namespace"
    if ($PSVersionTable.PSVersion -le 5) { fixuri $project_uri }

    $params = @{
        Endpoint = $project_uri
    }
    $project = send-request $params
    if (!$project) { throw "Can't find project: $Namespace" }
    $project.id
}

# Any Invoke-RestMethod parameters are provided as HashTable except Endpoint which is removed
function send-request( [HashTable] $Params ) {
    $p = $Params.Clone()
    if (!$p.Method)      { $p.Method = 'Get' }
    if (!$p.Uri)         { $p.Uri = '{0}/{1}' -f $GitLab.Url, $p.EndPoint }
    if (!$p.ContentType) { $p.ContentType = 'application/json; charset=utf-8' }
    if (!$p.Headers)     { $p.Headers = @{} }
    if ($p.Body)         { $p.Body = $p.Body | ConvertTo-Json -Depth 100 }

    $p.Headers."PRIVATE-TOKEN" = $GitLab.Token
    $p.Remove('EndPoint')

    ($p | ConvertTo-Json -Depth 100).Replace('\"', '"').Replace('\r\n', '') | Write-Verbose
    Invoke-RestMethod @p
}
