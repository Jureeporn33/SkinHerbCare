import os
from rembg import remove
from PIL import Image
# codeช่วยลบพื้นหลังโปรงใส ว่านหาง
# 📂 โฟลเดอร์ที่เก็บรูปต้นฉบับ
input_dir = r"D:\DB_BNA\dataset_5\ว่านหาง\ทดสอบ"

# 📂 โฟลเดอร์สำหรับบันทึกรูปที่ลบพื้นหลังแล้ว
output_dir = r"D:\output_remove_bg\ว่านหาง"

# สร้างโฟลเดอร์ output ถ้ายังไม่มี
os.makedirs(output_dir, exist_ok=True)

# วนลูปทุกไฟล์ใน input_dir
for filename in os.listdir(input_dir):
    if filename.lower().endswith(('.png', '.jpg', '.jpeg')):  # กรองเฉพาะไฟล์รูป
        input_path = os.path.join(input_dir, filename)

        # ตั้งชื่อไฟล์ผลลัพธ์ใหม่ (เปลี่ยนนามสกุลเป็น .png)
        name, _ = os.path.splitext(filename)
        output_path = os.path.join(output_dir, f"{name}-no-bg.png")

        # เปิดภาพ
        input_image = Image.open(input_path)

        # ลบพื้นหลัง
        output_image = remove(input_image)

        # บันทึกผลลัพธ์
        output_image.save(output_path)

        print(f"✅ ลบพื้นหลัง: {filename} → {output_path}")

print("🎉 เสร็จสิ้น ลบพื้นหลังครบทุกไฟล์ในโฟลเดอร์แล้ว!")
