import os

# โฟลเดอร์ที่เก็บไฟล์
input_folder = r"D:\herbSkin_Project66\มังคุด"

# ชื่อใหม่ที่ต้องการให้เป็นทั้งหมด
new_text = "Mangosteen Peel"

# ดึงชื่อไฟล์ที่ต้องการแก้
image_files = [f for f in os.listdir(input_folder) if f.lower().endswith(('.jpg', '.png'))]

# เรียงตามชื่อไฟล์เดิม (เพื่อไม่ให้สลับลำดับ)
image_files.sort()

# รันเลขลำดับไฟล์ใหม่ทั้งหมด
for i, filename in enumerate(image_files, start=1):
    ext = os.path.splitext(filename)[1]  # นามสกุลไฟล์ (.jpg, .png)
    new_name = f"{new_text}_{i:03d}{ext}"  # เช่น Ivy Gourd_001.jpg
    old_path = os.path.join(input_folder, filename)
    new_path = os.path.join(input_folder, new_name)
    os.rename(old_path, new_path)
    print(f"{filename} -> {new_name}")
