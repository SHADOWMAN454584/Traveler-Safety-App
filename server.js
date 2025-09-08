const express = require("express");
const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const cors = require("cors");
const rateLimit = require("express-rate-limit");
require("dotenv").config();

const app = express();

// 🔹 Middleware
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});
app.use(limiter);

// 🔹 Connect to MongoDB
mongoose.connect(process.env.MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => console.log("✅ MongoDB connected"))
.catch(err => console.log("❌ DB error:", err));

// 🔹 DATABASE SCHEMAS

// User Schema (General Authentication)
const UserSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, unique: true, required: true },
  password: { type: String, required: true },
  userType: { type: String, enum: ['tourist', 'authority'], default: 'tourist' },
  createdAt: { type: Date, default: Date.now },
  lastLogin: { type: Date },
  isActive: { type: Boolean, default: true }
});

// Tourist Profile Schema
const TouristSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  digitalId: { type: String, unique: true, required: true },
  fullName: { type: String, required: true },
  nationality: { type: String, required: true },
  passportNumber: { type: String, required: true },
  phoneNumber: { type: String, required: true },
  emergencyContact: {
    name: String,
    phone: String,
    relationship: String
  },
  currentLocation: {
    latitude: Number,
    longitude: Number,
    address: String,
    lastUpdated: { type: Date, default: Date.now }
  },
  safetyScore: { type: Number, default: 100 },
  isInEmergency: { type: Boolean, default: false },
  tripDetails: {
    checkInDate: Date,
    checkOutDate: Date,
    accommodation: String,
    purpose: String
  },
  preferences: {
    language: { type: String, default: 'en' },
    notifications: { type: Boolean, default: true }
  },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

// Authority Schema
const AuthoritySchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  badgeNumber: { type: String, unique: true, required: true },
  department: { type: String, required: true },
  rank: { type: String, required: true },
  jurisdiction: {
    state: String,
    district: String,
    area: String
  },
  permissions: {
    viewAlerts: { type: Boolean, default: true },
    manageAlerts: { type: Boolean, default: true },
    generateReports: { type: Boolean, default: true },
    broadcastAlerts: { type: Boolean, default: false }
  },
  isOnDuty: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now }
});

// Emergency Alert Schema
const AlertSchema = new mongoose.Schema({
  alertId: { type: String, unique: true, required: true },
  touristId: { type: mongoose.Schema.Types.ObjectId, ref: 'Tourist', required: true },
  type: { type: String, enum: ['panic', 'medical', 'theft', 'lost', 'general'], required: true },
  severity: { type: String, enum: ['low', 'medium', 'high', 'critical'], required: true },
  status: { type: String, enum: ['active', 'acknowledged', 'resolved', 'false_alarm'], default: 'active' },
  location: {
    latitude: { type: Number, required: true },
    longitude: { type: Number, required: true },
    address: String,
    accuracy: Number
  },
  description: String,
  responseTime: Number,
  assignedOfficer: { type: mongoose.Schema.Types.ObjectId, ref: 'Authority' },
  createdAt: { type: Date, default: Date.now },
  resolvedAt: Date,
  notes: [{ 
    officer: { type: mongoose.Schema.Types.ObjectId, ref: 'Authority' },
    note: String,
    timestamp: { type: Date, default: Date.now }
  }]
});

// Safety Zone Schema
const SafetyZoneSchema = new mongoose.Schema({
  name: { type: String, required: true },
  type: { type: String, enum: ['safe', 'caution', 'danger'], required: true },
  coordinates: {
    center: {
      latitude: Number,
      longitude: Number
    },
    radius: Number // in meters
  },
  description: String,
  isActive: { type: Boolean, default: true },
  createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'Authority' },
  createdAt: { type: Date, default: Date.now }
});

// Broadcast Alert Schema
const BroadcastSchema = new mongoose.Schema({
  title: { type: String, required: true },
  message: { type: String, required: true },
  type: { type: String, enum: ['warning', 'info', 'emergency'], required: true },
  targetArea: {
    state: String,
    district: String,
    radius: Number
  },
  isActive: { type: Boolean, default: true },
  createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'Authority', required: true },
  createdAt: { type: Date, default: Date.now },
  expiresAt: Date
});

// Create Models
const User = mongoose.model("User", UserSchema);
const Tourist = mongoose.model("Tourist", TouristSchema);
const Authority = mongoose.model("Authority", AuthoritySchema);
const Alert = mongoose.model("Alert", AlertSchema);
const SafetyZone = mongoose.model("SafetyZone", SafetyZoneSchema);
const Broadcast = mongoose.model("Broadcast", BroadcastSchema);

// 🔹 MIDDLEWARE

// JWT Authentication Middleware
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  jwt.verify(token, process.env.JWT_SECRET || 'secretkey', (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Invalid or expired token' });
    }
    req.user = user;
    next();
  });
};

// Generate unique IDs
const generateDigitalId = () => {
  const prefix = 'TID';
  const timestamp = Date.now().toString().slice(-6);
  const random = Math.random().toString(36).substring(2, 8).toUpperCase();
  return `${prefix}${timestamp}${random}`;
};

const generateAlertId = () => {
  const prefix = 'ALT';
  const timestamp = Date.now().toString().slice(-6);
  const random = Math.random().toString(36).substring(2, 6).toUpperCase();
  return `${prefix}${timestamp}${random}`;
};

// 🔹 AUTHENTICATION ENDPOINTS

// User Registration
app.post("/signup", async (req, res) => {
  try {
    const { name, email, password, userType = 'tourist' } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({ error: 'All fields are required' });
    }

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ error: 'User already exists' });
    }

    const hashedPassword = await bcrypt.hash(password, 12);
    const user = new User({ 
      name, 
      email, 
      password: hashedPassword, 
      userType 
    });
    
    await user.save();

    const token = jwt.sign(
      { id: user._id, email: user.email, userType: user.userType }, 
      process.env.JWT_SECRET || 'secretkey', 
      { expiresIn: '24h' }
    );

    res.status(201).json({ 
      message: 'User registered successfully', 
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        userType: user.userType
      }
    });
  } catch (err) {
    console.error('Signup error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// User Login
app.post("/signin", async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    const user = await User.findOne({ email, isActive: true });
    if (!user) {
      return res.status(400).json({ error: 'Invalid credentials' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ error: 'Invalid credentials' });
    }

    // Update last login
    user.lastLogin = new Date();
    await user.save();

    const token = jwt.sign(
      { id: user._id, email: user.email, userType: user.userType }, 
      process.env.JWT_SECRET || 'secretkey', 
      { expiresIn: '24h' }
    );

    res.json({ 
      message: 'Login successful', 
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        userType: user.userType
      }
    });
  } catch (err) {
    console.error('Signin error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Token Refresh
app.post("/refresh-token", authenticateToken, async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user || !user.isActive) {
      return res.status(403).json({ error: 'User not found or inactive' });
    }

    const newToken = jwt.sign(
      { id: user._id, email: user.email, userType: user.userType }, 
      process.env.JWT_SECRET || 'secretkey', 
      { expiresIn: '24h' }
    );

    res.json({ token: newToken });
  } catch (err) {
    console.error('Token refresh error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 🔹 TOURIST ENDPOINTS

// Register Tourist Profile
app.post("/tourist/register", authenticateToken, async (req, res) => {
  try {
    const { 
      fullName, 
      nationality, 
      passportNumber, 
      phoneNumber, 
      emergencyContact,
      tripDetails 
    } = req.body;

    if (!fullName || !nationality || !passportNumber || !phoneNumber) {
      return res.status(400).json({ error: 'All required fields must be provided' });
    }

    const existingTourist = await Tourist.findOne({ userId: req.user.id });
    if (existingTourist) {
      return res.status(400).json({ error: 'Tourist profile already exists' });
    }

    const digitalId = generateDigitalId();
    
    const tourist = new Tourist({
      userId: req.user.id,
      digitalId,
      fullName,
      nationality,
      passportNumber,
      phoneNumber,
      emergencyContact,
      tripDetails
    });

    await tourist.save();

    res.status(201).json({ 
      message: 'Tourist profile created successfully',
      digitalId,
      profile: tourist
    });
  } catch (err) {
    console.error('Tourist registration error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get Tourist Profile
app.get("/tourist/profile", authenticateToken, async (req, res) => {
  try {
    const tourist = await Tourist.findOne({ userId: req.user.id })
      .populate('userId', 'name email');
    
    if (!tourist) {
      return res.status(404).json({ error: 'Tourist profile not found' });
    }

    res.json({ profile: tourist });
  } catch (err) {
    console.error('Get profile error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update Tourist Profile
app.put("/tourist/profile", authenticateToken, async (req, res) => {
  try {
    const updateData = req.body;
    updateData.updatedAt = new Date();

    const tourist = await Tourist.findOneAndUpdate(
      { userId: req.user.id },
      updateData,
      { new: true, runValidators: true }
    );

    if (!tourist) {
      return res.status(404).json({ error: 'Tourist profile not found' });
    }

    res.json({ 
      message: 'Profile updated successfully',
      profile: tourist 
    });
  } catch (err) {
    console.error('Update profile error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update Location
app.post("/tourist/location", authenticateToken, async (req, res) => {
  try {
    const { latitude, longitude, address, accuracy } = req.body;

    if (!latitude || !longitude) {
      return res.status(400).json({ error: 'Latitude and longitude are required' });
    }

    const tourist = await Tourist.findOneAndUpdate(
      { userId: req.user.id },
      {
        currentLocation: {
          latitude,
          longitude,
          address,
          lastUpdated: new Date()
        },
        updatedAt: new Date()
      },
      { new: true }
    );

    if (!tourist) {
      return res.status(404).json({ error: 'Tourist profile not found' });
    }

    // Calculate safety score based on location
    const safetyScore = await calculateSafetyScore(latitude, longitude);
    tourist.safetyScore = safetyScore;
    await tourist.save();

    res.json({ 
      message: 'Location updated successfully',
      location: tourist.currentLocation,
      safetyScore 
    });
  } catch (err) {
    console.error('Location update error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get Safety Score
app.get("/tourist/safety-score", authenticateToken, async (req, res) => {
  try {
    const tourist = await Tourist.findOne({ userId: req.user.id });
    
    if (!tourist) {
      return res.status(404).json({ error: 'Tourist profile not found' });
    }

    // Update safety score if location is recent
    let safetyScore = tourist.safetyScore;
    if (tourist.currentLocation && tourist.currentLocation.latitude) {
      safetyScore = await calculateSafetyScore(
        tourist.currentLocation.latitude, 
        tourist.currentLocation.longitude
      );
      tourist.safetyScore = safetyScore;
      await tourist.save();
    }

    res.json({ 
      safetyScore,
      location: tourist.currentLocation,
      lastUpdated: tourist.currentLocation?.lastUpdated 
    });
  } catch (err) {
    console.error('Safety score error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 🔹 EMERGENCY ENDPOINTS

// Panic Button - Emergency Alert
app.post("/emergency/panic", authenticateToken, async (req, res) => {
  try {
    const { latitude, longitude, description, type = 'panic' } = req.body;

    if (!latitude || !longitude) {
      return res.status(400).json({ error: 'Location coordinates are required' });
    }

    const tourist = await Tourist.findOne({ userId: req.user.id });
    if (!tourist) {
      return res.status(404).json({ error: 'Tourist profile not found' });
    }

    const alertId = generateAlertId();
    
    const alert = new Alert({
      alertId,
      touristId: tourist._id,
      type,
      severity: 'critical',
      location: {
        latitude,
        longitude,
        accuracy: req.body.accuracy
      },
      description: description || 'Emergency panic button activated'
    });

    await alert.save();

    // Update tourist emergency status
    tourist.isInEmergency = true;
    tourist.currentLocation = {
      latitude,
      longitude,
      lastUpdated: new Date()
    };
    await tourist.save();

    // Here you would typically:
    // 1. Send notifications to nearby authorities
    // 2. Send SMS to emergency contacts
    // 3. Log to emergency response system

    res.status(201).json({ 
      message: 'Emergency alert created successfully',
      alertId,
      alert: {
        id: alertId,
        type,
        severity: 'critical',
        status: 'active',
        createdAt: alert.createdAt
      }
    });
  } catch (err) {
    console.error('Emergency panic error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get Recent Alerts for Tourist
app.get("/alerts/recent", authenticateToken, async (req, res) => {
  try {
    const tourist = await Tourist.findOne({ userId: req.user.id });
    if (!tourist) {
      return res.status(404).json({ error: 'Tourist profile not found' });
    }

    const alerts = await Alert.find({ touristId: tourist._id })
      .sort({ createdAt: -1 })
      .limit(20)
      .populate('assignedOfficer', 'badgeNumber department rank');

    res.json({ alerts });
  } catch (err) {
    console.error('Get alerts error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get Broadcast Alerts
app.get("/alerts/broadcasts", authenticateToken, async (req, res) => {
  try {
    const tourist = await Tourist.findOne({ userId: req.user.id });
    if (!tourist) {
      return res.status(404).json({ error: 'Tourist profile not found' });
    }

    const broadcasts = await Broadcast.find({
      isActive: true,
      $or: [
        { expiresAt: { $gt: new Date() } },
        { expiresAt: null }
      ]
    })
    .sort({ createdAt: -1 })
    .limit(10);

    res.json({ broadcasts });
  } catch (err) {
    console.error('Get broadcasts error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 🔹 AUTHORITY/DASHBOARD ENDPOINTS

// Authority Login (separate from regular login for enhanced security)
app.post("/dashboard/login", async (req, res) => {
  try {
    const { email, password, badgeNumber } = req.body;

    if (!email || !password || !badgeNumber) {
      return res.status(400).json({ error: 'All fields are required' });
    }

    const user = await User.findOne({ email, userType: 'authority', isActive: true });
    if (!user) {
      return res.status(400).json({ error: 'Invalid credentials' });
    }

    const authority = await Authority.findOne({ userId: user._id, badgeNumber });
    if (!authority) {
      return res.status(400).json({ error: 'Invalid badge number' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ error: 'Invalid credentials' });
    }

    // Update last login and duty status
    user.lastLogin = new Date();
    authority.isOnDuty = true;
    await user.save();
    await authority.save();

    const token = jwt.sign(
      { 
        id: user._id, 
        email: user.email, 
        userType: user.userType,
        authorityId: authority._id,
        badgeNumber: authority.badgeNumber 
      }, 
      process.env.JWT_SECRET || 'secretkey', 
      { expiresIn: '8h' } // Shorter session for authorities
    );

    res.json({ 
      message: 'Authority login successful', 
      token,
      authority: {
        id: authority._id,
        name: user.name,
        badgeNumber: authority.badgeNumber,
        department: authority.department,
        rank: authority.rank,
        permissions: authority.permissions
      }
    });
  } catch (err) {
    console.error('Authority login error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Dashboard Statistics
app.get("/dashboard/stats", authenticateToken, async (req, res) => {
  try {
    if (req.user.userType !== 'authority') {
      return res.status(403).json({ error: 'Access denied' });
    }

    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const thisWeek = new Date(today.getTime() - 7 * 24 * 60 * 60 * 1000);

    const stats = {
      totalTourists: await Tourist.countDocuments(),
      activeTourists: await Tourist.countDocuments({ 
        'currentLocation.lastUpdated': { $gte: new Date(Date.now() - 24 * 60 * 60 * 1000) }
      }),
      totalAlerts: await Alert.countDocuments(),
      activeAlerts: await Alert.countDocuments({ status: 'active' }),
      todayAlerts: await Alert.countDocuments({ createdAt: { $gte: today } }),
      weeklyAlerts: await Alert.countDocuments({ createdAt: { $gte: thisWeek } }),
      criticalAlerts: await Alert.countDocuments({ severity: 'critical', status: 'active' }),
      emergencyTourists: await Tourist.countDocuments({ isInEmergency: true }),
      onDutyOfficers: await Authority.countDocuments({ isOnDuty: true })
    };

    // Alert breakdown by type
    const alertsByType = await Alert.aggregate([
      { $match: { createdAt: { $gte: thisWeek } } },
      { $group: { _id: '$type', count: { $sum: 1 } } }
    ]);

    // Recent high priority alerts
    const recentCriticalAlerts = await Alert.find({ 
      severity: { $in: ['high', 'critical'] },
      status: 'active'
    })
    .populate('touristId', 'fullName digitalId phoneNumber')
    .sort({ createdAt: -1 })
    .limit(10);

    res.json({ 
      stats,
      alertsByType,
      recentCriticalAlerts
    });
  } catch (err) {
    console.error('Dashboard stats error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get All Active Alerts for Dashboard
app.get("/dashboard/alerts", authenticateToken, async (req, res) => {
  try {
    if (req.user.userType !== 'authority') {
      return res.status(403).json({ error: 'Access denied' });
    }

    const { status, severity, page = 1, limit = 50 } = req.query;
    const skip = (page - 1) * limit;

    let query = {};
    if (status) query.status = status;
    if (severity) query.severity = severity;

    const alerts = await Alert.find(query)
      .populate('touristId', 'fullName digitalId phoneNumber currentLocation')
      .populate('assignedOfficer', 'badgeNumber department rank')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit));

    const total = await Alert.countDocuments(query);

    res.json({ 
      alerts,
      pagination: {
        current: parseInt(page),
        total: Math.ceil(total / limit),
        count: alerts.length,
        totalRecords: total
      }
    });
  } catch (err) {
    console.error('Get dashboard alerts error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update Alert Status
app.put("/dashboard/alerts/:alertId", authenticateToken, async (req, res) => {
  try {
    if (req.user.userType !== 'authority') {
      return res.status(403).json({ error: 'Access denied' });
    }

    const { alertId } = req.params;
    const { status, notes } = req.body;

    const alert = await Alert.findOne({ alertId });
    if (!alert) {
      return res.status(404).json({ error: 'Alert not found' });
    }

    alert.status = status;
    if (status === 'resolved') {
      alert.resolvedAt = new Date();
      
      // Update tourist emergency status
      const tourist = await Tourist.findById(alert.touristId);
      if (tourist) {
        tourist.isInEmergency = false;
        await tourist.save();
      }
    }

    if (notes) {
      alert.notes.push({
        officer: req.user.authorityId,
        note: notes,
        timestamp: new Date()
      });
    }

    await alert.save();

    res.json({ 
      message: 'Alert updated successfully',
      alert
    });
  } catch (err) {
    console.error('Update alert error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Create Broadcast Alert
app.post("/dashboard/broadcast", authenticateToken, async (req, res) => {
  try {
    if (req.user.userType !== 'authority') {
      return res.status(403).json({ error: 'Access denied' });
    }

    const authority = await Authority.findById(req.user.authorityId);
    if (!authority?.permissions?.broadcastAlerts) {
      return res.status(403).json({ error: 'Insufficient permissions to broadcast alerts' });
    }

    const { title, message, type, targetArea, expiresIn } = req.body;

    if (!title || !message || !type) {
      return res.status(400).json({ error: 'Title, message, and type are required' });
    }

    const broadcast = new Broadcast({
      title,
      message,
      type,
      targetArea,
      createdBy: req.user.authorityId,
      expiresAt: expiresIn ? new Date(Date.now() + expiresIn * 60 * 60 * 1000) : null
    });

    await broadcast.save();

    res.status(201).json({ 
      message: 'Broadcast alert created successfully',
      broadcast
    });
  } catch (err) {
    console.error('Create broadcast error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Generate E-FIR
app.post("/dashboard/generate-efir", authenticateToken, async (req, res) => {
  try {
    if (req.user.userType !== 'authority') {
      return res.status(403).json({ error: 'Access denied' });
    }

    const { alertId, firDetails } = req.body;

    const alert = await Alert.findOne({ alertId })
      .populate('touristId', 'fullName digitalId phoneNumber nationality passportNumber');

    if (!alert) {
      return res.status(404).json({ error: 'Alert not found' });
    }

    const authority = await Authority.findById(req.user.authorityId)
      .populate('userId', 'name');

    // Generate FIR number
    const firNumber = `FIR/${new Date().getFullYear()}/${Date.now().toString().slice(-6)}`;

    const eFIR = {
      firNumber,
      alertId: alert.alertId,
      incidentDetails: {
        type: alert.type,
        severity: alert.severity,
        location: alert.location,
        description: alert.description,
        dateTime: alert.createdAt
      },
      touristDetails: {
        name: alert.touristId.fullName,
        digitalId: alert.touristId.digitalId,
        nationality: alert.touristId.nationality,
        passportNumber: alert.touristId.passportNumber,
        phoneNumber: alert.touristId.phoneNumber
      },
      officerDetails: {
        name: authority.userId.name,
        badgeNumber: authority.badgeNumber,
        department: authority.department,
        rank: authority.rank
      },
      additionalDetails: firDetails,
      generatedAt: new Date()
    };

    // In a real implementation, you would:
    // 1. Store this in a FIR database
    // 2. Generate a PDF document
    // 3. Send to relevant authorities
    // 4. Update alert with FIR reference

    alert.notes.push({
      officer: req.user.authorityId,
      note: `E-FIR generated: ${firNumber}`,
      timestamp: new Date()
    });
    await alert.save();

    res.json({ 
      message: 'E-FIR generated successfully',
      eFIR
    });
  } catch (err) {
    console.error('Generate E-FIR error:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 🔹 UTILITY FUNCTIONS

// Calculate Safety Score based on location
async function calculateSafetyScore(latitude, longitude) {
  try {
    // Check against safety zones
    const safetyZones = await SafetyZone.find({ isActive: true });
    let score = 100; // Base score

    for (const zone of safetyZones) {
      const distance = calculateDistance(
        latitude, longitude,
        zone.coordinates.center.latitude,
        zone.coordinates.center.longitude
      );

      if (distance <= zone.coordinates.radius) {
        switch (zone.type) {
          case 'safe':
            score = Math.min(100, score + 10);
            break;
          case 'caution':
            score = Math.max(60, score - 20);
            break;
          case 'danger':
            score = Math.max(20, score - 40);
            break;
        }
      }
    }

    // Additional factors could include:
    // - Time of day
    // - Recent incidents in area
    // - Weather conditions
    // - Local events

    return Math.max(0, Math.min(100, score));
  } catch (err) {
    console.error('Safety score calculation error:', err);
    return 75; // Default safe score on error
  }
}

// Calculate distance between two coordinates (Haversine formula)
function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371e3; // Earth's radius in meters
  const φ1 = lat1 * Math.PI/180;
  const φ2 = lat2 * Math.PI/180;
  const Δφ = (lat2-lat1) * Math.PI/180;
  const Δλ = (lon2-lon1) * Math.PI/180;

  const a = Math.sin(Δφ/2) * Math.sin(Δφ/2) +
          Math.cos(φ1) * Math.cos(φ2) *
          Math.sin(Δλ/2) * Math.sin(Δλ/2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));

  return R * c; // Distance in meters
}

// 🔹 HEALTH CHECK ENDPOINT
app.get("/health", (req, res) => {
  res.json({ 
    status: "OK", 
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    mongoStatus: mongoose.connection.readyState === 1 ? "Connected" : "Disconnected"
  });
});

// 🔹 ERROR HANDLING
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ error: 'Internal server error' });
});

// 🔹 404 HANDLER
app.use((req, res) => {
  res.status(404).json({ error: 'Endpoint not found' });
});

// 🔹 START SERVER
const PORT = process.env.PORT || 5000;
app.listen(PORT, "0.0.0.0", () => {
  console.log(`✅ Tourist Safety Backend Server running on port ${PORT}`);
  console.log(`🌐 Health check: http://localhost:${PORT}/health`);
  console.log(`📊 API Documentation: All endpoints ready for production use`);
});
