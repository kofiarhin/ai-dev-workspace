[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$ProjectPath = ".",

    [switch]$Force
)

$ErrorActionPreference = "Stop"

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$source = Join-Path $repositoryRoot "skill"

if (-not (Test-Path -LiteralPath $source -PathType Container)) {
    throw "Skill source directory was not found: $source"
}

$resolvedProject = (Resolve-Path -LiteralPath $ProjectPath).Path
$skillsDirectory = Join-Path $resolvedProject ".claude\skills"
$destination = Join-Path $skillsDirectory "setup-prd-workspace"

if (Test-Path -LiteralPath $destination) {
    if (-not $Force) {
        throw "The skill is already installed at '$destination'. Rerun with -Force to replace it."
    }

    Remove-Item -LiteralPath $destination -Recurse -Force
}

New-Item -ItemType Directory -Path $skillsDirectory -Force | Out-Null
Copy-Item -LiteralPath $source -Destination $destination -Recurse

if (-not (Test-Path -LiteralPath (Join-Path $destination "SKILL.md") -PathType Leaf)) {
    throw "Installation failed because SKILL.md was not copied."
}

Write-Host "Installed setup-prd-workspace at: $destination"
Write-Host "Open the project in Claude Code and run: /setup-prd-workspace PRD.md"
