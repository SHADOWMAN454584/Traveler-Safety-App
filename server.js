const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5000;

// 🔹 MIDDLEWARE SETUP
app.use(cors());
app.use(express.json());

// Rate limiting for security
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: { error: 'Too many requests, please try again later.' }
});
app.use(limiter);

// 🔹 DATABASE CONNECTION WITH AUTO-RETRY
const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('✅ MongoDB connected successfully');
    return true;
  } catch (error) {
    console.log('❌ MongoDB connection failed:', error.message);
    console.log('🔄 Retrying connection in 5 seconds...');
    setTimeout(connectDB, 5000);
    return false;
  }
};

// 🔹 DATABASE SCHEMAS
const UserSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, unique: true, required: true },
  password: { type: String, required: true },
  role: { type: String, enum: ['tourist', 'authority'], default: 'tourist' },
  createdAt: { type: Date, default: Date.now }
});

const TouristSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  personalInfo: {
    fullName: { type: String, required: true },
    age: { type: Number, required: true },
    gender: { type: String, enum: ['male', 'female', 'other'], required: true },
    nationality: { type: String, required: true },
    phoneNumber: { type: String, required: true },
    emergencyContact: {
      name: { type: String, required: true },
      phone: { type: String, required: true },
      relationship: { type: String, required: true }
    }
  },
  digitalId: { type: String, unique: true, required: true },
  safetyScore: { type: Number, default: 85 },
  currentLocation: {
    latitude: { type: Number },
    longitude: { type: Number },
    address: { type: String },
    lastUpdated: { type: Date, default: Date.now }
  },
  travelPlan: {
    destinations: [{ type: String }],
    startDate: { type: Date },
    endDate: { type: Date },
    accommodations: [{ type: String }]
  },
  isActive: { type: Boolean, default: true },
  createdAt: { type: Date, default: Date.now }
});

const AuthoritySchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  badgeNumber: { type: String, unique: true, required: true },
  department: { type: String, required: true },
  rank: { type: String, required: true },
  jurisdiction: {
    area: { type: String, required: true },
    coordinates: [{
      latitude: { type: Number },
      longitude: { type: Number }
    }]
  },
  permissions: {
    canViewTourists: { type: Boolean, default: true },
    canIssueAlerts: { type: Boolean, default: true },
    canAccessEmergency: { type: Boolean, default: true },
    canManageZones: { type: Boolean, default: false }
  },
  isActive: { type: Boolean, default: true },
  createdAt: { type: Date, default: Date.now }
});

const AlertSchema = new mongoose.Schema({
  alertId: { type: String, unique: true, required: true },
  touristId: { type: mongoose.Schema.Types.ObjectId, ref: 'Tourist', required: true },
  type: { type: String, enum: ['emergency', 'safety', 'medical', 'security'], required: true },
  severity: { type: String, enum: ['low', 'medium', 'high', 'critical'], required: true },
  title: { type: String, required: true },
  description: { type: String, required: true },
  location: {
    latitude: { type: Number, required: true },
    longitude: { type: Number, required: true },
    address: { type: String }
  },
  status: { type: String, enum: ['active', 'resolved', 'investigating'], default: 'active' },
  assignedAuthority: { type: mongoose.Schema.Types.ObjectId, ref: 'Authority' },
  timeline: [{
    timestamp: { type: Date, default: Date.now },
    action: { type: String },
    performedBy: { type: String },
    notes: { type: String }
  }],
  createdAt: { type: Date, default: Date.now }
});

const SafetyZoneSchema = new mongoose.Schema({
  zoneId: { type: String, unique: true, required: true },
  name: { type: String, required: true },
  description: { type: String },
  safetyLevel: { type: String, enum: ['very-safe', 'safe', 'moderate', 'caution', 'danger'], required: true },
  coordinates: {
    center: {
      latitude: { type: Number, required: true },
      longitude: { type: Number, required: true }
    },
    radius: { type: Number, required: true } // in meters
  },
  guidelines: [{ type: String }],
  facilities: [{ type: String }],
  emergencyContacts: [{
    type: { type: String },
    number: { type: String }
  }],
  isActive: { type: Boolean, default: true },
  createdAt: { type: Date, default: Date.now }
});

const BroadcastSchema = new mongoose.Schema({
  broadcastId: { type: String, unique: true, required: true },
  title: { type: String, required: true },
  message: { type: String, required: true },
  type: { type: String, enum: ['general', 'warning', 'emergency', 'update'], required: true },
  priority: { type: String, enum: ['low', 'medium', 'high', 'urgent'], required: true },
  targetArea: {
    type: { type: String, enum: ['all', 'zone', 'coordinates'], default: 'all' },
    zoneId: { type: String },
    coordinates: {
      latitude: { type: Number },
      longitude: { type: Number },
      radius: { type: Number }
    }
  },
  issuedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'Authority', required: true },
  isActive: { type: Boolean, default: true },
  expiresAt: { type: Date },
  createdAt: { type: Date, default: Date.now }
});

// Create models
const User = mongoose.model('User', UserSchema);
const Tourist = mongoose.model('Tourist', TouristSchema);
const Authority = mongoose.model('Authority', AuthoritySchema);
const Alert = mongoose.model('Alert', AlertSchema);
const SafetyZone = mongoose.model('SafetyZone', SafetyZoneSchema);
const Broadcast = mongoose.model('Broadcast', BroadcastSchema);

// 🔹 AUTHENTICATION MIDDLEWARE
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ error: 'Invalid token' });
    req.user = user;
    next();
  });
};

// 🔹 UTILITY FUNCTIONS
const generateDigitalId = () => {
  const prefix = 'TID';
  const timestamp = Date.now().toString(36);
  const random = Math.random().toString(36).substr(2, 5);
  return `${prefix}-${timestamp}-${random}`.toUpperCase();
};

const generateAlertId = () => {
  const prefix = 'ALERT';
  const timestamp = Date.now().toString(36);
  const random = Math.random().toString(36).substr(2, 4);
  return `${prefix}-${timestamp}-${random}`.toUpperCase();
};

const generateBroadcastId = () => {
  const prefix = 'BCAST';
  const timestamp = Date.now().toString(36);
  const random = Math.random().toString(36).substr(2, 4);
  return `${prefix}-${timestamp}-${random}`.toUpperCase();
};

const calculateSafetyScore = (tourist) => {
  let score = 85; // Base score
  
  if (tourist.personalInfo && tourist.personalInfo.emergencyContact) score += 10;
  if (tourist.travelPlan && tourist.travelPlan.destinations && tourist.travelPlan.destinations.length > 0) score += 5;
  if (tourist.currentLocation && tourist.currentLocation.latitude && tourist.currentLocation.longitude) score += 5;
  
  return Math.min(score, 100);
};

// 🔹 API ROUTES

// Health check
app.get('/', (req, res) => {
  res.json({
    message: '🛡️ Tourist Safety Backend API',
    status: 'active',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    endpoints: {
      auth: '/api/auth/*',
      tourists: '/api/tourists/*',
      authorities: '/api/authorities/*',
      alerts: '/api/alerts/*',
      safety: '/api/safety/*',
      broadcasts: '/api/broadcasts/*'
    }
  });
});

// 🔹 AUTHENTICATION ROUTES
app.post('/api/auth/register', async (req, res) => {
  try {
    const { name, email, password, role = 'tourist' } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({ error: 'All fields are required' });
    }

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ error: 'User already exists' });
    }

    const hashedPassword = await bcrypt.hash(password, 12);
    const user = new User({ name, email, password: hashedPassword, role });
    await user.save();

    const token = jwt.sign(
      { userId: user._id, email: user.email, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: '24h' }
    );

    res.status(201).json({
      message: 'User registered successfully',
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role
      }
    });
  } catch (error) {
    res.status(500).json({ error: 'Registration failed' });
  }
});

app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ error: 'Invalid credentials' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ error: 'Invalid credentials' });
    }

    const token = jwt.sign(
      { userId: user._id, email: user.email, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: '24h' }
    );

    res.json({
      message: 'Login successful',
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role
      }
    });
  } catch (error) {
    res.status(500).json({ error: 'Login failed' });
  }
});

// 🔹 TOURIST ROUTES
app.post('/api/tourists/profile', authenticateToken, async (req, res) => {
  try {
    const { personalInfo, travelPlan } = req.body;

    if (!personalInfo || !personalInfo.fullName || !personalInfo.age || !personalInfo.phoneNumber) {
      return res.status(400).json({ error: 'Personal information is required' });
    }

    const digitalId = generateDigitalId();
    const tourist = new Tourist({
      userId: req.user.userId,
      personalInfo,
      digitalId,
      travelPlan: travelPlan || {},
      safetyScore: calculateSafetyScore({ personalInfo, travelPlan: travelPlan || {} })
    });

    await tourist.save();

    res.status(201).json({
      message: 'Tourist profile created successfully',
      digitalId,
      tourist
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to create profile' });
  }
});

app.get('/api/tourists/profile', authenticateToken, async (req, res) => {
  try {
    const tourist = await Tourist.findOne({ userId: req.user.userId }).populate('userId');
    
    if (!tourist) {
      return res.status(404).json({ error: 'Tourist profile not found' });
    }

    res.json(tourist);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch profile' });
  }
});

app.put('/api/tourists/location', authenticateToken, async (req, res) => {
  try {
    const { latitude, longitude, address } = req.body;

    if (!latitude || !longitude) {
      return res.status(400).json({ error: 'Latitude and longitude are required' });
    }

    const tourist = await Tourist.findOneAndUpdate(
      { userId: req.user.userId },
      {
        currentLocation: {
          latitude,
          longitude,
          address: address || '',
          lastUpdated: new Date()
        }
      },
      { new: true }
    );

    if (!tourist) {
      return res.status(404).json({ error: 'Tourist profile not found' });
    }

    res.json({
      message: 'Location updated successfully',
      location: tourist.currentLocation
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update location' });
  }
});

// 🔹 ALERT ROUTES
app.post('/api/alerts/emergency', authenticateToken, async (req, res) => {
  try {
    const { type, severity, title, description, location } = req.body;

    if (!type || !severity || !title || !location) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const tourist = await Tourist.findOne({ userId: req.user.userId });
    if (!tourist) {
      return res.status(404).json({ error: 'Tourist profile not found' });
    }

    const alertId = generateAlertId();
    const alert = new Alert({
      alertId,
      touristId: tourist._id,
      type,
      severity,
      title,
      description,
      location,
      timeline: [{
        action: 'Alert created',
        performedBy: tourist.personalInfo.fullName,
        notes: 'Emergency alert submitted'
      }]
    });

    await alert.save();

    res.status(201).json({
      message: 'Emergency alert created successfully',
      alertId,
      alert
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to create alert' });
  }
});

app.get('/api/alerts/my-alerts', authenticateToken, async (req, res) => {
  try {
    const tourist = await Tourist.findOne({ userId: req.user.userId });
    if (!tourist) {
      return res.status(404).json({ error: 'Tourist profile not found' });
    }

    const alerts = await Alert.find({ touristId: tourist._id }).sort({ createdAt: -1 });

    res.json({
      alerts,
      total: alerts.length
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch alerts' });
  }
});

// 🔹 SAFETY ZONE ROUTES
app.get('/api/safety/zones', async (req, res) => {
  try {
    const zones = await SafetyZone.find({ isActive: true });

    res.json({
      zones,
      total: zones.length
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch safety zones' });
  }
});

app.get('/api/safety/score', authenticateToken, async (req, res) => {
  try {
    const tourist = await Tourist.findOne({ userId: req.user.userId });
    if (!tourist) {
      return res.status(404).json({ error: 'Tourist profile not found' });
    }

    const updatedScore = calculateSafetyScore(tourist);
    
    await Tourist.findByIdAndUpdate(tourist._id, { safetyScore: updatedScore });

    res.json({
      safetyScore: updatedScore,
      factors: {
        hasEmergencyContact: !!(tourist.personalInfo && tourist.personalInfo.emergencyContact),
        hasTravelPlan: !!(tourist.travelPlan && tourist.travelPlan.destinations && tourist.travelPlan.destinations.length > 0),
        hasLocation: !!(tourist.currentLocation && tourist.currentLocation.latitude && tourist.currentLocation.longitude)
      }
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to calculate safety score' });
  }
});

// 🔹 BROADCAST ROUTES
app.get('/api/broadcasts', async (req, res) => {
  try {
    const { type, priority } = req.query;
    
    let filter = { isActive: true };
    if (type) filter.type = type;
    if (priority) filter.priority = priority;

    const broadcasts = await Broadcast.find(filter)
      .populate('issuedBy')
      .sort({ createdAt: -1 })
      .limit(20);

    res.json({
      broadcasts,
      total: broadcasts.length
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch broadcasts' });
  }
});

// 🔹 AUTHORITY ROUTES
app.post('/api/authorities/profile', authenticateToken, async (req, res) => {
  try {
    const { badgeNumber, department, rank, jurisdiction, permissions } = req.body;

    if (!badgeNumber || !department || !rank) {
      return res.status(400).json({ error: 'Badge number, department, and rank are required' });
    }

    const existingAuthority = await Authority.findOne({ badgeNumber });
    if (existingAuthority) {
      return res.status(400).json({ error: 'Badge number already exists' });
    }

    const authority = new Authority({
      userId: req.user.userId,
      badgeNumber,
      department,
      rank,
      jurisdiction: jurisdiction || { area: 'General', coordinates: [] },
      permissions: permissions || {}
    });

    await authority.save();

    res.status(201).json({
      message: 'Authority profile created successfully',
      authority
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to create authority profile' });
  }
});

app.get('/api/authorities/dashboard', authenticateToken, async (req, res) => {
  try {
    const authority = await Authority.findOne({ userId: req.user.userId });
    if (!authority) {
      return res.status(404).json({ error: 'Authority profile not found' });
    }

    const activeAlerts = await Alert.countDocuments({ status: 'active' });
    const totalTourists = await Tourist.countDocuments({ isActive: true });
    const recentAlerts = await Alert.find({ status: 'active' })
      .populate('touristId')
      .sort({ createdAt: -1 })
      .limit(10);

    res.json({
      stats: {
        activeAlerts,
        totalTourists,
        resolvedToday: await Alert.countDocuments({
          status: 'resolved',
          createdAt: { $gte: new Date(new Date().setHours(0, 0, 0, 0)) }
        })
      },
      recentAlerts,
      authority
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch dashboard' });
  }
});

app.put('/api/authorities/alerts/:alertId', authenticateToken, async (req, res) => {
  try {
    const { alertId } = req.params;
    const { status, notes } = req.body;

    const authority = await Authority.findOne({ userId: req.user.userId });
    if (!authority) {
      return res.status(404).json({ error: 'Authority profile not found' });
    }

    const alert = await Alert.findOne({ alertId });
    if (!alert) {
      return res.status(404).json({ error: 'Alert not found' });
    }

    const updateData = {
      status,
      assignedAuthority: authority._id
    };

    if (notes) {
      alert.timeline.push({
        action: `Status updated to ${status}`,
        performedBy: `${authority.rank} ${authority.badgeNumber}`,
        notes
      });
    }

    const updatedAlert = await Alert.findOneAndUpdate(
      { alertId },
      updateData,
      { new: true }
    );

    res.json({
      message: 'Alert updated successfully',
      alert: updatedAlert
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update alert' });
  }
});

app.post('/api/authorities/broadcasts', authenticateToken, async (req, res) => {
  try {
    const { title, message, type, priority, targetArea } = req.body;

    if (!title || !message || !type || !priority) {
      return res.status(400).json({ error: 'Title, message, type, and priority are required' });
    }

    const authority = await Authority.findOne({ userId: req.user.userId });
    if (!authority) {
      return res.status(404).json({ error: 'Authority profile not found' });
    }

    const broadcastId = generateBroadcastId();
    const broadcast = new Broadcast({
      broadcastId,
      title,
      message,
      type,
      priority,
      targetArea: targetArea || { type: 'all' },
      issuedBy: authority._id
    });

    await broadcast.save();

    res.status(201).json({
      message: 'Broadcast created successfully',
      broadcastId,
      broadcast
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to create broadcast' });
  }
});

// 🔹 ADMIN/SYSTEM ROUTES
app.get('/api/system/status', async (req, res) => {
  try {
    const stats = {
      totalUsers: await User.countDocuments(),
      totalTourists: await Tourist.countDocuments(),
      totalAuthorities: await Authority.countDocuments(),
      activeAlerts: await Alert.countDocuments({ status: 'active' }),
      totalSafetyZones: await SafetyZone.countDocuments({ isActive: true }),
      activeBroadcasts: await Broadcast.countDocuments({ isActive: true }),
      systemStatus: 'operational',
      mongoStatus: mongoose.connection.readyState === 1 ? "Connected" : "Disconnected",
      timestamp: new Date().toISOString()
    };

    res.json(stats);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch system status' });
  }
});

// 🔹 DATABASE SEEDING FUNCTION (RUNS ON STARTUP)
const seedDatabase = async () => {
  try {
    console.log('🌱 Checking if database seeding is needed...');

    const userCount = await User.countDocuments();
    if (userCount > 0) {
      console.log('✅ Database already has data, skipping seed');
      return;
    }

    console.log('🌱 Seeding database with initial data...');

    // Seed Authority Users
    const authorities = [
      {
        name: "Inspector Raj Sharma",
        email: "raj.sharma@delhipolice.gov.in",
        password: await bcrypt.hash("police123", 12),
        role: "authority"
      },
      {
        name: "Sub-Inspector Priya Singh", 
        email: "priya.singh@delhipolice.gov.in",
        password: await bcrypt.hash("police123", 12),
        role: "authority"
      },
      {
        name: "ASI Kumar Patel",
        email: "kumar.patel@delhipolice.gov.in", 
        password: await bcrypt.hash("police123", 12),
        role: "authority"
      }
    ];

    const createdUsers = await User.insertMany(authorities);
    console.log('✅ Created 3 authority users');

    // Seed Authority Profiles
    const authorityProfiles = [
      {
        userId: createdUsers[0]._id,
        badgeNumber: "DLP001",
        department: "Delhi Police",
        rank: "Inspector",
        jurisdiction: { area: "Central Delhi", coordinates: [] },
        permissions: { canManageZones: true }
      },
      {
        userId: createdUsers[1]._id,
        badgeNumber: "DLP002", 
        department: "Delhi Police",
        rank: "Sub-Inspector",
        jurisdiction: { area: "South Delhi", coordinates: [] }
      },
      {
        userId: createdUsers[2]._id,
        badgeNumber: "DLP003",
        department: "Delhi Police", 
        rank: "Assistant Sub-Inspector",
        jurisdiction: { area: "North Delhi", coordinates: [] }
      }
    ];

    await Authority.insertMany(authorityProfiles);
    console.log('✅ Created 3 authority profiles');

    // Seed Safety Zones
    const safetyZones = [
      {
        zoneId: "ZONE-001",
        name: "India Gate Area",
        description: "Popular tourist destination with high security",
        safetyLevel: "very-safe",
        coordinates: { center: { latitude: 28.6129, longitude: 77.2295 }, radius: 1000 },
        guidelines: ["Stay in well-lit areas", "Keep valuables secure"],
        facilities: ["Police patrol", "CCTV coverage", "Tourist helpdesk"]
      },
      {
        zoneId: "ZONE-002", 
        name: "Red Fort Complex",
        description: "Historic monument with moderate tourist activity",
        safetyLevel: "safe",
        coordinates: { center: { latitude: 28.6562, longitude: 77.2410 }, radius: 800 },
        guidelines: ["Follow monument rules", "Stay with group"],
        facilities: ["Security checkpoints", "First aid center"]
      },
      {
        zoneId: "ZONE-003",
        name: "Connaught Place",
        description: "Busy commercial area requiring caution",
        safetyLevel: "moderate", 
        coordinates: { center: { latitude: 28.6315, longitude: 77.2167 }, radius: 500 },
        guidelines: ["Beware of pickpockets", "Use authorized transport"],
        facilities: ["Police outpost", "Emergency helpline"]
      },
      {
        zoneId: "ZONE-004",
        name: "Lotus Temple",
        description: "Peaceful religious site with good security",
        safetyLevel: "very-safe",
        coordinates: { center: { latitude: 28.5535, longitude: 77.2588 }, radius: 600 },
        guidelines: ["Maintain silence", "Follow temple protocols"],
        facilities: ["Security guards", "Visitor guidance"]
      },
      {
        zoneId: "ZONE-005",
        name: "Humayun's Tomb",
        description: "World Heritage site with standard security",
        safetyLevel: "safe",
        coordinates: { center: { latitude: 28.5930, longitude: 77.2507 }, radius: 700 },
        guidelines: ["Stay on designated paths", "Respect heritage rules"],
        facilities: ["Monument security", "Tourist information"]
      }
    ];

    await SafetyZone.insertMany(safetyZones);
    console.log('✅ Created 5 safety zones');

    // Seed Sample Broadcasts
    const broadcasts = [
      {
        broadcastId: generateBroadcastId(),
        title: "Weather Alert",
        message: "Heavy rainfall expected in Delhi NCR. Tourists advised to plan indoor activities.",
        type: "warning",
        priority: "medium",
        targetArea: { type: "all" },
        issuedBy: createdUsers[0]._id
      },
      {
        broadcastId: generateBroadcastId(),
        title: "Festival Celebration",
        message: "Diwali celebrations at India Gate. Extra security arrangements in place.",
        type: "general",
        priority: "low",
        targetArea: { type: "zone", zoneId: "ZONE-001" },
        issuedBy: createdUsers[1]._id
      },
      {
        broadcastId: generateBroadcastId(),
        title: "Traffic Advisory", 
        message: "Road closures near Red Fort due to maintenance work. Use alternate routes.",
        type: "update",
        priority: "medium",
        targetArea: { type: "zone", zoneId: "ZONE-002" },
        issuedBy: createdUsers[2]._id
      }
    ];

    await Broadcast.insertMany(broadcasts);
    console.log('✅ Created 3 sample broadcasts');

    console.log('🎉 Database seeding completed successfully!');
    console.log('📋 Test Credentials:');
    console.log('   Inspector: raj.sharma@delhipolice.gov.in | Password: police123');
    console.log('   Sub-Inspector: priya.singh@delhipolice.gov.in | Password: police123');
    console.log('   ASI: kumar.patel@delhipolice.gov.in | Password: police123');

  } catch (error) {
    console.log('❌ Database seeding failed:', error.message);
  }
};

// 🔹 SERVER STARTUP
const startServer = async () => {
  try {
    console.log('🚀 Starting Tourist Safety Backend...');
    
    // Connect to database
    await connectDB();
    
    // Seed database if needed
    await seedDatabase();
    
    // Start server
    app.listen(PORT, () => {
      console.log(`✅ Server running on port ${PORT}`);
      console.log(`🌐 API Base URL: http://localhost:${PORT}`);
      console.log(`📊 Health Check: http://localhost:${PORT}/`);
      console.log(`📱 Ready for Flutter app integration!`);
    });
    
  } catch (error) {
    console.error('❌ Server startup failed:', error);
    process.exit(1);
  }
};

// Handle graceful shutdown
process.on('SIGTERM', () => {
  console.log('🔄 SIGTERM received, shutting down gracefully');
  mongoose.connection.close(() => {
    console.log('💤 MongoDB connection closed');
    process.exit(0);
  });
});

// Start the server
startServer();

module.exports = app;
