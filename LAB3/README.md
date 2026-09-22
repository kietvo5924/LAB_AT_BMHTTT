# BÁO CÁO THỰC HÀNH LAB 3
## NHẬN DIỆN VÀ ỨNG PHÓ CÁC MỐI ĐE DỌA ĐẾN AN TOÀN THÔNG TIN

---

### 1. THÔNG TIN SINH VIÊN
* **Họ và tên:** Võ Anh Kiệt
* **Mã số sinh viên (MSSV):** 1150080143
* **Mã lớp:** 11CNPM2
* **Học phần:** An toàn và Bảo mật Hệ thống Thông tin
* **Link Video minh chứng (nếu có yêu cầu):** [Dán link Google Drive / YouTube Unlisted tại đây]

---

### 2. PHIÊN BẢN MÔI TRƯỜNG THỰC HÀNH
* **Ảo hóa:** VMware Workstation Pro 26H1 (Chế độ mạng: Host-only cô lập)
* **Hệ điều hành máy trạm:** Windows 11 25H2 x64, OS build 26200.9445 (Bản cập nhật bảo mật KB5124008)
* **Snapshot sạch tham chiếu:** `LAB3_CLEAN_20260914`
* **Endpoint Protection:** Microsoft Defender Antivirus tích hợp (Real-time protection: ON, Tamper Protection: ON)
* **Công cụ phân tích và đo đạc chuẩn hóa:**
  * Sysmon: v15.22 (Schema cấu hình: 4.90)
  * Autoruns: v14.3
  * Process Explorer: v17.14
  * Wireshark: v4.6.8 Stable + Npcap loopback driver
  * Python: v3.14.7 (Chỉ phục vụ local load test và web server nội bộ 127.0.0.1)

---

### 3. CÁCH DỰNG MÔI TRƯỜNG
1. **Khởi tạo VM:** Dựng máy ảo Windows 11 Pro 64-bit trên VMware Workstation với cấu hình khuyến nghị (2 vCPU, 6 GB RAM, 64 GB Disk).
2. **Cô lập mạng & Snapshot:** Cấu hình card mạng máy ảo về `Host-only` để đảm bảo an toàn tuyệt đối. Chụp ảnh `H1_VM_Windows_Version.png` và lưu Snapshot `LAB3_CLEAN_20260914`.
3. **Cấu trúc thư mục:** Khởi tạo cây thư mục làm việc tập trung `C:\LAB3` gồm `Evidence\`, `Tools\`, `Downloads\`, `lab3_assets\`.
4. **Triển khai dữ liệu và công cụ:**
   * Giải nén gói `LAB3_Threats_Assets.zip` vào thư mục `C:\LAB3\lab3_assets`.
   * Cài đặt Python 3.14.7 và Wireshark 4.6.8 (kèm Npcap).
   * Tải bộ công cụ Microsoft Sysinternals (Sysmon, Autoruns, Process Explorer) vào `C:\LAB3\Tools`.
   * Chụp ảnh xác nhận phiên bản `H2_ToolVersions.png`.
5. **Thu thập Baseline:** Chạy lệnh thu thập cấu hình hệ thống, dịch vụ mạng, tiến trình và trạng thái Defender/Firewall vào `C:\LAB3\Evidence\`. Chụp ảnh `H3_Baseline_Defender_Firewall.png`.

---

### 4. CÁC TÌNH HUỐNG THỰC HIỆN VÀ KẾT QUẢ

| STT | Tình huống (Scenario) | Mục tiêu và kỹ thuật thực hiện | Kết quả |
| :---: | :--- | :--- | :---: |
| **TH1** | Baseline và Risk Register | Lập Risk Register phân tích Asset - Vulnerability - Threat - Risk - Control; phân loại 5 nguồn nguy cơ. | **PASS** |
| **TH2** | Malware (EICAR Verification) | Ghi chuỗi kiểm thử EICAR, kiểm chứng chu trình tự động chặn và cách ly của Defender (`Protection history`). Chụp ảnh H4. | **PASS** |
| **TH3** | Password & Keylogger Risk | Bật Audit Logon, tạo tài khoản `lab3user`, sinh log đăng nhập sai (Event ID 4625) / đúng (Event ID 4624), thực hiện xoay vòng mật khẩu (credential rotation). Chụp ảnh H5. | **PASS** |
| **TH4** | Backdoor & Persistence | Kích hoạt Sysmon schema 4.90 (Event ID 1), cấu hình persistence lành tính (Run Key & Scheduled Task), tạo HTTP listener 127.0.0.1:8080 và ánh xạ Process Explorer. Chụp ảnh H6, H7, H8. | **PASS** |
| **TH5** | Sniffing, MITM & Spoofing | Bắt gói tin HTTP loopback phát hiện chuỗi bản rõ `TRAINING_ONLY` so sánh với mã hóa TLS/443. Chụp ảnh H9, H10a. | **PASS** |
| **TH6** | DoS, DDoS & Mail Bombing | Thực thi kiểm thử tải nội bộ `local_load_test.py` trên 127.0.0.1; phân tích tập dữ liệu DDoS mẫu (TEST-NET) và log tấn công Mail Bombing offline. Chụp ảnh H10b. | **PASS** |
| **TH7** | Social Engineering & Phishing | Đánh dấu 5 chỉ dấu email lừa đảo trong `phishing_email.txt`; phân loại 6 kịch bản Social Engineering từ file mẫu. Chụp ảnh H10c. | **PASS** |
| **TH8** | Cleanup, Recovery & Hash | Gỡ bỏ toàn bộ artefact thử nghiệm, đóng cổng, xác nhận Defender vẫn bật (H11), xuất mã băm SHA-256 danh mục bằng chứng ra `evidence_sha256.csv`. | **PASS** |

---

### 5. LỖI GẶP PHẢI VÀ CÁCH KHẮC PHỤC

* **Lỗi 1: Trình cài đặt Windows 11 bắt buộc đăng nhập tài khoản Microsoft cá nhân (OOBE Online)**
  * *Hiện tượng:* Trình duyệt cài đặt không cho tạo tài khoản cục bộ, yêu cầu nhập email Microsoft.
  * *Cách khắc phục:* Nhấn tổ hợp phím `Shift + F10` mở CMD, chạy lệnh `oobe\bypassnro` để khởi động lại máy ảo. Sau đó ngắt mạng tạm thời (Disconnect Network Adapter) và chọn *"Continue with limited setup"* để tạo tài khoản máy trạm offline.
* **Lỗi 2: Không tải được winget/công cụ khi VM đang ở chế độ mạng Host-only**
  * *Hiện tượng:* Lệnh `winget install` hoặc tải từ `download.sysinternals.com` thất bại do không có kết nối Internet ngoài.
  * *Cách khắc phục:* Chuyển tạm card mạng máy ảo sang chế độ `NAT` trong quá trình cài đặt công cụ. Sau khi hoàn tất cài đặt và kiểm tra phiên bản (H2), chuyển card mạng trở lại `Host-only` đúng quy định bảo mật trước khi thực hành các tình huống TH1–TH7.
* **Lỗi 3: Quyền thực thi lệnh trên PowerShell bị từ chối**
  * *Hiện tượng:* Không thể cấu hình Run key Registry hoặc kích hoạt Audit policy.
  * *Cách khắc phục:* Luôn mở PowerShell bằng quyền quản trị tối cao (`Run as administrator`).

---

### 6. CẤU TRÚC DANH MỤC TỆP TRONG THƯ MỤC LAB3/
```text
LAB3/
├── README.md                              # Báo cáo tổng hợp markdown
├── [MãLớp]-LAB3_[MSSV]-[HọTên].docx        # File báo cáo Word hoàn chỉnh
├── evidence_sha256.csv                    # Danh sách mã băm SHA-256 của các tệp bằng chứng
├── images/                                # Thư mục chứa 11 ảnh chụp chứng minh (H1 đến H11)
│   ├── H1_VM_Windows_Version.png
│   ├── H2_ToolVersions.png
│   ├── H3_Baseline_Defender_Firewall.png
│   ├── H4_ProtectionHistory_EICAR.png
│   ├── H5_Event4625.png
│   ├── H6_Sysmon_Event1.png
│   ├── H7_Autoruns_LAB3_Run_Demo.png
│   ├── H8_ProcessExplorer_Python.png
│   ├── H9_HTTP_Plaintext.png
│   ├── H10_Load_and_Log_Analysis.png
│   └── H11_Recovery_Verification.png
└── logs/                                  # Toàn bộ tệp log và output đã được làm sạch dữ liệu
    ├── baseline_defender.txt
    ├── baseline_firewall.txt
    ├── auth_events_before_rotation.txt
    ├── local_load_test.txt
    └── ...