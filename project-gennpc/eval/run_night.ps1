param(
    [ValidateSet("gemini", "ollama")][string]$Lane,
    [string]$Godot = (Join-Path $env:USERPROFILE "OneDrive\Desktop\Godot\Godot_v4.7.1-stable_win64.exe"),
    [int]$Runs = 3,
    [int]$DailyLimit = 490,
    [switch]$Plan
)

$Proj = Split-Path $PSScriptRoot -Parent
$Results = Join-Path $PSScriptRoot "results"
$Log = Join-Path $Results "night_log.txt"
$ResetHour = 2
$CardCount = 66

$LaneJobs = [ordered]@{
    gemini = @(
        @{ Size = 66; Mode = "emb9" },
        @{ Size = 132; Mode = "full" },
        @{ Size = 132; Mode = "emb9" },
        @{ Size = 47; Mode = "full" },
        @{ Size = 47; Mode = "emb9" }
    )
    ollama = @(
        @{ Size = 132; Mode = "emb9" },
        @{ Size = 47; Mode = "emb9" },
        @{ Size = 47; Mode = "full" },
        @{ Size = 132; Mode = "full"; NumCtx = 10240 },
        @{ Size = 264; Mode = "emb9" },
        @{ Size = 264; Mode = "full"; NumCtx = 18432 }
    )
}

$LogMutex = New-Object System.Threading.Mutex($false, "Local\GenNpcNightLog")
$SummaryMutex = New-Object System.Threading.Mutex($false, "Local\GenNpcNightSummary")

function Enter-Lock($Mutex) {
    try { [void]$Mutex.WaitOne() } catch [System.Threading.AbandonedMutexException] { }
}

function Write-Log([string]$Message) {
    $line = "[{0}] [{1}] {2}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Lane, $Message
    Enter-Lock $LogMutex
    try {
        for ($i = 0; $i -lt 10; $i++) {
            try { Add-Content -Path $Log -Value $line -Encoding UTF8 -ErrorAction Stop; break } catch { Start-Sleep -Milliseconds 300 }
        }
    }
    finally { $LogMutex.ReleaseMutex() }
    Write-Host $line
}

function Get-DoneFile([string]$Provider, $Size, [string]$Mode) {
    $pattern = "big_{0}_{1}_{2}_*.json" -f $Provider, $Size, $Mode
    foreach ($f in Get-ChildItem -Path $Results -Filter $pattern -ErrorAction SilentlyContinue) {
        $complete = Select-String -Path $f.FullName -Pattern '^\t"complete": true' -Quiet
        $runsOk = Select-String -Path $f.FullName -Pattern ('^\t"runs": {0},?$' -f $Runs) -Quiet
        $cardsOk = Select-String -Path $f.FullName -Pattern ('^\t"card_count": {0},?$' -f $CardCount) -Quiet
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

function Get-GeminiUsed {
    $out = Join-Path $env:TEMP "gennpc_budget_$PID.txt"
    Start-Process -FilePath $Godot -ArgumentList "--headless --path `"$Proj`" res://eval/big_eval.tscn -- --budget" -NoNewWindow -Wait -RedirectStandardOutput $out | Out-Null
    $text = @(Get-Content -Path $out -Encoding UTF8 -ErrorAction SilentlyContinue)
    Remove-Item -Path $out -Force -ErrorAction SilentlyContinue
    $line = $text | Where-Object { $_ -match '^GEMINI_CALLS_SINCE_RESET=(\d+)' } | Select-Object -Last 1
    if ($line -and $line -match '=(\d+)') { return [int]$Matches[1] }
    return -1
}

if ($Plan) {
    foreach ($name in $LaneJobs.Keys) {
        "Lane {0}:" -f $name
        $i = 0
        foreach ($job in $LaneJobs[$name]) {
            $i++
            $done = Get-DoneFile $name $job.Size $job.Mode
            $extra = if ($job.NumCtx) { " (num_ctx $($job.NumCtx))" } else { "" }
            "  {0}. size {1,-3} {2,-5} {3}{4}" -f $i, $job.Size, $job.Mode, $(if ($done) { "done: $done" } else { "will run" }), $extra
        }
    }
    ""
    "Godot found: {0}   Ollama up: {1}" -f (Test-Path $Godot), (Test-Ollama)
    if (Test-Path $Godot) {
        $used = Get-GeminiUsed
        $next = (Get-Date).Date.AddHours($ResetHour)
        if ($next -le (Get-Date)) { $next = $next.AddDays(1) }
        "Gemini calls used since the last reset: {0} of {1} (next reset {2:yyyy-MM-dd HH:mm})" -f $used, $DailyLimit, $next
    }
    return
}

if (-not $Lane) {
    Write-Host "Pick a lane: -Lane gemini or -Lane ollama (or -Plan to see both lists)."
    exit 1
}

$Jobs = $LaneJobs[$Lane]
$TmpDir = Join-Path $env:TEMP "gennpc_night_$Lane"
New-Item -ItemType Directory -Force $Results | Out-Null
New-Item -ItemType Directory -Force $TmpDir | Out-Null

function Invoke-Job($Job) {
    $tag = "{0}_{1}_{2}" -f $Lane, $Job.Size, $Job.Mode
    $out = Join-Path $TmpDir "$tag.out.txt"
    $err = Join-Path $TmpDir "$tag.err.txt"
    $arguments = "--headless --path `"$Proj`" res://eval/big_eval.tscn -- --provider $Lane --size $($Job.Size) --mode $($Job.Mode) --runs=$Runs --daily-limit $DailyLimit --no-summary"
    if ($Job.NumCtx) { $arguments += " --num-ctx $($Job.NumCtx)" }
    $start = Get-Date
    $proc = Start-Process -FilePath $Godot -ArgumentList $arguments -NoNewWindow -Wait -PassThru -RedirectStandardOutput $out -RedirectStandardError $err
    $text = @(Get-Content -Path $out -Encoding UTF8 -ErrorAction SilentlyContinue)
    $calls = 0
    $callLine = $text | Where-Object { $_ -match '^GEMINI_CALLS=(\d+)' } | Select-Object -Last 1
    if ($callLine -and $callLine -match '^GEMINI_CALLS=(\d+)') { $calls = [int]$Matches[1] }
    return @{ Code = $proc.ExitCode; Minutes = ((Get-Date) - $start).TotalMinutes; Calls = $calls; Text = $text; ErrFile = $err }
}

function Update-Summary {
    Enter-Lock $SummaryMutex
    try {
        $out = Join-Path $TmpDir "rescore.out.txt"
        $err = Join-Path $TmpDir "rescore.err.txt"
        $arguments = "--headless --path `"$Proj`" res://eval/big_eval.tscn -- --rescore"
        $proc = Start-Process -FilePath $Godot -ArgumentList $arguments -NoNewWindow -Wait -PassThru -RedirectStandardOutput $out -RedirectStandardError $err
        if ($proc.ExitCode -eq 0) { Write-Log "  big_summary.md rebuilt" } else { Write-Log "  big_summary.md rebuild failed (exit $($proc.ExitCode))" }
    }
    finally { $SummaryMutex.ReleaseMutex() }
}

function Wait-ForReset {
    $now = Get-Date
    $next = $now.Date.AddHours($ResetHour)
    if ($next -le $now) { $next = $next.AddDays(1) }
    $next = $next.AddMinutes(3)
    Write-Log ("  waiting until {0:yyyy-MM-dd HH:mm} (daily Gemini reset at {1}:00, plus 3 minutes)" -f $next, $ResetHour)
    while ((Get-Date) -lt $next) { Start-Sleep -Seconds 30 }
}

Add-Type -Namespace GenNpcNight -Name Power -MemberDefinition '[DllImport("kernel32.dll")] public static extern uint SetThreadExecutionState(uint esFlags);'
$ES_CONTINUOUS = [uint32]2147483648
$ES_SYSTEM_REQUIRED = [uint32]1

$nightStart = Get-Date
$totalGemini = 0
Write-Log "===== Lane start (runs=$Runs, daily Gemini limit=$DailyLimit, $($Jobs.Count) jobs) ====="
[GenNpcNight.Power]::SetThreadExecutionState($ES_CONTINUOUS -bor $ES_SYSTEM_REQUIRED) | Out-Null
try {
    foreach ($job in $Jobs) {
        $name = "{0} size {1} {2}" -f $Lane, $job.Size, $job.Mode
        $done = Get-DoneFile $Lane $job.Size $job.Mode
        if ($done) {
            Write-Log "SKIP $name (already completed: $done)"
            continue
        }
        if ($Lane -eq "ollama" -and -not (Start-OllamaIfNeeded)) {
            Write-Log "FAIL $name (Ollama is not reachable at localhost:11434)"
            continue
        }

        Write-Log "START $name"
        $waited = $false
        while ($true) {
            $r = Invoke-Job $job
            $totalGemini += $r.Calls
            $budgetLine = $r.Text | Where-Object { $_ -like "Gemini budget:*" } | Select-Object -Last 1
            if ($budgetLine) { Write-Log "  $budgetLine" }
            if ($r.Code -eq 4 -and $Lane -eq "gemini" -and -not $waited) {
                $waited = $true
                Write-Log "  $name could go over the daily limit now. Waiting for the reset."
                Wait-ForReset
                Write-Log "  Retrying $name after the reset"
                continue
            }
            break
        }

        $code = $r.Code
        $info = "exit $code, {0:N1} min, Gemini calls {1}" -f $r.Minutes, $r.Calls
        switch ($code) {
            0 {
                $saved = $r.Text | Where-Object { $_ -match '^Saved res://eval/results/(big_\S+\.json)$' } | Select-Object -First 1
                $file = if ($saved -and $saved -match '(big_\S+\.json)$') { $Matches[1] } else { "?" }
                Write-Log "DONE $name ($info) -> $file"
                Update-Summary
            }
            4 { Write-Log "SKIP $name (still over the daily Gemini limit of $DailyLimit after the reset; $info)" }
            3 {
                Write-Log "STOP $name (self-check failed; $info)"
                $r.Text | Select-Object -Last 20 | ForEach-Object { Write-Log "  | $_" }
            }
            2 {
                $stopLine = $r.Text | Where-Object { $_ -like "STOPPED:*" } | Select-Object -Last 1
                Write-Log "ABORTED $name ($info): $stopLine"
            }
            default {
                Write-Log "FAIL $name ($info). Last lines:"
                $r.Text | Select-Object -Last 15 | ForEach-Object { Write-Log "  | $_" }
                Get-Content -Path $r.ErrFile -Encoding UTF8 -ErrorAction SilentlyContinue | Select-Object -Last 5 | ForEach-Object { Write-Log "  ! $_" }
            }
        }
        if ($code -eq 3) { break }
    }
}
finally {
    [GenNpcNight.Power]::SetThreadExecutionState($ES_CONTINUOUS) | Out-Null
    Remove-Item -Path $TmpDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Log ("===== Lane end ({0:N1} min, Gemini calls {1}) =====" -f ((Get-Date) - $nightStart).TotalMinutes, $totalGemini)
}
