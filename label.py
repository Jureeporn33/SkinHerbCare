# ===============================
# สร้าง Label และ Preview โปร่งใส สำหรับ YOLO
# ===============================

import os
import cv2
import numpy as np

# ===============================
# ฟังก์ชันอ่านไฟล์ภาพ unicode-safe
# ===============================
def imread_unicode(path, flags=cv2.IMREAD_UNCHANGED):
    with open(path, "rb") as f:
        data = np.frombuffer(f.read(), np.uint8)
    return cv2.imdecode(data, flags)

# ===============================
# Path
# ===============================
input_folder = r"D:\herbSkin_Project66\Dataset\images_all"
output_label_folder = r"D:\herbSkin_Project66\Dataset\LabelV.2\label"
output_preview_folder = r"D:\herbSkin_Project66\Dataset\LabelV.2\preview"

os.makedirs(output_label_folder, exist_ok=True)
os.makedirs(output_preview_folder, exist_ok=True)

# ===============================
# ขนาด final image
# ===============================
FINAL_SIZE = 640

# ===============================
# ชื่อคลาส
# ===============================
class_names = [
    'Snake Plant', 'Turmeric', 'Galanga', 'cucumber', 'Alovera',
    'Garlic', 'Houttuynia cordata', 'pluLeaf', 'Ivy Gourd', 'Mangosteen Peel',
    'khaproa', 'horapa'
]

# ===============================
# สีแต่ละ class (BGR)
# ===============================
CLASS_COLORS = {
    'Snake Plant': (255, 0, 0),
    'Turmeric': (0, 255, 0),
    'Galanga': (255, 0, 255),
    'cucumber': (0, 200, 255),
    'Alovera': (0, 0, 255),
    'Garlic': (0, 165, 255),
    'Houttuynia cordata': (255, 102, 178),
    'pluLeaf': (128, 128, 0),
    'Ivy Gourd': (255, 255, 0),
    'Mangosteen_Peel': (192, 192, 192),
    'khaproa': (0, 128, 128),
    'horapa': (128, 0, 128)
}

# ===============================
# ดึงไฟล์ภาพ
# ===============================
image_files = [f for f in os.listdir(input_folder) if f.lower().endswith(('.png', '.jpg', '.jpeg'))]
total_files = len(image_files)

for idx, file in enumerate(image_files, start=1):
    print(f"📸 [{idx}/{total_files}] กำลังประมวลผล: {file}")

    img_path = os.path.join(input_folder, file)
    img = imread_unicode(img_path)

    if img is None:
        print(f"❌ ไม่สามารถอ่านรูป: {file} — ข้าม")
        continue

    # ตรวจสอบ alpha channel
    if img.shape[2] == 4:
        bgr = img[:, :, :3]
        alpha = img[:, :, 3]
    else:
        bgr = img
        alpha = np.ones(bgr.shape[:2], dtype=np.uint8) * 255

    height, width = bgr.shape[:2]

    # ===== กำหนด class_id จากชื่อไฟล์ =====
    # ตัวอย่าง: "Alovera_001.png" → class_id = index ของ "Alovera"
    base_name = os.path.splitext(file)[0]
    class_name = base_name.split("_")[0]  # ดึงชื่อคลาสจากไฟล์
    if class_name not in class_names:
        print(f"⚠️ ไม่พบ class ของไฟล์: {file} — ใช้ FORCE_CLASS_ID แทน")
        class_id = 0
        class_name = class_names[class_id]
    else:
        class_id = class_names.index(class_name)

    # สร้าง mask จาก alpha
    _, mask = cv2.threshold(alpha, 1, 255, cv2.THRESH_BINARY)
    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    min_area = 500
    filtered_contours = [c for c in contours if cv2.contourArea(c) > min_area]

    if not filtered_contours:
        print(f"⚠️ ไม่เจอวัตถุที่ใหญ่พอใน: {file} — ข้าม")
        continue

    # สร้างไฟล์ label
    label_file = os.path.splitext(file)[0] + ".txt"
    with open(os.path.join(output_label_folder, label_file), "w") as f:
        for contour in filtered_contours:
            x, y, bw, bh = cv2.boundingRect(contour)
            x_center = (x + bw / 2) / width
            y_center = (y + bh / 2) / height
            w_norm = bw / width
            h_norm = bh / height
            f.write(f"{class_id} {x_center:.6f} {y_center:.6f} {w_norm:.6f} {h_norm:.6f}\n")

    # สร้าง preview BGRA (โปร่งใส)
    preview_img = np.zeros((height, width, 4), dtype=np.uint8)
    preview_img[:, :, :3] = bgr
    preview_img[:, :, 3] = alpha

    color = CLASS_COLORS.get(class_name, (0, 255, 0))
    for contour in filtered_contours:
        x, y, bw, bh = cv2.boundingRect(contour)
        # วาดกรอบ
        cv2.rectangle(preview_img, (x, y), (x + bw, y + bh), color + (255,), 2)
        # วางชื่อคลาส
        cv2.putText(preview_img, class_name, (x + 5, max(y - 5, 15)),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.6, color + (255,), 1, cv2.LINE_AA)

    # ปรับขนาด preview
    scale = FINAL_SIZE / max(preview_img.shape[:2])
    new_w = int(preview_img.shape[1] * scale)
    new_h = int(preview_img.shape[0] * scale)
    resized_preview = cv2.resize(preview_img, (new_w, new_h), interpolation=cv2.INTER_AREA)

    # สร้าง final BGRA ขนาด 224x224
    final_img = np.zeros((FINAL_SIZE, FINAL_SIZE, 4), dtype=np.uint8)
    x_offset = (FINAL_SIZE - new_w) // 2
    y_offset = (FINAL_SIZE - new_h) // 2
    final_img[y_offset:y_offset + new_h, x_offset:x_offset + new_w] = resized_preview

    preview_file = os.path.splitext(file)[0] + ".png"
    cv2.imwrite(os.path.join(output_preview_folder, preview_file), final_img)

    print(f"✅ สำเร็จ: {file}")

print("\n🎉 เสร็จแล้ว! สร้าง preview โปร่งใส พร้อม bounding box และ label เรียบร้อย 🎯")
