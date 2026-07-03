# Power Automate Flow Troubleshooter

> **Status:** v0.1.0 private-preview plugin workspace  
> **For:** operators and engineers who need to inspect Power Automate flow runs without guessing which run failed

Power Automate Flow Troubleshooter packages a repeatable, PowerShell-backed workflow for listing recent flow runs and diagnosing a specific run from its Power Automate portal URL.

The source idea was extracted from an internal operator workflow that used two explicit modes:

- `list` — show recent runs with status, start time, duration, and portal URL
- `diagnose` — inspect one specific run, including failed actions, skipped actions, inputs/outputs links, and loop repetition failures

The product version must be configured by the user. Flow environment IDs, flow IDs, tenant-specific URLs, and local paths belong in user configuration, not in the reusable plugin logic.

## Prerequisites

This private-preview plugin assumes PowerShell. Loading the plugin does not install Microsoft Power Platform authentication cmdlets. Live diagnostics require the user's machine/session to have supported Microsoft PowerApps PowerShell modules available.

Required commands:

- `Add-PowerAppsAccount`
- `Get-JwtToken`
- `InvokeApiNoParseContent`

Typical module dependencies:

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

Organizations may require an approved software-install path instead of direct `Install-Module`. The plugin should fail clearly if these commands are unavailable; it should not silently install modules, bypass policy, or embed credentials.

Verify prerequisites:

```powershell
Get-Command Add-PowerAppsAccount
Get-Command Get-JwtToken
Get-Command InvokeApiNoParseContent
```

## Security and access model

Power Automate Flow Troubleshooter uses a delegated user-auth model. The plugin should not ship credentials, tenant IDs, environment IDs, flow IDs, run IDs, cookies, tokens, or service-account secrets.

For diagnose mode, the intended flow is:

1. The user provides a specific Power Automate run URL.
2. The plugin parses the URL for environment ID, flow ID, and run ID.
3. The runtime checks whether the user already has a local Power Platform authentication session.
4. If no session exists, the runtime may open an interactive Microsoft sign-in through supported Power Platform tooling.
5. The user signs in with their own Entra ID account.
6. Power Automate authorizes the API calls based on that user's rights to the environment, flow, and run history.
7. The plugin performs read-only diagnostics against the run and action endpoints.
8. The plugin redacts or summarizes sensitive action inputs and outputs by default.

The token audience used by the Power Automate service is commonly `https://service.flow.microsoft.com/`; this is not Microsoft-internal-specific. The API endpoint is commonly `https://api.flow.microsoft.com/...`. Access is still controlled by the customer's tenant, environment governance, Conditional Access policies, DLP policies, and the signed-in user's Power Automate permissions.

This model can work for external commercial Power Automate customers when their tenant allows the required Power Platform API access and the signed-in user has permission to read the target flow run. It may need adaptation for sovereign clouds, tenant policies that block PowerShell/API access, managed environments with stricter governance, or users who lack owner/co-owner/admin rights.

## What it does

- Lists recent Power Automate flow runs for a configured flow.
- Diagnoses a specific flow run from a portal run URL.
- Extracts environment ID, flow ID, and run ID from supported Power Automate run URLs.
- Fetches run summary, action summary, failed actions, skipped actions, and successful actions.
- Drills into loop repetitions when a run fails but top-level actions appear successful.
- Produces an operator-facing diagnosis prompt so an AI assistant can categorize failures.
- Avoids the dangerous "just diagnose latest run" pattern for flows that run on a schedule.

## Why it is useful

Scheduled Power Automate flows can run frequently. If an operator says "the flow failed," diagnosing the latest run can easily inspect the wrong run. This plugin makes the operator choose either:

1. list recent runs, then pick the correct run URL; or
2. diagnose a specific provided run URL.

That explicit workflow reduces wrong-run analysis and gives operators a consistent troubleshooting path.

## What this is not

- It is not a generic Power Platform administration suite.
- It does not change, trigger, enable, or disable flows.
- It does not automatically inspect every flow in an environment.
- It does not claim to work until the user configures flow profiles.
- It does not ship tenant-specific flow IDs as reusable product logic.
- It does not bypass Power Automate permissions or tenant policy.
- It does not use Microsoft-internal credentials or hidden access.
- It is not runtime-neutral; the current private-preview implementation is PowerShell-backed.
- It does not replace the Power Automate portal for full run-history exploration.

## Package structure

```text
marketplace\agency-plugin-bundle\
  INSTALL.md
  plugins\
    marketplace.json
    power-automate-flow-troubleshooter\
      .claude-plugin\plugin.json
      agency.json
      package.json
      owners.txt
      CHANGELOG.md
      README.md
      agents\power-automate-flow-troubleshooter.md
      skills\power-automate-flow-troubleshooting\SKILL.md
      skills\power-automate-flow-troubleshooting\references\
      tools\power-automate-flow-tools\
      tools\power-automate-flow-tools\scripts\Get-FlowRunDiagnostics.ps1
```

## Source extraction

Raw source extracts are local-only reference material and are ignored by default. They may contain project-specific environment IDs, flow IDs, run IDs, URLs, action names, or operational assumptions. Do not package, publish, commit, or use those files as reusable product logic.

The productized package keeps only the general pattern:

- explicit `list` mode
- explicit `diagnose` mode
- user-configured flow profiles
- run URL parsing
- action and loop-repetition inspection
- redacted operator-facing diagnosis output

Productized logic should use:

```text
marketplace\agency-plugin-bundle\plugins\power-automate-flow-troubleshooter\skills\power-automate-flow-troubleshooting\references\flow-profile-template.md
```

Runtime tools should follow:

```text
marketplace\agency-plugin-bundle\plugins\power-automate-flow-troubleshooter\tools\power-automate-flow-tools\IMPLEMENTATION_CONTRACT.md
```

## Suggested trigger examples

- "List recent Power Automate flow runs."
- "Diagnose this Power Automate flow run URL."
- "Troubleshoot this PA flow failure."
- "Run Power Automate Flow Troubleshooter in diagnose mode."
