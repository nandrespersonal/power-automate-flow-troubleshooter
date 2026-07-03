# Flow profile template

Power Automate Flow Troubleshooter requires user-configured flow profiles.

Do not ship tenant-specific IDs in productized plugin logic.

## Markdown profile format

```markdown
## <profile-name>

Display name:
<friendly flow name>

Environment ID:
<power-platform-environment-id>

Flow ID:
<flow-id>

Portal base:
https://make.powerautomate.com

Schedule:
<manual | scheduled | recurrence>

Auth prerequisites:
<PowerApps module, pac CLI, browser auth, service account, etc.>

Default list count:
10

Safety notes:
<for example: runs every 15 minutes; do not auto-diagnose latest run>
```

## JSON-style profile shape

```json
{
  "profiles": [
    {
      "name": "production-flow",
      "displayName": "Production Flow",
      "environmentId": "user-provided-environment-id",
      "flowId": "user-provided-flow-id",
      "portalBase": "https://make.powerautomate.com",
      "schedule": "scheduled",
      "authPrerequisites": [
        "Microsoft.PowerApps.Administration.PowerShell",
        "Power Platform login"
      ],
      "defaultTop": 10,
      "safetyNotes": [
        "Do not auto-diagnose latest run; user must choose a run URL."
      ]
    }
  ]
}
```

