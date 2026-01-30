# PowerShell script to validate ShellCheck installation and run a test

Write-Host "Checking ShellCheck installation..."

$shellcheck = Get-Command shellcheck -ErrorAction SilentlyContinue
if ($null -eq $shellcheck) {
    Write-Host "ShellCheck is NOT installed or not in PATH." -ForegroundColor Red
    exit 1
}

Write-Host "ShellCheck found at: $($shellcheck.Source)"

# Create a temporary shell script for testing
$testScript = "$env:TEMP\shellcheck_test.sh"
@'
#!/bin/sh
echo "Hello, world!"
VAR=1
if [ $VAR -eq 1 ]; then
  echo "VAR is 1"
fi
'@ | Set-Content -Path $testScript -Encoding UTF8

Write-Host "Running ShellCheck on a test script..."
shellcheck $testScript

Remove-Item $testScript
Write-Host "ShellCheck validation complete."
