# Get-ActionInput
```

NAME
    Get-ActionInput
    
SYNOPSIS
    Gets the value of an input. The value is also trimmed.
    Equivalent of `core.getInput(name)`.
    
    
SYNTAX
    Get-ActionInput [-Name] <String> [-Required] [<CommonParameters>]
    
    
DESCRIPTION
    

PARAMETERS
    -Name <String>
        Name of the input to get.
        
        Required?                    true
        Position?                    1
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -Required [<SwitchParameter>]
        Whether the input is required. If required and not present, will throw.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    System.String
    
    
    
RELATED LINKS
    https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions#jobsjob_idstepswith
    https://github.com/actions/toolkit/tree/7f7e22a9406f546f9084e9eb7a4e541a3563f92b/packages/core#inputsoutputs

```

