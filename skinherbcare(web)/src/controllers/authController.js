import User from '../models/User.js';
import jwt from 'jsonwebtoken';

// ฟังก์ชันสร้าง Token
const generateToken = (id) => {
    return jwt.sign({ id }, process.env.JWT_SECRET, {
        expiresIn: '30d',
    });
};

// @desc    สมัครสมาชิก
// @route   POST /api/auth/register
export const registerUser = async (req, res) => {
    const { firstName, lastName, email, password } = req.body;

    try {
        const userExists = await User.findOne({ email });

        if (userExists) {
            return res.status(400).json({ success: false, message: 'อีเมลนี้ถูกใช้งานแล้ว' });
        }

        // สร้าง User จริงลง MongoDB (Password จะถูก Hash อัตโนมัติจาก Model)
        const user = await User.create({
            firstName,
            lastName,
            email,
            password,
        });

        if (user) {
            res.status(201).json({
                success: true,
                _id: user._id,
                firstName: user.firstName,
                lastName: user.lastName,
                email: user.email,
                token: generateToken(user._id), // ส่ง Token จริงกลับไป
            });
        } else {
            res.status(400).json({ success: false, message: 'ข้อมูลผู้ใช้ไม่ถูกต้อง' });
        }
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// @desc    เข้าสู่ระบบ
// @route   POST /api/auth/login
export const loginUser = async (req, res) => {
    const { email, password } = req.body;

    try {
        // หา User จากอีเมล และขอ field password มาด้วย (เพราะใน Model set select: false ไว้)
        const user = await User.findOne({ email }).select('+password');

        // ตรวจสอบรหัสผ่านด้วย method ที่เขียนไว้ใน Model
        if (user && (await user.matchPassword(password))) {
            res.json({
                success: true,
                _id: user._id,
                firstName: user.firstName,
                lastName: user.lastName,
                email: user.email,
                token: generateToken(user._id), // ส่ง Token จริงที่ Auth Middleware จะอ่านรู้เรื่อง
            });
        } else {
            res.status(401).json({ success: false, message: 'อีเมลหรือรหัสผ่านไม่ถูกต้อง' });
        }
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// @desc    ดึงข้อมูลโปรไฟล์
// @route   GET /api/auth/profile
export const getUserProfile = async (req, res) => {
    try {
        const user = await User.findById(req.user._id);
        if (user) {
            res.json({
                success: true,
                user: {
                    id: user._id,
                    firstName: user.firstName,
                    lastName: user.lastName,
                    email: user.email,
                    role: user.role
                }
            });
        } else {
            res.status(404).json({ success: false, message: 'ไม่พบผู้ใช้' });
        }
    } catch (error) {
        res.status(500).json({ success: false, message: 'Server Error' });
    }
};