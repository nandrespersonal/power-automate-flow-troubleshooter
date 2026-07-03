# Power Automate Flow Troubleshooting

Use this skill when the user asks to troubleshoot Power Automate, inspect a flow run, list recent flow runs, diagnose a run URL, analyze run history, or understand why a Power Automate flow failed.

## Purpose

Provide a safe, repeatable workflow for Power Automate run troubleshooting.

## Modes

### list

Use when the user wants recent runs.

Inputs:

- configured flow profile
- optional `top` count

Output:

- run ID
- status
- start time
- end time
- duration
- portal URL

### diagnose

Use when the user provides a specific Power Automate run URL.

Inputs:

- run URL

Output:

- parsed environment ID, flow ID, run ID
- run summary
- action summary
- failed action details
- skipped action summary
- loop repetition failures when top-level failures are absent
- likely failure category
- next operator action

## Required behavior

- Do not auto-diagnose the latest run for scheduled flows.
- Ask the user to pick a run from list output if no run URL is provided.
- Treat inputs, outputs, and URLs as potentially sensitive.
- Redact or summarize sensitive payloads before pasting into broad channels.
- Use live Power Automate APIs only for run history and diagnostics.
- Use exported flow definitions for structural validation.

## Configuration

Before use, the user must configure flow profiles. See:

```text
references\flow-profile-template.md
```

## Runtime helper

For private-preview testing, use the PowerShell-backed helper:

```powershell
tools\power-automate-flow-tools\scripts\Get-FlowRunDiagnostics.ps1 -RunUrl "<Power Automate run URL>"
```

The helper requires PowerShell plus Microsoft PowerApps PowerShell commands:

- `Add-PowerAppsAccount`
- `Get-JwtToken`
- `InvokeApiNoParseContent`

It performs read-only diagnostics for run details, top-level actions, and loop/scope repetition findings when available.

## Source lessons

The workflow was extracted from an operator process that used:

- `Get-RecentFlowRuns.ps1` for list mode
- `Diagnose-FlowRunError.ps1` for diagnose mode
- explicit two-mode selection to avoid wrong-run diagnosis
- loop repetition scanning for hidden failures
