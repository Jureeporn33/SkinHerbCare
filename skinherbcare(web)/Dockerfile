# ใช้ nginx เป็นเว็บเซิร์ฟเวอร์
FROM nginx:alpine

# คัดลอกไฟล์เว็บไปยัง nginx
COPY . /usr/share/nginx/html

# เปิดพอร์ต 80
EXPOSE 80

# รัน nginx
CMD ["nginx", "-g", "daemon off;"]
