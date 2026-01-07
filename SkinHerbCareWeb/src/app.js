import express from 'express';
import dotenv from 'dotenv';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import path from 'path';
import { fileURLToPath } from 'url';
import morgan from 'morgan'; // 📦 แนะนำให้ลง npm install morgan เพิ่ม
import connectDB from './config/db.js';

// Import Routes
import authRoutes from './routes/auth.js';
import adminRoutes from './routes/admin.js';
import geminiRoutes from './routes/gemini.js';

// Config
dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Connect to Database
connectDB();

// Initialize Express
const app = express();

// 1. Logger (ช่วยดู Log เวลาขึ้น Server จริง)
app.use(morgan('dev'));

// Security Middleware
app.use(
  helmet({
    contentSecurityPolicy: {
      directives: {
        ...helmet.contentSecurityPolicy.getDefaultDirectives(),
        "script-src": ["'self'", "https://cdn.tailwindcss.com", "https://cdn.jsdelivr.net/npm/chart.js", "'unsafe-inline'"],
        "style-src": ["'self'", "https://fonts.googleapis.com", "'unsafe-inline'"],
        "font-src": ["'self'", "https://fonts.gstatic.com"],
        "img-src": ["'self'", "data:", "https://placehold.co"],
        "connect-src": ["'self'", process.env.FRONTEND_URL || "*"], // กันเหนียวสำหรับ API call
      },
    },
    crossOriginResourcePolicy: { policy: "cross-origin" },
  })
);

// 2. CORS แบบปลอดภัย (Production Ready)
const whitelist = [
  'http://localhost:5173', 
  'http://localhost:3000',
  process.env.FRONTEND_URL // อย่าลืมใส่ใน .env บน Server
];

app.use(cors({
  origin: function (origin, callback) {
    if (!origin || whitelist.includes(origin)) {
      callback(null, true);
    } else {
      console.log('Blocked by CORS:', origin);
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true
}));

// Rate Limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  standardHeaders: true, 
  legacyHeaders: false,
});
app.use('/api/', limiter);

// Body Parser
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/gemini', geminiRoutes);

// Static Files
app.use(express.static(path.join(__dirname, '../public')));

// 3. Catch-all Route (แก้ปัญหา Refresh แล้วจอขาว/404 สำหรับ SPA)
app.get('*', (req, res) => {
  // ตรวจสอบว่าไม่ใช่ API call ถึงค่อยส่ง index.html
  if (!req.path.startsWith('/api')) {
    res.sendFile(path.join(__dirname, '../public', 'index.html'));
  } else {
    res.status(404).json({ success: false, message: 'API path not found' });
  }
});

// Error Handler
app.use((err, req, res, next) => {
  console.error('❌ Error:', err.stack);
  res.status(500).json({
    success: false,
    message: process.env.NODE_ENV === 'production' ? 'เกิดข้อผิดพลาดภายในเซิร์ฟเวอร์' : err.message,
  });
});

// Start Server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`
╔═══════════════════════════════════════════════════╗
║   🌿 Skin Herb Care System                        ║
║   🚀 Server is running on port ${PORT}               ║
╚═══════════════════════════════════════════════════╝
  `);
});