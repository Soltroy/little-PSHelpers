FUNCTION Get-MSIInformation
{
  <#
      .SYNOPSIS
      Returns MSI Property Values
      .DESCRIPTION
      Returns MSI Property values as Powershell Object.
      Returned Informations:
      Name and FullName from File
      MSI Property Values for ProductName ,Manufacturer, ProductLanguage, ProductVersion and ProductCode
      .PARAMETER Path
      Path to MSI File
      .EXAMPLE
      GET-MSIInformation -Path .\AcroRead.msi
      .EXAMPLE
      Get-ChildItem -Path $env:ProgramFiles -Recurse -Filter '*.msi' | Get-MSIInformation
      .NOTES
      SolTroys little PSHelpers
      Code Base from
      http://www.scconfigmgr.com/2014/08/22/how-to-get-msi-file-information-with-powershell/
      --### TODO ###--
      * Better Messages / Texts
      .LINK
      https://github.com/Soltroy/little-PSHelpers
      .INPUTS
      System.String[]
      You can pipe a file system path (in quotation marks) to Get-ChildItem.
      .OUTPUTS
      System.Management.Automation.PSCustomObject
  #>
  [Alias('gmsi')]
  [CmdletBinding()]
  param(
    [parameter(Mandatory = $true,ValueFromPipelineByPropertyName)]
    [Alias('FullName')]
    [ValidateNotNullOrEmpty()]
    [string]$Path
  )
  Begin{
    Write-Verbose -Message '<BEGIN>'
    ## set Function Process Counter
    [int]$funcProcCounter = 0
    [int]$funcProcOKCounter = 0
    [int]$funcErrorCounter = 0
    
    ## set MSI Property Names
    [string[]]$Properties = ('ProductName', 'Manufacturer', 'ProductLanguage', 'ProductVersion', 'ProductCode')
    
    ##create Windowsinstaller Object
    $WindowsInstaller = New-Object -ComObject WindowsInstaller.Installer
    Write-Verbose -Message '</BEGIN>'
  }
  Process {
    $funcProcCounter++
    Write-Verbose -Message ('<PROCESS #{0}>' -f $funcProcCounter)
    ## Check if File/Path is valid
    Write-Verbose -Message ('Testing Path "{0}"' -f $Path)
    IF((Get-Item -LiteralPath $Path -ErrorAction SilentlyContinue).Extension -ne '.msi')
    {
      $errorParam = @{
        'Message'          = ('File not valid. Either no MSI extension {0} or Path invalid ({1})' -f $Path.Extension, $Path.FullName)
        'Category'         = 'OpenError'
        'CategoryReason'   = 'Get-ItemException'
        'CategoryTargetName' = ('{0}' -f $Path.FullName)
      }
      Write-Error @errorParam
      $funcErrorCounter++
      RETURN     
    }
    ELSE
    {
      ## rewrite item to item object
      $Path = Get-Item -LiteralPath $Path
      Write-Verbose -Message 'File OK'
      TRY 
      {
        # Read MSI Database
        Write-Verbose -Message 'Open MSI Database'
        $MSIDatabase = $WindowsInstaller.GetType().InvokeMember('OpenDatabase', 'InvokeMethod', $null, $WindowsInstaller, @($Path.FullName, 0))
        
        ## create outputObject
        Write-Verbose -Message 'Creating Output-Object'
        $obj = New-Object -TypeName PSObject
        Write-Verbose -Message ('adding Object-Member "Name" with value "{0}"' -f $Path.Name)
        $obj | Add-Member -MemberType NoteProperty -Name 'Name' -Value $Path.Name
        Write-Verbose -Message ('adding Object-Member "FullName" with value "{0}"' -f $Path.FullName)
        $obj | Add-Member -MemberType NoteProperty -Name 'FullName' -Value $Path.FullName
        ## loop throug properties
        FOREACH($Property in $Properties)
        {
          ## create query an read from MSI
          Write-Verbose -Message ('creating query for Property "{0}"' -f $Property)
          $Query = ("SELECT Value FROM Property WHERE Property = '{0}'" -f ($Property))
          $View = $MSIDatabase.GetType().InvokeMember('OpenView', 'InvokeMethod', $null, $MSIDatabase, ($Query))
          $null = $View.GetType().InvokeMember('Execute', 'InvokeMethod', $null, $View, $null)
          $Record = $View.GetType().InvokeMember('Fetch', 'InvokeMethod', $null, $View, $null)
        
          ## get the value - try and catch -> if property is not present, catch error and write NULL value to property Output
          TRY
          {
            $Value = $Record.GetType().InvokeMember('StringData', 'GetProperty', $null, $Record, 1)
          }
          CATCH
          {
            Write-Verbose -Message ('Property "{0}" not found or empty. Setting Value to NULL' -f $Property)
            $Value = $null
          }
          ## write property data to obj
          Write-Verbose -Message ('adding Object-Member "{0}" with value "{1}"' -f $Property, $Value)
          $obj | Add-Member -MemberType NoteProperty -Name $Property -Value $Value
          
          ## close the view
          $null = $View.GetType().InvokeMember('Close', 'InvokeMethod', $null, $View, $null) 
          $View = $null
        }
        ## Write Output
        Write-Verbose -Message 'Write-Output'
        Write-Output -InputObject $obj
        # close database
        Write-Verbose -Message 'close MSI Database'
        $null = $MSIDatabase.GetType().InvokeMember('Commit', 'InvokeMethod', $null, $MSIDatabase, $null)
        $MSIDatabase = $null
        $funcProcOKCounter++
      } 
      CATCH 
      {
        Write-Error -Message $_.Exception.Message
        $funcErrorCounter++
        Write-Verbose -Message ('</PROCESS #{0}> (terminated)' -f $funcProcCounter)
        RETURN
      }
    }
    Write-Verbose -Message ('</PROCESS #{0}>' -f $funcProcCounter)
  }
  End {
    Write-Verbose -Message '<END>'
    Write-Verbose -Message 'clean up and recycle objects'
    $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($WindowsInstaller)
    $null = [System.GC]::Collect()
    Write-Verbose -Message '</END>'
    Write-Verbose -Message ('Total Process Count : {0}' -f $funcProcCounter)
    Write-Verbose -Message ('         Successful : {0}' -f $funcProcOKCounter)
    Write-Verbose -Message ('              Error : {0}' -f $funcErrorCounter)
  }
}
