# Claude Bridge for Premiere Pro - installer (per-user, no admin, no Creative Cloud needed)
$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "Installing Claude Bridge panel for Premiere Pro..." -ForegroundColor Cyan
$extDir = Join-Path $env:APPDATA 'Adobe\CEP\extensions\com.claude.premierebridge'
if (Test-Path $extDir) { Remove-Item $extDir -Recurse -Force }
New-Item -ItemType Directory -Force -Path (Split-Path $extDir) | Out-Null
Copy-Item (Join-Path $here 'extension\com.claude.premierebridge') $extDir -Recurse
Write-Host "  Panel copied to $extDir"

# Allow unsigned extensions (CEP 9-12 covers Premiere 2019 - 2025; 2022 uses CSXS.11)
foreach ($v in 9,10,11,12) {
  $key = "HKCU:\Software\Adobe\CSXS.$v"
  New-Item -Path $key -Force | Out-Null
  Set-ItemProperty -Path $key -Name 'PlayerDebugMode' -Value '1' -Type String
}
Write-Host "  Enabled unsigned extensions (PlayerDebugMode=1)"

# Copy MCP server for manual setups
$cfg = Join-Path $env:APPDATA 'ClaudePremiereBridge'
New-Item -ItemType Directory -Force -Path $cfg | Out-Null
Copy-Item (Join-Path $here 'mcp\server\index.js') (Join-Path $cfg 'mcp-server.js') -Force

Write-Host ""
Write-Host "Done! Next steps:" -ForegroundColor Green
Write-Host "  1. Restart Premiere Pro, then open Window > Extensions > Claude Bridge"
Write-Host "  2. Double-click premiere-pro-bridge.mcpb to add it to Claude Desktop"
Write-Host ""
Read-Host "Press Enter to close"
