# Setup-AIDelivery.ps1
# Installs AI-Delivery on this machine. Asks for every variable up front,
# then builds the folders, writes the config, clones the staging repo,
# installs the tools, and (optionally) creates the sync scheduled task.
#
# Run from the folder you cloned the AI-Delivery package into:
#   powershell -ExecutionPolicy Bypass -File Setup-AIDelivery.ps1
#
# NOTHING is deleted. Existing folders and files are left alone; the
# setup only adds what is missing or refreshes the tool files it owns.

$ErrorActionPreference = "Stop"
$pkg = Split-Path -Parent $MyInvocation.MyCommand.Path

function Ask([string]$Prompt, [string]$Default) {
    $answer = Read-Host "$Prompt [$Default]"
    if ([string]::IsNullOrWhiteSpace($answer)) { return $Default }
    return $answer.Trim()
}

Write-Host ""
Write-Host "=== AI-Delivery setup ==="
Write-Host "Press Enter to accept the [default] for any question."
Write-Host ""

# --- prerequisites ----------------------------------------------------------
foreach ($tool in @("git", "python")) {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
        Write-Host "MISSING PREREQUISITE: '$tool' is not on PATH. Install it, then run setup again."
        exit 1
    }
}
Write-Host "git and python found."
Write-Host ""

# --- variables --------------------------------------------------------------
$defaultBase = Join-Path $env:USERPROFILE "AI-Delivery"
$base = Ask "Base folder for AI-Delivery" $defaultBase

Write-Host ""
Write-Host "Staging repo address: PASTE it, do not type it from memory."
Write-Host "A retyped address once picked up an invisible extra character"
Write-Host "and failed for hours while the pasted one worked. Paste is truth."
$repoUrl = Ask "Git address of the staging repo (https://...git)" ""
if ([string]::IsNullOrWhiteSpace($repoUrl)) {
    Write-Host "A staging repo address is required. Setup stopped; nothing was changed."
    exit 1
}
$branch = Ask "Staging repo branch" "main"
$modelsCsv = Ask "Model boxes to create (comma-separated)" "Muse,Grok-Bot,ChatGPT,Caeled"
$stagingModel = Ask "Which model's boxes does the git sync bridge?" "Muse"
$interval = Ask "Sync interval in minutes" "5"
$wantTask = Ask "Create the scheduled sync task? (Y/N)" "Y"
$wantRouter = Ask "Install the web router tool at the base folder? (Y/N)" "Y"

$models = $modelsCsv -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }

# --- folders ----------------------------------------------------------------
foreach ($kind in @("Inbox", "Outbox")) {
    foreach ($m in $models) {
        New-Item -ItemType Directory -Force -Path (Join-Path $base "$kind\$m") | Out-Null
    }
}
$scriptsDir = Join-Path $base "Scripts"
New-Item -ItemType Directory -Force -Path $scriptsDir, (Join-Path $base "Archive") | Out-Null
Write-Host ""
Write-Host "Folders ready under $base"

# --- repo url + config ------------------------------------------------------
# The URL is stored exactly as pasted (whitespace trimmed) and read as
# bytes by the sync at runtime. Scripts never contain the address typed
# out in their source.
$urlPath = Join-Path $scriptsDir "repo-url.txt"
Set-Content -Path $urlPath -Value $repoUrl -Encoding ASCII -NoNewline
$storedBytes = (Get-Item $urlPath).Length
Write-Host "repo-url.txt written ($storedBytes bytes, exactly as pasted)."

$config = [ordered]@{
    basePath     = $base
    stagingModel = $stagingModel
    branch       = $branch
}
$config | ConvertTo-Json | Set-Content -Path (Join-Path $scriptsDir "aidelivery-config.json") -Encoding UTF8
Write-Host "aidelivery-config.json written."

# --- validate the staging repo using the stored bytes -----------------------
Write-Host ""
Write-Host "Testing the staging repo address from repo-url.txt..."
git ls-remote (Get-Content $urlPath -Raw) | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "git could not reach that address. Check what was pasted and run setup again."
    exit 1
}
Write-Host "Staging repo answers. Good."

# --- tools ------------------------------------------------------------------
Copy-Item (Join-Path $pkg "tools\Sync-AIDelivery.ps1") (Join-Path $scriptsDir "Sync-AIDelivery.ps1") -Force
Copy-Item (Join-Path $pkg "tools\Move-AIDelivery.ps1") (Join-Path $scriptsDir "Move-AIDelivery.ps1") -Force
Write-Host "Sync and console mover installed in Scripts\."
if ($wantRouter -eq "Y") {
    Copy-Item (Join-Path $pkg "tools\ai-delivery-router.py") (Join-Path $base "ai-delivery-router.py") -Force
    Copy-Item (Join-Path $pkg "tools\Run-AIDeliveryRouter.bat") (Join-Path $base "Run-AIDeliveryRouter.bat") -Force
    Write-Host "Web router installed at the base folder (lives one level above the boxes)."
}

# --- scheduled task -----------------------------------------------------------
if ($wantTask -eq "Y") {
    $taskName = "AI-Delivery-Sync"
    $action = New-ScheduledTaskAction -Execute "powershell.exe" `
        -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptsDir\Sync-AIDelivery.ps1`""
    $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) `
        -RepetitionInterval (New-TimeSpan -Minutes ([int]$interval))
    $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger `
        -Settings $settings -Force | Out-Null
    Write-Host "Scheduled task '$taskName' created: sync every $interval minutes."
}

# --- first sync + summary -----------------------------------------------------
Write-Host ""
Write-Host "Running the sync once now..."
& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $scriptsDir "Sync-AIDelivery.ps1")
Write-Host "Sync run finished (LastExitCode $LASTEXITCODE)."

Write-Host ""
Write-Host "=== AI-Delivery is installed ==="
Write-Host "Base folder : $base"
Write-Host "Boxes       : $($models -join ', ') (Inbox and Outbox each)"
Write-Host "Sync bridge : $stagingModel <-> staging repo, every $interval minutes"
Write-Host "Router      : run Run-AIDeliveryRouter.bat in the base folder, open http://127.0.0.1:8765"
Write-Host ""
Write-Host "Next step: open the prompts folder in this package and hand each"
Write-Host "model its setup prompt (01 for Muse, 02 for Grok, 03 for"
Write-Host "ChatGPT, 04 is the template for any new model)."
