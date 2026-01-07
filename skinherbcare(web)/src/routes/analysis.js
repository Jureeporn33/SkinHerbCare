import express from 'express';
import { getSalesData, getCategoryData } from '../../controllers/analysisController.js';
// import { protect, admin } from '../middleware/auth.js'; // Optional: Add security later

const router = express.Router();

// All routes here will be prefixed with /api/analysis
router.route('/sales').get(getSalesData); // GET /api/analysis/sales
router.route('/categories').get(getCategoryData); // GET /api/analysis/categories

export default router;
