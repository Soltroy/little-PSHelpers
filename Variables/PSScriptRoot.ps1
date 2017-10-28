### Set $PSScriptRoot if not available (PS2.0 combatiblity) [SolTroys little PSHelpers]
IF(!$PSScriptRoot)
{
  $PSScriptRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
}]