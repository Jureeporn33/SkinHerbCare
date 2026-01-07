import mongoose from 'mongoose';

const connectDB = async () => {
  try {
    // ปิด Warning ของ Mongoose
    mongoose.set('strictQuery', false);

    // เช็คว่ามีค่า URI ใน .env ไหม
    if (!process.env.MONGODB_URI) {
      throw new Error('MONGODB_URI ไม่พบในไฟล์ .env กรุณาตรวจสอบ!');
    }

    console.log('🔍 Connecting to MongoDB...');

    // เริ่มเชื่อมต่อ
    const conn = await mongoose.connect(process.env.MONGODB_URI);

    // ถ้าเชื่อมต่อสำเร็จ จะขึ้นข้อความนี้
    console.log(`✅ MongoDB Connected: ${conn.connection.host}`);

  } catch (error) {
    console.error(`❌ MongoDB Connection Error: ${error.message}`);
    // ลบ process.exit(1) ออก หรือ comment ไว้
    // process.exit(1); 

    // อาจจะเพิ่ม logic ให้ retry connection ได้ในอนาคต
    console.log("⚠️ Retrying connection in 5 seconds...");
    setTimeout(connectDB, 5000);
  }
};

// **บรรทัดนี้สำคัญที่สุด** คือการส่งออกฟังก์ชันให้ server.js เรียกใช้ได้
export default connectDB;