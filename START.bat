@echo off
title Tourist Safety System - Full Startup

echo.
echo ╔═══════════════════════════════════════════════════════════════════════╗
echo ║                🚨 SMART TOURIST SAFETY SYSTEM 🚨                     ║
echo ║                    One-Command Full Startup                          ║
echo ╚═══════════════════════════════════════════════════════════════════════╝
echo.

echo 🔄 Starting complete Tourist Safety System...
echo.

REM Check if Node.js is installed
where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Node.js is not installed or not in PATH
    echo 📥 Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)

REM Check if we're in the right directory
if not exist "server.js" (
    echo ❌ server.js not found! 
    echo 📁 Please run this from the Project8 directory
    pause
    exit /b 1
)

REM Check for .env file
if not exist ".env" (
    echo ❌ .env file not found!
    echo 📝 Please create .env file with MONGO_URI and JWT_SECRET
    pause
    exit /b 1
)

echo ✅ Environment checks passed
echo.

REM Run the comprehensive startup script
node start-system.js

echo.
echo 🔴 Tourist Safety System has stopped
pause
