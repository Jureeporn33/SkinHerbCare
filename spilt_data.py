import os
import shutil
import random
from pathlib import Path

def split_data_with_labels(images_folder, labels_folder, output_folder, train_ratio=0.6, val_ratio=0.4, 
                          image_extensions=None, label_extensions=None, seed=42):
    """
    แยกข้อมูลรูปภาพและไฟล์ label ที่ชื่อตรงกันเป็น train และ val
    วางรูปและ label แยกกันเป็นโฟลเดอร์ images/... และ labels/...
    """
    
    # ตรวจสอบสัดส่วน
    if abs(train_ratio + val_ratio - 1.0) > 1e-6:
        raise ValueError("สัดส่วน train + val ต้องเท่ากับ 1.0")
    
    # ตั้งค่าเริ่มต้น
    if image_extensions is None:
        image_extensions = ['.jpg', '.jpeg', '.png', '.bmp', '.tiff', '.webp']
    if label_extensions is None:
        label_extensions = ['.txt', '.xml', '.json', '.csv']
    
    random.seed(seed)
    
    # สร้างพาธ
    images_path = Path(images_folder)
    labels_path = Path(labels_folder)
    output_path = Path(output_folder)
    
    # สร้างโฟลเดอร์ผลลัพธ์ (แยกรูปและ labels)
    images_train_path = output_path / "images" / "train"
    images_val_path = output_path / "images" / "val"
    labels_train_path = output_path / "labels" / "train"
    labels_val_path = output_path / "labels" / "val"
    
    for p in (images_train_path, images_val_path, labels_train_path, labels_val_path):
        p.mkdir(parents=True, exist_ok=True)
    
    # ตรวจสอบโฟลเดอร์ต้นทาง
    if not images_path.exists():
        raise FileNotFoundError(f"ไม่พบโฟลเดอร์รูปภาพ: {images_folder}")
    if not labels_path.exists():
        raise FileNotFoundError(f"ไม่พบโฟลเดอร์ labels: {labels_folder}")
    
    print(f"เริ่มแยกข้อมูลจาก:")
    print(f"  รูปภาพ: {images_folder}")
    print(f"  Labels: {labels_folder}")
    print(f"สัดส่วน - Train: {train_ratio*100:.1f}%, Val: {val_ratio*100:.1f}%")
    
    # รวบรวมคู่ไฟล์ที่ชื่อตรงกัน
    matched_pairs = []
    
    # หาไฟล์รูปภาพทั้งหมด
    image_files = {}
    for img_file in images_path.iterdir():
        if img_file.is_file() and img_file.suffix.lower() in image_extensions:
            base_name = img_file.stem  # ชื่อไฟล์ไม่มี extension
            image_files[base_name] = img_file
    
    print(f"\nพบรูปภาพทั้งหมด: {len(image_files)} ไฟล์")
    
    # หาไฟล์ label ที่ตรงกัน
    for label_file in labels_path.iterdir():
        if label_file.is_file() and label_file.suffix.lower() in label_extensions:
            base_name = label_file.stem
            if base_name in image_files:
                matched_pairs.append({
                    'image': image_files[base_name],
                    'label': label_file,
                    'base_name': base_name
                })
    
    total_pairs = len(matched_pairs)
    print(f"พบคู่ไฟล์ที่ตรงกัน: {total_pairs} คู่")
    
    if total_pairs == 0:
        print("❌ ไม่พบคู่ไฟล์ที่ชื่อตรงกัน!")
        return
    
    # สุ่มลำดับ
    random.shuffle(matched_pairs)
    
    # คำนวณจำนวนไฟล์
    train_count = int(total_pairs * train_ratio)
    val_count = total_pairs - train_count
    
    print(f"\nการแยกข้อมูล:")
    print(f"  Train: {train_count} คู่ (รูป + label)")
    print(f"  Val: {val_count} คู่ (รูป + label)")
    
    # คัดลอกไฟล์ train (วางแยกโฟลเดอร์)
    print("\n🚀 กำลังคัดลอก Train set...")
    for i, pair in enumerate(matched_pairs[:train_count]):
        shutil.copy2(pair['image'], images_train_path / pair['image'].name)
        shutil.copy2(pair['label'], labels_train_path / pair['label'].name)
        
        if (i + 1) % 100 == 0:
            print(f"  คัดลอกแล้ว: {i + 1}/{train_count} คู่")
    
    # คัดลอกไฟล์ val (วางแยกโฟลเดอร์)
    print("\n🚀 กำลังคัดลอก Val set...")
    for i, pair in enumerate(matched_pairs[train_count:]):
        shutil.copy2(pair['image'], images_val_path / pair['image'].name)
        shutil.copy2(pair['label'], labels_val_path / pair['label'].name)
        
        if (i + 1) % 100 == 0:
            print(f"  คัดลอกแล้ว: {i + 1}/{val_count} คู่")
    
    print(f"\n✅ แยกข้อมูลเสร็จสิ้น!")
    print(f"ผลลัพธ์ถูกบันทึกที่: {output_folder}")
    print(f"\nโครงสร้างโฟลเดอร์:")
    print(f"  {output_folder}\\images\\train/ - {train_count} รูป")
    print(f"  {output_folder}\\images\\val/   - {val_count} รูป")
    print(f"  {output_folder}\\labels\\train/ - {train_count} labels")
    print(f"  {output_folder}\\labels\\val/   - {val_count} labels")

# ตัวอย่างการใช้งาน
if __name__ == "__main__":
    
    # แยกข้อมูลจาก images_All และ labels_All
    images_folder = r"C:\skin_project\herbSkin_Project66\new\images"
    labels_folder = r"C:\skin_project\herbSkin_Project66\new\label" 
    output_folder = r"C:\skin_project\herbSkin_Project66\new\dataset"
    
    print("=== แยกข้อมูลรูปภาพ + Labels ===")
    split_data_with_labels(
        images_folder=images_folder,
        labels_folder=labels_folder,
        output_folder=output_folder,
        train_ratio=0.6,
        val_ratio=0.4
    )