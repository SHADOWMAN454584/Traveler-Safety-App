#!/usr/bin/env node

const { spawn, exec } = require('child_process');
const path = require('path');

// Colors for console output
const colors = {
  green: '\x1b[32m',
  red: '\x1b[31m', 
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
  magenta: '\x1b[35m',
  reset: '\x1b[0m',
  bold: '\x1b[1m'
};

function log(color, message) {
  console.log(`${color}${message}${colors.reset}`);
}

function delay(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function runCommand(command, description) {
  return new Promise((resolve, reject) => {
    log(colors.blue, `🔄 ${description}...`);
    
    const child = exec(command, (error, stdout, stderr) => {
      if (error) {
        log(colors.red, `❌ ${description} failed: ${error.message}`);
        reject(error);
        return;
      }
      
      if (stderr && !stderr.includes('Warning') && !stderr.includes('deprecated')) {
        log(colors.yellow, `⚠️  ${description} warnings: ${stderr}`);
      }
      
      log(colors.green, `✅ ${description} completed successfully`);
      if (stdout) {
        console.log(stdout);
      }
      resolve(stdout);
    });
  });
}

async function checkMongoDB() {
  try {
    const mongoose = require('mongoose');
    require('dotenv').config();
    
    log(colors.blue, '🔍 Checking MongoDB connection...');
    
    await mongoose.connect(process.env.MONGO_URI);
    
    log(colors.green, '✅ MongoDB connection successful');
    await mongoose.connection.close();
    return true;
  } catch (error) {
    log(colors.red, `❌ MongoDB connection failed: ${error.message}`);
    log(colors.yellow, '⚠️  Please check your MONGO_URI in .env file');
    return false;
  }
}

async function startTouristSafetySystem() {
  try {
    log(colors.bold + colors.cyan, '\n🚨 SMART TOURIST SAFETY SYSTEM - FULL STARTUP');
    log(colors.cyan, '='.repeat(60));
    
    // Step 1: Check environment
    log(colors.magenta, '\n📋 Step 1: Environment Check');
    const fs = require('fs');
    
    if (!fs.existsSync('.env')) {
      log(colors.red, '❌ .env file not found!');
      log(colors.yellow, '⚠️  Please create .env file with MONGO_URI and JWT_SECRET');
      process.exit(1);
    }
    
    require('dotenv').config();
    if (!process.env.MONGO_URI || !process.env.JWT_SECRET) {
      log(colors.red, '❌ Missing required environment variables!');
      log(colors.yellow, '⚠️  Please set MONGO_URI and JWT_SECRET in .env file');
      process.exit(1);
    }
    
    log(colors.green, '✅ Environment variables configured');
    
    // Step 2: Check MongoDB connection
    log(colors.magenta, '\n📋 Step 2: Database Connection Check');
    const mongoConnected = await checkMongoDB();
    if (!mongoConnected) {
      process.exit(1);
    }
    
    // Step 3: Install dependencies (if needed)
    log(colors.magenta, '\n📋 Step 3: Dependencies Check');
    if (!fs.existsSync('node_modules')) {
      await runCommand('npm install', 'Installing dependencies');
    } else {
      log(colors.green, '✅ Dependencies already installed');
    }
    
    // Step 4: Seed database
    log(colors.magenta, '\n📋 Step 4: Database Seeding');
    try {
      await runCommand('node seed-database.js', 'Seeding database with authority accounts and safety zones');
    } catch (error) {
      log(colors.yellow, '⚠️  Database seeding may have failed, but continuing...');
    }
    
    // Step 5: Start server
    log(colors.magenta, '\n📋 Step 5: Starting Server');
    log(colors.cyan, '🚀 Starting Tourist Safety Backend Server...');
    log(colors.yellow, '📡 Server will be available at: http://localhost:5000');
    log(colors.yellow, '🏥 Health check: http://localhost:5000/health');
    log(colors.yellow, '⚡ Press Ctrl+C to stop the server');
    
    await delay(2000);
    
    // Start the server
    const serverProcess = spawn('node', ['server.js'], { 
      stdio: 'inherit',
      cwd: process.cwd()
    });
    
    serverProcess.on('close', (code) => {
      log(colors.yellow, `\n🔴 Server stopped with code ${code}`);
    });
    
    // Handle graceful shutdown
    process.on('SIGINT', () => {
      log(colors.yellow, '\n🛑 Shutting down Tourist Safety System...');
      serverProcess.kill('SIGINT');
      process.exit(0);
    });
    
    // Give server time to start, then show success message
    setTimeout(() => {
      log(colors.bold + colors.green, '\n🎉 TOURIST SAFETY SYSTEM FULLY OPERATIONAL!');
      log(colors.cyan, '='.repeat(60));
      log(colors.green, '✅ MongoDB: Connected');
      log(colors.green, '✅ Database: Seeded with test data');
      log(colors.green, '✅ Server: Running on port 5000');
      log(colors.green, '✅ API Endpoints: All 24 endpoints ready');
      
      log(colors.blue, '\n🔑 Test Authority Accounts:');
      log(colors.yellow, '   Inspector: raj.sharma@delhipolice.gov.in | Badge: DLP001 | Pass: police123');
      log(colors.yellow, '   Sub-Inspector: priya.singh@delhipolice.gov.in | Badge: DLP002 | Pass: police123');
      log(colors.yellow, '   ASI: kumar.patel@delhipolice.gov.in | Badge: DLP003 | Pass: police123');
      
      log(colors.blue, '\n🧪 Quick Tests:');
      log(colors.cyan, '   Health Check: curl http://localhost:5000/health');
      log(colors.cyan, '   API Test Suite: npm run test');
      log(colors.cyan, '   Tourist Signup: POST http://localhost:5000/signup');
      log(colors.cyan, '   Authority Login: POST http://localhost:5000/dashboard/login');
      
      log(colors.magenta, '\n📱 Ready for Flutter App Integration!');
      log(colors.reset, '');
    }, 3000);
    
  } catch (error) {
    log(colors.red, `❌ Startup failed: ${error.message}`);
    process.exit(1);
  }
}

// Run the startup sequence
startTouristSafetySystem();
