
## This commands implement a GitHub Actions 'Context' enacapsulating
## various elements of the running environment of the current action.
## It is an adaptation of the TypeScript version found here:
##  https://github.com/actions/toolkit/blob/master/packages/github/src/context.ts


## For now, every access to the Action Context requires constructing a
## new one since it's implemented purely as a nested tree of hashtables
## so there is no way to prevent modification -- future enhancement may
## be to re-implement as custom type with more strict, read-only members
## so we can resolve a globally shared instance
function New-ActionContextMap {
    [CmdletBinding()]
    param()

    ## local "safe" parser for [int] values
    $parseInt = { param($val) $int = -1; [int]::TryParse($val, [ref]$int) | Out-Null; $int }

    if ($env:GITHUB_EVENT_PATH) {
        $path = $env:GITHUB_EVENT_PATH
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
        _contextResolveDate = [datetime]::Now ## For Debugging for now

        EventName = $env:GITHUB_EVENT_NAME
        Sha = $env:GITHUB_SHA
        Ref = $env:GITHUB_REF
        Workflow = $env:GITHUB_WORKFLOW
        Action = $env:GITHUB_ACTION
        Actor = $env:GITHUB_ACTOR
        Job = $env:GITHUB_JOB
        RunNumber = &$parseInt($env:GITHUB_RUN_NUMBER)
        RunId = &$parseInt($env:GITHUB_RUN_ID)

        Payload = $payload
    }
}

function Get-ActionContextMap {
    [CmdletBinding()]
    param()

    New-ActionContextMap
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

    $context = New-ActionContextMap
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

    $context = New-ActionContextMap

    (Get-ActionRepo) + @{
        Number = ($context.Payload.issue ?? $context.Payload.pull_request ?? $context.Payload).number
    }
}
