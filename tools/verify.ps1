# Quick Test Script for Development Environment
# Run this in PowerShell to verify everything is installed correctly

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "MitOS Development Environment Verification" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$allGood = $true

# Test NASM
Write-Host "Testing NASM..." -ForegroundColor Yellow
$nasmCmd = Get-Command nasm -ErrorAction SilentlyContinue
if ($nasmCmd) {
    $nasmVersion = nasm -version 2>&1
    Write-Host "[OK] NASM: $nasmVersion" -ForegroundColor Green
} else {
    Write-Host "[MISSING] NASM not found!" -ForegroundColor Red
    $allGood = $false
}

# Test i686-elf-gcc
Write-Host "Testing i686-elf-gcc..." -ForegroundColor Yellow
$gccCmd = Get-Command i686-elf-gcc -ErrorAction SilentlyContinue
if ($gccCmd) {
    $gccVersion = i686-elf-gcc --version 2>&1 | Select-Object -First 1
    Write-Host "[OK] GCC: $gccVersion" -ForegroundColor Green
} else {
    Write-Host "[MISSING] i686-elf-gcc not found!" -ForegroundColor Red
    Write-Host "  Make sure cross-compiler is built and in PATH" -ForegroundColor Yellow
    $allGood = $false
}

# Test i686-elf-ld
Write-Host "Testing i686-elf-ld..." -ForegroundColor Yellow
$ldCmd = Get-Command i686-elf-ld -ErrorAction SilentlyContinue
if ($ldCmd) {
    $ldVersion = i686-elf-ld --version 2>&1 | Select-Object -First 1
    Write-Host "[OK] Linker: $ldVersion" -ForegroundColor Green
} else {
    Write-Host "[MISSING] i686-elf-ld not found!" -ForegroundColor Red
    $allGood = $false
}

# Test QEMU
Write-Host "Testing QEMU..." -ForegroundColor Yellow
$qemuCmd = Get-Command qemu-system-i386 -ErrorAction SilentlyContinue
if ($qemuCmd) {
    $qemuVersion = qemu-system-i386 --version 2>&1 | Select-Object -First 1
    Write-Host "[OK] QEMU: $qemuVersion" -ForegroundColor Green
} else {
    Write-Host "[MISSING] QEMU not found!" -ForegroundColor Red
    $allGood = $false
}

# Test Make
Write-Host "Testing Make..." -ForegroundColor Yellow
$makeCmd = Get-Command make -ErrorAction SilentlyContinue
if ($makeCmd) {
    $makeVersion = make --version 2>&1 | Select-Object -First 1
    Write-Host "[OK] Make: $makeVersion" -ForegroundColor Green
} else {
    Write-Host "[MISSING] Make not found!" -ForegroundColor Red
    $allGood = $false
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan

if ($allGood) {
    Write-Host "[SUCCESS] All tools are installed correctly!" -ForegroundColor Green
    Write-Host "[SUCCESS] You're ready to start developing!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Read ROADMAP.md Phase 1.2" -ForegroundColor White
    Write-Host "  2. Write your first bootloader" -ForegroundColor White
    Write-Host "  3. Test with: make run" -ForegroundColor White
} else {
    Write-Host "[INCOMPLETE] Some tools are missing!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install the missing tools:" -ForegroundColor Yellow
    Write-Host "  - See INSTALL_REMAINING.md for quick installation" -ForegroundColor White
    Write-Host "  - Or see GETTING_STARTED.md for full guide" -ForegroundColor White
}

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
