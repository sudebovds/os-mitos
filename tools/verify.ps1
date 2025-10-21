# Quick Test Script for Development Environment
# Run this in PowerShell to verify everything is installed correctly

Write-Host "=========================================="
Write-Host "MitOS Development Environment Verification"
Write-Host "=========================================="
Write-Host ""

$allGood = $true

# Test NASM
Write-Host "Testing NASM..." -ForegroundColor Yellow
$nasmCmd = Get-Command nasm -ErrorAction SilentlyContinue
if ($nasmCmd) {
    $nasmVersion = nasm -version 2>&1
    Write-Host "✓ NASM: $nasmVersion" -ForegroundColor Green
} else {
    Write-Host "✗ NASM not found!" -ForegroundColor Red
    $allGood = $false
}

# Test i686-elf-gcc
Write-Host "Testing i686-elf-gcc..." -ForegroundColor Yellow
$gccCmd = Get-Command i686-elf-gcc -ErrorAction SilentlyContinue
if ($gccCmd) {
    $gccVersion = i686-elf-gcc --version 2>&1 | Select-Object -First 1
    Write-Host "✓ GCC: $gccVersion" -ForegroundColor Green
} else {
    Write-Host "✗ i686-elf-gcc not found!" -ForegroundColor Red
    Write-Host "  Make sure cross-compiler is built and in PATH" -ForegroundColor Yellow
    $allGood = $false
}

# Test i686-elf-ld
Write-Host "Testing i686-elf-ld..." -ForegroundColor Yellow
$ldCmd = Get-Command i686-elf-ld -ErrorAction SilentlyContinue
if ($ldCmd) {
    $ldVersion = i686-elf-ld --version 2>&1 | Select-Object -First 1
    Write-Host "✓ Linker: $ldVersion" -ForegroundColor Green
} else {
    Write-Host "✗ i686-elf-ld not found!" -ForegroundColor Red
    $allGood = $false
}

# Test QEMU
Write-Host "Testing QEMU..." -ForegroundColor Yellow
$qemuCmd = Get-Command qemu-system-i386 -ErrorAction SilentlyContinue
if ($qemuCmd) {
    $qemuVersion = qemu-system-i386 --version 2>&1 | Select-Object -First 1
    Write-Host "✓ QEMU: $qemuVersion" -ForegroundColor Green
} else {
    Write-Host "✗ QEMU not found!" -ForegroundColor Red
    $allGood = $false
}

# Test Make
Write-Host "Testing Make..." -ForegroundColor Yellow
$makeCmd = Get-Command make -ErrorAction SilentlyContinue
if ($makeCmd) {
    $makeVersion = make --version 2>&1 | Select-Object -First 1
    Write-Host "✓ Make: $makeVersion" -ForegroundColor Green
} else {
    Write-Host "✗ Make not found!" -ForegroundColor Red
    $allGood = $false
}

Write-Host ""
Write-Host "=========================================="

if ($allGood) {
    Write-Host "All tools are installed correctly! ✓" -ForegroundColor Green
    Write-Host "You're ready to start developing!" -ForegroundColor Green
} else {
    Write-Host "Some tools are missing! ✗" -ForegroundColor Red
    Write-Host "Please check docs/SETUP_GUIDE.md for installation instructions" -ForegroundColor Yellow
}

Write-Host "=========================================="
Write-Host ""
