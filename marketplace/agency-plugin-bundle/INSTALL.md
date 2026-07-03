# Install Power Automate Flow Troubleshooter

This is a private-preview Agency-style plugin package for trusted personal/internal testing. It is not positioned as a public marketplace product yet.

## Contents

```text
plugins\
  marketplace.json
  power-automate-flow-troubleshooter\
    .claude-plugin\plugin.json
    agency.json
    README.md
    agents\power-automate-flow-troubleshooter.md
    skills\power-automate-flow-troubleshooting\SKILL.md
    tools\power-automate-flow-tools\scripts\Get-FlowRunDiagnostics.ps1
```

## Required setup

### 1. Install/import Power Platform PowerShell prerequisites

Loading this plugin does not install Microsoft PowerApps PowerShell cmdlets. Live diagnostics require the runtime environment to provide:

- `Add-PowerAppsAccount`
- `Get-JwtToken`
- `InvokeApiNoParseContent`

Typical modules:

- `Microsoft.PowerApps.Administration.PowerShell`
- `Microsoft.PowerApps.PowerShell`

Typical setup:

```powershell
Install-Module Microsoft.PowerApps.Administration.PowerShell -Scope CurrentUser
Install-Module Microsoft.PowerApps.PowerShell -Scope CurrentUser
Import-Module Microsoft.PowerApps.Administration.PowerShell
Import-Module Microsoft.PowerApps.PowerShell
Add-PowerAppsAccount
```

Use your organization's approved module-install process if direct `Install-Module` is restricted.

### 2. Verify prerequisites

```powershell
Get-Command Add-PowerAppsAccount
Get-Command Get-JwtToken
Get-Command InvokeApiNoParseContent
```

If any command is missing, live diagnostics will fail before any Flow API call is attempted.

### 3. Configure flow profiles

Before first use, configure flow profiles using:

```text
skills\power-automate-flow-troubleshooting\references\flow-profile-template.md
```

Each profile must define the environment ID, flow ID, display name, auth prerequisites, and whether the flow is scheduled.

### 4. First run test

Use a specific Power Automate run URL:

```powershell
.\plugins\power-automate-flow-troubleshooter\tools\power-automate-flow-tools\scripts\Get-FlowRunDiagnostics.ps1 -RunUrl "<Power Automate run URL>"
```

The script is read-only. It reuses the signed-in user's Power Platform session or prompts through `Add-PowerAppsAccount`.

## Trigger examples

- "List recent runs for my configured Power Automate flow."
- "Diagnose this Power Automate run URL."
- "Troubleshoot this PA flow failure."
