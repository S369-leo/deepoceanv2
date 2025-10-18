param(
  [switch]$FailFast
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Invoke-Step {
  param(
    [Parameter(Mandatory)] [string]$Title,
    [Parameter(Mandatory)] [string[]]$Command
  )

  Write-Host "==> $Title" -ForegroundColor Cyan
  & $Command
  if ($LASTEXITCODE -ne 0) {
    if ($FailFast) {
      throw "Step '$Title' failed with exit code $LASTEXITCODE"
    }
    exit $LASTEXITCODE
  }
}

Invoke-Step -Title 'flutter analyze' -Command @('flutter', 'analyze')
Invoke-Step -Title 'flutter test' -Command @('flutter', 'test')
Invoke-Step -Title 'flutter test integration_test' -Command @('flutter', 'test', 'integration_test')

Write-Host 'All checks passed.' -ForegroundColor Green