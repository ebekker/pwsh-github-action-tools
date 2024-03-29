
Import-Module Pester

Import-Module $PSScriptRoot/../GitHubActions

BeforeAll {
    . $PSScriptRoot/test-helpers.ps1
}

InModuleScope GitHubActions {

    Describe 'Get-ActionContext' {
        It 'Should match Real or Faked environment values' {
            # From https://4sysops.com/archives/convert-json-to-a-powershell-hash-table/, added for Windows PowerShell compatability
            function ConvertTo-Hashtable {
                [CmdletBinding()]
                [OutputType('hashtable')]
                param (
                    [Parameter(ValueFromPipeline)]
                    $InputObject
                )
                process {
                    ## Return null if the input is null. This can happen when calling the function
                    ## recursively and a property is null
                    if ($null -eq $InputObject) {
                        return $null
                    }
                    ## Check if the input is an array or collection. If so, we also need to convert
                    ## those types into hash tables as well. This function will convert all child
                    ## objects into hash tables (if applicable)
                    if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string]) {
                        $collection = @(
                            foreach ($object in $InputObject) {
                                ConvertTo-Hashtable -InputObject $object
                            }
                        )
                        ## Return the array but don't enumerate it because the object may be pretty complex
                        Write-Output -NoEnumerate $collection
                    }
                    elseif ($InputObject -is [psobject]) {
                        ## If the object has properties that need enumeration
                        ## Convert it to its own hash table and return it
                        $hash = @{}
                        foreach ($property in $InputObject.PSObject.Properties) {
                            $hash[$property.Name] = ConvertTo-Hashtable -InputObject $property.Value
                        }
                        $hash
                    }
                    else {
                        ## If the object isn't an array, collection, or other object, it's already a hash table
                        ## So just return it.
                        $InputObject
                    }
                }
            }

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

            if (-not $env:GITHUB_EVENT_PATH) {
                $eventPath = "$($PSScriptRoot)/payload-sample1.json"
                $env:GITHUB_EVENT_PATH = $eventPath
            }

            $context = Get-ActionContext

            $context.EventName | Should -Be $env:GITHUB_EVENT_NAME
            $context.Sha | Should -Be $env:GITHUB_SHA
            $context.Ref | Should -Be $env:GITHUB_REF
            $context.Workflow | Should -Be $env:GITHUB_WORKFLOW
            $context.Action | Should -Be $env:GITHUB_ACTION
            $context.Actor | Should -Be $env:GITHUB_ACTOR
            $context.Job | Should -Be $env:GITHUB_JOB
            $context.RunNumber | Should -Be ([long]::Parse($env:GITHUB_RUN_NUMBER))
            $context.RunId | Should -Be ([long]::Parse($env:GITHUB_RUN_ID))

            ## We want to canonicalize the output formats in way that we can do a deep compare
            ## that only cares about the 'essence' of property names and values, but ignores
            ## irrelevent differences such as exact type mismatches (int32 vs in64; array vs list)
            $payload = $context.Payload

            $eventJson = Get-Content -Raw $env:GITHUB_EVENT_PATH -Encoding utf8
            $eventProps = $eventJson | ConvertFrom-Json | ConvertTo-Hashtable
            $eventDetail = [pscustomobject]::new()
            AddReadOnlyProps $eventDetail $eventProps

            ## Weird bug
            if (-not (Get-Command recursiveEquality -ErrorAction SilentlyContinue)) {
                Write-Warning "test-helpers.ps1 missing, trying to resolve"
                . $PSScriptRoot/test-helpers.ps1
            }

            recursiveEquality $eventDetail $payload -Verbose | Should -Be $true
        }

        It 'Should only construct a context once' {
            $context1 = Get-ActionContext
            $context2 = Get-ActionContext

            $context2 | Should -Be $context1
            $context2._resolveDatetime | Should -Be $context1._resolveDatetime
        }
    }
}
