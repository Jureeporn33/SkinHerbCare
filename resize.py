import os
from PIL import Image, ImageEnhance
import pillow_heif

pillow_heif.register_heif_opener()

input_folder = r'C:\Dataset\กระเพรา\เทรน'
output_folder = r'C:\Dataset\img_resize\กะเพรา'
resize_size = (640,640)

print(f"input_folder: {input_folder}")
print(f"output_folder: {output_folder}")
os.makedirs(output_folder, exist_ok=True)

try:
    file_list = os.listdir(input_folder)
except Exception as e:
    print(f"❌ ไม่สามารถอ่านโฟลเดอร์ input ได้: {e}")
    file_list = []

print(f"ไฟล์ทั้งหมดใน {input_folder}: {file_list}")

found = False
supported_exts = ('.heic', '.jpg', '.jpeg', '.png')
count = 1
success = 0
fail = 0

for filename in file_list:
    print(f"ตรวจสอบไฟล์: {filename}")
    if filename.lower().endswith(supported_exts):
        found = True
        file_path = os.path.join(input_folder, filename)
        try:
            image = Image.open(file_path).convert("RGBA")
            original_width, original_height = image.size

            # คำนวณขนาดใหม่โดยรักษาสัดส่วน
            ratio = min(resize_size[0] / original_width, resize_size[1] / original_height)
            new_size = (int(original_width * ratio), int(original_height * ratio))
            image = image.resize(new_size, Image.LANCZOS)

            # สร้างพื้นหลังขนาด 1024x1024
            background = Image.new("RGBA", resize_size, (255, 255, 255, 0))  # พื้นหลังโปร่งใส
            paste_position = ((resize_size[0] - new_size[0]) // 2, (resize_size[1] - new_size[1]) // 2)
            background.paste(image, paste_position, image)

            # 🔍 เพิ่มความคมชัด
            enhancer = ImageEnhance.Sharpness(background)
            image = enhancer.enhance(2.0)

            new_filename = f"กะเพรา_{count:03d}.png"
            save_path = os.path.join(output_folder, new_filename)
            image.save(save_path, format="PNG")
            print(f"✅ แปลง {filename} เป็น {new_filename} เรียบร้อยแล้ว")
            count += 1
            success += 1
        except Exception as e:
            print(f"❌ แปลง {filename} ไม่ได้: {e}")
            fail += 1
    else:
        print(f"ข้ามไฟล์ (ไม่รองรับ): {filename}")

if not found:
    print(f"ไม่พบไฟล์ที่รองรับ ({supported_exts}) ในโฟลเดอร์นี้!")

print(f"\nสรุป: แปลงสำเร็จ {success} ไฟล์ | ล้มเหลว {fail} ไฟล์")
print("🎉 เสร็จแล้วค้าบบบ!")
