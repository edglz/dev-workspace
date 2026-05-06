# Stub for Windows PowerShell 5.1 - sources the PS7+ AllHosts profile.
# Place at: ~\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
$shared = "$env:USERPROFILE\Documents\PowerShell\profile.ps1"
if (Test-Path $shared) { . $shared }
