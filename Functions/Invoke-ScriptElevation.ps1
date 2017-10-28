FUNCTION Invoke-ScriptElevation
{
  <#
      .SYNOPSIS
      Elevates the current running script to run with Administrator privileges.
      .DESCRIPTION
      This Function must be used within a Script. When the Function is called it restarts the Script in an elevated Powershell Session.
      Therefore the Function should be used at the beginning of the Script.
      .NOTES
      SolTroys little PSHelpers
      .LINK
      https://github.com/Soltroy/little-PSHelpers
  #>

  $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')
  IF (!$isAdmin)  
  {
    # Build base arguments for powershell.exe
    [string[]]$argList = @('-NoLogo -NoProfile', '-ExecutionPolicy Bypass')
    IF($VerbosePreference)
    {
      $argList += '-noexit'
    }
    $argList += @('-File', """$($script:MyInvocation.MyCommand.Path)""")

    # Add 
    $argList += $script:MyInvocation.BoundParameters.GetEnumerator() | ForEach-Object -Process {
      "-$($_.Key)", """$($_.Value)"""
    }
    $argList += $script:MyInvocation.UnboundArguments
     
    try
    {
      $null = Start-Process -FilePath PowerShell.exe -PassThru -Verb Runas -ArgumentList $argList
      RETURN
    }
    catch 
    {
      Write-Error -Message 'Failed to elevate the Script.'  
      RETURN
    }
  }
}