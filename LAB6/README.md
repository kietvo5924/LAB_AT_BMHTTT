# LAB 6 — QUẢN TRỊ CHÍNH SÁCH BẢO MẬT, TÍCH HỢP ACTIVE DIRECTORY (LDAP), CAPTIVE PORTAL VÀ ĐIỀU TIẾT LƯU LƯỢNG VỚI PFSENSE

## 1. Thông tin bài thực hành

- **Họ và tên:** Võ Anh Kiệt
- **Mã số sinh viên:** 1150080143
- **Mã lớp:** 11_ĐH_CNPM2
- **Môn học:** An toàn và Bảo mật Hệ thống Thông tin
- **Bài thực hành:** LAB 6 — Quản trị chính sách bảo mật, tích hợp Active Directory (LDAP), Captive Portal và điều tiết lưu lượng với Firewall pfSense
- **Link Video Demo:** *https://youtu.be/mW9HzHD2Phk*

---

## 2. Môi trường thực hành

### pfSense

- **Phiên bản:** pfSense Community Edition 2.7.2-RELEASE
- **WAN (`em0` / Card 1):** NAT / Bridged Adapter
  * Nhận IP tự động qua DHCP
- **MGMT (`em1` / Card 2):** Host-Only Adapter
  * IP: `192.168.56.254/24`
  * Mục đích: Quản trị WebGUI độc lập, chống khóa quản trị (Anti-lockout)
- **LAN (`em2` / Card 3):** Internal Network `lab6-lan`
  * IP: `10.6.0.1/24`
- **DMZ (`em3` / Card 4):** Internal Network `lab6-dmz`
  * IP: `172.16.6.1/24`

### Windows Server — Domain Controller (DC-VoAnhKiet)

- **Hệ điều hành:** Windows Server 2025 Standard Evaluation
- **Tên máy:** `DC-VoAnhKiet`
- **IP tĩnh:** `10.6.0.10/24`
- **Gateway:** `10.6.0.1`
- **DNS:** `10.6.0.10`
- **DNS Forwarder:** `8.8.8.8`
- **Domain:** `voanhkiet.local`
- **Tổ chức & Người dùng AD:**
  * Organizational Unit (OU): `LAB6-Users`
  * Người dùng: `sv_a`, `sv_b`
  * Service Account (LDAP Bind): `svc_pfsense_ldap`
- **Chính sách bảo mật bổ sung (Server 2025):** Vô hiệu hóa `LDAP server signing requirements` và `enforcement` trong `secpol.msc` để hỗ trợ Simple Bind từ pfSense.

### LAN Test Client (LAN-Test-VoAnhKiet)

- **Tên máy:** `LAN-Test-VoAnhKiet`
- **Hệ điều hành:** Ubuntu Server (CLI)
- **Network:** Internal Network `lab6-lan`
- **Gateway:** `10.6.0.1`
- **IP mô phỏng luân phiên:**
  * **Client-A:** `10.6.0.21/24`
  * **Client-B:** `10.6.0.22/24`

### DMZ Web Server (DMZ-Test-VoAnhKiet)

- **Tên máy:** `DMZ-Test-VoAnhKiet`
- **Hệ điều hành:** Ubuntu Server
- **Network:** Internal Network `lab6-dmz`
- **Gateway:** `172.16.6.1`
- **Dịch vụ:** Nginx Web Server, file test 10MB (`/var/www/html/test10m.bin`)
- **4 IP mô phỏng danh mục website (IP Aliasing trên `enp0s3`):**
  * `172.16.6.10/24`: **GENERAL_SITE** (Trang web thông thường)
  * `172.16.6.20/24`: **JOB_SITE** (Trang tìm kiếm việc làm)
  * `172.16.6.30/24`: **SOCIAL_SITE** (Mạng xã hội)
  * `172.16.6.40/24`: **RESTRICTED_SITE** (Trang web cấm)

---

## 3. Mô hình mạng (Topology)

```text
                                  INTERNET
                                      │
                                      ▼
                             ┌─────────────────┐
                             │  WAN (DHCP/NAT) │
┌──────────────────┐         ├─────────────────┤
│ Máy thật Admin   │◄───────►│ MGMT 192.168.56.254 (Host-Only)
└──────────────────┘         ├─────────────────┤
                             │     pfSense     │
                             └────────┬────────┘
                                      │
                 ┌────────────────────┴────────────────────┐
                 │                                         │
                 ▼                                         ▼
         LAN 10.6.0.1/24                           DMZ 172.16.6.1/24
      (Internal: lab6-lan)                       (Internal: lab6-dmz)
                 │                                         │
        ┌────────┴────────┐                                │
        │                 │                                ▼
┌───────▼──────┐  ┌───────▼────────┐             ┌───────────────────┐
│Windows Server│  │  Ubuntu Client │             │  DMZ Web Server   │
│  Domain DC   │  │(A: .21 / B: .22│             │ 172.16.6.10 (GEN) │
│  10.6.0.10   │  │ LAN-Test-Client│             │ 172.16.6.20 (JOB) │
│voanhkiet.local  └────────────────┘             │ 172.16.6.30 (SOC) │
└──────────────┘                                 │ 172.16.6.40 (RES) │
                                                 └───────────────────┘
```

---

## 4. Các cấu hình chính

### 4.1. Phân tách Interface & Cấu hình pfSense
- Thiết lập 4 card mạng độc lập: WAN, MGMT (Host-Only), LAN (`lab6-lan`), DMZ (`lab6-dmz`).
- Tách biệt cổng quản trị WebGUI sang phân đoạn MGMT, tránh xung đột với Captive Portal trên LAN.
- Cấu hình Hybrid Outbound NAT đảm bảo định tuyến Internet khi cần thiết.

### 4.2. Tích hợp Active Directory (LDAP) & Captive Portal
- **LDAP Authentication Server (`LAB6-AD`):**
  * Server IP: `10.6.0.10`, Port: `389` (Standard TCP).
  * Search Scope: `Entire Subtree`.
  * Base DN: `DC=voanhkiet,DC=local`.
  * Authentication Container: `OU=LAB6-Users,DC=voanhkiet,DC=local`.
  * Bind Credentials: `CN=svc_pfsense_ldap,CN=Users,DC=voanhkiet,DC=local`.
- **Captive Portal Zone (`LAB6_USERS`):**
  * Gắn trên Interface `LAN`.
  * Cơ chế xác thực: `Use an Authentication backend` trỏ về `LAB6-AD`.
  * Cấu hình `Allowed IP Addresses` bypass cho các máy trạm dòng lệnh CLI (`10.6.0.21`, `10.6.0.22`).

### 4.3. Quản lý Đối tượng (Aliases) & Lịch biểu (Schedules)
- **Aliases:**
  * Host Aliases: `CLIENT_A` (`10.6.0.21`), `CLIENT_B` (`10.6.0.22`), `POLICY_CLIENTS` (`10.6.0.21`, `10.6.0.22`).
  * Web Aliases: `GENERAL_SITE` (`.10`), `JOB_SITE` (`.20`), `SOCIAL_SITE` (`.30`), `RESTRICTED_SITE` (`.40`).
  * Port Aliases: `WEB_PORTS` (`80`, `443`).
- **Schedules:**
  * `LUNCH_WINDOW`: Thứ 2 đến Thứ 6, từ 11:30 đến 13:00.
  * `WORK_HOURS`: Thứ 2 đến Thứ 6, từ 08:00 đến 17:00.
  * `TEST_NOW`: Lịch kiểm thử tức thì trong ngày.

### 4.4. Điều tiết Băng thông (Traffic Shaping - Limiter)
- Tạo 2 Pipes điều tiết: `LIMIT_DOWN` và `LIMIT_UP` với băng thông `1 Mbit/s`.
- Áp dụng vào Rule tường lửa thông qua tùy chọn `In / Out pipe`.

---

## 5. Các kịch bản và kết quả kiểm thử

### Kịch bản Nền tảng 01 — Xác thực LDAP và Captive Portal
- **Mục tiêu:** Kiểm tra khả năng đồng bộ danh bạ người dùng AD và cổng xác thực Captive Portal.
- **Kết quả:**
  * Kiểm tra qua *Diagnostics / Authentication*: User `sv_a` và `sv_b` xác thực thành công (`User authenticated successfully`).
  * Trình duyệt máy trạm truy cập HTTP tự động nhận mã chuyển hướng `302 Found`, đăng nhập thành công hiển thị session active.
- **Đánh giá:** PASS.

### Kịch bản 01 — Chặn JOB_SITE đối với Client-A
- **Mục tiêu:** Cấm Client-A truy cập trang tuyển dụng, các trang thông thường vẫn truy cập bình thường.
- **Quy tắc Firewall:** `Block CLIENT_A -> JOB_SITE TCP/80 + Log` đặt phía trên rule `Pass`.
- **Kết quả:**
  * `curl -I http://172.16.6.10`: Trả về `HTTP/1.1 200 OK` (PASS).
  * `curl -I --connect-timeout 3 http://172.16.6.20`: Bị ngắt kết nối sau 3004 ms với lỗi `Connection timed out` (BLOCKED).
- **Đánh giá:** PASS.

### Kịch bản 02 — Chặn RESTRICTED_SITE cho toàn bộ nhóm POLICY_CLIENTS
- **Mục tiêu:** Cấm cả Client-A và Client-B truy cập trang web cấm.
- **Quy tắc Firewall:** `Block POLICY_CLIENTS -> RESTRICTED_SITE TCP/80 + Log`.
- **Kết quả:**
  * Client-A (`10.6.0.21`): Truy cập `.10` ra `200 OK`; truy cập `.40` bị `Connection timed out`.
  * Client-B (`10.6.0.22`): Truy cập `.10` ra `200 OK`; truy cập `.40` bị `Connection timed out`.
- **Đánh giá:** PASS.

### Kịch bản 03 — Kiểm soát SOCIAL_SITE theo Thời gian (Schedule)
- **Mục tiêu:** Chỉ cho phép truy cập mạng xã hội trong khung giờ nghỉ quy định, ngoài giờ sẽ bị chặn.
- **Quy tắc Firewall:** 
  * Rule 1: `Pass POLICY_CLIENTS -> SOCIAL_SITE TCP/80` gắn Schedule `TEST_NOW`.
  * Rule 2: `Block POLICY_CLIENTS -> SOCIAL_SITE TCP/80` (chặn khi ngoài giờ).
- **Kết quả:**
  * **Trong giờ (Schedule Active):** `curl` tới `172.16.6.30` trả về `HTTP/1.1 200 OK`.
  * **Ngoài giờ (Schedule Inactive):** `curl` tới `172.16.6.30` bị `Connection timed out` sau 3001 ms.
- **Đánh giá:** PASS.

### Kịch bản 04 — Giới hạn Băng thông truy cập (Traffic Shaping - Limiter)
- **Mục tiêu:** Bóp tốc độ tải dữ liệu từ máy chủ web DMZ về máy Client xuống tối đa `1 Mbit/s`.
- **Quy tắc Firewall:** Gắn `In / Out pipe` (`LIMIT_DOWN` / `LIMIT_UP`) vào rule Pass của LAN.
- **Kết quả:**
  * Chạy lệnh tải file 10MB: `curl -o /dev/null http://172.16.6.10/test10m.bin`.
  * Tốc độ trung bình được ghìm ổn định ở mức `117.7k` (khoảng 118 KB/s ~ 1 Mbit/s).
  * Thời gian tải kéo dài đúng 1 phút 26 giây thay vì tải tức thì.
- **Đánh giá:** PASS.

### Kịch bản 05 — Cô lập DMZ khỏi LAN (Stateful Firewall)
- **Mục tiêu:** Cho phép LAN kết nối Web DMZ; cấm tuyệt đối máy chủ DMZ chủ động tấn công hoặc kết nối vào vùng nội bộ LAN.
- **Quy tắc Firewall (Tab DMZ):** `Block DMZ subnets -> LAN subnets + Log` đặt trên cùng.
- **Kết quả:**
  * **Chiều LAN -> DMZ:** Client-A chạy `curl` tới `172.16.6.10` nhận phản hồi `HTTP/1.1 200 OK`.
  * **Chiều DMZ -> LAN:** Từ máy DMZ ping sang máy DC (`10.6.0.10`) nhận kết quả `100% packet loss` (bị tường lửa chặn đứng hoàn toàn).
- **Đánh giá:** PASS.

### Giám sát Nhật ký Tường lửa (Firewall Logs)
- Trang *Status / System Logs / Firewall* ghi nhận chi tiết toàn bộ các gói tin vi phạm có gắn cờ Log: thể hiện rõ biểu tượng dấu X màu đỏ chặn IP `10.6.0.21` gửi gói SYN đến các đích `.20:80` và `.40:80`.

---

## 6. Danh sách minh chứng

Toàn bộ ảnh chụp màn hình quá trình cấu hình và kiểm thử được lưu trữ tại thư mục:

```text
evidence/
```

Danh mục các file ảnh minh chứng:

```text
01_CaiDat_4CardMang_pfSense_VoAnhKiet.png
02_Console_DatIP_pfSense_VoAnhKiet.png
03_Dashboard_pfSense_VoAnhKiet.png
04_DMZ_Web_IPs_Nginx.png
05_AD_LDAP_pfSense_Config.png
06_LDAP_Test_Diagnostics_Auth.png
07_Captive_Portal_Zone_Config.png
08_Captive_Portal_Login_Client.png
09_Aliases_pfSense.png
10_Schedules_pfSense.png
11a_KB1_Rule_Block_JobSite.png
11b_KB1_KiemThu_ClientA.png
12a_KB2_Rule_Block_Restricted.png
12b_KB2_KiemThu_ClientA_ClientB.png
13a_KB3_Rule_Schedule_Social.png
13b_KB3_KiemThu_TrongGio_NgoaiGio.png
14a_KB4_Limiter_Config.png
14b_KB4_Rule_Limiter_LAN.png
14c_KB4_KiemThu_Limiter.png
15a_KB5_Rule_DMZ_Block_LAN.png
15b_KB5_KiemThu_2Chieu_LAN_DMZ.png
15_KB5_Firewall_Logs.png
```

---

## 7. Kiểm tra tính toàn vẹn minh chứng

File mã băm **SHA-256** được tạo để đảm bảo tính toàn vẹn và chống chỉnh sửa của các file ảnh minh chứng:

```text
evidence_sha256.csv
```

Có thể khởi tạo hoặc kiểm tra lại bằng PowerShell:

```powershell
Get-ChildItem -Path .\evidence\*.* |
Get-FileHash -Algorithm SHA256 |
Export-Csv -Path .\evidence_sha256.csv -NoTypeInformation -Encoding UTF8
```

---

## 8. Cấu trúc thư mục bàn giao

```text
LAB6/
├── evidence/
│   └── (Toàn bộ các ảnh chụp minh chứng định dạng Screenshot_YYYY-MM-DD.png)
├── evidence_sha256.csv
├── 11CNPM2_LAB6_1150080143_VoAnhKiet.docx
└── README.md
```

---

## 9. Tổng kết

LAB 6 đã xây dựng và kiểm thử thành công hệ thống phòng thủ mạng nâng cao kết hợp xác thực tập trung:

1. **Kiến trúc mạng 4 vùng an toàn:** Phân tách rõ ràng WAN, MGMT (Out-of-band), LAN nội bộ và DMZ cung cấp dịch vụ.
2. **Tích hợp Active Directory qua LDAP:** Kết nối pfSense với Windows Server 2025, xử lý thành công chính sách bảo mật *LDAP Signing Enforcement*.
3. **Cổng kiểm soát Captive Portal:** Xác thực danh tính người dùng trước khi cấp quyền truy cập mạng.
4. **Kiểm soát chính sách truy cập chi tiết:**
   - Lọc trang web theo nhóm đối tượng người dùng (Aliases).
   - Kiểm soát truy cập linh hoạt theo khung giờ (Schedules).
   - Giới hạn lưu lượng băng thông chính xác với thuật toán Dummynet Limiter (1 Mbit/s).
5. **Đảm bảo nguyên tắc Stateful Firewall:** Cô lập hoàn toàn vùng DMZ khỏi LAN, ngăn chặn việc leo thang truy cập trái phép vào tài nguyên nội bộ.

**Tất cả các nội dung và tình huống kiểm thử trong LAB 6 đều đạt kết quả PASS.**