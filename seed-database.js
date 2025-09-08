const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config();

// Connect to MongoDB
mongoose.connect(process.env.MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

// Import models (simplified versions for seeding)
const UserSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, unique: true, required: true },
  password: { type: String, required: true },
  userType: { type: String, enum: ['tourist', 'authority'], default: 'tourist' },
  createdAt: { type: Date, default: Date.now },
  lastLogin: { type: Date },
  isActive: { type: Boolean, default: true }
});

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

const SafetyZoneSchema = new mongoose.Schema({
  name: { type: String, required: true },
  type: { type: String, enum: ['safe', 'caution', 'danger'], required: true },
  coordinates: {
    center: {
      latitude: Number,
      longitude: Number
    },
    radius: Number
  },
  description: String,
  isActive: { type: Boolean, default: true },
  createdAt: { type: Date, default: Date.now }
});

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
  createdAt: { type: Date, default: Date.now },
  expiresAt: Date
});

const User = mongoose.model('User', UserSchema);
const Authority = mongoose.model('Authority', AuthoritySchema);
const SafetyZone = mongoose.model('SafetyZone', SafetyZoneSchema);
const Broadcast = mongoose.model('Broadcast', BroadcastSchema);

async function seedDatabase() {
  try {
    console.log('🌱 Starting database seeding...');

    // Clear existing data
    await User.deleteMany({ userType: 'authority' });
    await Authority.deleteMany({});
    await SafetyZone.deleteMany({});
    await Broadcast.deleteMany({});

    // Create Authority Users
    const authorityUsers = [
      {
        name: 'Inspector Raj Sharma',
        email: 'raj.sharma@delhipolice.gov.in',
        password: await bcrypt.hash('police123', 12),
        userType: 'authority'
      },
      {
        name: 'Sub-Inspector Priya Singh',
        email: 'priya.singh@delhipolice.gov.in',
        password: await bcrypt.hash('police123', 12),
        userType: 'authority'
      },
      {
        name: 'ASI Kumar Patel',
        email: 'kumar.patel@delhipolice.gov.in',
        password: await bcrypt.hash('police123', 12),
        userType: 'authority'
      }
    ];

    const createdUsers = await User.insertMany(authorityUsers);
    console.log('✅ Authority users created');

    // Create Authority Profiles
    const authorities = [
      {
        userId: createdUsers[0]._id,
        badgeNumber: 'DLP001',
        department: 'Delhi Police',
        rank: 'Inspector',
        jurisdiction: {
          state: 'Delhi',
          district: 'Central Delhi',
          area: 'Connaught Place'
        },
        permissions: {
          viewAlerts: true,
          manageAlerts: true,
          generateReports: true,
          broadcastAlerts: true
        }
      },
      {
        userId: createdUsers[1]._id,
        badgeNumber: 'DLP002',
        department: 'Delhi Police',
        rank: 'Sub-Inspector',
        jurisdiction: {
          state: 'Delhi',
          district: 'South Delhi',
          area: 'India Gate'
        },
        permissions: {
          viewAlerts: true,
          manageAlerts: true,
          generateReports: false,
          broadcastAlerts: false
        }
      },
      {
        userId: createdUsers[2]._id,
        badgeNumber: 'DLP003',
        department: 'Delhi Police',
        rank: 'Assistant Sub-Inspector',
        jurisdiction: {
          state: 'Delhi',
          district: 'New Delhi',
          area: 'Red Fort Area'
        },
        permissions: {
          viewAlerts: true,
          manageAlerts: false,
          generateReports: false,
          broadcastAlerts: false
        }
      }
    ];

    await Authority.insertMany(authorities);
    console.log('✅ Authority profiles created');

    // Create Safety Zones
    const safetyZones = [
      {
        name: 'India Gate Tourist Area',
        type: 'safe',
        coordinates: {
          center: { latitude: 28.6129, longitude: 77.2295 },
          radius: 1000
        },
        description: 'Well-patrolled tourist area with CCTV coverage'
      },
      {
        name: 'Red Fort Complex',
        type: 'safe',
        coordinates: {
          center: { latitude: 28.6562, longitude: 77.2410 },
          radius: 800
        },
        description: 'UNESCO World Heritage site with security personnel'
      },
      {
        name: 'Connaught Place',
        type: 'caution',
        coordinates: {
          center: { latitude: 28.6315, longitude: 77.2167 },
          radius: 1200
        },
        description: 'Busy commercial area - be aware of pickpockets'
      },
      {
        name: 'Old Delhi Market Area',
        type: 'caution',
        coordinates: {
          center: { latitude: 28.6506, longitude: 77.2334 },
          radius: 1500
        },
        description: 'Crowded market area - exercise caution'
      },
      {
        name: 'Yamuna River Bank',
        type: 'danger',
        coordinates: {
          center: { latitude: 28.6692, longitude: 77.2482 },
          radius: 2000
        },
        description: 'Avoid during night hours - poorly lit area'
      }
    ];

    await SafetyZone.insertMany(safetyZones);
    console.log('✅ Safety zones created');

    // Create Sample Broadcast Alerts
    const broadcasts = [
      {
        title: 'Weather Advisory',
        message: 'Heavy rainfall expected in Delhi NCR region from 6 PM today. Tourists are advised to carry umbrellas and avoid low-lying areas.',
        type: 'warning',
        targetArea: {
          state: 'Delhi',
          district: 'All Districts',
          radius: 50000
        },
        createdBy: authorities[0]._id,
        expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000) // 24 hours from now
      },
      {
        title: 'Festival Celebration',
        message: 'Diwali celebrations ongoing at India Gate. Extra security deployed. Enjoy the festivities safely!',
        type: 'info',
        targetArea: {
          state: 'Delhi',
          district: 'Central Delhi',
          radius: 5000
        },
        createdBy: authorities[0]._id,
        expiresAt: new Date(Date.now() + 12 * 60 * 60 * 1000) // 12 hours from now
      },
      {
        title: 'Emergency Drill',
        message: 'Emergency response drill will be conducted at Red Fort area between 2-4 PM. This is a scheduled drill, not a real emergency.',
        type: 'info',
        targetArea: {
          state: 'Delhi',
          district: 'North Delhi',
          radius: 3000
        },
        createdBy: authorities[1]._id,
        expiresAt: new Date(Date.now() + 6 * 60 * 60 * 1000) // 6 hours from now
      }
    ];

    await Broadcast.insertMany(broadcasts);
    console.log('✅ Broadcast alerts created');

    console.log('\n🎉 Database seeding completed successfully!');
    console.log('\n📋 Seeded Data Summary:');
    console.log(`   👮 Authority Users: ${authorityUsers.length}`);
    console.log(`   🏛️  Authority Profiles: ${authorities.length}`);
    console.log(`   🛡️  Safety Zones: ${safetyZones.length}`);
    console.log(`   📢 Broadcast Alerts: ${broadcasts.length}`);

    console.log('\n🔑 Authority Login Credentials:');
    console.log('   Email: raj.sharma@delhipolice.gov.in | Badge: DLP001 | Password: police123');
    console.log('   Email: priya.singh@delhipolice.gov.in | Badge: DLP002 | Password: police123');
    console.log('   Email: kumar.patel@delhipolice.gov.in | Badge: DLP003 | Password: police123');

    console.log('\n🌐 Test your API endpoints:');
    console.log('   Health: GET http://localhost:5000/health');
    console.log('   Authority Login: POST http://localhost:5000/dashboard/login');
    console.log('   Tourist Signup: POST http://localhost:5000/signup');

  } catch (error) {
    console.error('❌ Seeding failed:', error);
  } finally {
    mongoose.connection.close();
  }
}

// Run seeding
seedDatabase();
