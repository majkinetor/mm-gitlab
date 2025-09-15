# GitLab PowerShell Module

## How to use

1. Obtain GitLab *Personal Access Token* key via *Profile -> Preferences -> Access tokens*
1. Import module: `import-module mm-gitlab`
1. Initialize session: `Initialize-GitlabSession -Url 'https://gitlab...' -Token '<token>'`

You can use any module function now. To get a list of available functions invoke: `Get-Command -Module mm-gitlab`.

Use `$VerbosePreference = 'Continue'` on the top of the script or `-Verbose` option on any function to see detailed low level communication with GitLab.

## Prerequisites

Nothing particular is required. Works with PowerShell 3+.

## Functions

|         Function          |                      Description                      |
| ------------------------- | ----------------------------------------------------- |
| Initialize-GitLabSession  | Login to the system by providing URL and token        |
| Get-AllPages              | Paginate over Gitlab response pages                   |
| Get-GitLabProjectId       | Get GitLab project Id from the Namespace              |
| Get-GitLabIssue           | List project issues or get an issue                   |
| Set-GitLabIssue           | Edit issues title, description, milestone or due date |
| New-GitLabIssueFilter     | Create issue filter to be used with Get-GitLabIssue   |
| Get-GitlabMilestone       | List project milestone                                |
| Set-GitlabMilestone       | Edit milestone                                        |
| New-GitLabMilestone       | Create a milestone                                    |
| Get-GitlabMilestoneIssues | Get all issues assigned to a single milestone         |
| Remove-GitlabMilestone    | Remove milestone                                      |
| Get-GitLabLabel           | List labels                                           |
| New-GitlabLabel           | Create label                                          |
| Remove-GitlabLabel        | Remove label                                          |

## Example

```powershell
Initialize-GitlabSession -Url 'https://gitlab.example.com/api/v4' -Token $tokens

$issueId = 946
$issue = Get-GitLabIssue -IId $issueId

$f = New-GitLabIssueFilter -Assignee_Username 'majkinetor'
$all_issues = Get-AllPages -Action "Get-GitLabIssue" @{ Filter = $f } -ShowProgress
```
