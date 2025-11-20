# Script de Compilación Rápida - Quartus Prime
# Solo ejecuta Analysis & Synthesis + Fitter (omite timing analysis para debug rápido)

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  Compilación Rápida RV32I FPGA" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

$projectPath = "D:\SistemasUniversidad\sistemas6\Arquitectura\Proyecto\rv32i_mono\quartus"
$projectName = "rv32i_fpga"

Set-Location $projectPath

Write-Host "[1/3] Limpiando archivos previos..." -ForegroundColor Yellow
Remove-Item -Path "output_files\*.rpt" -ErrorAction SilentlyContinue
Remove-Item -Path "output_files\*.summary" -ErrorAction SilentlyContinue
Write-Host "      ✓ Limpieza completada" -ForegroundColor Green
Write-Host ""

$startTime = Get-Date

Write-Host "[2/3] Ejecutando Analysis & Synthesis..." -ForegroundColor Yellow
quartus_map --read_settings_files=on --write_settings_files=off $projectName -c $projectName
if ($LASTEXITCODE -ne 0) {
    Write-Host "      ✗ ERROR en Synthesis" -ForegroundColor Red
    exit 1
}
Write-Host "      ✓ Synthesis completado" -ForegroundColor Green
Write-Host ""

Write-Host "[3/3] Ejecutando Fitter..." -ForegroundColor Yellow
quartus_fit --read_settings_files=off --write_settings_files=off $projectName -c $projectName
if ($LASTEXITCODE -ne 0) {
    Write-Host "      ✗ ERROR en Fitter" -ForegroundColor Red
    exit 1
}
Write-Host "      ✓ Fitter completado" -ForegroundColor Green
Write-Host ""

$endTime = Get-Date
$duration = $endTime - $startTime

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  COMPILACIÓN COMPLETADA" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "Tiempo total: $($duration.Minutes) min $($duration.Seconds) seg" -ForegroundColor Cyan
Write-Host ""
Write-Host "Para compilación completa con timing, ejecuta:" -ForegroundColor Yellow
Write-Host "  quartus_sh --flow compile $projectName" -ForegroundColor White
Write-Host ""
