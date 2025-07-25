$ErrorActionPreference = 'stop'
$VerbosePreference = 'Continue'
Import-Module $PSScriptRoot\mm-gitlab.psm1 -Force

$token = Get-Content $PSScriptRoot\gltoken
Initialize-GitlabSession -Url 'https://gitlab.nil.rs/api/v4' -Token $token

$GL_ProjectId = Get-GitLabProjectId 'jafin-ng/jafin'

<# ====== Issues
    $f = New-GitLabIssueFilter -Labels 'service-rest', 'meta-trivial'
    $f = New-GitLabIssueFilter -Milestone 'NEXT'
    $f = New-GitLabIssueFilter -Assignee_Username 'mmilic'
    $f = New-GitLabIssueFilter -Author_Username 'mmilic'
    $f = New-GitLabIssueFilter -Created_After ([datetime]::Now).AddMonths(-1)
    $f = New-GitLabIssueFilter -Search alat
    $all_issues = Get-AllPages -Action "Get-GitLabIssue" @{ Filter = $f } -ShowProgress
    $all_issues.Count
    $all_issues | Format-Table
#>

<# ====== Milestones
    Get-GitlabMilestone -Iid 1,86 | ft
    Get-GitlabMilestone -Title NEXT | ft

    $m = New-GitLabMilestone -Title test2 -Description meh -StartDate ([datetime]::now) -DueDate ([datetime]::now.AddMonths(1))
    $GL_MilestoneId = $m.id
    Set-GitlabMilestone -State close
    Remove-GitlabMilestone
#>

<# ====== Labels
    Get-GitLabLabel | ft
    New-GitlabLabel -Name test -Color red -Description test
    Remove-GitlabLabel -LabelId test
#>

$labels = Get-Content C:\Work\_\nil\jafin2k\jafin\scripts\gitlab\project\labels.txt
foreach ($label in $labels) {
    $p = @{}
    $p.name, $p.color, $p.description = $label -split '\s+',3
    try { New-GitlabLabel @p  | Format-Table name, description } catch {}
}
