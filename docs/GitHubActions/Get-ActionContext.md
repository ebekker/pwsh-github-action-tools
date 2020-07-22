# Get-ActionContext
```

NAME
    Get-ActionContext
    
SYNOPSIS
    Returns details of the executing GitHub Workflow assembled from the environment.
    
    
SYNTAX
    Get-ActionContext [<CommonParameters>]
    
    
DESCRIPTION
    The returned context is a read-only object that assembles elements from the
    executing environment of a Workflow such as environment variables and files
    and is a _PowerShelly_ adaptation of the API and interfaces defined by the
    GitHub Actions Toolkit for TypeScript.
    

PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > Import-Module GitHubActions
    
    $context = Get-ActionContext
    if ($context.EventName -eq 'push') {
        $payload = $context.Payload
        Write-ActionInfo "The head commit is: $($payload.head_commit | ConvertTo-Json)"
    }
    
    
    
    
    
RELATED LINKS
    https://github.com/actions/toolkit
    https://github.com/actions/toolkit/tree/main/packages/github
    https://github.com/actions/toolkit/blob/master/packages/github/src/context.ts

```

