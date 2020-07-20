
## These commands implement a GitHub Actions 'Context' enacapsulating
## various elements of the running environment of the current action.
## It is an adaptation of the TypeScript version found here:
##  https://github.com/actions/toolkit/blob/master/packages/github/src/context.ts


function Get-ActionContext {
    [CmdletBinding()]
    param()

    $context = Get-Variable -Name actionContext -Scope script -ValueOnly -ErrorAction SilentlyContinue
    if (-not $context) {
        $context = New-ActionContextMap
        Set-Variable -Name actionContext -Scope script -Value $context
    }
    $context
}

function Get-ActionRepo {
    [CmdletBinding()]
    param()

    if ($env:GITHUB_REPOSITORY) {
        Write-Verbose "Resolving Repo via env GITHUB_REPOSITORY"
        ($owner, $repo) = $env:GITHUB_REPOSITORY -split '/',2
        return @{
            Owner = $owner
            Repo = $repo
        }
    }

    $context = Get-ActionContext
    if ($context.Payload.repository) {
        Write-Verbose "Resolving Repo via Action Context"
        return @{
            Owner = $context.Payload.repository.owner.login
            Repo = $context.Payload.repository.name
        }
    }

    throw "context.repo requires a GITHUB_REPOSITORY environment variable like 'owner/repo'"
}

function Get-ActionIssue {
    [CmdletBinding()]
    param()

    $context = Get-ActionContext

    (Get-ActionRepo) + @{
        Number = ($context.Payload.issue ?? $context.Payload.pull_request ?? $context.Payload).number
    }
}

function New-ActionContextMap {
    [CmdletBinding()]
    param()

    Write-Verbose "Resolving Action Context"

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
    
    $context = [pscustomobject]::new()
    $context.PSObject.TypeNames.Insert(0, "GitHub.Context")
    $contextProps = @{
        _contextResolveDate = [datetime]::Now ## For Debugging for now

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

    AddReadOnlyProps $context $contextProps

    $context
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