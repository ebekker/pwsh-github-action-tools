
Import-Module Pester

Import-Module $PSScriptRoot/../GitHubActions

if (-not (Get-Variable EOL -ErrorAction Ignore)) {
    Set-Variable -Scope Script -Option Constant -Name EOL -Value ([System.Environment]::NewLine)
}

## These two are borrowed and adapted from:
##   https://github.com/chriskuech/functional/blob/master/functional.psm1#L42
class NULL{}
$NULL_INST = [NULL]::new()
function isPsCustomObject($v) {
    $v.PSTypeNames -contains 'System.Management.Automation.PSCustomObject'
}
function recursiveEquality($a, $b) {
    if ($a -is [array] -and $b -is [array]) {
        Write-Debug "recursively test arrays '$a' '$b'"
        if ($a.Count -ne $b.Count) {
            return $false
        }
        $inequalIndexes = 0..($a.Count - 1) | ? { -not (recursiveEquality $a[$_] $b[$_]) }
        if ($inequalIndexes.Count) { Write-Verbose "Inequal Indexes: $inequalIndexes" }
        return $inequalIndexes.Count -eq 0
    }
    if ($a -is [hashtable] -and $b -is [hashtable]) {
        Write-Debug "recursively test hashtable '$a' '$b'"
        $inequalKeys = $a.Keys + $b.Keys `
        | Sort-Object -Unique `
        | ? { -not (recursiveEquality $a[$_] $b[$_]) }
        if ($inequalKeys.Count) { Write-Verbose "Inequal HT Keys: $inequalKeys" }
        return $inequalKeys.Count -eq 0
    }
    if ((isPsCustomObject $a) -and (isPsCustomObject $b)) {
        Write-Debug "a is pscustomobject: $($a -is [psobject])"
        Write-Debug "recursively test objects '$a' '$b'"
        $inequalKeys = $a.psobject.Properties + $b.psobject.Properties `
        | % Name `
        | Sort-Object -Unique `
        | ? { -not (recursiveEquality $a.$_ $b.$_) }
        if ($inequalKeys.Count) { Write-Verbose "Inequal PSCO Keys: $inequalKeys" }
        return $inequalKeys.Count -eq 0
    }
    Write-Debug "test leaves '$a'($(($a ?? $NULL_INST).GetType().FullName)) '$b'($(($b ?? $NULL_INST).GetType().FullName))"

    return (($null -eq $a -and $null -eq $b) -or ($null -ne $a -and $null -ne $b -and $a.GetType() -eq $b.GetType() -and $a -eq $b))
}

Describe 'Get-ActionContext' {
    It 'Should match Real or Faked environment values' {
        ## When run within an actual GH Workflow, these values
        ## should already exist, otherwise we fake them out
        if (-not $env:GITHUB_EVENT_NAME) { $env:GITHUB_EVENT_NAME = 'GITHUB_EVENT_NAME' }
        if (-not $env:GITHUB_SHA) { $env:GITHUB_SHA = 'GITHUB_SHA' }
        if (-not $env:GITHUB_REF) { $env:GITHUB_REF = 'GITHUB_REF' }
        if (-not $env:GITHUB_WORKFLOW) { $env:GITHUB_WORKFLOW = 'GITHUB_WORKFLOW' }
        if (-not $env:GITHUB_ACTION) { $env:GITHUB_ACTION = 'GITHUB_ACTION' }
        if (-not $env:GITHUB_ACTOR) { $env:GITHUB_ACTOR = 'GITHUB_ACTOR' }
        if (-not $env:GITHUB_JOB) { $env:GITHUB_JOB = 'GITHUB_JOB' }
        if (-not $env:GITHUB_RUN_NUMBER) { $env:GITHUB_RUN_NUMBER = '999' }
        if (-not $env:GITHUB_RUN_ID) { $env:GITHUB_RUN_ID = '888' }

        $eventPath = "$($PSScriptRoot)/payload-sample1.json"
        $env:GITHUB_EVENT_PATH = $eventPath

        $context = Get-ActionContext

        $context.EventName | Should -Be $env:GITHUB_EVENT_NAME
        $context.Sha | Should -Be $env:GITHUB_SHA
        $context.Ref | Should -Be $env:GITHUB_REF
        $context.Workflow | Should -Be $env:GITHUB_WORKFLOW
        $context.Action | Should -Be $env:GITHUB_ACTION
        $context.Actor | Should -Be $env:GITHUB_ACTOR
        $context.Job | Should -Be $env:GITHUB_JOB
        $context.RunNumber | Should -Be ([int]::Parse($env:GITHUB_RUN_NUMBER))
        $context.RunId | Should -Be ([int]::Parse($env:GITHUB_RUN_ID))

        ## We want to canonicalize the output formats in way that we can do a deep compare
        ## that only cares about the 'essence' of property names and values, but ignores
        ## irrelevent differences such as exact type mismatches (int32 vs in64; array vs list)
        $payload = $context.Payload
        $payloaddJson = $payload | ConvertTo-Json -Depth 7
        $eventDtlJson = Get-Content -Raw $eventPath -Encoding utf8

        $eventDtlHash = $eventDtlJson | ConvertFrom-Json -AsHashtable
        $payloaddHash = $payloaddJson | ConvertFrom-Json -AsHashtable
        
        recursiveEquality $eventDtlHash $payloaddHash -Verbose | Should -Be $true
    }

    It 'Should only construct a context once' {
        $context1 = Get-ActionContext
        $context2 = Get-ActionContext

        $context2 | Should -Be $context1
        $context2._contextResolveDate | Should -Be $context1._contextResolveDate
    }
}
