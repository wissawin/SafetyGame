# Safety Game (ทางออกฉุกเฉิน) — Corporate Testing

เว็บแอปพลิเคชันเกมทดสอบและประเมินความรู้ด้านความปลอดภัยสำหรับพนักงานในองค์กร (จำกัดสิทธิ์เฉพาะอีเมล `@scg.com` / `@scg.co.th`) เพื่อใช้เล่นก่อนเริ่มการประชุมประจำสัปดาห์ (Weekly Meeting) พร้อมระบบบันทึกคะแนนและ Datalog อัตโนมัติ

---

## 🔗 Live Deployment

- **Cloud Run URL**: [https://safety-game-996648108877.asia-southeast1.run.app](https://safety-game-996648108877.asia-southeast1.run.app)
- **GCP Project**: `dulcet-palace-377003`
- **Region**: `asia-southeast1` (Singapore / ใกล้ประเทศไทย ค่า Latency ต่ำ)
- **Hosting Cost**: **0 บาท / เดือน** (Cloud Run scale to 0 instances เมื่อไม่มีผู้ใช้งาน และฟรี 2,000,000 requests แรกใน GCP Free Tier)

---

## 📊 การตั้งค่า Data Logging เข้า Google Sheets (ฟรี 100%)

ตัวเกมถูกออกแบบมาให้ส่ง Log อัตโนมัติผ่าน Webhook ไปยัง Google Sheets เพื่อให้ทีมผู้จัดสามารถดูผลคะแนน, สถิติข้อผิดพลาด, และ Reflection ของพนักงานแต่ละคนได้ทันที

### ขั้นตอนการสร้าง Webhook:
1. เปิด [Google Sheets](https://sheets.new) ขึ้นมา 1 แผ่น
2. ไปที่เมนู **ส่วนขยาย (Extensions)** > **Apps Script**
3. ลบโค้ดเดิมออกทั้งหมด แล้ววางโค้ดด้านล่างนี้:

```javascript
function doPost(e) {
  try {
    var sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
    
    // สร้าง Header อัตโนมัติในแถวที่ 1 หากยังไม่มี
    if (sheet.getLastRow() === 0) {
      sheet.appendRow([
        "Timestamp",
        "Event Type",
        "Email",
        "Display Name",
        "Scenario",
        "Result",
        "Grade",
        "Mistakes Count",
        "Time Left (sec)",
        "Reflection Text"
      ]);
      sheet.getRange(1, 1, 1, 10).setFontWeight("bold").setBackground("#f3f3f3");
    }

    var data = JSON.parse(e.postData.contents);
    
    sheet.appendRow([
      data.timestamp || new Date().toISOString(),
      data.type || "",
      data.email || "",
      data.name || "",
      data.scenario || "",
      data.result || "",
      data.grade || "",
      data.mistakes !== undefined ? data.mistakes : "",
      data.timeLeft !== undefined ? data.timeLeft : "",
      data.text || ""
    ]);

    return ContentService.createTextOutput("Success").setMimeType(ContentService.MimeType.TEXT);
  } catch (err) {
    return ContentService.createTextOutput("Error: " + err.message).setMimeType(ContentService.MimeType.TEXT);
  }
}
```

4. กดปุ่ม **ทำให้ใช้งานได้ (Deploy)** > **การทำให้ใช้งานได้รายการใหม่ (New deployment)**
   - เลือกประเภท: **เว็บแอป (Web app)**
   - ดำเนินการในฐานะ (Execute as): **ฉัน (Me)**
   - ผู้ที่มีสิทธิ์เข้าถึง (Who has access): **ทุกคน (Anyone)**
5. กด **Deploy** และอนุญาตสิทธิ์ (Authorize access)
6. คัดลอก **URL ของเว็บแอป (Web App URL)** ที่ลงท้ายด้วย `/exec`
7. นำ URL ที่ได้ไปแทนที่ค่า `SHEET_WEBAPP_URL` ในไฟล์ `index.html` (บรรทัดที่กำหนดตัวแปร `SHEET_WEBAPP_URL`)

---

## 🚀 สั่ง Deploy อัปเดตขึ้น Cloud Run อีกครั้งในอนาคต

เมื่อมีการแก้ไขเนื้อหาคำถามหรือใส่ URL Google Sheets แล้ว สามารถสั่ง Deploy เวอร์ชั่นใหม่ได้ง่ายๆ ด้วยคำสั่งเดียว:

```bash
gcloud run deploy safety-game \
  --source . \
  --region asia-southeast1 \
  --project dulcet-palace-377003 \
  --allow-unauthenticated \
  --port 8080 \
  --min-instances 0 \
  --max-instances 2 \
  --memory 256Mi \
  --cpu 1
```
