
## These commands implement a GitHub Actions 'Context' enacapsulating
## various elements of the running environment of the current action.
## It is an adaptation of the TypeScript version found here:
##  https://github.com/actions/toolkit/blob/master/packages/github/src/context.ts

<#
.SYNOPSIS
Returns details of the executing GitHub Workflow assembled from the environment.

.DESCRIPTION
The returned context is a read-only object that assembles elements from the
executing environment of a Workflow such as environment variables and files
and is a _PowerShelly_ adaptation of the API and interfaces defined by the
GitHub Actions Toolkit for TypeScript.

.EXAMPLE
Import-Module GitHubActions

$context = Get-ActionContext
if ($context.EventName -eq 'push') {
    $payload = $context.Payload
    Write-ActionInfo "The head commit is: $($payload.head_commit | ConvertTo-Json)"
}

.LINK
https://github.com/actions/toolkit
https://github.com/actions/toolkit/tree/main/packages/github
https://github.com/actions/toolkit/blob/master/packages/github/src/context.ts
#>
function Get-ActionContext {
    [CmdletBinding()]
    param()

    $context = $script:actionContext
    if (-not $context) {
        $context = [pscustomobject]::new()
        $context.PSObject.TypeNames.Insert(0, "GitHub.Context")
        $contextProps = BuildActionContextMap
        AddReadOnlyProps $context $contextProps
        $script:actionContext = $context
    }
    $context
}

<#
.SYNOPSIS
Returns details of the repository, including owner and repo name.
#>
function Get-ActionRepo {
    [CmdletBinding()]
    param()

    $repo = $script:actionContextRepo
    if (-not $repo) {
        $repo = [pscustomobject]::new()
        $repo.PSObject.TypeNames.Insert(0, "GitHub.ContextRepo")
        $repoProps = BuildActionContextRepoMap
        AddReadOnlyProps $repo $repoProps
        $script:actionContextRepo = $repo
    }
    $repo
}

<#
.SYNOPSIS
Returns details of the issue associated with the workflow trigger,
including owner and repo name, and the issue (or PR) number.
#>
function Get-ActionIssue {
    [CmdletBinding()]
    param()

    $issue = $script:actionContextIssue
    if (-not $issue) {
        $issue = [pscustomobject]::new()
        $issue.PSObject.TypeNames.Insert(0, "GitHub.ContextIssue")
        $issueProps = BuildActionContextIssueMap
        AddReadOnlyProps $issue $issueProps
        $script:actionContextIssue = $issue
    }
    $issue
}

function BuildActionContextMap {
    [CmdletBinding()]
    param()

    Write-Verbose "Building Action Context"

    if ($env:GITHUB_EVENT_PATH) {
        $path = $env:GITHUB_EVENT_PATH
        Write-Verbose "Loading event payload from [$path]"
        if (Test-Path -PathType Leaf $path) {
            ## Webhook payload object that triggered the workflow
            $payload = (Get-Content -Raw $path -Encoding utf8) |
                ConvertFrom-Json -AsHashtable
        }
        else {
            Write-Warning "`GITHUB_EVENT_PATH` [$path] does not eixst"
        }
    }

    @{
        _resolveDatetime = [datetime]::Now

        EventName = $env:GITHUB_EVENT_NAME
        Sha = $env:GITHUB_SHA
        Ref = $env:GITHUB_REF
        Workflow = $env:GITHUB_WORKFLOW
        Action = $env:GITHUB_ACTION
        Actor = $env:GITHUB_ACTOR
        Job = $env:GITHUB_JOB
        RunNumber = ParseIntSafely $env:GITHUB_RUN_NUMBER
        RunId = ParseIntSafely $env:GITHUB_RUN_ID

        Payload = $payload
    }
}

function BuildActionContextRepoMap {
    [CmdletBinding()]
    param()

    Write-Verbose "Building Action Context Repo"

    if ($env:GITHUB_REPOSITORY) {
        Write-Verbose "Resolving Repo via env GITHUB_REPOSITORY"
        ($owner, $repo) = $env:GITHUB_REPOSITORY -split '/',2
        return @{
            _resolveDatetime = [datetime]::Now

            Owner = $owner
            Repo = $repo
        }
    }

    $context = Get-ActionContext
    if ($context.Payload.repository) {
        Write-Verbose "Resolving Repo via Action Context"
        return @{
            _resolveDatetime = [datetime]::Now

            Owner = $context.Payload.repository.owner.login
            Repo = $context.Payload.repository.name
        }
    }

    throw "context.repo requires a GITHUB_REPOSITORY environment variable like 'owner/repo'"
}

function BuildActionContextIssueMap {
    [CmdletBinding()]
    param()

    Write-Verbose "Building Action Context Issue"

    $context = Get-ActionContext
    (BuildActionContextRepoMap) + @{
        Number = ($context.Payload.issue ?? $context.Payload.pull_request ?? $context.Payload).number
    }
}

function ParseIntSafely {
    param(
        [object]$value,
        [int]$default=-1
    )

    [int]$int = 0
    if (-not [int]::TryParse($value, [ref]$int)) {
        $int = $default
    }
    $int
}

function AddReadOnlyProps {
    param(
        [pscustomobject]$psco,
        [hashtable]$props
    )

    $props.GetEnumerator() | ForEach-Object {
        $propName = $_.Key
        $propValue = $_.Value

        if ($propValue -and ($propValue -is [hashtable])) {
            $newPropValue = [pscustomobject]::new()
            AddReadOnlyProps $newPropValue $propValue
            $propValue = $newPropValue
        }

        $psco | Add-Member -Name $propName -MemberType ScriptProperty -Value {
            $propValue
        }.GetNewClosure() -SecondValue {
            Write-Warning "Cannot modify Read-only property '$($propName)'"
        }.GetNewClosure()
    }
}
