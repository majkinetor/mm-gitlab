$ErrorActionPreference = 'stop'
$VerbosePreference = 'Continue'
Import-Module $PSScriptRoot\mm-gitlab.psm1 -Force

$token = Get-Content $PSScriptRoot\gltoken
Initialize-GitlabSession -Url 'https://gitlab.nil.rs/api/v4' -Token $token

Set-GitLabProjectId 'jafin-ng/jafin'
$res = New-GitlabPipeline -Ref master
$res
#Set-GitLabMilestoneId -Title 'NEXT'

#$issue = New-GitLabIssue -Description "*Test*" -Title "Test Powershell" -Labels "qa","service-rest"
#$note = New-GitLabIssueNote -IssueId 954 -Body "test"
#$note
<#
# === Issues
    $issueId = 123
    $issue = Get-GitLabIssue -IssueId $issueId

    $f = New-GitLabIssueFilter -Labels 'qa', 'priority-hi'
    $f = New-GitLabIssueFilter -Milestone 'NEXT'
    $f = New-GitLabIssueFilter -Assignee_Username 'majkinetor'
    $f = New-GitLabIssueFilter -Author_Username 'majkinetor'
    $f = New-GitLabIssueFilter -Created_After ([datetime]::Now).AddMonths(-1)
    $f = New-GitLabIssueFilter -Search tool
    $all_issues = Get-AllPages -Action "Get-GitLabIssue" @{ Filter = $f } -ShowProgress
    $all_issues.Count
    $all_issues | Format-Table

    $file = Send-GitLabFile -FilePath $PSScriptRoot\test.ps1
    $description = $issue.description + "`n" + $file.markdown
    Set-GitlabIssue -IssueId $issueId -Description $description

    $issue = New-GitLabIssue -Description "*Test*" -Title "Test Powershell" -Labels 'qa','priorty-hi'
    $note = New-GitLabIssueNote -IssueId $issue.id -Body "test"

# === Milestones
    Get-GitlabMilestone -Iid 1,86 | ft
    Get-GitlabMilestone -Title NEXT | ft

    $m = New-GitLabMilestone -Title test2 -Description meh -StartDate ([datetime]::now) -DueDate ([datetime]::now.AddMonths(1))
    $GL_MilestoneId = $m.id
    Set-GitlabMilestone -State close
    Remove-GitlabMilestone

# === Labels
    Get-GitLabLabel | ft
    New-GitlabLabel -Name test -Color red -Description test
    Remove-GitlabLabel -LabelId test

# Add labels from file containing lines: label_name #color description:
#   priority-low       #CC0033 Low priority task
#   priority-immediate #CC0033 This task needs maximum attention immediately. Stop everything else until this is done.
#   priority-hi        #CC0033 High priority task

 $labels = Get-Content labels.txt
 foreach ($label in $labels) {
     $p = @{}
     $p.name, $p.color, $p.description = $label -split '\s+',3
     try { New-GitlabLabel @p  | Format-Table name, description } catch {}
 }

#>