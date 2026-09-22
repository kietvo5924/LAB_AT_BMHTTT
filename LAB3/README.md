# BÁO CÁO THỰC HÀNH LAB 3
## NHẬN DIỆN VÀ ỨNG PHÓ CÁC MỐI ĐE DỌA ĐẾN AN TOÀN THÔNG TIN

---

### 1. THÔNG TIN SINH VIÊN
* **Họ và tên:** Võ Anh Kiệt
* **Mã số sinh viên (MSSV):** 1150080143
* **Lớp:** 11CNPM2
* **Học phần:** An toàn và Bảo mật Hệ thống Thông tin
* **Tệp báo cáo chính:** `11CNPM2_LAB3_1150080143_VoAnhKiet.docx`
* **Link youtube:** https://www.youtube.com/watch?v=S_jDaWqyg7c

---

### 2. PHIÊN BẢN MÔI TRƯỜNG THỰC HÀNH
* **Nền tảng ảo hóa:** VMware Workstation Pro (Cấu hình card mạng cách ly: `Host-only`)
* **Hệ điều hành máy trạm:** Windows 11 Pro 64-bit (OS Build 26200.9445)
* **Snapshot sạch tham chiếu:** `LAB3_CLEAN_20260914`
* **Endpoint Protection:** Microsoft Defender Antivirus (Real-time Protection: `ON`, Tamper Protection: `ON`)
* **Danh mục công cụ chuẩn hóa:**
  * **Sysmon:** v15.22 (Schema cấu hình: 4.90)
  * **Autoruns:** v14.3
  * **Process Explorer:** v17.14
  * **Wireshark:** v4.6.8 + Trình điều khiển Npcap loopback
  * **Python:** v3.14.7 (Phục vụ dịch vụ kiểm thử nội bộ trên `127.0.0.1:8080`)

---

### 3. QUY TRÌNH THIẾT LẬP MÔI TRƯỜNG
1. **Thiết lập máy ảo:** Khởi tạo Windows 11 Pro, cấu hình mạng ở chế độ cô lập `Host-only` đảm bảo an toàn, chụp ảnh **H1**.
2. **Cài đặt bộ công cụ:** Chuyển tạm sang chế độ mạng `NAT` để nạp các công cụ thông qua winget và tải trực tiếp gói Microsoft Sysinternals vào `C:\LAB3\Tools`.
3. **Xác nhận phiên bản:** Chạy kiểm tra phiên bản toàn bộ 5 công cụ trong PowerShell, chụp ảnh **H2**.
4. **Thu thập Baseline:** Chuyển card mạng trở lại `Host-only`, xuất thông tin cấu hình OS, trạng thái Defender, Firewall, Process ra thư mục `Evidence/`, chụp ảnh **H3**.
5. **Đóng băng trạng thái:** Tạo Snapshot sạch mang tên `LAB3_CLEAN_20260914`.

---

### 4. TÓM TẮT KẾT QUẢ CÁC TÌNH HUỐNG (TH1 - TH8)

| Tình huống | Nội dung kỹ thuật thực hiện | Bằng chứng thu thập | Trạng thái |
| :--- | :--- | :--- | :---: |
| **TH1: Risk Register** | Phân tích 5 tài sản quan trọng (Credentials, Lab data, HTTP Service, Email, Defender) theo Asset - Vulnerability - Threat - Risk - Control; phân loại 5 nguồn nguy cơ. | Bảng mục B.1 trong Word | **PASS** |
| **TH2: Malware (EICAR)** | Ghi chuỗi kiểm thử chuẩn EICAR vào đĩa, kiểm chứng khả năng tự động chặn và đưa vào diện cách ly (`Quarantined`) của Defender. | Ảnh **H4**, `defender_eicar.txt` | **PASS** |
| **TH3: Authentication & Keylogger** | Kích hoạt Audit Logon, tạo `lab3user`, sinh log đăng nhập sai (Event 4625) / đúng (Event 4624), thực hiện xoay vòng mật khẩu (Credential Rotation). | Ảnh **H5**, `auth_events_before_rotation.txt` | **PASS** |
| **TH4: Backdoor & Persistence** | Cài Sysmon schema 4.90 bắt Event ID 1 (Process Create); tạo cơ chế tự khởi động `LAB3_Run_Demo` (Autoruns); mở HTTP listener `127.0.0.1:8080` (Process Explorer). | Ảnh **H6**, **H7**, **H8** | **PASS** |
| **TH5: Sniffing & Traffic Analysis** | Bắt gói tin HTTP loopback qua Npcap, phân tích dòng dữ liệu lộ lọt bản rõ `TRAINING_ONLY` qua Follow HTTP Stream, đối chiếu tính an toàn của HTTPS/TLS. | Ảnh **H9** | **PASS** |
| **TH6: DoS & Mail Bombing** | Chạy kiểm thử tải nội bộ `local_load_test.py` trên 127.0.0.1; phân tích nguồn IP tấn công trong tệp DDoS mẫu và dấu hiệu dội bom thư rác. | Ảnh **H10**, `local_load_test.txt`, `ddos_top_sources.txt` | **PASS** |
| **TH7: Phishing & Social Engineering** | Phân tích 5 chỉ dấu lừa đảo trong bức thư mẫu `phishing_email.txt`; phân loại chính xác 6 kịch bản Social Engineering phổ biến. | Phân tích chi tiết mục B.7 | **PASS** |
| **TH8: Recovery & Hash Integrity** | Dọn dẹp tiến trình, xóa Run key persistence, xóa user test, gỡ Sysmon; xác nhận Defender vẫn bảo vệ liên tục; băm toàn bộ bằng chứng ra SHA-256. | Ảnh **H11**, `evidence_sha256.csv` | **PASS** |

---

### 5. CẤU TRÚC DANH MỤC TỆP NỘP BÀI
```text
LAB3/
├── 11CNPM2_LAB3_1150080143_VoAnhKiet.docx        # Báo cáo hoàn chỉnh (đã chèn đủ 11 ảnh H1-H11)
├── README.md                                     # Tệp thuyết minh tổng hợp bài thực hành
├── evidence_sha256.csv                           # Danh sách mã băm SHA-256 của các tệp bằng chứng
└── Evidence/                                     # Thư mục lưu trữ nhật ký và kết quả đo đạc
    ├── baseline_os.txt
    ├── baseline_defender.txt
    ├── baseline_firewall.txt
    ├── baseline_network.txt
    ├── baseline_processes.txt
    ├── start_time.txt
    ├── defender_eicar.txt
    ├── auth_events_before_rotation.txt
    ├── local_load_test.txt
    └── ddos_top_sources.txt