param(
    [Parameter(Mandatory=$false, Position=0)][int]$Port = 15001,
    [Parameter(Mandatory=$false, Position=1)][string]$Mode = 'raw'
)

function Mode-Jsonl {
    param(
        [string]$Port
    )

    $udpClient = New-Object System.Net.Sockets.UdpClient($Port)
    try {
        $task = $null
        $RESET_PAYLOAD = "`r`n`r`n"
        $ENTITY_DELIMITER = "`n"
        $ENTITY_MAX_LENGTH = 8192
        $recv = $null
        $payload = $null
        $restPaylod = $null
        $entities = $null
        while ($true) {
            if ($null -eq $task) {
                $task = $udpClient.ReceiveAsync()
            }
            if (-not $task.Wait(20)) {
                continue
            }
            $receiveBytes = $task.GetAwaiter().GetResult();

            $recv = [Text.Encoding]::UTF8.GetString($receiveBytes.Buffer)
            $payload = $recv -split $RESET_PAYLOAD
            if ($payload.length -gt 1) {
                Write-Host 'reset'
                $restPaylod = ""
            }
            $entities = ($restPaylod + $payload[-1]) -split $ENTITY_DELIMITER
                | Where-Object {($_ -ne "") -and ($_.Length -le $ENTITY_MAX_LENGTH)}
            $restPaylod = ""
            foreach ($entity in $entities) {
                try {
                    $entity | ConvertFrom-Json | Write-Host
                }
                catch {
                    if ($entity -eq $entities[-1]) {
                        $restPaylod = $entity
                    }
                }
            }

            $task = $null
        }
    }
    catch {
        Write-Host "error: $($_.Exception.Message)"
    }
    finally {
        $udpClient.Close()
    }
}

function Mode-Raw {
    param(
        [string]$Port
    )

    $udpClient = New-Object System.Net.Sockets.UdpClient($Port)
    try {
        $task = $null
        $message = ''
        while ($true) {
            if ($null -eq $task) {
                $task = $udpClient.ReceiveAsync()
            }
            if (-not $task.Wait(20)) {
                continue
            }
            $receiveBytes = $task.GetAwaiter().GetResult();
            $message = [Text.Encoding]::UTF8.GetString($receiveBytes.Buffer)
            Write-Host $message -NoNewline

            $task = $null
        }
    }
    catch {
        Write-Host "error: $($_.Exception.Message)"
    }
    finally {
        $udpClient.Close()
    }
}

switch ( $Mode )
{
    Jsonl { Mode-Jsonl -Port $Port }
    Raw   { Mode-Raw -Port $Port }
}
