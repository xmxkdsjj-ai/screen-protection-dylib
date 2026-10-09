# ScreenProtection.dylib

Objective-C dynamic library สำหรับทดสอบการป้องกันภาพหน้าจอใน IPA ที่คุณเป็นเจ้าของหรือได้รับอนุญาตให้แก้ไข ตัวไลบรารีไม่พึ่ง Logos หรือ Substrate เพื่อให้เครื่องมือฉีด dylib และเซ็น IPA จัดการได้โดยตรง

## Build และใช้งานผ่าน iPhone

branch `dylib-build` มีเฉพาะไฟล์ tweak และ workflow ที่จำเป็นสำหรับ build โดยไม่ส่งไฟล์อื่นจากโปรเจกต์ Replit:

1. ใน Replit Git pane เลือก branch `dylib-build` แล้วกด **Push branch** ไปยัง repository ส่วนตัว
2. การ push จะเริ่ม GitHub Actions workflow ชื่อ **Build iOS dylib** โดยอัตโนมัติ
3. เปิด repository ใน GitHub แล้วไปที่ **Actions → Build iOS dylib** เลือก run ล่าสุด และดาวน์โหลด artifact ชื่อ `ScreenProtection-dylib`
4. แตกไฟล์ artifact แล้วนำ `ScreenProtection.dylib` เข้า GBox เพื่อ inject/sign IPA ที่คุณเป็นเจ้าของหรือได้รับอนุญาตให้แก้ไข

GBox เป็นตัวเลือก IPA และจัดการการเซ็น/ติดตั้ง ส่วน GitHub Actions คอมไพล์ไลบรารีในคลาวด์ การควบคุมทั้งหมดทำจาก iPhone ได้ แต่การคอมไพล์ไม่ได้เกิดบนตัว iPhone เอง

## Build ในเครื่องที่มี Theos

```sh
export THEOS=/path/to/theos
bash build.sh
```

ไฟล์จะถูกคัดลอกไปที่ `dist/ScreenProtection.dylib`

## ข้อจำกัด

- ใช้ private API `_setSecure:` ซึ่ง Apple ไม่รับรอง อาจไม่มีหรือไม่ทำงานใน iOS บางเวอร์ชัน และไม่เหมาะกับแอปที่ต้องผ่าน App Store review
- iOS ไม่มี API สาธารณะที่รับประกันการปิดกั้น screenshot หรือ screen recording สำหรับทั้งแอปได้ โค้ดนี้เป็น best-effort เท่านั้น
- การทำงานจริงขึ้นกับว่า GBox เวอร์ชันที่ใช้ inject dylib นี้และเซ็น IPA เป้าหมายได้ รวมถึงข้อกำหนด signing ของแอปนั้น
- ไม่ใช้ overlay `UITextField` เต็มหน้าจอ เพราะไม่ได้รับประกันการป้องกันภาพและอาจรบกวน UI
