## Copyright (c) Eugene Bekker. All rights reserved.
## Licensed under the MIT License.

@{
    GUID = '35b95976-97b3-473d-b132-f6165981f0d2'
    Author = 'https://github.com/ebekker/pwsh-github-action-tools/contributors'
    CompanyName = 'https://github.com/ebekker/pwsh-github-action-tools'
    Copyright = 'Copyright (C) Eugene Bekker.  All rights reserved.'

    ModuleVersion = '0.7.0'
    Description = 'Supports interacting with Github Actions environment'

    ## Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '7.0'

    ## Script module or binary module file associated with this manifest.
    RootModule = 'GitHubActions.psm1'

    NestedModules = @(
        ,'context.ps1'
    )

    ## Private data to pass to the module specified in RootModule/ModuleToProcess. This may
    ## also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{

        PSData = @{

            ## Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('GitHub', 'Actions', 'CI')

            ## A URL to the license for this module.
            LicenseUri = 'https://github.com/ebekker/pwsh-github-action-tools/blob/master/LICENSE'

            ## A URL to the main website for this project.
            ProjectUri = 'https://github.com/ebekker/pwsh-github-action-tools'

            ## A URL to an icon representing this module.
            # IconUri = ''

            ## ReleaseNotes of this module
            ReleaseNotes = 'https://github.com/ebekker/pwsh-github-action-base/releases/'
        }
    }

    ## Functions to export from this module
    FunctionsToExport = @(
        ,'Add-ActionPath'
        ,'Add-ActionSecretMask'
        ,'Enter-ActionOutputGroup'
        ,'Exit-ActionOutputGroup'
        ,'Get-ActionInput'
        ,'Get-ActionInputs'
        ,'Invoke-ActionWithinOutputGroup'
        ,'Set-ActionFailed'
        ,'Set-ActionOutput'
        ,'Set-ActionVariable'
        ,'Write-ActionDebug'
        ,'Write-ActionError'
        ,'Write-ActionInfo'
        ,'Write-ActionWarning'
        ## Context-related
        ,'Get-ActionContext'
        ,'Get-ActionIssue'
        ,'Get-ActionRepo'
    )

    ## Aliases to export from this module
    # AliasesToExport = @()

    ## Cmdlets to export from this module
    # CmdletsToExport = '*'

    ## Variables to export from this module
    # VariablesToExport = '*'    

    ## Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = 'Action'

    ## Modules that must be imported into the global environment prior to importing this module
    # RequiredModules = @()

    ## Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()

    ## Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()

    ## List of all modules packaged with this module
    # ModuleList = @()

    ## List of all files packaged with this module
    # FileList = @()

    ## HelpInfo URI of this module
    # HelpInfoURI = ''
}
