import os
from pathlib import Path
import cv2
import numpy as np
from rembg import remove, new_session
from PIL import Image
from typing import List

# --- การตั้งค่า (ปรับแก้ตรงนี้) ---

# โฟลเดอร์ที่เก็บรูปภาพต้นฉบับ
INPUT_DIR = Path(r"C:\Dataset\img_resize\พลูคาว\640")

# โฟลเดอร์สำหรับเก็บผลลัพธ์
OUTPUT_DIR = Path(r"C:\Dataset\img_removeBG\พลูคาว")

# กำหนดค่าสีขาว: สีใดๆ ที่มีค่า R, G, B มากกว่าหรือเท่ากับค่านี้ จะถูกลบ
# F0 ในเลขฐาน 16 คือ 240 ในเลขฐาน 10
NEAR_WHITE_THRESHOLD = 240

# --- สิ้นสุดการตั้งค่า ---


def clean_background(img: Image.Image, session) -> Image.Image:
    """
    ลบพื้นหลังด้วย rembg และทำความสะอาดขอบขาวที่หลงเหลืออยู่
    """
    # 1. ลบพื้นหลังด้วยโมเดล rembg
    # ผลลัพธ์ที่ได้จะเป็นภาพที่มี Alpha channel (ความโปร่งใส)
    img_no_bg = remove(img, session=session)

    # 2. แปลงภาพ PIL เป็น NumPy array เพื่อให้ OpenCV จัดการได้
    # และแยก channel สี (Red, Green, Blue) และ Alpha ออกจากกัน
    arr = np.array(img_no_bg)
    r, g, b, a = cv2.split(arr)

    # 3. สร้างเงื่อนไขเพื่อหาพิกเซลที่เป็น "สีเกือบขาว"
    # เงื่อนไขคือ: R, G, และ B ต้องมีค่ามากกว่าหรือเท่ากับ NEAR_WHITE_THRESHOLD (240)
    is_near_white = (r >= NEAR_WHITE_THRESHOLD) & \
                    (g >= NEAR_WHITE_THRESHOLD) & \
                    (b >= NEAR_WHITE_THRESHOLD)

    # 4. ปรับค่า Alpha channel:
    # ตรงไหนที่เป็นสีเกือบขาว ให้ปรับค่า Alpha เป็น 0 (โปร่งใสเต็มที่)
    a[is_near_white] = 0

    # 5. (ทางเลือก) ใช้เทคนิค Morphology เพื่อทำให้ขอบของวัตถุเรียบเนียนขึ้น
    # - MORPH_OPEN: ช่วยลบจุด noise เล็กๆ ที่เป็นสีขาวออกไป
    # - MORPH_CLOSE: ช่วยอุดรูเล็กๆ ที่เป็นสีดำภายในวัตถุ
    kernel = np.ones((3, 3), np.uint8)
    alpha_cleaned = cv2.morphologyEx(a, cv2.MORPH_OPEN, kernel, iterations=1)
    alpha_cleaned = cv2.morphologyEx(alpha_cleaned, cv2.MORPH_CLOSE, kernel, iterations=2)

    # 6. รวม channel R, G, B และ Alpha channel ที่ผ่านการทำความสะอาดแล้วกลับเป็นภาพเดียว
    final_arr = cv2.merge([r, g, b, alpha_cleaned])

    # 7. แปลง NumPy array กลับเป็นภาพ PIL เพื่อนำไปบันทึก
    return Image.fromarray(final_arr, mode="RGBA")


def main():
    """
    ฟังก์ชันหลักสำหรับประมวลผลไฟล์ทั้งหมดในโฟลเดอร์
    """
    print("🚀 เริ่มต้นกระบวนการลบพื้นหลังและทำความสะอาดขอบขาว...")

    # สร้างโฟลเดอร์ผลลัพธ์ถ้ายังไม่มี
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    # โหลดโมเดล rembg แค่ครั้งเดียวเพื่อประสิทธิภาพที่ดีที่สุด
    print("🧠 กำลังโหลดโมเดล 'isnet-general-use'...")
    session = new_session("isnet-general-use")
    print("✨ โมเดลพร้อมใช้งาน")

    # ค้นหาไฟล์รูปภาพทั้งหมด (png, jpg, jpeg)
    image_extensions = ['*.png', '*.jpg', '*.jpeg']
    files_to_process: List[Path] = []
    for ext in image_extensions:
        files_to_process.extend(INPUT_DIR.glob(ext))
    
    total_files = len(files_to_process)
    if total_files == 0:
        print(f"⚠️ ไม่พบไฟล์รูปภาพในโฟลเดอร์: {INPUT_DIR}")
        return

    print(f"🖼️ พบไฟล์รูปภาพทั้งหมด {total_files} ไฟล์. เริ่มประมวลผล...")

    # วนลูปเพื่อประมวลผลไฟล์ทีละไฟล์
    for i, file_path in enumerate(files_to_process):
        output_filename = f"{file_path.stem}.png"
        output_path = OUTPUT_DIR / output_filename
        
        print(f"Processing [{i+1}/{total_files}]: {file_path.name}")

        try:
            with Image.open(file_path) as img:
                # เรียกใช้ฟังก์ชันทำความสะอาด
                cleaned_image = clean_background(img, session)
                
                # บันทึกผลลัพธ์เป็นไฟล์ PNG เพื่อรักษาความโปร่งใส
                cleaned_image.save(output_path, format="PNG")
                
        except Exception as e:
            print(f"❌ เกิดข้อผิดพลาดกับไฟล์ {file_path.name}: {e}")

    print("\n🎉 ประมวลผลเสร็จสิ้นทุกไฟล์!")


if __name__ == "__main__":
    main()