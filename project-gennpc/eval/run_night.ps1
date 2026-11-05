param(
    [string]$Godot = (Join-Path $env:USERPROFILE "OneDrive\Desktop\Godot\Godot_v4.7.1-stable_win64.exe"),
    [int]$Runs = 3,
    [int]$DailyLimit = 490,
    [switch]$Plan
)

$Proj = Split-Path $PSScriptRoot -Parent
$Results = Join-Path $PSScriptRoot "results"
$Log = Join-Path $Results "night_log.txt"
$TmpDir = Join-Path $env:TEMP "gennpc_night"
New-Item -ItemType Directory -Force $Results | Out-Null
New-Item -ItemType Directory -Force $TmpDir | Out-Null

$Jobs = @(
    @{ Provider = "gemini"; Size = 66; Mode = "full" },
    @{ Provider = "gemini"; Size = 66; Mode = "emb9" },
    @{ Provider = "ollama"; Size = 66; Mode = "full" },
    @{ Provider = "ollama"; Size = 66; Mode = "emb9" }
)

function Write-Log([string]$Message) {
    $line = "[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
    Add-Content -Path $Log -Value $line -Encoding UTF8
    Write-Host $line
}

function Get-DoneFile($Job) {
    $pattern = "big_{0}_{1}_{2}_*.json" -f $Job.Provider, $Job.Size, $Job.Mode
    foreach ($f in Get-ChildItem -Path $Results -Filter $pattern -ErrorAction SilentlyContinue) {
        $complete = Select-String -Path $f.FullName -Pattern '^\t"complete": true' -Quiet
        $runsOk = Select-String -Path $f.FullName -Pattern ('^\t"runs": {0},?$' -f $Runs) -Quiet
        $cardsOk = Select-String -Path $f.FullName -Pattern '^\t"card_count": 66,?$' -Quiet
        if ($complete -and $runsOk -and $cardsOk) { return $f.Name }
    }
    return $null
}

function Test-Ollama {
    try { Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -TimeoutSec 5 | Out-Null; return $true } catch { return $false }
}

function Start-OllamaIfNeeded {
    if (Test-Ollama) { return $true }
    $app = Join-Path $env:LOCALAPPDATA "Programs\Ollama\ollama app.exe"
    if (-not (Test-Path $app)) { return $false }
    Write-Log "Ollama is not running. Starting the Ollama app."
    Start-Process -FilePath $app
    for ($i = 0; $i -lt 60; $i++) {
        Start-Sleep -Seconds 2
        if (Test-Ollama) { return $true }
    }
    return $false
}

if ($Plan) {
    foreach ($job in $Jobs) {
        $done = Get-DoneFile $job
        "{0,-7} {1,-4} {2,-5} {3}" -f $job.Provider, $job.Size, $job.Mode, $(if ($done) { "done: $done" } else { "will run" })
    }
    "Godot found: {0}  Ollama up: {1}" -f (Test-Path $Godot), (Test-Ollama)
    return
}

Add-Type -Namespace GenNpcNight -Name Power -MemberDefinition '[DllImport("kernel32.dll")] public static extern uint SetThreadExecutionState(uint esFlags);'
$ES_CONTINUOUS = [uint32]2147483648
$ES_SYSTEM_REQUIRED = [uint32]1

$nightStart = Get-Date
$totalGemini = 0
Write-Log "===== Night run start (runs=$Runs, daily Gemini limit=$DailyLimit) ====="
[GenNpcNight.Power]::SetThreadExecutionState($ES_CONTINUOUS -bor $ES_SYSTEM_REQUIRED) | Out-Null
try {
    foreach ($job in $Jobs) {
        $name = "{0} size {1} {2}" -f $job.Provider, $job.Size, $job.Mode
        $done = Get-DoneFile $job
        if ($done) {
            Write-Log "SKIP $name (already completed: $done)"
            continue
        }
        if ($job.Provider -eq "ollama" -and -not (Start-OllamaIfNeeded)) {
            Write-Log "FAIL $name (Ollama is not reachable at localhost:11434)"
            continue
        }

        $tag = "{0}_{1}_{2}" -f $job.Provider, $job.Size, $job.Mode
        $out = Join-Path $TmpDir "$tag.out.txt"
        $err = Join-Path $TmpDir "$tag.err.txt"
        $arguments = "--headless --path `"$Proj`" res://eval/big_eval.tscn -- --provider {0} --size {1} --mode {2} --runs={3} --daily-limit {4}" -f $job.Provider, $job.Size, $job.Mode, $Runs, $DailyLimit
        Write-Log "START $name"
        $jobStart = Get-Date
        $proc = Start-Process -FilePath $Godot -ArgumentList $arguments -NoNewWindow -Wait -PassThru -RedirectStandardOutput $out -RedirectStandardError $err
        $code = $proc.ExitCode
        $minutes = ((Get-Date) - $jobStart).TotalMinutes
        $text = @(Get-Content -Path $out -Encoding UTF8 -ErrorAction SilentlyContinue)

        $calls = 0
        $callLine = $text | Where-Object { $_ -match '^GEMINI_CALLS=(\d+)' } | Select-Object -Last 1
        if ($callLine -and $callLine -match '^GEMINI_CALLS=(\d+)') { $calls = [int]$Matches[1] }
        $totalGemini += $calls
        $budgetLine = $text | Where-Object { $_ -like "Gemini budget:*" } | Select-Object -Last 1
        if ($budgetLine) { Write-Log "  $budgetLine" }

        $info = "exit $code, {0:N1} min, Gemini calls $calls" -f $minutes
        switch ($code) {
            0 {
                $saved = $text | Where-Object { $_ -match '^Saved res://eval/results/(big_\S+\.json)$' } | Select-Object -First 1
                $file = if ($saved -and $saved -match '(big_\S+\.json)$') { $Matches[1] } else { "?" }
                Write-Log "DONE $name ($info) -> $file"
            }
            4 { Write-Log "SKIP $name (it could go over the daily Gemini limit of $DailyLimit; $info)" }
            3 {
                Write-Log "STOP $name (self-check failed; $info). Not running anything else."
                $text | Select-Object -Last 20 | ForEach-Object { Write-Log "  | $_" }
            }
            2 {
                $stopLine = $text | Where-Object { $_ -like "STOPPED:*" } | Select-Object -Last 1
                Write-Log "ABORTED $name ($info): $stopLine"
            }
            default {
                Write-Log "FAIL $name ($info). Last lines:"
                $text | Select-Object -Last 15 | ForEach-Object { Write-Log "  | $_" }
                Get-Content -Path $err -Encoding UTF8 -ErrorAction SilentlyContinue | Select-Object -Last 5 | ForEach-Object { Write-Log "  ! $_" }
            }
        }
        if ($code -eq 3) { break }
    }
}
finally {
    [GenNpcNight.Power]::SetThreadExecutionState($ES_CONTINUOUS) | Out-Null
    Remove-Item -Path $TmpDir -Recurse -Force -ErrorAction SilentlyContinue
    $total = ((Get-Date) - $nightStart).TotalMinutes
    Write-Log ("===== Night run end ({0:N1} min, Gemini calls {1}) =====" -f $total, $totalGemini)
}
