# GitHubActions _(0.7.0)_
Supports interacting with Github Actions environment
| Cmdlet | Synopsis |
|-|-|
| [Add-ActionPath](Add-ActionPath.md) | Prepends path to the PATH (for this action and future actions).<br/>Equivalent of `core.addPath(path)`. |
| [Add-ActionSecret](Add-ActionSecret.md) | Registers a secret which will get masked from logs.<br/>Equivalent of `core.setSecret(secret)`. |
| [Enter-ActionOutputGroup](Enter-ActionOutputGroup.md) | Begin an output group.<br/>Output until the next `groupEnd` will be foldable in this group.<br/>Equivalent of `core.startGroup(name)`. |
| [Exit-ActionOutputGroup](Exit-ActionOutputGroup.md) | End an output group.<br/>Equivalent of `core.endGroup()`. |
| [Get-ActionContext](Get-ActionContext.md) | Returns details of the executing GitHub Workflow assembled from the environment. |
| [Get-ActionInput](Get-ActionInput.md) | Gets the value of an input. The value is also trimmed.<br/>Equivalent of `core.getInput(name)`. |
| [Get-ActionInputs](Get-ActionInputs.md) | Returns a map of all the available inputs and their values.<br/>No quivalent in `@actions/core` package. |
| [Get-ActionIsDebug](Get-ActionIsDebug.md) | Gets whether Actions Step Debug is on or not.<br/>Equivalent of `core.isDebug()`. |
| [Get-ActionIssue](Get-ActionIssue.md) | Returns details of the issue associated with the workflow trigger,<br/>including owner and repo name, and the issue (or PR) number. |
| [Get-ActionRepo](Get-ActionRepo.md) | Returns details of the repository, including owner and repo name. |
| [Invoke-ActionGroup](Invoke-ActionGroup.md) | Executes the argument script block within an output group.<br/>Equivalent of `core.group(name, func)`. |
| [Invoke-ActionNoCommandsBlock](Invoke-ActionNoCommandsBlock.md) | Invokes a scriptblock that won't result in any output interpreted as a workflow command.<br/>Useful for printing arbitrary text that may contain command-like text.<br/>No quivalent in `@actions/core` package. |
| [Send-ActionCommand](Send-ActionCommand.md) | Sends a command to the hosting Workflow/Action context.<br/>Equivalent to `core.issue(cmd, msg)`/`core.issueCommand(cmd, props, msg)`. |
| [Set-ActionCommandEcho](Set-ActionCommandEcho.md) | Enables or disables the echoing of commands into stdout for the rest of the step.<br/>Echoing is disabled by default if ACTIONS_STEP_DEBUG is not set.<br/>Equivalent of `core.setCommandEcho(enabled)`. |
| [Set-ActionFailed](Set-ActionFailed.md) | Sets an action status to failed.<br/>When the action exits it will be with an exit code of 1.<br/>Equivalent of `core.setFailed(message)`. |
| [Set-ActionOutput](Set-ActionOutput.md) | Sets the value of an output.<br/>Equivalent of `core.setOutput(name, value)`. |
| [Set-ActionVariable](Set-ActionVariable.md) | Sets env variable for this action and future actions in the job.<br/>Equivalent of `core.exportVariable(name, value)`. |
| [Write-ActionDebug](Write-ActionDebug.md) | Writes debug message to user log.<br/>Equivalent of `core.debug(message)`. |
| [Write-ActionError](Write-ActionError.md) | Adds an error issue.<br/>Equivalent of `core.error(message)`. |
| [Write-ActionInfo](Write-ActionInfo.md) | Writes info to log with console.log.<br/>Equivalent of `core.info(message)`.<br/>Forwards to Write-Host. |
| [Write-ActionWarning](Write-ActionWarning.md) | Adds a warning issue.<br/>Equivalent of `core.warning(message)`. |
###### Copyright (C) Eugene Bekker.  All rights reserved.
