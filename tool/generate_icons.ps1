# Regenere les icones PNG du logo a partir des sources SVG de design/.
# Utilise Edge (ou Chrome) en mode headless : aucune dependance a installer.
#   powershell -ExecutionPolicy Bypass -File tool\generate_icons.ps1

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

$browser = @(
  "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
  "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
  "$env:ProgramFiles\Google\Chrome\Application\chrome.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $browser) { throw 'Edge ou Chrome introuvable.' }

# Source SVG -> (fichier PNG, taille en pixels)
$targets = @(
  @('design\logo.svg',          'web\icons\Icon-192.png',          192),
  @('design\logo.svg',          'web\icons\Icon-512.png',          512),
  @('design\logo-maskable.svg', 'web\icons\Icon-maskable-192.png', 192),
  @('design\logo-maskable.svg', 'web\icons\Icon-maskable-512.png', 512),
  @('design\favicon.svg',       'web\favicon.png',                 64),
  @('design\logo.svg',          'assets\images\logo.png',          512)
)

$tmp = Join-Path ([IO.Path]::GetTempPath()) 'chess_stats_icons'
New-Item -ItemType Directory -Force $tmp | Out-Null

foreach ($t in $targets) {
  $svg = Join-Path $root $t[0]
  $png = Join-Path $root $t[1]
  $size = $t[2]
  New-Item -ItemType Directory -Force (Split-Path -Parent $png) | Out-Null

  # Page HTML qui affiche le SVG a la taille voulue, sans marge ni fond.
  $html = Join-Path $tmp 'render.html'
  $svgUrl = ([Uri]$svg).AbsoluteUri
  "<!doctype html><html><body style=`"margin:0;background:transparent`"><img src=`"$svgUrl`" width=`"$size`" height=`"$size`" style=`"display:block`"></body></html>" |
    Set-Content -Encoding utf8 $html

  # Le navigateur ecrit sur stderr meme quand tout va bien : ne pas en faire une erreur.
  $ErrorActionPreference = 'Continue'
  & $browser --headless --disable-gpu --hide-scrollbars --allow-file-access-from-files `
    --default-background-color=00000000 --force-device-scale-factor=1 `
    "--window-size=$size,$size" "--screenshot=$png" ([Uri]$html).AbsoluteUri 2>$null | Out-Null
  $ErrorActionPreference = 'Stop'
  if (-not (Test-Path $png)) { throw "Echec du rendu : $png" }
  Write-Host "$($t[1]) ($size px)"
}
