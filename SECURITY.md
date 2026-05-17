# Security Policy

## Supported Versions

The `main` branch is the supported development version.

## Reporting A Vulnerability

Please report security issues privately through GitHub Security Advisories when
the repository is published. Avoid opening public issues with exploit details.

## Security Notes

XiexiePet is designed to be local-only:

- No network requests are made by the app.
- No analytics or telemetry are collected.
- No personal documents or user content are read.
- The app reads only limited system state used for pet behavior, including CPU
  load, battery/power source state, low power mode, and thermal state.

When reviewing changes, pay special attention to new networking, file-system,
process-launching, scripting, or update mechanisms.
