
## This impelements a quick and dirty way to convert
## native PWSH help content into a Markdown format.
## It generates one file for each exported command
## along with an aggregate index page with links for
## each exported command to its specific page.

## Invoke as a child session to not mix module under build with modules in Runspace
pwsh -c @'
    ipmo ./GitHubActions/
    $modDocs = './docs/GitHubActions'

    if (-not (Test-Path $modDocs)) { mkdir $modDocs }

    $mod = Get-Module GitHubActions
    Write-Output """"                                    > $modDocs/README.md
    Write-Output ""# $($mod.Name) _($($mod.Version))_"" >> $modDocs/README.md
    Write-Output ""$($mod.Description)""                >> $modDocs/README.md
    Write-Output ""| Cmdlet | Synopsis |""              >> $modDocs/README.md
    Write-Output ""|-|-|""                              >> $modDocs/README.md

    Get-Command -Module GitHubActions | % { Get-Help $_.Name | Select-Object @{
        Name = ""Row""
        Expression = {
            $n = $_.Name.Trim()
            $s = $_.Synopsis.Trim().Replace(""`r"",'').Replace(""`n"", '<br/>')
            ""| [$($n)]($($n).md) | $($s) |""
        }
    } } | Select-Object -Expand Row  >> $modDocs/README.md
    Get-Command -Module GitHubActions | % { Get-Help -Full $_.Name | Select-Object @{
        Name = ""Row""
        Expression = {
            $n = $_.Name.Trim()
            ""# $n""
            ""``````""
            $_
            ""``````""
        }
    } | Select-Object -Expand Row  > ""$modDocs/$($_.Name).md"" }

    Write-Output ""###### $($mod.Copyright)"" >> $modDocs/README.md
'@
