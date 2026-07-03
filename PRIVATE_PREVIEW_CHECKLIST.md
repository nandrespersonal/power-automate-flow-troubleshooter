# Private preview checklist

Use this checklist before testing the plugin with a first private customer flow.

## 1. Confirm runtime assumptions

- PowerShell is available.
- Microsoft PowerApps PowerShell modules are installed or available through the approved install path.
- These commands resolve:

```powershell
Get-Command Add-PowerAppsAccount
Get-Command Get-JwtToken
Get-Command InvokeApiNoParseContent
```

## 2. Authenticate as the customer user

```powershell
Add-PowerAppsAccount
```

The plugin uses delegated user access. It should read only what the signed-in user can read in Power Automate.

## 3. Use a specific run URL

Do not diagnose "latest run" for scheduled flows. Start with a specific run URL from the Power Automate portal.

```powershell
.\marketplace\agency-plugin-bundle\plugins\power-automate-flow-troubleshooter\tools\power-automate-flow-tools\scripts\Get-FlowRunDiagnostics.ps1 -RunUrl "<Power Automate run URL>"
```

## 4. Keep output local by default

Default output does not expand action inputs or outputs. Use `-RawLocalOutput` only when troubleshooting locally and do not paste raw payloads into broad channels.

## 5. Expected result

The helper should return JSON with:

- parsed environment ID, flow ID, and run ID
- run status
- action summary
- failed actions
- skipped actions
- loop/scope repetition findings
- likely failure category
- safety note

## 6. Failure interpretation

| Failure | Meaning |
| --- | --- |
| Missing command | PowerApps PowerShell prerequisites are not installed/imported. |
| Auth prompt appears | No reusable Power Platform session exists; sign in as the customer user. |
| 401/403 | The signed-in user cannot read this environment, flow, or run history. |
| Unsupported URL | The run URL shape is not currently parsed by the helper. |
| Empty repetition findings | No failed loop/scope repetitions were found or the endpoint is unavailable for those actions. |

