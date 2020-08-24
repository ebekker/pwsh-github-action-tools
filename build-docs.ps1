#!/usr/bin/env pwsh

## This impelements a quick and dirty way to convert
## native PWSH help content into a Markdown format.
## It generates one file for each exported command
## along with an aggregate index page with links for
## each exported command to its specific page.

## Invoke as a child session to not mix module under build with modules in Runspace
$cmd = {
    $mod = Import-Module ./GitHubActions -PassThru -Scope Local -Force

    $docsPath = "docs/$($mod.Name)"
    $readme = "$docsPath/README.md"
    Remove-Item $docsPath -Force -Recurse -ErrorAction:Ignore
    if (-not (Test-Path $docsPath)) {
        mkdir $docsPath | Out-Null
    }
    Write-Output "# $($mod.Name) _($($mod.Version))_" >> $readme
    Write-Output "$($mod.Description)"                >> $readme
    Write-Output "| Cmdlet | Synopsis |"              >> $readme
    Write-Output "|-|-|"                              >> $readme
    Get-Command -Module $mod.Name | ForEach-Object {
        Get-Help $_.Name | Select-Object @{
            Name       = "Row"
            Expression = {
                $n = $_.Name.Trim()
                $s = $_.Synopsis.Trim() -replace '\r?\n', '<br/>'
                "| [$($n)]($($n).md) | $($s) |"
            }
        }
    } | Select-Object -Expand Row  >> $readme

    Write-Output "###### $($mod.Copyright)" >> $readme

    Get-Command -Module $mod.Name | ForEach-Object {
        Get-Help -Full $_.Name | Select-Object @{
            Name       = "Row"
            Expression = {
                $n = $_.Name.Trim()
                "# $n"
                "``````"
                $_
                "``````"
            }
        } | Select-Object -Expand Row  > "$docsPath/$($_.Name).md"
    }
}
pwsh -c $cmd -wd $PSScriptRoot
