<#
.SYNOPSIS
  Links all skills from rust-product-skills into an agent's skills directory using NTFS junctions.
#>
[CmdletBinding()]
param(
  [ValidateSet('antigravity', 'claude', 'agents', 'workspace')]
  [string]$Target = 'agents',
  [string]$WorkspacePath = ''
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$skillsSrc = Join-Path $repoRoot 'skills'

$destRoot = switch ($Target) {
  'antigravity' { Join-Path $HOME '.gemini\config\skills' }
  'claude'      { Join-Path $HOME '.claude\skills' }
  'agents'      { Join-Path $HOME '.agents\skills' }
  'workspace'   {
    if (-not $WorkspacePath) {
      throw 'Provide -WorkspacePath when using -Target workspace.'
    }
    Join-Path $WorkspacePath '.agents\skills'
  }
}

New-Item -ItemType Directory -Force -Path $destRoot | Out-Null

Get-ChildItem -LiteralPath $skillsSrc -Directory | ForEach-Object {
  $linkPath = Join-Path $destRoot $_.Name
  if (Test-Path -LiteralPath $linkPath) {
    Remove-Item -LiteralPath $linkPath -Force -Recurse
  }
  New-Item -ItemType Junction -Path $linkPath -Target $_.FullName | Out-Null
  Write-Host "Linked $($_.Name) -> $linkPath" -ForegroundColor Green
}
