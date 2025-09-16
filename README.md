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

|         Function          |                        Description                         |
| ------------------------- | ---------------------------------------------------------- |
| Initialize-GitLabSession  | Login to the system by providing URL and token             |
| Get-AllPages              | Paginate over Gitlab response pages                        |
| Get-GitLabProjectId       | Get GitLab project Id from the Namespace                   |
| Set-GitLabProject         | Set GitLab project Id so that you can skip it as parameter |
| Get-GitLabIssue           | List project issues or get an issue                        |
| Set-GitLabIssue           | Edit issues title, description, milestone or due date      |
| New-GitLabIssue           | Create new GitLab issue                                    |
| New-GitLabIssueNote       | Create new Gitlab issue note                               |
| New-GitLabIssueFilter     | Create issue filter to be used with Get-GitLabIssue        |
| Get-GitLabMilestone       | List project milestone                                     |
| Set-GitLabMilestone       | Edit milestone                                             |
| Set-GitlabMilestonId      | Set Milestone id so that you can skip it as parameter      |
| New-GitLabMilestone       | Create a milestone                                         |
| Get-GitLabMilestoneIssues | Get all issues assigned to a single milestone              |
| Remove-GitLabMilestone    | Remove milestone                                           |
| Get-GitLabLabel           | List labels                                                |
| New-GitLabLabel           | Create label                                               |
| Remove-GitLabLabel        | Remove label                                               |
| Send-GitLabFile           | Upload a file to project                                   |

## Example

```powershell
import-module mm-gitlab

Initialize-GitlabSession -Url 'https://gitlab.example.com/api/v4' -Token $tokens

# Set working project so -Project argument in other functions can be skipped
Set-GitLabProjectId '<group>/<project>'

# Get single issue
$issueId = 1
$issue = Get-GitLabIssue -IssueId $issueId

# Filter issues by assignee username and return all pages at once
$f = New-GitLabIssueFilter -Assignee_Username 'majkinetor'
$all_issues = Get-AllPages -Action "Get-GitLabIssue" @{ Filter = $f } -ShowProgress

# Upload a file and add it to the issue description
$file = Send-GitLabFile -FilePath $PSScriptRoot\test.ps1
$description = $issue.description + "`n" + $file.markdown
Set-GitlabIssue -IssueId $issueId -Description $issue.description

New-GitlabIssueNote -IssueId $issueId -Body "Powershell test"
```
