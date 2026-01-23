param(
  [string]$FilePath = "_data/i18n.yml",
  [string]$Branch = "main",
  [string]$Remote = "origin",
  [string]$CommitMessage = "fix(i18n): save _data/i18n.yml as UTF-8 without BOM"
)

$ErrorActionPreference = "Stop"

function Fail([string]$msg, [int]$code = 1) {
  Write-Error $msg
  exit $code
}

try {
  Write-Host "Starting commit script (debug)...

"

  # Ensure running from repo root
  $cwd = Get-Location
  Write-Host "Working directory: $cwd"

  if (-not (Test-Path $FilePath)) {
    Fail "File not found: $FilePath. Run this script from the repository root or provide --FilePath."
  }

  # Ensure git exists
  if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Fail "git not found in PATH. Install git or add it to PATH."
  }

  # Show git top-level (sanity)
  $gitTop = git rev-parse --show-toplevel 2>&1
  if ($LASTEXITCODE -ne 0) {
    Fail "Not a git repository or git failed: `n$gitTop"
  }
  Write-Host "Git top-level: $gitTop"

  # Create BOM-free temporary copy
  $temp = "$FilePath.tmp"
  Write-Host "Writing BOM-free copy to $temp"
  $content = Get-Content -Raw -Path $FilePath
  $content | Out-File -FilePath $temp -Encoding utf8NoBOM

  # Replace only if different (avoid unnecessary commits)
  $origHash = Get-FileHash -Path $FilePath -Algorithm SHA256
  $tmpHash  = Get-FileHash -Path $temp -Algorithm SHA256
  if ($origHash.Hash -ne $tmpHash.Hash) {
    Write-Host "File differs after BOM removal — replacing original file."
    Move-Item -Force $temp $FilePath
  } else {
    Remove-Item -Force $temp
    Write-Host "No changes needed (file already UTF-8 no BOM)."
  }

  Write-Host "`n--- Git status (before) ---"
  git status --porcelain
  Write-Host "--------------------------`n"

  Write-Host "Staging $FilePath"
  & git add $FilePath
  if ($LASTEXITCODE -ne 0) { Fail "git add failed" }

  Write-Host "Staged files:"
  & git diff --cached --name-only

  # If nothing staged for this path, exit gracefully
  $staged = git diff --cached --name-only | Select-String -Pattern [regex]::Escape($FilePath)
  if (-not $staged) {
    Write-Host "No changes staged for $FilePath — nothing to commit."
    exit 0
  }

  Write-Host "Committing..."
  $commitOutput = git commit -m $CommitMessage 2>&1
  Write-Host $commitOutput
  if ($LASTEXITCODE -ne 0) {
    Fail "git commit failed. See output above."
  }

  Write-Host "Pushing to $Remote/$Branch..."
  $pushOutput = git push $Remote $Branch 2>&1
  Write-Host $pushOutput
  if ($LASTEXITCODE -ne 0) {
    Fail "git push failed. Common causes: authentication, wrong remote/branch, or network issues."
  }

  Write-Host "`nSuccess: committed and pushed $FilePath to $Remote/$Branch"
  exit 0
}
catch {
  Write-Error "`nException: $($_.Exception.Message)"
  if ($_.InvocationInfo.PositionMessage) { Write-Error $_.InvocationInfo.PositionMessage }
  exit 1
}