# ==========================
# STEP 0: Mount Google Drive
# ==========================
from google.colab import drive
drive.mount('/content/drive')

# --------------------------
# STEP 1: แบ่ง dataset เป็น train/val/test
# --------------------------
import os
import shutil
import random
from pathlib import Path

# path dataset ต้นฉบับ (แก้ไขเป็น path ที่อยู่ใน Google Drive ของคุณ)
input_dir = Path("/content/drive/MyDrive/Dataset/img_removeBG/เปลือกมังคุด")
output_dir = Path("/content/drive/MyDrive/Dataset/herb_dataset")  # โฟลเดอร์ผลลัพธ์ train/val/test

# สัดส่วน train/val/test
train_ratio = 0.7
val_ratio = 0.2
test_ratio = 0.1

# สร้างโฟลเดอร์เปล่า train/val/test
for split in ["train", "val", "test"]:
    (output_dir / split).mkdir(parents=True, exist_ok=True)

# กำหนด class (กรณีมีหลายคลาสให้เพิ่มชื่อที่นี่)
classes = ["เปลือกมังคุด"]

for class_name in classes:
    class_input_dir = input_dir  # สำหรับคลาสเดียวรวมภาพทั้งหมด
    images = list(class_input_dir.glob("*.png")) + \
             list(class_input_dir.glob("*.jpg")) + \
             list(class_input_dir.glob("*.jpeg"))
    if len(images) == 0:
        print(f"⚠️ ไม่พบภาพในโฟลเดอร์ {class_input_dir}")
        continue

    random.shuffle(images)
    n_total = len(images)
    n_train = int(n_total * train_ratio)
    n_val = int(n_total * val_ratio)

    train_files = images[:n_train]
    val_files = images[n_train:n_train+n_val]
    test_files = images[n_train+n_val:]

    # ฟังก์ชันคัดลอกไฟล์
    def move_files(file_list, split):
        split_dir = output_dir / split / class_name
        split_dir.mkdir(parents=True, exist_ok=True)
        for f in file_list:
            shutil.copy(f, split_dir / f.name)

    move_files(train_files, "train")
    move_files(val_files, "val")
    move_files(test_files, "test")

print("✅ Dataset ถูกแบ่งเป็น train/val/test แล้ว")
