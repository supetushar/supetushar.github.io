<#
.SYNOPSIS
  Swap the live portfolio theme (index.html) between the 3 rotating designs.

.USAGE
  ./switch-theme.ps1 A      # Aurora Grid (dark, glowing gradients)
  ./switch-theme.ps1 B      # Terminal / Dev Console
  ./switch-theme.ps1 C      # Glassmorphic Mesh
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("A","B","C","a","b","c")]
    [string]$Theme
)

$map = @{
    "A" = "theme-a-aurora.html"
    "B" = "theme-b-terminal.html"
    "C" = "theme-c-glass.html"
}

$key = $Theme.ToUpper()
$source = $map[$key]

if (-not (Test-Path $source)) {
    Write-Error "Theme file '$source' not found. Run this script from the repo root."
    exit 1
}

Copy-Item -Path $source -Destination "index.html" -Force
Write-Host "Switched live site to Theme $key ($source) -> index.html" -ForegroundColor Green
Write-Host "Review with 'git diff index.html', then commit and push when ready." -ForegroundColor Yellow
