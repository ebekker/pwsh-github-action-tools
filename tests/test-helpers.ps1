
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
