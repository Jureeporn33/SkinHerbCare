# -*- coding: utf-8 -*-
"""
สุ่มเลือกรูปภาพ 50 รูปจากโฟลเดอร์ต้นทาง แล้วคัดลอกไปยังโฟลเดอร์ปลายทาง
- ไม่สร้างโฟลเดอร์ปลายทางให้อัตโนมัติ (ต้องมีอยู่แล้ว)
- รองรับชื่อไฟล์ภาษาไทย (ใช้ pathlib)
- ป้องกันชื่อไฟล์ชนกันด้วยการเติม _001, _002, ...
"""

from pathlib import Path
import random
import shutil
import sys

# 🔧 ตั้งค่าโฟลเดอร์ที่นี่
INPUT_DIR = Path(r"C:\Dataset\img_removeBG\ตำลึง")
OUTPUT_DIR = Path(r"C:\Dataset\dataset_testtrain_model\ตำลึง")
NUM_TO_PICK = 50                              # จำนวนรูปที่จะสุ่ม

# นามสกุลรูปที่รองรับ
IMAGE_EXTS = {".jpg", ".jpeg", ".png", ".bmp", ".gif", ".webp", ".tif", ".tiff"}

def unique_dest_path(dest_dir: Path, filename: str) -> Path:
    """
    สร้างพาธปลายทางที่ไม่ชนกัน
    ถ้ามีไฟล์ชื่อซ้ำ จะเติม _001, _002, ... ที่หน้าส่วนขยาย
    """
    base = Path(filename).stem
    ext = Path(filename).suffix
    candidate = dest_dir / (base + ext)

    if not candidate.exists():
        return candidate

    i = 1
    while True:
        candidate = dest_dir / f"{base}_{i:03d}{ext}"
        if not candidate.exists():
            return candidate
        i += 1

def main():
    # ตรวจโฟลเดอร์
    if not INPUT_DIR.exists() or not INPUT_DIR.is_dir():
        print(f"❌ ไม่พบโฟลเดอร์ต้นทาง: {INPUT_DIR}")
        sys.exit(1)

    if not OUTPUT_DIR.exists() or not OUTPUT_DIR.is_dir():
        print(f"❌ ไม่พบโฟลเดอร์ปลายทาง (จะไม่สร้างให้อัตโนมัติ): {OUTPUT_DIR}")
        sys.exit(1)

    # รวบรวมไฟล์รูป
    files = [p for p in INPUT_DIR.iterdir()
             if p.is_file() and p.suffix.lower() in IMAGE_EXTS]

    total = len(files)
    if total == 0:
        print("❗ ไม่พบไฟล์รูปในโฟลเดอร์ต้นทาง")
        sys.exit(0)

    # จำนวนที่จะสุ่ม (ถ้ามีรูปน้อยกว่า 50 จะสุ่มเท่าที่มี)
    k = min(NUM_TO_PICK, total)

    # สุ่มแบบไม่ซ้ำ
    random.shuffle(files)
    picked = files[:k]

    print(f"🖼️ พบไฟล์รูปทั้งหมด: {total} ไฟล์ | สุ่มเลือก: {k} ไฟล์")
    for i, src in enumerate(picked, 1):
        dst = unique_dest_path(OUTPUT_DIR, src.name)
        shutil.copy2(src, dst)  # คัดลอกพร้อม metadata
        print(f"[{i:02d}/{k}] ✅ {src.name} → {dst.name}")

    print("🎉 เสร็จสิ้นการคัดลอกรูปที่สุ่มแล้ว!")

if __name__ == "__main__":
    main()
