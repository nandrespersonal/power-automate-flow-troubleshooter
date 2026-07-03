# Security

Power Automate Flow Troubleshooter is a private-preview plugin package for operator-guided flow run diagnostics.

## Boundaries

- Users must configure their own flow profiles.
- The reusable package should not ship tenant-specific environment IDs or flow IDs as defaults.
- The reusable package must not ship credentials, cookies, tokens, tenant secrets, or service-account configuration.
- Authentication should be delegated to the current user's Power Platform session.
- Authorization is controlled by Power Automate based on the signed-in user's rights.
- The tool should fail clearly if the user cannot read the environment, flow, or run history.
- Runtime operations for this package are read-only diagnostics; they should not trigger, enable, disable, update, or delete flows.
- The current private-preview runtime assumes PowerShell and Microsoft PowerApps PowerShell modules.
- Diagnose output may include action inputs, outputs, URLs, or error payloads that can contain sensitive operational data.
- Assistants should redact or summarize sensitive fields before sharing output outside the troubleshooting context.

## External customer applicability

The same delegated-user model can apply to commercial Power Automate customers when their tenant permits the required API access and the signed-in user has the necessary flow permissions. Sovereign clouds, Conditional Access policy, tenant restrictions, DLP policy, and managed-environment governance may require endpoint or auth-flow adaptation.

## Reporting

Report security concerns through the repository issue process once the package is published.
