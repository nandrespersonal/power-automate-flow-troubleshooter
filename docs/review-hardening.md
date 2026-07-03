# Review hardening

This package applies the same packaging lessons learned from prior plugin work.

## Applied checks

| Risk | Mitigation |
| --- | --- |
| Hardcoded flow IDs in product logic | Flow IDs are described as user profile configuration, not reusable package defaults. |
| Raw proprietary source extracts | `source-extract\` is local-only and ignored by default; product logic must use sanitized contracts/templates. |
| Fake CLI/runtime claims | The package is positioned as plugin/skill/agent guidance until a real runtime tool is implemented. |
| Weak README | README leads with what the plugin does, why it matters, modes, setup boundary, and non-goals. |
| Mixed personal data and reusable logic | Source extracts are separated from product references and labeled as reference-only. |
| Wrong-run diagnosis | Skill requires explicit `list` or `diagnose` mode and does not auto-diagnose latest run. |
| Repo-relative runtime assumptions | Product references describe configuration files and user setup, not hidden repo-relative assumptions. |
