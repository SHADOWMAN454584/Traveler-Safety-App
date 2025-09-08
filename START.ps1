# Tourist Safety System - PowerShell Startup Script

# Set colors
$Host.UI.RawUI.WindowTitle = "Tourist Safety System - Full Startup"

Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                🚨 SMART TOURIST SAFETY SYSTEM 🚨                     ║" -ForegroundColor Cyan
Write-Host "║                    One-Command Full Startup                          ║" -ForegroundColor Cyan  
Write-Host "╚═══════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Host "🔄 Starting complete Tourist Safety System..." -ForegroundColor Blue
Write-Host ""

# Check if Node.js is installed
try {
    $nodeVersion = node --version
    Write-Host "✅ Node.js detected: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js is not installed or not in PATH" -ForegroundColor Red
    Write-Host "📥 Please install Node.js from https://nodejs.org/" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Check if we're in the right directory
if (-not (Test-Path "server.js")) {
    Write-Host "❌ server.js not found!" -ForegroundColor Red
    Write-Host "📁 Please run this from the Project8 directory" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Check for .env file
if (-not (Test-Path ".env")) {
    Write-Host "❌ .env file not found!" -ForegroundColor Red
    Write-Host "📝 Please create .env file with MONGO_URI and JWT_SECRET" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "✅ Environment checks passed" -ForegroundColor Green
Write-Host ""

# Run the comprehensive startup script
try {
    node start-system.js
} catch {
    Write-Host "❌ Failed to start system: $_" -ForegroundColor Red
} finally {
    Write-Host ""
    Write-Host "🔴 Tourist Safety System has stopped" -ForegroundColor Red
    Read-Host "Press Enter to exit"
}
