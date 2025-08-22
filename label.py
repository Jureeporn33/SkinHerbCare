#โค้ดทำ Label
import os
import cv2
import numpy as np

def imread_unicode(path, flags=cv2.IMREAD_UNCHANGED):
    with open(path, "rb") as f:
        data = np.frombuffer(f.read(), np.uint8)
    return cv2.imdecode(data, flags)

# ===== กำหนด path =====
input_folder = r"D:\dataset\พญายอ\delete bg"
output_label_folder = r"D:\dataset\label"
output_preview_folder = r"D:\dataset\preview"

os.makedirs(output_label_folder, exist_ok=True)
os.makedirs(output_preview_folder, exist_ok=True)

# ===== ขนาด preview / final =====
FINAL_SIZE = 224  # ปรับได้ตามต้องการ (ตัวอย่าง 224)

# ===== ข้อมูลคลาสจาก data.yaml =====
class_names = [
    'snake plant', 'ขมิ้น', 'ข่า', 'แตงกวา', 'ว่านหางจรเข้',
    'กระเทียม', 'พลูคาว', 'พลู', 'ตำลึง', 'เปลือกมังคุดแห้ง','กระเพรา','โหรพา'
]

# ===== กำหนดสีสำหรับแต่ละ class_id ===== (BGR) — ไม่ต้องมี alpha channel ในนี้
CLASS_COLORS = {
    0: (255, 0, 0),         # Candyapple - น้ำเงิน
    1: (0, 255, 0),         # Namwa - เขียว
    2: (255, 0, 255),       # Namwadam - ม่วง
    3: (0, 200, 255),       # Homthong - เหลือง
    4: (0, 0, 255),         # Nak - แดง
    5: (0, 165, 255),       # Thepphanom - ส้ม
    6: (255, 102, 178),     # Kai - ม่วงอมน้ำเงิน
    7: (128, 128, 0),       # Lepchanggud - น้ำเงินเขียว
    8: (255, 255, 0),       # Ngachang - ฟ้า
    9: (192, 192, 192),      # Huamao - เทาเงิน
    10: (0, 128, 128),       # Khamin - เขียวอมฟ้า
    11: (128, 0, 128)        # Kha - ม่วงอมเขียว
}

FORCE_CLASS_ID = 0  # เปลี่ยนตรงนี้ได้ตามต้องการ

image_files = [f for f in os.listdir(input_folder) if f.lower().endswith(('.png', '.jpg', '.jpeg'))]
total_files = len(image_files)

for idx, file in enumerate(image_files, start=1):
    print(f"📸 [{idx}/{total_files}] กำลังประมวลผล: {file}")

    img_path = os.path.join(input_folder, file)
    img = imread_unicode(img_path)  # เปลี่ยนตรงนี้

    if img is None:
        print(f"❌ ไม่สามารถอ่านรูป: {file} — ข้าม")
        continue

    if img.shape[2] == 4:
        bgr = img[:, :, :3]
        alpha = img[:, :, 3]
    else:
        bgr = img
        alpha = np.ones(bgr.shape[:2], dtype=np.uint8) * 255

    height, width = bgr.shape[:2]

    class_id = FORCE_CLASS_ID

    # สร้าง mask จาก alpha channel
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

    # สร้าง preview image BGRA (พื้นหลังโปร่งใส)
    preview_img = np.zeros((height, width, 4), dtype=np.uint8)
    preview_img[:, :, :3] = bgr
    preview_img[:, :, 3] = alpha

    # วาดกรอบและชื่อคลาส (ใช้สี BGR)
    color = CLASS_COLORS.get(class_id, (0, 255, 0))
    for contour in filtered_contours:
        x, y, bw, bh = cv2.boundingRect(contour)
        cv2.rectangle(preview_img, (x, y), (x + bw, y + bh), color + (255,), 2)  # เติม alpha=255 ที่ปลาย tuple
        # วาดชื่อคลาสโดยให้ข้อความไม่โปร่งใส ใช้สีเดียวกัน (BGR) + alpha=255
        cv2.putText(preview_img, class_names[class_id], (x + 5, max(y - 5, 15)),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.6, color + (255,), 1, cv2.LINE_AA)

    # ปรับขนาด preview
    scale = FINAL_SIZE / max(preview_img.shape[:2])
    new_w = int(preview_img.shape[1] * scale)
    new_h = int(preview_img.shape[0] * scale)
    resized_preview = cv2.resize(preview_img, (new_w, new_h), interpolation=cv2.INTER_AREA)

    # สร้างภาพ final 224x224 โปร่งใส
    final_img = np.zeros((FINAL_SIZE, FINAL_SIZE, 4), dtype=np.uint8)
    x_offset = (FINAL_SIZE - new_w) // 2
    y_offset = (FINAL_SIZE - new_h) // 2
    final_img[y_offset:y_offset + new_h, x_offset:x_offset + new_w] = resized_preview

    preview_file = os.path.splitext(file)[0] + ".png"
    cv2.imwrite(os.path.join(output_preview_folder, preview_file), final_img)

    print(f"✅ สำเร็จ: {file}")

print("\n🎉 เสร็จแล้วค้าบ: สร้าง preview ภาพโปร่งใส พร้อมกรอบและชื่อคลาสเรียบร้อย! 🎯")
