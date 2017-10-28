FUNCTION Get-ConsoleVisibility
{
  <#
      .SYNOPSIS
      Get the visibility state of the current console Window. Returns TRUE if visible and FALSE if hidden.
      .NOTES
      SolTroys little PSHelpers
      .LINK
      https://github.com/Soltroy/little-PSHelpers
  #>
  ## CHeck if we are inside a console
  IF(!($host.Name -eq 'ConsoleHost')){
    Write-Warning -Message ('Host is not a Console ({0}). Terminating Function.' -f $host.Name)
    RETURN
  }
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
  
  RETURN [Console.Window]::IsWindowVisible($consolePtr)
}