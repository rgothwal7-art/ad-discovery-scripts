# Active Directory Discovery Script

This PowerShell script collects Active Directory environment information including:

- Domain information
- Trust relationships
- Domain controllers
- Users
- Service accounts
- Privileged accounts
- Stale accounts
- Computer objects
- GPOs
- Security groups
- Organizational units

## Output
Exports results to:

C:\ADDiscovery\ALLDiscovery.csv

## Requirements
- ActiveDirectory PowerShell module
- GroupPolicy module
- Domain read permissions

## Usage
Run the script from a domain controller or management server:

powershell -ExecutionPolicy Bypass -File AD-Discovery.ps1
