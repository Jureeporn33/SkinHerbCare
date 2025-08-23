# ===============================
# YOLOv8 Classification Training + Summary Report
# ===============================
# สำหรับ Python 3.x + ultralytics
# วางไฟล์นี้ไว้ใน VS Code แล้วรันได้เลย

import os
import shutil
import random
from pathlib import Path
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
from ultralytics import YOLO
from sklearn.metrics import confusion_matrix, ConfusionMatrixDisplay

# ------------------------------
# STEP 0: ตั้งค่า path dataset
# ------------------------------
# โฟลเดอร์รวมรูปทั้งหมด
input_dir = Path(r"D:\herbSkin_Project66\Dataset\images_all")   # <-- แก้ path ตามเครื่องคุณ
output_dir = Path(r"D:\herbSkin_Project66\Dataset\herbV.2")  

# สัดส่วน train/val/test
train_ratio, val_ratio, test_ratio = 0.7, 0.2, 0.1

# ------------------------------
# STEP 1: แบ่ง dataset ตามชื่อไฟล์
# ------------------------------
# ดึงไฟล์ทั้งหมด
images = list(input_dir.glob("*.jpg")) + \
         list(input_dir.glob("*.png")) + \
         list(input_dir.glob("*.jpeg"))

if len(images) == 0:
    raise ValueError(f"⚠️ ไม่พบภาพในโฟลเดอร์ {input_dir}")

# แยก class จาก prefix ของชื่อไฟล์ (เช่น "เปลือกมังคุด_001.jpg" → class = "เปลือกมังคุด")
class_dict = {}
for img in images:
    class_name = img.stem.split("_")[0]
    class_dict.setdefault(class_name, []).append(img)

# สร้างโฟลเดอร์ train/val/test
for split in ["train", "val", "test"]:
    (output_dir / split).mkdir(parents=True, exist_ok=True)

# แบ่งไฟล์และคัดลอก
for class_name, file_list in class_dict.items():
    random.shuffle(file_list)
    n_total = len(file_list)
    n_train = int(n_total * train_ratio)
    n_val   = int(n_total * val_ratio)

    train_files = file_list[:n_train]
    val_files   = file_list[n_train:n_train+n_val]
    test_files  = file_list[n_train+n_val:]

    def copy_files(files, split):
        split_dir = output_dir / split / class_name
        split_dir.mkdir(parents=True, exist_ok=True)
        for f in files:
            shutil.copy(f, split_dir / f.name)

    copy_files(train_files, "train")
    copy_files(val_files, "val")
    copy_files(test_files, "test")

print("✅ Dataset ถูกแบ่งออกตามชื่อคลาสแล้ว")
print(f"มีทั้งหมด {len(class_dict)} คลาส: {list(class_dict.keys())}")

# ------------------------------
# STEP 2: เทรน YOLOv8 Classification
# ------------------------------
model = YOLO("yolov8n-cls.pt")  # โหลดโมเดล pretrained

model.train(
    data=str(output_dir),   # โฟลเดอร์ dataset หลัก
    epochs=100,              # จำนวนรอบเทรน
    imgsz=640,              # ขนาด input image
    batch=64,               # batch size
    workers=4,              # DataLoader workers
    device="cpu"            # ใช้ GPU ถ้ามี เช่น device="0"
)

# ------------------------------
# STEP 3: ประเมินผลบน test set
# ------------------------------
metrics = model.val(data=str(output_dir / "test"))
print("📊 Metrics:", metrics)

# ------------------------------
# STEP 4: แสดงกราฟสรุปผลครอบคลุม
# ------------------------------
log_path = Path(model.trainer.save_dir) / "results.csv"
df = pd.read_csv(log_path)

# --- Loss ---
plt.figure(figsize=(10,5))
plt.plot(df["epoch"], df["train/loss"], label="Train Loss", color="blue")
plt.plot(df["epoch"], df["val/loss"], label="Val Loss", color="orange")
plt.xlabel("Epoch")
plt.ylabel("Loss")
plt.title("Training & Validation Loss")
plt.legend()
plt.grid(True)
plt.show()

# --- Accuracy ---
plt.figure(figsize=(10,5))
plt.plot(df["epoch"], df["metrics/accuracy_top1"], label="Top-1 Accuracy", color="green")
plt.plot(df["epoch"], df["metrics/accuracy_top5"], label="Top-5 Accuracy", color="red")
plt.xlabel("Epoch")
plt.ylabel("Accuracy")
plt.title("Validation Accuracy")
plt.legend()
plt.grid(True)
plt.show()

# --- Precision / Recall / F1 ---
if "metrics/precision" in df.columns:
    plt.figure(figsize=(10,5))
    plt.plot(df["epoch"], df["metrics/precision"], label="Precision", color="purple")
    plt.plot(df["epoch"], df["metrics/recall"], label="Recall", color="brown")
    plt.plot(df["epoch"], df["metrics/f1"], label="F1-score", color="teal")
    plt.xlabel("Epoch")
    plt.ylabel("Score")
    plt.title("Precision, Recall, F1 per Epoch")
    plt.legend()
    plt.grid(True)
    plt.show()

# --- Confusion Matrix ---
print("📊 สร้าง Confusion Matrix...")
best_model = YOLO(str(Path(model.trainer.save_dir) / "weights/best.pt"))
pred_results = best_model.val(data=str(output_dir / "test"), save=False, plots=False)

# y_true และ y_pred อาจต้องปรับตาม structure ที่ ultralytics คืนค่า
# ถ้า val() ไม่ return probs ตรง ๆ แนะนำใช้ predict loop
try:
    y_true = pred_results.results[0].dataset.labels
    y_pred = pred_results.results[0].probs.argmax(1).cpu().numpy()

    cm = confusion_matrix(y_true, y_pred, labels=range(len(class_dict)))
    disp = ConfusionMatrixDisplay(confusion_matrix=cm, display_labels=list(class_dict.keys()))
    fig, ax = plt.subplots(figsize=(10,10))
    disp.plot(ax=ax, cmap="Blues", xticks_rotation=45)
    plt.title("Confusion Matrix (Test set)")
    plt.show()

    # --- Class-wise Accuracy ---
    class_acc = (cm.diagonal() / cm.sum(axis=1)) * 100
    plt.figure(figsize=(12,6))
    plt.bar(class_dict.keys(), class_acc, color="skyblue")
    plt.xticks(rotation=45, ha="right")
    plt.ylabel("Accuracy (%)")
    plt.title("Accuracy per Class (Test set)")
    plt.grid(axis="y")
    plt.show()
except Exception as e:
    print("⚠️ ไม่สามารถสร้าง Confusion Matrix ได้:", e)

# ------------------------------
# STEP 5: โหลดโมเดลที่ดีที่สุดและทดสอบภาพใหม่
# ------------------------------
img_path = r"C:\Dataset\sample_image.jpg"  # <-- เปลี่ยนเป็น path ภาพทดสอบ
results = best_model.predict(img_path)
results.show()
