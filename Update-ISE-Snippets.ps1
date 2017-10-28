<#
    ############################################################################################
    ############################################################################################
    ############################################################################################

    "This is not a little helper, this is a lazy dev script!"

    The Script is used for Auto-Generating Snippets from Functions and Variables.

    ############################################################################################
    ############################################################################################
    ############################################################################################
#>

Function Update-ISESnippetfromFile
{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true,Position = 0,ValueFromPipelineByPropertyName)]
    [Alias('FullName')]
    [string]$Path,
    [Parameter(Mandatory = $true,Position = 1)]
    [ValidateSet('Functions','Scripts','Variables','Templates')]
    [string]$Category,
    [string]$Author = $env:USERNAME,
    [ValidateRange(0, [Int32]::MaxValue)]
    [Int32]$CaretOffset = 0,
    [switch]$Force
  )
  begin{
    Write-Verbose -Message '-- Update-ISESnippetfromFile --'
    Write-Verbose -Message '<BEGIN>'
    ## set Function Process Counter
    [int]$funcProcCounter = 0
    [int]$funcProcOKCounter = 0
    [int]$funcErrorCounter = 0
    
    ### internal Create SnippetFunction
    FUNCTION New-Snippet
    {
      if($Text.IndexOf(']]>') -ne -1)
      {
        throw [Microsoft.PowerShell.Host.ISE.SnippetStrings]::SnippetsNoCloseCData -f 'Text', ']]>'
      }
      $snippet = (@"
<?xml version='1.0' encoding='utf-8' ?>
    <Snippets  xmlns='http://schemas.microsoft.com/PowerShell/Snippets'>
        <Snippet Version='1.0.0'>
            <Header>
                <Title>{0}</Title>
                <Description>{1}</Description>
                <Author>{2}</Author>
                <SnippetTypes>
                    <SnippetType>Expansion</SnippetType>
                </SnippetTypes>
            </Header>

            <Code>
                <Script Language='PowerShell' CaretOffset='{3}'>
                    <![CDATA[{4}]]>
                </Script>
            </Code>

    </Snippet>
</Snippets>

"@ -f [System.Security.SecurityElement]::Escape($Title), [System.Security.SecurityElement]::Escape($Description), [System.Security.SecurityElement]::Escape($Author), $CaretOffset, $Text)

      $pathCharacters = '/\`*?[]:><"|.'
      $fileName = New-Object -TypeName text.stringBuilder
      for($ix = 0; $ix -lt $preFileName.Length; $ix++)
      {
        $titleChar = $preFileName[$ix]
        if($pathCharacters.IndexOf($titleChar) -ne -1)
        {
          $titleChar = '_'
        }

        $null = $fileName.Append($titleChar)
      }

      $params = @{
        FilePath = ('{0}\{1}.snippets.ps1xml' -f $snippetPath, $fileName)
        Encoding = 'UTF8'
      }

      if ($Force)
      {
        $params['Force'] = $true
      }
      else
      {
        $params['NoClobber'] = $true
      }

      $snippet | Out-File @params
      
      ## 2nd Output
      $params['FilePath'] = ('{0}\{1}.snippets.ps1xml' -f $snippetPathLocal, $fileName)
      $snippet | Out-File @params
    }
    Write-Verbose -Message '</BEGIN>'
  }
  process{
    $funcProcCounter++
    Write-Verbose -Message ('<PROCESS #{0}>' -f $funcProcCounter)
    TRY{
      Write-Verbose -Message ('processing "{0}"' -f $Path)
      $snippetPath = Join-Path -Path (Split-Path -Path $profile.CurrentUserCurrentHost) -ChildPath ('Snippets\{0}' -f $Category)
      $snippetPathLocal = Join-Path -Path $PSScriptRoot -ChildPath ('ISE-Snippets\{0}' -f $Category)

      if (-not (Test-Path -Path $snippetPath))
      {
        $null = New-Item -Path $snippetPath -ItemType Directory -Force
      }
    
      if (-not (Test-Path -Path $snippetPathLocal))
      {
        $null = New-Item -Path $snippetPathLocal -ItemType Directory -Force
      }
        
      ## rewrite Path-Avriable
      $PathObj = Get-Item -LiteralPath $Path
      ### Get Data from InputFile
  
      IF($Category -eq 'Functions')
      {
        ## Load Functions and return them
        $currentFunctions = Get-ChildItem -Path function:
        # dot source your script to load it to the current runspace
        . $PathObj
        $scriptFunctions = Get-ChildItem -Path function: | Where-Object {
          $currentFunctions -notcontains $_
        }

        FOREACH ($scriptFunction in $scriptFunctions)
        {
          $preFileName = ('{0}_{1}' -f $scriptFunction.Noun, $scriptFunction.Verb)
          
          $Title = ('{0} [{1}]' -f $scriptFunction.Noun, $scriptFunction.Verb)
          $Description = (Get-Help -Name $scriptFunction).Synopsis
          $Text = ('FUNCTION {0}' -f (Get-Command -Name $scriptFunction).Name) + ' {'
          $Text += (Get-Command -Name $scriptFunction).Definition
          $Text += '}'

          New-Snippet
        }
      }
      ### Variables, Templates
      ELSE
      {
        $preFileName = $PathObj.BaseName
        
        $FileContent = (Get-Content -LiteralPath $PathObj)
        $Title = $PathObj.BaseName
        $Description = $FileContent[0].Replace('#','').Trim()
    
        $Text = (@'
{0}
'@ -f ($FileContent | Out-String))
    
        New-Snippet
      }
      $funcProcOKCounter++
    }
    CATCH{
      Write-Error -Message $_.Exception.Message
      $funcErrorCounter++
      Write-Verbose -Message ('</PROCESS #{0}> (terminated)' -f $funcProcCounter)
      RETURN
    }
    Write-Verbose -Message ('</PROCESS #{0}>' -f $funcProcCounter)
  }

  end{
    Write-Verbose -Message '<END>'  
    Write-Verbose -Message '</END>'
    Write-Verbose -Message ('Total Process Count : {0}' -f $funcProcCounter)
    Write-Verbose -Message ('         Successful : {0}' -f $funcProcOKCounter)
    Write-Verbose -Message ('              Error : {0}' -f $funcErrorCounter)
  } 
}

Get-ChildItem -Path ('{0}\Functions' -f $PSScriptRoot) -File -Filter '*.ps1' | Update-ISESnippetfromFile -Author 'SolTroy' -Category Functions -Force -Verbose
Get-ChildItem -Path ('{0}\Variables' -f $PSScriptRoot) -File -Filter '*.ps1' | Update-ISESnippetfromFile -Author 'SolTroy' -Category Variables -Force -Verbose