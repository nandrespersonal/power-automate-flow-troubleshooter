# Proprietary data boundary

This package is intended to productize a troubleshooting pattern, not a private project flow.

## Local-only material

`source-extract\` is local-only reference material. It may contain proprietary information from the project flow that inspired the package. It is ignored by default and must not be committed, packaged, zipped, or published.

## Reusable material

Reusable package logic may include:

- workflow concepts
- mode names
- run URL parsing rules
- generic failure categories
- profile templates
- diagnostic output structure
- safety requirements

Reusable package logic must not include:

- credentials
- tenant IDs
- environment IDs
- flow IDs
- run IDs
- private URLs
- user names
- private team names
- private flow action names
- project-specific escalation paths

## Configuration model

Users provide their own Power Automate flow details through local configuration, following:

```text
marketplace\agency-plugin-bundle\plugins\power-automate-flow-troubleshooter\skills\power-automate-flow-troubleshooting\references\flow-profile-template.md
```

