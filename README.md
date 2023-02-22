# GitLab PowerShell Module

## How to use

1. Obtain GitLab *Personal Access Token* key via *Profile -> Preferences -> Access tokens*
1. Import module: `import-module mm-gitlab`
1. Initialize session: `Initialize-GitlabSession -Url 'https://gitlab...' -Token '<token>'`

You can use any module function now. To get a list of available functions invoke: `Get-Command -Module mm-gitlab`.

Use `$VerbosePreference = 'Continue'` on the top of the script or `-Verbose` option on any function to see detailed low level communication with GitLab.

## Prerequisites

Nothing particular is required. Works with PowerShell 3+.

## Examples

### Login

```ps1
# Login to redmine using your key: My account -> API access key
# Must have Administration -> Settings -> API -> [x] Enable REST web service
Initialize-GitLabSession -Url 'https://redmine...' -Key '<key>'
```
