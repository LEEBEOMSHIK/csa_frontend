# hot_reload.ps1 - Auto hot reload watcher for Flutter web (polling mode)
# Usage: powershell -ExecutionPolicy Bypass -File hot_reload.ps1

param(
    [string]$WsUrl = "",
    [int]$PollMs = 500
)

# Auto-detect VM Service URL - find latest active flutter run
if (-not $WsUrl) {
    $files = Get-ChildItem "$env:TEMP" -Recurse -Filter "*.output" -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending

    foreach ($file in $files) {
        $raw = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
        if ($raw -match 'ws://127\.0\.0\.1:(\d+)/[^\s"]+/ws') {
            $port = [int]$Matches[1]
            $sock = New-Object Net.Sockets.TcpClient
            try {
                $sock.Connect("127.0.0.1", $port)
                $WsUrl = $Matches[0]
                $sock.Close()
                break
            } catch { $sock.Close() }
        }
    }
}

if (-not $WsUrl) {
    Write-Host "[ERROR] flutter run is not running. Start it first." -ForegroundColor Red
    exit 1
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Flutter Auto Hot Reload Watcher" -ForegroundColor Cyan
Write-Host " VM Service : $WsUrl" -ForegroundColor Cyan
Write-Host " Poll interval: ${PollMs}ms   Stop: Ctrl+C" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

function Invoke-HotReload {
    try {
        $ws = [System.Net.WebSockets.ClientWebSocket]::new()
        $ct = [System.Threading.CancellationToken]::None
        $ws.ConnectAsync([Uri]$WsUrl, $ct).Wait(3000) | Out-Null

        $enc  = [System.Text.Encoding]::UTF8
        $buf  = [byte[]]::new(65536)

        # Send message helper
        $send = {
            param($msg)
            $b = $enc.GetBytes($msg)
            $ws.SendAsync([ArraySegment[byte]]::new($b),
                [Net.WebSockets.WebSocketMessageType]::Text, $true, $ct).Wait()
        }
        # Recv message helper
        $recv = {
            $r = $ws.ReceiveAsync([ArraySegment[byte]]::new($buf), $ct).Result
            $enc.GetString($buf, 0, $r.Count) | ConvertFrom-Json
        }

        # 1. Get isolate ID
        & $send '{"jsonrpc":"2.0","method":"getVM","params":{},"id":1}'
        $vm = & $recv
        $isolateId = $vm.result.isolates[0].id

        # 2. Hot reload
        & $send "{`"jsonrpc`":`"2.0`",`"method`":`"reloadSources`",`"params`":{`"isolateId`":`"$isolateId`"},`"id`":2}"
        $res = & $recv

        $ws.CloseAsync([Net.WebSockets.WebSocketCloseStatus]::NormalClosure, "ok", $ct).Wait() | Out-Null

        Write-Host "[$(Get-Date -f 'HH:mm:ss')] Hot reload OK" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "[$(Get-Date -f 'HH:mm:ss')] Reload failed: $_" -ForegroundColor Red
        return $false
    }
}

# Build initial snapshot of lib/ dart files
$libPath = Join-Path $PSScriptRoot "lib"
$snapshot = @{}
Get-ChildItem $libPath -Recurse -Filter "*.dart" | ForEach-Object {
    $snapshot[$_.FullName] = $_.LastWriteTimeUtc
}

Write-Host "[$(Get-Date -f 'HH:mm:ss')] Watching $libPath ..." -ForegroundColor Gray

try {
    while ($true) {
        Start-Sleep -Milliseconds $PollMs

        $changed = $false
        Get-ChildItem $libPath -Recurse -Filter "*.dart" | ForEach-Object {
            $path = $_.FullName
            $mtime = $_.LastWriteTimeUtc
            if (-not $snapshot.ContainsKey($path) -or $snapshot[$path] -ne $mtime) {
                $snapshot[$path] = $mtime
                Write-Host "[$(Get-Date -f 'HH:mm:ss')] Changed: $([System.IO.Path]::GetFileName($path))" -ForegroundColor Yellow
                $changed = $true
            }
        }

        if ($changed) {
            Invoke-HotReload | Out-Null
        }
    }
} finally {
    Write-Host "Watcher stopped." -ForegroundColor Gray
}
