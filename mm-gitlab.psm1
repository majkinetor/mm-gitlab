# v0.1

function Initialize-GitLabSession {
    param(
        [string] $Url,
        [string] $Token
    )
    $script:GitLab = @{ Url = $Url; Token = $Token }
}

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
