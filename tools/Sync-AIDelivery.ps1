# Sync-AIDelivery.ps1
# Bridges ONE model's AI-Delivery boxes to the git staging repo.
# Behavior matches the deployed bridge (transfer-log format included):
#   - Reads the staging repo address from repo-url.txt in this folder,
#     as raw bytes at runtime. NEVER retype the address from reading it:
#     a retyped address once picked up an invisible extra character and
#     every check 404'd for hours while pasted addresses worked.
#   - Inbound:  files in <repo>\ai-delivery\inbox\  -> <base>\Inbox\<MODEL>\
#   - Outbound: files in <base>\Outbox\<MODEL>\     -> <repo>\ai-delivery\outbox\  (commit + push)
#   - Copies only when the file is missing or its SHA-256 differs.
#     Never deletes anything on either side.
#   - Logs one line per transfer to <base>\Inbox\<MODEL>\transfer-log.txt:
#       yyyy-MM-dd HH:mm:ss <filename> in
#       yyyy-MM-dd HH:mm:ss <filename> out
# Config lives in aidelivery-config.json in this same folder, written by
# Setup-AIDelivery.ps1: { basePath, stagingModel, branch }.
# Runs unattended from Task Scheduler every N minutes. No prompts.

$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

$configPath = Join-Path $here "aidelivery-config.json"
if (-not (Test-Path $configPath)) { throw "Missing config: $configPath -- run Setup-AIDelivery.ps1 first." }
$config = Get-Content $configPath -Raw | ConvertFrom-Json
$base   = $config.basePath
$model  = $config.stagingModel
$branch = $config.branch
if (-not $branch) { $branch = "main" }

$urlFile = Join-Path $here "repo-url.txt"
if (-not (Test-Path $urlFile)) { throw "Missing $urlFile -- run Setup-AIDelivery.ps1 first." }
$repoUrl = (Get-Content $urlFile -Raw).Trim()

$clone = Join-Path $here "_staging-clone"
$inboxLocal  = Join-Path $base "Inbox\$model"
$outboxLocal = Join-Path $base "Outbox\$model"
$logPath = Join-Path $inboxLocal "transfer-log.txt"
New-Item -ItemType Directory -Force -Path $inboxLocal, $outboxLocal | Out-Null

function Log-Transfer([string]$Name, [string]$Direction) {
    $stamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logPath -Value "$stamp $Name $Direction" -Encoding UTF8
}

# --- get a clean, current clone --------------------------------------------
if (-not (Test-Path (Join-Path $clone ".git"))) {
    if (Test-Path $clone) { Remove-Item $clone -Recurse -Force }
    git clone --quiet --branch $branch $repoUrl $clone
    if ($LASTEXITCODE -ne 0) { throw "git clone failed for the staging repo in repo-url.txt" }
} else {
    git -C $clone checkout --quiet $branch
    git -C $clone pull --quiet --rebase origin $branch
    if ($LASTEXITCODE -ne 0) { throw "git pull failed" }
}
$stageInbox  = Join-Path $clone "ai-delivery\inbox"
$stageOutbox = Join-Path $clone "ai-delivery\outbox"
New-Item -ItemType Directory -Force -Path $stageInbox, $stageOutbox | Out-Null

# --- inbound: staging inbox -> local Inbox ----------------------------------
foreach ($f in (Get-ChildItem $stageInbox -File)) {
    $dest = Join-Path $inboxLocal $f.Name
    $needs = $true
    if (Test-Path $dest) {
        $needs = (Get-FileHash $dest).Hash -ne (Get-FileHash $f.FullName).Hash
    }
    if ($needs) {
        Copy-Item $f.FullName $dest -Force
        Log-Transfer $f.Name "in"
    }
}

# --- outbound: local Outbox -> staging outbox, then push --------------------
$changed = $false
foreach ($f in (Get-ChildItem $outboxLocal -File)) {
    $dest = Join-Path $stageOutbox $f.Name
    $needs = $true
    if (Test-Path $dest) {
        $needs = (Get-FileHash $dest).Hash -ne (Get-FileHash $f.FullName).Hash
    }
    if ($needs) {
        Copy-Item $f.FullName $dest -Force
        Log-Transfer $f.Name "out"
        $changed = $true
    }
}
if ($changed) {
    git -C $clone add ai-delivery/outbox
    git -C $clone commit --quiet -m "AI-Delivery: outbox sync"
    git -C $clone push --quiet origin $branch
    if ($LASTEXITCODE -ne 0) { throw "git push failed" }
}
