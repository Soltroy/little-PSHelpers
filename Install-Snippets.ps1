param(
  [switch]$ISE,
  [switch]$VSCode,
  [ValidateSet('CurrentUser', 'AllUsers')]
  [string]$Scope = 'CurrentUser'
)
### Get all the content
#### Get files
$Functions = Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Functions') -Filter '*.ps1' -Recurse
$Scripts = Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Scripts') -Filter '*.ps1' -Recurse
$Variables = Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Variables') -Filter '*.ps1' -Recurse

#### init object hashtable
$objContent = @()

#### get objects and add to hashtable
IF($Functions)
{
  FOREACH($Function in $Functions)
  {
    $obj = [PSCustomObject] @{
      Type     = 'Functions'
      FullName = $Function.FullName
      BaseName = $Function.BaseName
      Synopsis = 'ToDo - Get Synopsis from Function'
    }
    $objContent += $obj
  }
}
IF($Scripts)
{
  FOREACH($Script in $Scripts)
  {
    $obj = [PSCustomObject] @{
      Type     = 'Scripts'
      FullName = $Script.FullName
      BaseName = $Script.BaseName
      Synopsis = (Get-Help -Name $Script.FullName | Select-Object -ExpandProperty 'Synopsis')
    }
    $objContent += $obj
  }
}
IF($Variables)
{
  FOREACH($Variable in $Variables)
  {
    $obj = [PSCustomObject] @{
      Type     = 'Variables'
      FullName = $Variable.FullName
      BaseName = $Variable.BaseName
      Synopsis = (Get-Help -Name $Variable.FullName | Select-Object -ExpandProperty 'Synopsis')
    }
    $objContent += $obj
  }
}

### create snippets for ISE
IF($ISE)
{
  ### set BasePath (CurrentUser/AllUsers)
  IF($Scope -eq 'CurrentUser')
  {
    Join-Path -Path (Split-Path -Path $profile.CurrentUserCurrentHost) -ChildPath 'Snippets'
  }
  ELSE
  {
    Join-Path -Path (Split-Path -Path $profile.AllUsersCurrentHost) -ChildPath 'Snippets'
  }
}

### create snippets for Visual Studio Code
IF($VSCode)
{
  function Get-VScodeSnippets () 
  {

  }
  IF($Scope -eq 'CurrentUser')
  {
    $outPath = Join-Path -Path $env:APPDATA -ChildPath 'Code\User\snippets'
    #'powershell.json'
  }
  ELSE
  {

  }
}
