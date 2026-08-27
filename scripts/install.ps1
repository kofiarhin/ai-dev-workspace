[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$ProjectPath = ".",

    [switch]$Force
)

$ErrorActionPreference = "Stop"

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$sourceRoot = Join-Path $repositoryRoot "skills"

if (-not (Test-Path -LiteralPath $sourceRoot -PathType Container)) {
    throw "Skills source directory was not found: $sourceRoot"
}

$skillNames = @()
Get-ChildItem -LiteralPath $sourceRoot -Directory |
    Sort-Object Name |
    ForEach-Object {
        if (Test-Path -LiteralPath (Join-Path $_.FullName "SKILL.md") -PathType Leaf) {
            $skillNames += $_.Name
        }
    }

if ($skillNames.Count -eq 0) {
    throw "No installable skills containing SKILL.md were found under: $sourceRoot"
}

$resolvedProject = (Resolve-Path -LiteralPath $ProjectPath).Path
$skillsDirectory = Join-Path $resolvedProject ".claude\skills"
$legacyDestination = Join-Path $skillsDirectory "setup-prd-workspace"

$existing = @()
foreach ($skillName in $skillNames) {
    $destination = Join-Path $skillsDirectory $skillName
    if (Test-Path -LiteralPath $destination) {
        $existing += $destination
    }
}
if (Test-Path -LiteralPath $legacyDestination) {
    $existing += $legacyDestination
}

if ($existing.Count -gt 0 -and -not $Force) {
    throw "One or more workspace skills are already installed. Rerun with -Force to replace them: $($existing -join ', ')"
}

New-Item -ItemType Directory -Path $skillsDirectory -Force | Out-Null

if ($Force) {
    foreach ($path in $existing) {
        Remove-Item -LiteralPath $path -Recurse -Force
    }
}

foreach ($skillName in $skillNames) {
    $source = Join-Path $sourceRoot $skillName
    $destination = Join-Path $skillsDirectory $skillName

    Copy-Item -LiteralPath $source -Destination $destination -Recurse

    if (-not (Test-Path -LiteralPath (Join-Path $destination "SKILL.md") -PathType Leaf)) {
        throw "Installation failed for skill: $skillName"
    }
}

Write-Host "Installed $($skillNames.Count) AI software-delivery skills at: $skillsDirectory"
Write-Host "Installed skills: $($skillNames -join ', ')"
Write-Host "Start with: /setup-workspace PRD.md"
Write-Host "Audit consistency with: /workspace-health"
Write-Host "Queue the next evidence-backed ticket with: /morning-brief"
Write-Host "Deliver a ticket end to end with: /deliver-ticket"
Write-Host "Manual control remains: /ticket -> /spec -> /plan -> /implement-plan"
Write-Host "Reset owned operating state with: /reset-workspace"
