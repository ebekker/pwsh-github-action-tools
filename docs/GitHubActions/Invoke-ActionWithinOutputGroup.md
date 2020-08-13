# Invoke-ActionWithinOutputGroup
```

NAME
    Invoke-ActionWithinOutputGroup
    
SYNOPSIS
    Executes the argument script block within an output group.
    
    
SYNTAX
    Invoke-ActionWithinOutputGroup [-Name] <String> [-ScriptBlock] <ScriptBlock> [<CommonParameters>]
    
    
DESCRIPTION
    

PARAMETERS
    -Name <String>
        Name of the output group.
        
        Required?                    true
        Position?                    1
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    -ScriptBlock <ScriptBlock>
        Script block to execute in between opening and closing output group.
        
        Required?                    true
        Position?                    2
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    
RELATED LINKS
    https://github.com/actions/toolkit/tree/a6e72497764b1cf53192eb720f551d7f0db3a4b4/packages/core#logging

```

