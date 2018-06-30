<#
    .SYNOPSIS
    creates a sortable Timestamp Variable (yyyyMMdd_HHmmss)
    .NOTES
    SolTroys little PSHelpers
    .LINK
    https://github.com/Soltroy/little-PSHelpers
#>
$TimeStamp = Get-Date -Format 'yyyyMMdd_HHmmss'