# dsh-mcp-setup installer (Windows PowerShell)
$ErrorActionPreference = "Stop"

$Profile = if ($env:DSH_PROFILE) { $env:DSH_PROFILE } else { "web" }
$DshHome = if ($env:DSH_HOME) { $env:DSH_HOME } else { Join-Path $HOME ".dsh" }
$PatchDir = Join-Path $DshHome "profiles\$Profile"
$Patch = Join-Path $PatchDir "cordis.patch.yml"
$Marker = "# >>> dsh-mcp-setup <<<"

$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Src = Join-Path $Root "cordis.patch.yml"
if (-not (Test-Path $Src)) { throw "找不到 $Src" }

New-Item -ItemType Directory -Force -Path $PatchDir | Out-Null

if ((Test-Path $Patch) -and (Select-String -Path $Patch -SimpleMatch $Marker -Quiet)) {
  Write-Host "检测到已有 dsh-mcp-setup 段，先移除旧段…"
  $lines = Get-Content $Patch
  $out = New-Object System.Collections.Generic.List[string]
  $in = $false
  foreach ($l in $lines) {
    if ($l -eq $Marker) { $in = -not $in; continue }
    if (-not $in) { $out.Add($l) }
  }
  Set-Content -Path $Patch -Value $out
}

if (Test-Path $Patch) {
  Copy-Item $Patch "$Patch.bak.$(Get-Date -UFormat %s)"
}

Add-Content -Path $Patch -Value ""
Add-Content -Path $Patch -Value $Marker
Get-Content $Src | Add-Content -Path $Patch
Add-Content -Path $Patch -Value $Marker

Write-Host "✅ 已写入 $Patch"
Write-Host "下一步："
Write-Host "  1) 设置环境变量: $env:TAVILY_API_KEY='...'; $env:EXA_API_KEY='...'; $env:GITHUB_TOKEN='...'"
Write-Host "  2) 完全退出并重启 DSH Desktop"
