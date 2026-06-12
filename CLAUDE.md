# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A collection of PowerShell scripts for Windows endpoint management, organized by platform/tool. Scripts target SCCM/MECM, Intune, and standalone Windows environments in an enterprise IT context.

## Repository layout

| Folder | Purpose |
|---|---|
| `Applications/` | Per-app detection, remediation, and installation scripts |
| `SCCM MEMCM/` | ConfigMgr scripts — OSD task sequences, compliance items, client utilities |
| `Intune/` | Intune Proactive Remediation pairs (`Detection.ps1` + `Remediation.ps1`) |
| `Windows/` | General-purpose Windows admin utilities |
| `Projects/` | Longer-running or more complex standalone scripts |
| `Reference/` | Reusable snippets and helper functions |
| `WIP/` | Work-in-progress scripts not yet ready for use |

## Conventions

**SCCM Compliance Items** return `0` (compliant) or `1` (non-compliant) via `return`.

**Intune Proactive Remediations** come in pairs:
- `Detection.ps1` — exits `0` (compliant / no action needed) or `1` (remediation needed); writes a human-readable `Write-Host` message before exiting.
- `Remediation.ps1` — exits `0` on success or `1` on failure; uses a `try/catch` block and writes the error message to `Write-Host` on failure.

**Advanced functions** (scripts that wrap a reusable function) use `[cmdletbinding()]` and `param()` blocks with typed, validated parameters.

**Logging** (where present) uses a local `Write-Log` helper that appends timestamped lines to a date-stamped `.log` file.

## CI

The GitHub Actions workflow (`.github/workflows/CI.yml`) runs on `windows-latest` and currently only validates that PowerShell is available (`$PSVersionTable`). There are no automated linting or test steps — validation is manual.

## Linting / syntax checking

To check a script for syntax errors locally (requires PowerShell or pwsh):

```powershell
$null = [System.Management.Automation.Language.Parser]::ParseFile(".\path\to\script.ps1", [ref]$null, [ref]$errors)
$errors
```

PSScriptAnalyzer (if installed) provides style and best-practice analysis:

```powershell
Invoke-ScriptAnalyzer -Path .\path\to\script.ps1
```
