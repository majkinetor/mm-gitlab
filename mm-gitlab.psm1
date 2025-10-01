# v0.6

# https://docs.gitlab.com/api/jobs/#run-a-job
function Invoke-GitLabProjectJob {
        param(
        [int] $ProjectId = $script:GitLab.ProjectId,
        [int] $JobId,
        [ValidateSet('run', 'retry', 'cancel', 'erase')]
        [string] $Action
    )

    $params = @{
        Method = "Post"
        Endpoint = "projects/$ProjectId/jobs/$JobId/$Action"
    }
    Send-Request $params
}

# https://docs.gitlab.com/api/jobs/#list-pipeline-trigger-jobs
function Get-GitLabProjectPipelineBridges {
    param(
        [int] $ProjectId = $script:GitLab.ProjectId,
        [int] $PipelineId
    )

    $params = @{
        Method = "Get"
        Endpoint = "projects/$ProjectId/pipelines/$PipelineId/bridges"
    }
    Send-Request $params
}

# https://docs.gitlab.com/api/jobs/#list-pipeline-jobs
function Get-GitLabProjectPipelineJobs {
    param(
        [int] $ProjectId = $script:GitLab.ProjectId,
        [int] $PipelineId
    )

    $params = @{
        Method = "Get"
        Endpoint = "projects/$ProjectId/pipelines/$PipelineId/jobs"
    }
    Send-Request $params
}

# https://docs.gitlab.com/api/jobs/#list-project-jobs
function Get-GitLabProjectJobs {
    param(
        [int] $ProjectId = $script:GitLab.ProjectId
    )

    $params = @{
        Method = "Get"
        Endpoint = "projects/$ProjectId/jobs"
    }
    Send-Request $params
}

# https://docs.gitlab.com/api/pipelines/#list-project-pipelines
# Use 'latest' as id for latest pipeline
function Get-GitLabPipeline {
    param(
        [int] $ProjectId = $script:GitLab.ProjectId,
        [int] $Id,
        [string] $Name,
        [string] $Status,
        [string] $Username,
        [string] $Source
    )

    $query = ""
    $query += if ($Name) { "&name=" +  [uri]::EscapeDataString( $Name ) }
    $query += if ($Status) { "&status=$Status" }
    $query += if ($Username) { "&username=$Username" }
    $query += if ($Source) { "&source=$Source" }
    $query = if ($query) { $query.Substring(1) }

    $params = @{
        Method = "Get"
        Endpoint = $Id ? "projects/$ProjectId/pipelines/$Id" : "projects/$ProjectId/pipelines?$query"
    }
    Send-Request $params
}

# https://docs.gitlab.com/api/pipelines/#create-a-new-pipeline
function New-GitLabPipeline {
    param(
        [int] $ProjectId = $script:GitLab.ProjectId,
        [string] $Ref
    )

    $params = @{
        Method = "Post"
        Endpoint = "projects/$ProjectId/pipeline?ref=$ref"
    }
    Send-Request $params
}

# https://docs.gitlab.com/api/pipelines/#cancel-all-jobs-for-a-pipeline
function Stop-GitLabPipeline {
    param(
        [int] $ProjectId = $script:GitLab.ProjectId,
        [int] $Id
    )

    $params = @{
        Method = "Post"
        Endpoint = "projects/$ProjectId/pipelines/$Id/cancel"
    }
    Send-Request $params
}

# https://docs.gitlab.com/api/pipelines/#delete-a-pipeline
function Remove-GitLabPipeline {
    param(
        [int] $ProjectId = $script:GitLab.ProjectId,
        [int] $Id
    )

    $params = @{
        Method = "Delete"
        Endpoint = "projects/$ProjectId/pipelines/$Id"
    }
    Send-Request $params
}

# https://docs.gitlab.com/api/notes/#create-new-issue-note
function New-GitLabIssueNote {
    param(
        [int] $ProjectId = $script:GitLab.ProjectId,
        [int] $IssueId,
        [string] $Body
    )

    $query = ''
    $query += if ($Body) { '&body=' + [uri]::EscapeDataString( $Body ) }
    $query = if ($query) { $query.Substring(1) }

    $params = @{
        Method = "Post"
        Endpoint = "projects/$ProjectId/issues/$IssueId/notes?$query"
    }
    Send-Request $params
}

# https://docs.gitlab.com/api/project_markdown_uploads
function Send-GitLabFile {
    [CmdletBinding()]
    param(
        [int] $ProjectId = $script:GitLab.ProjectId,
        [string] $FilePath
    )
    $fileInfo = Get-Item $FilePath -ErrorAction Stop
    $params = @{
        Method = "Post"
        Endpoint = "projects/$ProjectId/uploads"
        Form = @{ file = $fileInfo }
    }
    Send-Request $params
}

# https://docs.gitlab.com/ee/api/labels.html
function Get-GitLabLabel {
    [CmdletBinding()]
    param(
        [int] $ProjectId = $script:GitLab.ProjectId,
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
    [CmdletBinding()]
    param(
        [int] $ProjectId = $script:GitLab.ProjectId,
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
    [CmdletBinding()]
    param(
        [int] $ProjectId = $script:GitLab.ProjectId,
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

# https://docs.gitlab.com/api/issues/#new-issue
function New-GitLabIssue {
    [CmdletBinding()]
    param(
        [int] $ProjectId = $script:GitLab.ProjectId,
        [int] $MilestoneId = $script:GitLab.MilestoneId,
        [int] $AssigneeId,
        [string]   $Title,
        [string]   $Description,
        [datetime] $DueDate,
        [string[]] $Labels
    )

    $query = ''
    $query += if ($AssigneId) { "&assignee_id=$AssigneeId" }
    $query += if ($MilestoneId) { "&milestone_id=$MilestoneId" }
    $query += if ($Title) { '&title=' + [uri]::EscapeDataString( $Title ) }
    $query += if ($Description) {'&description=' + [uri]::EscapeDataString( $Description )}
    $query += if ($DueDate) {"&due_date=" + $DueDate.ToString('s') }
    $query += if ($Labels) { "&labels=" + ($Labels -join ',') }
    $query = $query.Substring(1)

    $params = @{
        Method = 'Post'
        Endpoint = "projects/$ProjectId/issues?$query"
    }
    Send-Request $params
}

# https://docs.gitlab.com/ee/api/issues.html
function Get-GitLabIssue {
    [CmdletBinding()]
    param(
        [int] $ProjectId = $script:GitLab.ProjectId,
        [int] $Page = 1,
        [int] $PerPage = 100,
        [ref] $Count,
        [ref] $TotalPages,
        [PSCustomObject] $Filter,
        [int[]] $IssueId,

        [ValidateSet('asc', 'desc')]
        [string] $Sort = 'asc',

        [ValidateSet('all', 'opened', 'closed')]
        [string] $State = 'all',

        [switch] $With_Labels_Details
    )

    if ($IssueId) { $Filter = New-GitLabIssueFilter -IId $IssueId }

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

function Set-GitlabMilestoneId {
    param(
        [int] $ProjectId = $script:GitLab.ProjectId,
        # Case sensitive full milestone title
        [string] $Title,
        [int] $Iid
    )

    $res = Get-GitLabMilestone -ProjectId $ProjectId -Title $Title -IId $Iid
    $script:GitLab.MilestoneId = $res[0].id
}

#https://docs.gitlab.com/ee/api/milestones.html#list-project-milestones
function Get-GitlabMilestone {
    param(
        [int] $ProjectId = $script:GitLab.ProjectId,
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
        [int] $ProjectId = $script:GitLab.ProjectId,
        [string] $Title,
        [string] $Description,
        [datetime] $StartDate,
        [datetime] $DueDate
    )

    $query = 'title=' + [uri]::EscapeDataString( $Title )
    $query += if ($Description) { '&description=' + [uri]::EscapeDataString( $Description )}
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
        [int]      $ProjectId = $script:GitLab.ProjectId,
        [int]      $IssueId,

        [int]      $MilestoneId = $script:GitLab.MilestoneId,
        [string]   $Title,
        [string]   $Description,
        [datetime] $DueDate,
        [string[]] $Labels
    )

    $query = ''
    $query += if ($MilestoneId) { "&milestone_id=$MilestoneId" }
    $query += if ($Title) { '&title=' + [uri]::EscapeDataString( $Title ) }
    $query += if ($Description) { '&description=' + [uri]::EscapeDataString( $Description ) }
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
    [CmdletBinding()]
    param(
        [int]      $ProjectId = $script:GitLab.ProjectId,
        [int]      $MilestoneId = $script:GitLab.MilestoneId,
        [string]   $Title,
        [string]   $Description,
        [datetime] $StartDate,
        [datetime] $DueDate,
        [ValidateSet('close', 'activate')]
        [string]   $StateEvent
    )

    $query = ''
    $query += if ($Title) { '&title=' + [uri]::EscapeDataString( $Title ) }
    $query += if ($Description) { '&description=' + [uri]::EscapeDataString( $Description ) }
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
    [CmdletBinding()]
    param(
        [int] $ProjectId = $script:GitLab.ProjectId,
        [int] $MilestoneId = $script:GitLab.MilestoneId,
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
        [int] $ProjectId = $script:GitLab.ProjectId,
        [int] $MilestoneId = $script:GitLab.MilestoneId
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
    [CmdletBinding()]
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

function Set-GitLabProjectId([string] $Namespace) {
    $script:GitLab.ProjectId = Get-GitLabProjectId $Namespace
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

    ($p | ConvertTo-Json).Replace('\"', '"').Replace('\r\n', '') | Write-Verbose
    Invoke-RestMethod @p
}

function Initialize-GitLabSession {
    param(
        [string] $Url,
        [string] $Token
    )
    $script:GitLab = @{ Url = $Url; Token = $Token }
}
