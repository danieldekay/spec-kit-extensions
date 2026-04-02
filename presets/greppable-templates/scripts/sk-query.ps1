# sk-query.ps1 — Query spec-kit artifact files by greppable marker type
#
# Usage: sk-query.ps1 <type> [file]
#
# Types: fr, sc, task, open, done, parallel, story, findings, critical, high,
#        medium, low, info, chk, open-chk, done-chk, stats, list-types
#
# Examples:
#   sk-query.ps1 fr spec.md
#   sk-query.ps1 task tasks.md
#   sk-query.ps1 open tasks.md
#   sk-query.ps1 stats tasks.md
#   sk-query.ps1 story US1 tasks.md
#   sk-query.ps1 findings code-review\code-review.md

[CmdletBinding()]
param(
    [Parameter(Position = 0, Mandatory = $true)]
    [string]$Type,
    [Parameter(Position = 1)]
    [string]$Arg1 = "",
    [Parameter(Position = 2)]
    [string]$Arg2 = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Find-DefaultFile {
    param([string]$Name)
    $found = Get-ChildItem -Recurse -Depth 4 -Filter $Name -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch '\.git' } |
        Select-Object -First 1
    return $found?.FullName
}

function Resolve-File {
    param([string]$QueryType, [string]$Hint)
    if ($Hint -and (Test-Path $Hint)) { return $Hint }
    switch ($QueryType) {
        { $_ -in 'fr','sc' }                    { return Find-DefaultFile "spec.md" }
        { $_ -in 'task','open','done','parallel','stats' } { return Find-DefaultFile "tasks.md" }
        { $_ -in 'findings','critical','high','medium','low','info' } {
            $f = Find-DefaultFile "code-review.md"
            if (-not $f) { $f = Find-DefaultFile "ux-research-report.md" }
            return $f
        }
        default { return $null }
    }
}

function Assert-File {
    param([string]$Path, [string]$Hint)
    if (-not $Path -or -not (Test-Path $Path)) {
        Write-Error "File not found: $Hint. Pass the file path explicitly."
        exit 1
    }
}

function Show-Header {
    param([string]$Title, [string]$File)
    Write-Output "# $Title — $File"
    Write-Output ""
}

function Query-Pattern {
    param([string]$File, [string]$Pattern, [string]$NoneMsg = "(none found)")
    $results = Select-String -Path $File -Pattern $Pattern | ForEach-Object { $_.Line }
    if ($results) { $results } else { Write-Output $NoneMsg }
}

# ── dispatch ─────────────────────────────────────────────────────────────────

switch ($Type) {
    "fr" {
        $file = Resolve-File fr $Arg1
        Assert-File $file "spec.md"
        Show-Header "Functional Requirements" $file
        Query-Pattern $file "^FR-"
    }
    "sc" {
        $file = Resolve-File sc $Arg1
        Assert-File $file "spec.md"
        Show-Header "Success Criteria" $file
        Query-Pattern $file "^SC-"
    }
    "task" {
        $file = Resolve-File task $Arg1
        Assert-File $file "tasks.md"
        Show-Header "All Tasks" $file
        Query-Pattern $file "^TASK-"
    }
    "open" {
        $file = Resolve-File open $Arg1
        Assert-File $file "tasks.md"
        Show-Header "Open Tasks" $file
        Query-Pattern $file "^TASK-.*\[ \]" "(none — all done or no tasks)"
    }
    "done" {
        $file = Resolve-File done $Arg1
        Assert-File $file "tasks.md"
        Show-Header "Completed Tasks" $file
        Query-Pattern $file "(?i)^TASK-.*\[x\]" "(none completed yet)"
    }
    "parallel" {
        $file = Resolve-File parallel $Arg1
        Assert-File $file "tasks.md"
        Show-Header "Parallel Tasks" $file
        Query-Pattern $file "^TASK-.*\[P\]"
    }
    "story" {
        # sk-query.ps1 story US1 tasks.md
        $story = $Arg1.ToUpper() -replace '^\[',''-replace '\]$',''
        $file = Resolve-File story $Arg2
        Assert-File $file "tasks.md"
        Show-Header "Tasks for $story" $file
        Query-Pattern $file "^TASK-.*\[$story\]"
    }
    "findings" {
        $file = Resolve-File findings $Arg1
        Assert-File $file "findings file"
        Show-Header "All Findings" $file
        Query-Pattern $file "^FINDING-"
    }
    { $_ -in 'critical','high','medium','low','info' } {
        $file = Resolve-File $Type $Arg1
        Assert-File $file "findings file"
        Show-Header "$($Type.Substring(0,1).ToUpper() + $Type.Substring(1)) Findings" $file
        Query-Pattern $file "(?i)^FINDING-.*$Type"
    }
    "chk" {
        Assert-File $Arg1 "checklist file"
        Show-Header "Checklist Items" $Arg1
        Query-Pattern $Arg1 "^CHK-"
    }
    "open-chk" {
        Assert-File $Arg1 "checklist file"
        Show-Header "Open Checklist Items" $Arg1
        Query-Pattern $Arg1 "^CHK-.*\[ \]" "(none — all done or no items)"
    }
    "done-chk" {
        Assert-File $Arg1 "checklist file"
        Show-Header "Completed Checklist Items" $Arg1
        Query-Pattern $Arg1 "(?i)^CHK-.*\[x\]" "(none completed yet)"
    }
    "stats" {
        $file = Resolve-File stats $Arg1
        Assert-File $file "tasks.md"
        $all   = (Select-String -Path $file -Pattern "^TASK-").Count
        $done  = (Select-String -Path $file -Pattern "(?i)^TASK-.*\[x\]").Count
        $open  = (Select-String -Path $file -Pattern "^TASK-.*\[ \]").Count
        if ($all -eq 0) { Write-Output "No TASK-T* entries found in $file"; exit 0 }
        $pct   = [math]::Round(($done / $all) * 100)
        $status = if ($pct -ge 100) { "✅ Complete (100%) — ready for code quality pipeline" }
                  elseif ($pct -ge 50) { "🔄 In progress ($pct%)" }
                  else { "⏸️  Early stage ($pct%)" }
        Show-Header "Task Stats" $file
        Write-Output "Total:     $all"
        Write-Output "Done:      $done  ($pct%)"
        Write-Output "Open:      $open"
        Write-Output ""
        Write-Output "Status:    $status"
    }
    "list-types" {
        Write-Output "Available types: fr sc task open done parallel story findings critical high medium low info chk open-chk done-chk stats"
    }
    default {
        Write-Error "Unknown type: $Type. Run 'sk-query.ps1 list-types' for available types."
        exit 1
    }
}
