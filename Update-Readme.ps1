$Functions = Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Functions') -Filter '*.ps1' -Recurse
$Scripts = Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Scripts') -Filter '*.ps1' -Recurse
$Variables = Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Variables') -Filter '*.ps1' -Recurse

(Join-Path -Path $PSScriptRoot -ChildPath 'readme_test.md')

$ofParams = @{
  FilePath = (Join-Path -Path $PSScriptRoot -ChildPath 'README.md')
  Encoding = 'utf8'
  Force = $true
}

"# little-PSHelpers
Common used Powershell Functions, Variables, Scripts`n" | Out-File @ofParams


IF($Functions){
  '## Functions:' | Out-File @ofParams -Append
  FOREACH($Function in $Functions)
  {
    ("**{0}**  `n*{1}*  " -f $Function.BaseName, 'ToDo - Get Synopsis from Function') | Out-File @ofParams -Append
  }
}
IF($Scripts){
  '## Scripts:' | Out-File @ofParams -Append
  FOREACH($Script in $Scripts)
  {
    ("**{0}**  `n*{1}*  " -f $Script.BaseName, (Get-Help -Name $Script.FullName | Select-Object -ExpandProperty 'Synopsis')) | Out-File @ofParams -Append
  }
}
IF($Variables){
  '## Variables:' | Out-File @ofParams -Append
  FOREACH($Variable in $Variables)
  {
    ("**{0}**  `n*{1}*  " -f $Variable.BaseName, (Get-Help -Name $Variable.FullName | Select-Object -ExpandProperty 'Synopsis')) | Out-File @ofParams -Append
  }
}