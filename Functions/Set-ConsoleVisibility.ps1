﻿FUNCTION Set-ConsoleVisibility
{
  <#
      .SYNOPSIS
      Function to show, hide or change the Visibility of the current Console window.
      .PARAMETER change
      This parameter changes between show and hide regardig of the current state
      .PARAMETER show
      Shows the Console Window
      .PARAMETER hide
      Hides the Console Window
      .EXAMPLE
      Set-ConsoleVisibility -change
      If the Console Window is Visible it will be hidden, if the Console Window is not Visible it will be shown
      .EXAMPLE
      Set-ConsoleVisibility -show
      Independent from the current state the Console Window will be shown
      .EXAMPLE
      Set-ConsoleVisibility -hide
      Independent from the current state the Console Window will be hidden
      .NOTES
      SolTroys little PSHelpers
      .LINK
      https://github.com/Soltroy/little-PSHelpers
  #>


  [CmdletBinding(DefaultParameterSetName = 'change', 
      SupportsShouldProcess = $true, 
  ConfirmImpact = 'Low')]
  param(
    # Param1 help description
    [Parameter(ParameterSetName = 'change', Position = 0)]
    [switch]$change,
    [Parameter(ParameterSetName = 'show', Position = 0)]
    [switch]$show,
    [Parameter(ParameterSetName = 'hide', Position = 0)]
    [switch]$hide   
  )
  ## CHeck if we are inside a console
  IF(!($host.Name -eq 'ConsoleHost')){
    Write-Warning -Message ('Host is not a Console ({0}). Terminating Function.' -f $host.Name)
    RETURN
  }
  TRY
  {
    Write-Verbose -Message '<Set-ConsoleVisibility>'
    Write-Verbose -Message ('Parameter: -{0}' -f $PsCmdlet.ParameterSetName)
    
    ### add Console.Widows type
    IF (!('Console.Window' -as [type])) 
    {
      Add-Type -Name Window -Namespace Console -MemberDefinition '
        [DllImport("Kernel32.dll")]
        public static extern IntPtr GetConsoleWindow();

        [DllImport("user32.dll")]
        public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);

        [DllImport("user32.dll")]
        public static extern bool IsWindowVisible(int hwnd);
      '
    }
    ### get console pointer
    $consolePtr = [Console.Window]::GetConsoleWindow()
  
    ### set what to do
    switch ($PsCmdlet.ParameterSetName) 
    { 
      'show' 
      {
        $consoleVis = $false
      } 
      'hide'  
      {
        $consoleVis = $true
      }
      'change' 
      {
        $consoleVis = [Console.Window]::IsWindowVisible($consolePtr)
      }
    }
  
    Write-Verbose -Message ('Console Visible: {0}' -f $consoleVis)
  
    IF($consoleVis)
    {
      IF($PsCmdlet.ShouldProcess(('Send "SW_HIDE" to ConsoleWindow "{0}" ([Console.Window]::ShowWindow({0},0))' -f $consolePtr),'',''))
      {
        Write-Verbose -Message ('</Set-ConsoleVisibility -{0}>' -f $PsCmdlet.ParameterSetName)
      }
    }
    ELSE
    {
      IF($PsCmdlet.ShouldProcess(('Send "SW_RESTORE" to ConsoleWindow "{0}" ([Console.Window]::ShowWindow({0},9))' -f $consolePtr),'',''))
      {
        $NULL = [Console.Window]::ShowWindow($consolePtr,9)
      }
    }
  }
  CATCH
  {
    BREAK
  }
  Write-Verbose -Message '</Set-ConsoleVisibility>'
  RETURN [Console.Window]::IsWindowVisible($consolePtr)
}