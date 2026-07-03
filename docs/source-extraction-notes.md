# Source extraction notes

This workspace was created by extracting Power Automate flow troubleshooting concepts from a project-specific internal source repository.

The source repository was not modified.

## Source artifacts copied locally

```text
source-extract\scripts\Get-RecentFlowRuns.ps1
source-extract\scripts\Diagnose-FlowRunError.ps1
source-extract\scripts\Get-FlowRunDetails.ps1
source-extract\scripts\Get-FlowRunActions.ps1
```

These files are local-only reference extracts. They are intentionally ignored by `.gitignore` because they may contain project-specific data. Do not publish them, package them, or treat them as reusable runtime logic.

## Important source lessons

- Use two explicit modes: `list` and `diagnose`.
- Never auto-diagnose "latest run" for scheduled flows; wrong-run risk is high.
- Diagnose mode should require a run URL.
- Run URL parsing should support both `/flows/shared/<flowId>/runs/<runId>` and `/flows/<flowId>/runs/<runId>`.
- `InvokeApiNoParseContent` is preferred for Flow GET calls because wrapper parsing can hang or behave poorly.
- A failed run can have zero failed top-level actions; loop repetitions may contain the real failure.
- Operator output should include enough detail for an AI assistant to categorize the failure.

## Productization boundary

Copied scripts may contain environment-specific IDs and operational assumptions. Productized packages must move those values into user setup/profile configuration.

The reusable package should preserve concepts only:

- mode separation
- run URL parsing
- profile-driven environment/flow selection
- safe API access patterns
- failed/skipped/action summary
- loop repetition inspection
- redacted diagnostic output

It must not preserve proprietary identifiers, credentials, tenant assumptions, flow-specific action names, or project-specific escalation paths.
