#รีไซส์ + แปลงชื่อไฟล์
import os
from PIL import Image
import pillow_heif

pillow_heif.register_heif_opener()  # 🛠 บรรทัดสำคัญ!!

input_folder = r'C:\Dataset\plu_g'
output_folder = r'C:\Dataset\img_resize\plu-green\512_size'
resize_size = (512 , 512)  # ขนาดที่ต้องการรีไซส์

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
    if filename.lower().endswith(supported_exts):
        found = True
        file_path = os.path.join(input_folder, filename)
        try:
            image = Image.open(file_path)
            image = image.resize(resize_size, Image.LANCZOS)
            new_filename = f"plu-green_{count:03d}.png" # เปลี่ยนชื่อไฟล์ใหม่เป็นชื่อสมุนไพรนั้นๆ
            save_path = os.path.join(output_folder, new_filename)
            image.save(save_path, format="PNG")
            print(f"✅ แปลง {filename} เป็น {new_filename} เรียบร้อยแล้ว")
            count += 1
            success += 1
        except Exception as e:
            print(f"❌ แปลง {filename} ไม่ได้: {e}")
            fail += 1
if not found:
    print(f"ไม่พบไฟล์ที่รองรับ ({supported_exts}) ในโฟลเดอร์นี้!")
print(f"\nสรุป: แปลงสำเร็จ {success} ไฟล์ | ล้มเหลว {fail} ไฟล์")
print("🎉 เสร็จแล้วค้าบบบ!")
