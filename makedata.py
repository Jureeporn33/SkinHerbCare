import yaml

# ===== รายชื่อคลาส =====
class_names = [
    'Snake Plant', 'Turmeric', 'Galanga', 'cucumber', 'Alovera',
    'Garlic', 'Houttuynia cordata', 'pluLeaf', 'Ivy Gourd', 'Mangosteen Peel',
    'khaproa', 'horapa'
]

# ===== กำหนด path dataset =====
dataset_path = r"C:\skin_project\herbSkin_Project66\new\label"

# ===== สร้าง dictionary สำหรับ data.yml =====
data_yaml = {
    "path": dataset_path,       # path หลักของ dataset
    "train": "images/train",    # โฟลเดอร์รูป train
    "val": "images/val",        # โฟลเดอร์รูป validation
    "test": "images/test",      # (optional) โฟลเดอร์รูป test
    "nc": len(class_names),     # จำนวนคลาส
    "names": {i: name for i, name in enumerate(class_names)}  # mapping id:name
}

# ===== บันทึกลงไฟล์ data.yml =====
with open(f"{dataset_path}/data.yml", "w", encoding="utf-8") as f:
    yaml.dump(data_yaml, f, allow_unicode=True)

print("✅ สร้างไฟล์ data.yml เรียบร้อยแล้ว:", f"{dataset_path}/data.yml")
