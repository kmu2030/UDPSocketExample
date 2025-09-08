param(
    [Parameter(Mandatory=$false, Position=0)][int[]]$Ports = @(15001, 15002, 15003, 15004),
    [Parameter(Mandatory=$false, Position=1)][string]$Mode = 'raw'
)

$scriptFile = "simple-udp-monitor.ps1"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$scriptPath = Join-Path $scriptDir $scriptFile
if (-not (Test-Path $scriptPath)) {
    Write-Error "error: Not fount '${scriptFile}' in '${scriptPath}'"
    exit 1
}

$wtCommandString = "pwsh.exe -NoExit -Command ""&{ & `"${scriptPath}`" -Port $($Ports[0]) -Mode `"${Mode}`" }"" ; " + `
                   "split-pane -H pwsh.exe -NoExit -Command ""&{ & `"${scriptPath}`" -Port $($Ports[1]) -Mode `"${Mode}`" }"" ; " + `
                   "split-pane -V pwsh.exe -NoExit -Command ""&{ & `"${scriptPath}`" -Port $($Ports[2]) -Mode `"${Mode}`" }"" ; " + `
                   "split-pane -H pwsh.exe -NoExit -Command ""&{ & `"${scriptPath}`" -Port $($Ports[3]) -Mode `"${Mode}`" }"""

# For debug.
# Write-Host "command: wt.exe $wtCommandString"

Start-Process -FilePath "wt.exe" -ArgumentList $wtCommandString
