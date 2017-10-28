FUNCTION Invoke-Lockfile {
  <#
      .SYNOPSIS
      Creates a file and opens a file stream to lock the file.
      .NOTES
      SolTroys little PSHelpers
      .LINK
      https://github.com/Soltroy/little-PSHelpers
  #>
  param(
    [Parameter(Mandatory = $TRUE, Position = 0)]
    [string]$Path
  )
  $file = Join-Path -Path $Path -ChildPath '.pslock'
  $mode = "OpenOrCreate"
  $access = "Read"
  $share = "None"
  $output = [System.IO.File]::Open($file, $mode, $access, $share)
  RETURN $output
}

FUNCTION Revoke-Lockfile {
  <#
   <#
      .SYNOPSIS
      Closes the filestream from the lock-file an deletes the file.
      .NOTES
      SolTroys little PSHelpers
      .LINK
      https://github.com/Soltroy/little-PSHelpers
  #>
  param(
    [Parameter(Mandatory = $TRUE, Position = 0)]
    [System.IO.FileStream]$FileStream
  )
  $FileStream.Close()
  Remove-Item -Path $FileStream.Name -Force
}