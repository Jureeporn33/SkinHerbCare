import os

# โฟลเดอร์ที่เก็บไฟล์
input_folder = r"D:\dataset\พญายอ\delete bg"

# คำที่จะเปลี่ยน
old_text = "พญายอ"
new_text = "Snake Plant"

# ดึงชื่อไฟล์ที่ต้องการแก้
image_files = [f for f in os.listdir(input_folder) if f.lower().endswith(('.jpg', '.png'))]

for filename in image_files:
    if old_text in filename:
        new_name = filename.replace(old_text, new_text)
        old_path = os.path.join(input_folder, filename)
        new_path = os.path.join(input_folder, new_name)
        os.rename(old_path, new_path)
        print(f"{filename} -> {new_name}")
