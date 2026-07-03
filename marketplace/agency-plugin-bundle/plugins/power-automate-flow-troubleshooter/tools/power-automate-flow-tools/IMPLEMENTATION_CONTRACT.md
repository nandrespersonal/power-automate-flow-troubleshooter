# Power Automate flow tools implementation contract

Runtime tools must implement the generic troubleshooting pattern without embedding user-, tenant-, environment-, or flow-specific values.

The current private-preview implementation is:

```text
scripts\Get-FlowRunDiagnostics.ps1
```

## Required inputs

Tools must accept all operational identifiers as parameters or profile values:

- `environmentId`
- `flowId`
- `runId` or `runUrl`
- `top`
- auth/session context

## Required runtime dependencies

Runtime tools must check for these commands before attempting live diagnostics:

- `Add-PowerAppsAccount`
- `Get-JwtToken`
- `InvokeApiNoParseContent`

These commands are provided by Microsoft PowerApps/Power Platform PowerShell modules, not by the plugin package itself. If the commands are missing, tools must return a clear prerequisite error and must not silently install modules, embed credentials, or attempt an auth workaround.

Tools must not hardcode:

- tenant IDs
- environment IDs
- flow IDs
- run IDs
- user names
- local paths
- credentials
- connector names that are specific to one private flow
- escalation contacts that are specific to one private team

## Supported modes

### list

Lists recent runs for a configured flow profile.

Required output:

- run ID
- status
- start time
- end time
- duration
- portal URL

### diagnose

Diagnoses one explicit run URL or run ID.

Required output:

- parsed environment ID, flow ID, and run ID
- run summary
- action status summary
- failed action details
- skipped action details
- loop repetition failures, when present
- scope repetition failures, when present
- likely failure category
- redacted evidence summary
- recommended operator next action

## URL parsing

Runtime tools should support both common Power Automate URL shapes:

```text
/flows/shared/<flowId>/runs/<runId>
/flows/<flowId>/runs/<runId>
```

If environment ID is not present in the URL, the tool must get it from the selected profile or return a clear error.

## Safety rules

- Do not auto-diagnose the latest run for scheduled flows.
- Do not print credentials, tokens, cookies, or raw authorization headers.
- Treat action inputs and outputs as sensitive by default.
- Redact secrets, access tokens, signed URLs, connection strings, emails, and IDs unless the user explicitly asks for raw local-only output.
- Do not mutate flows.
- Do not trigger flows.
- Do not enable or disable flows.

## Productization rule

Reference source scripts may inspire the algorithm, but runtime tools must be clean-room generalized implementations using this contract and user-supplied profiles.
