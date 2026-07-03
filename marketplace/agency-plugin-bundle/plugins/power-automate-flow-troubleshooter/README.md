# Power Automate Flow Troubleshooter

Power Automate Flow Troubleshooter is a private-preview, PowerShell-backed plugin that helps operators list recent flow runs and diagnose a specific Power Automate run URL.

## Prerequisites

The plugin assumes PowerShell. It does not install Microsoft Power Platform authentication cmdlets. Live diagnostics require supported PowerApps PowerShell modules in the user's environment.

Required commands:

- `Add-PowerAppsAccount`
- `Get-JwtToken`
- `InvokeApiNoParseContent`

Typical setup:

```powershell
Install-Module Microsoft.PowerApps.Administration.PowerShell -Scope CurrentUser
Install-Module Microsoft.PowerApps.PowerShell -Scope CurrentUser
Import-Module Microsoft.PowerApps.Administration.PowerShell
Import-Module Microsoft.PowerApps.PowerShell
Add-PowerAppsAccount
```

If these commands are unavailable, the tool must fail with a clear prerequisite error. It must not silently install modules or bypass organization policy.

Verify prerequisites:

```powershell
Get-Command Add-PowerAppsAccount
Get-Command Get-JwtToken
Get-Command InvokeApiNoParseContent
```

## Security model

This plugin is designed for delegated user access:

1. User provides a specific Power Automate run URL.
2. The plugin parses environment ID, flow ID, and run ID from the URL.
3. The runtime reuses the user's existing Power Platform auth session or initiates interactive Microsoft sign-in.
4. Power Automate authorizes read access based on the signed-in user's permissions.
5. The plugin performs read-only diagnostics and redacts sensitive action payloads by default.

The plugin must not include bundled credentials, shared service accounts, tenant secrets, hardcoded environment IDs, hardcoded flow IDs, or hardcoded run IDs. It does not bypass tenant policy or Power Automate permissions.

This can work for external commercial Power Automate customers when their tenant permits the required API calls and the signed-in user has rights to the target environment, flow, and run history. Sovereign cloud endpoints, Conditional Access, DLP policy, managed-environment governance, or missing flow permissions may require adaptation or may block access.

## What it does

- Lists recent runs for a configured flow.
- Diagnoses one provided run URL.
- Summarizes run status, duration, action counts, failed actions, and skipped actions.
- Drills into loop repetitions for hidden failures.
- Guides an AI assistant to classify likely failure categories.

## What it does not do

- It does not trigger, enable, disable, or modify flows.
- It does not ship tenant-specific flow IDs as product defaults.
- It does not ship credentials or service-account secrets.
- It does not bypass Power Automate permissions.
- It is not runtime-neutral; the current private-preview implementation is PowerShell-backed.
- It does not auto-diagnose the latest run.
- It does not replace the Power Automate portal.

## Runtime helper

```powershell
.\tools\power-automate-flow-tools\scripts\Get-FlowRunDiagnostics.ps1 -RunUrl "<Power Automate run URL>"
```

The helper performs read-only GET diagnostics for run details, top-level actions, and loop/scope repetition findings when available.

## Primary skill

`power-automate-flow-troubleshooting`

## Primary agent

`power-automate-flow-troubleshooter`
