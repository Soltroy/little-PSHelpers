<#
    .SYNOPSIS
    Sets $PSScriptRoot  variable if not available (PS2.0 combatiblity)
    .NOTES
    SolTroys little PSHelpers
    .LINK
    https://github.com/Soltroy/little-PSHelpers
#>
IF(!$PSScriptRoot)
{
  $PSScriptRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
}]