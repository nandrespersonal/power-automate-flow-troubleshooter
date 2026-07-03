# Power Automate flow tools

This folder contains the private-preview PowerShell-backed runtime helper.

The current package is a skill/agent orchestration package plus a read-only diagnostic helper.

Raw copied source scripts are local-only reference material and must not be copied into this folder. Runtime tools added here must be implemented from the sanitized contract in `IMPLEMENTATION_CONTRACT.md`.

## Helper

```powershell
.\scripts\Get-FlowRunDiagnostics.ps1 -RunUrl "<Power Automate run URL>"
```

The helper assumes PowerShell and Microsoft PowerApps PowerShell module prerequisites. It performs read-only run/action diagnostics and includes loop/scope repetition findings when available.
