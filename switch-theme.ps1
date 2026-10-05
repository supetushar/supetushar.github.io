<#
.SYNOPSIS
  Make one of the 4 theme folders the live site by regenerating root index.html from it.

.DESCRIPTION
  Each theme lives in its own self-contained folder (theme-a/, theme-b/, theme-c/, theme-d/),
  each with its own index.html, links.html, projects.html, and Projects/<name>/*.html, all using
  paths relative to that folder. Shared binary assets (images/, Projects/*/thumbnails, Projects/Resume/)
  stay at the repo root and are referenced from inside each theme folder via "../".

  Because root index.html sits one level up from a theme folder, it cannot simply be a copy of
  theme-X/index.html -- paths need adjusting:
    - "../images/..."   -> "images/..."          (root is already at that level)
    - "../Projects/..."  -> "Projects/..."        (shared resources, e.g. Resume)
    - "Projects/AI_Job_Application_Agent/..." (theme-local project) -> "theme-X/Projects/AI_Job_Application_Agent/..."
    - "links.html" / "projects.html" (theme-local pages) -> "theme-X/links.html" / "theme-X/projects.html"

.USAGE
  ./switch-theme.ps1 A      # Aurora Grid (dark, glowing gradients)
  ./switch-theme.ps1 B      # Terminal / Dev Console
  ./switch-theme.ps1 C      # Glassmorphic Mesh
  ./switch-theme.ps1 D      # Cobalt Dark (starfield, skills/timeline)
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("A","B","C","D","a","b","c","d")]
    [string]$Theme
)

$key = $Theme.ToUpper()
$themeFolder = "theme-$($key.ToLower())"
$source = Join-Path $themeFolder "index.html"

if (-not (Test-Path $source)) {
    Write-Error "Theme folder '$themeFolder' (or its index.html) not found. Run this script from the repo root."
    exit 1
}

$content = Get-Content -Path $source -Raw

# Shared resources: theme folder is one level deep, so "../X" at theme level == "X" at root level.
$content = $content -replace 'href="\.\./images/', 'href="images/'
$content = $content -replace 'href="\.\./Projects/', 'href="Projects/'

# Theme-local project pages (e.g. the featured Job Agent tile) must stay inside the theme folder.
$content = $content -replace 'href="Projects/AI_Job_Application_Agent/', "href=`"$themeFolder/Projects/AI_Job_Application_Agent/"

# Theme-local pages (links/projects listing) likewise need the folder prefix from root.
$content = $content -replace 'href="links\.html"', "href=`"$themeFolder/links.html`""
$content = $content -replace 'href="projects\.html"', "href=`"$themeFolder/projects.html`""

Set-Content -Path "index.html" -Value $content -NoNewline
Write-Host "Switched live site to Theme $key ($themeFolder/index.html) -> index.html" -ForegroundColor Green
Write-Host "Review with 'git diff index.html', then commit and push when ready." -ForegroundColor Yellow
