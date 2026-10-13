# LAB 5 — THIẾT LẬP HỆ THỐNG PHÒNG THỦ MẠNG VỚI FIREWALL PFSENSE

## 1. Thông tin bài thực hành

* **Họ và tên:** Võ Anh Kiệt
* **Mã số sinh viên:** 1150080143
* **Mã lớp:** 11_ĐH_CNPM2
* **Môn học:** An toàn và Bảo mật Hệ thống Thông tin
* **Bài thực hành:** LAB 5 — Thiết lập hệ thống phòng thủ mạng với Firewall pfSense
* **Link Video Demo:** https://youtu.be/TleqYrrv72c

---

## 2. Môi trường thực hành

### pfSense

* **Phiên bản:** pfSense Community Edition 2.7.2-RELEASE
* **WAN (`em0`):** Bridged Adapter

  * IP: `192.168.1.3/24`
* **LAN (`em1`):** Host-Only Adapter

  * IP: `10.0.0.1/8`
* **DMZ (`em2`):** Internal Network `dmz-net`

  * IP: `172.16.0.1/16`

### Windows Server — Domain Controller

* **Hệ điều hành:** Windows Server 2025 Standard Evaluation
* **IP:** `10.0.0.2/8`
* **Gateway:** `10.0.0.1`
* **DNS:** `10.0.0.2`
* **DNS Forwarder:** `8.8.8.8`
* **Domain:** `voanhkiet.local`

### LAN Test Client

* **Tên máy:** `LAN-Test-VoAnhKiet`
* **Hệ điều hành:** Ubuntu Server
* **IP:** `10.0.0.3/8`
* **Gateway:** `10.0.0.1`
* **Network:** Host-Only Adapter

### DMZ Test Client

* **Tên máy:** `DMZ-Test-VoAnhKiet`
* **Hệ điều hành:** Ubuntu Server
* **IP:** `172.16.0.2/16`
* **Gateway:** `172.16.0.1`
* **Network:** Internal Network `dmz-net`

---

## 3. Mô hình mạng

```text
                         INTERNET
                            │
                            │
                    ┌───────▼───────┐
                    │    pfSense    │
                    │               │
                    │ WAN 192.168.1.3
                    │               │
                    │ LAN 10.0.0.1  │
                    │ DMZ 172.16.0.1│
                    └───┬────────┬──┘
                        │        │
                 LAN Network   DMZ Network
                 10.0.0.0/8   172.16.0.0/16
                        │        │
             ┌──────────┴──┐  ┌──┴──────────────┐
             │             │  │                 │
       Windows Server   Ubuntu          Ubuntu DMZ
       Domain Controller LAN-Test       DMZ-Test
       10.0.0.2         10.0.0.3        172.16.0.2
```

---

## 4. Các cấu hình chính

### 4.1. Cấu hình pfSense

* WAN sử dụng **Bridged Adapter** và nhận IP qua DHCP.
* LAN sử dụng **Host-Only Adapter** với IP `10.0.0.1/8`.
* DMZ sử dụng **Internal Network `dmz-net`** với IP `172.16.0.1/16`.
* Cấu hình **Hybrid Outbound NAT** để các mạng LAN/DMZ có thể truy cập Internet khi được Firewall cho phép.
* Tắt các rule mặc định `Default allow LAN to any rule`.
* Xây dựng các rule Firewall riêng để kiểm soát lưu lượng giữa LAN, DMZ và Internet.

### 4.2. Cấu hình Domain Controller

* Cài đặt Windows Server 2025.
* Cấu hình IP tĩnh `10.0.0.2/8`.
* Cài đặt **Active Directory Domain Services (AD DS)**.
* Tạo Forest/Domain:
  `voanhkiet.local`
* Cấu hình DNS Forwarder:
  `8.8.8.8`
* Cho phép ICMP Echo Request để phục vụ kiểm thử Firewall.

---

## 5. Các tình huống kiểm thử

### Tình huống 01 — Kiểm thử Rule nền tảng Bật/Tắt

**Mục tiêu:** Kiểm tra khả năng kiểm soát kết nối Internet của LAN thông qua rule nền tảng.

**Kết quả:**

* Khi bật rule:

  * DC ping `8.8.8.8` thành công.
  * `nslookup example.com` thành công.
  * `curl.exe` truy cập website thành công.
* Khi tắt rule nền tảng và Reset States:

  * DC ping `8.8.8.8` bị `Request timed out`.

**Kết quả:** PASS

**Minh chứng:**

```text
evidence/06_KiemThu_BatTat_Rule_DC_VoAnhKiet.png
```

---

### Tình huống 02 — Chặn ICMP, cho phép Web và DNS

**Mục tiêu:** Kiểm tra khả năng chặn ping nhưng vẫn cho phép DNS và HTTP/HTTPS.

**Rule LAN:**

```text
1. Block ICMP
2. Pass DNS (TCP/UDP 53)
3. Pass Web (TCP 80/443)
```

**Kết quả trên DC:**

* Ping `8.8.8.8`: BLOCKED
* `nslookup example.com 8.8.8.8`: SUCCESS
* `curl.exe -4 https://example.com`: SUCCESS

**Kết quả:** PASS

**Minh chứng:**

```text
evidence/07a_TH1_Rules_LAN_VoAnhKiet.png
evidence/07b_TH1_KiemThu_CMD_DC_VoAnhKiet.png
```

---

### Tình huống 03 — Giới hạn Internet cho host cụ thể

**Mục tiêu:** Chỉ cho phép Domain Controller truy cập Internet và chặn các host LAN khác.

**Rule LAN:**

```text
1. Pass 10.0.0.2 to Any
2. Block LAN net to Any
```

**Kết quả:**

* DC `10.0.0.2` ping `8.8.8.8`: SUCCESS
* Ubuntu `10.0.0.3` ping `8.8.8.8`: BLOCKED
* Ubuntu bị mất quyền truy cập Internet theo rule Firewall.

**Kết quả:** PASS

**Minh chứng:**

```text
evidence/08a_TH2_Rules_LAN_VoAnhKiet.png
evidence/08b_TH2_KiemThu_DC_va_Ubuntu_VoAnhKiet.png
```

---

## 6. Danh sách minh chứng

Toàn bộ ảnh chụp quá trình cấu hình và kiểm thử được lưu trong thư mục:

```text
evidence/
```

Các minh chứng bao gồm:

```text
01_CaiDat_3CardMang_pfSense_VoAnhKiet.png
02_Console_DatIP_LAN_10.0.0.1_VoAnhKiet.png
03_Dashboard_pfSense_VoAnhKiet.png
04_DMZ_Config_VoAnhKiet.png
05_NAT_Outbound_Hybrid_VoAnhKiet.png
06_LAN_Rule_NenTang_VoAnhKiet.png
07_TH_DisableRule_DC_VoAnhKiet.png
08a_TH1_Rules_LAN_VoAnhKiet.png
08b_TH1_KiemThu_CMD_DC_VoAnhKiet.png
09a_TH2_Rules_LAN_VoAnhKiet.png
09b_TH2_KiemThu_DC_va_Ubuntu_VoAnhKiet.png
10a_TH3_Baseline_Ping_DC_Pass_VoAnhKiet.png
10b_TH3_Rules_DMZ_VoAnhKiet.png
10c_TH3_KiemThu_CoLap_ThanhCong_VoAnhKiet.png
```

---

## 7. Kiểm tra tính toàn vẹn minh chứng

File:

```text
evidence_sha256.csv
```

chứa mã băm **SHA-256** của các file minh chứng trong thư mục `evidence/`, nhằm kiểm tra tính toàn vẹn của dữ liệu.

Có thể tạo lại file bằng PowerShell:

```powershell
Get-ChildItem -Path .\evidence\*.* |
Get-FileHash -Algorithm SHA256 |
Export-Csv -Path .\evidence_sha256.csv -NoTypeInformation -Encoding UTF8
```

---

## 8. Cấu trúc thư mục bàn giao

```text
LAB5/
├── evidence/
│   ├── 01_CaiDat_3CardMang_pfSense_VoAnhKiet.png
│   ├── 02_Console_DatIP_LAN_10.0.0.1_VoAnhKiet.png
│   ├── 03_Dashboard_pfSense_VoAnhKiet.png
│   ├── 04_DMZ_Config_VoAnhKiet.png
│   ├── 05_NAT_Outbound_Hybrid_VoAnhKiet.png
│   ├── 06_LAN_Rule_NenTang_VoAnhKiet.png
│   ├── 07_TH_DisableRule_DC_VoAnhKiet.png
│   ├── 08a_TH1_Rules_LAN_VoAnhKiet.png
│   ├── 08b_TH1_KiemThu_CMD_DC_VoAnhKiet.png
│   ├── 09a_TH2_Rules_LAN_VoAnhKiet.png
│   ├── 09b_TH2_KiemThu_DC_va_Ubuntu_VoAnhKiet.png
│   ├── 10a_TH3_Baseline_Ping_DC_Pass_VoAnhKiet.png
│   ├── 10b_TH3_Rules_DMZ_VoAnhKiet.png
│   └── 10c_TH3_KiemThu_CoLap_ThanhCong_VoAnhKiet.png
│
├── evidence_sha256.csv
├── pfSense-Config-Backup-VoAnhKiet.xml
├── 11_DH_CNPM2-Lab3_1150080143-VoAnhKiet.docx
└── README.md
```

---

## 9. Tổng kết

LAB 5 đã triển khai thành công mô hình Firewall pfSense với ba vùng mạng:

* **WAN:** Kết nối Internet.
* **LAN:** Mạng nội bộ chứa Domain Controller và máy kiểm thử.
* **DMZ:** Vùng mạng riêng biệt dành cho máy chủ/máy kiểm thử DMZ.

Các tình huống kiểm thử đã xác nhận Firewall có khả năng:

* Kiểm soát quyền truy cập Internet của LAN.
* Chặn ICMP nhưng cho phép DNS và Web.
* Giới hạn Internet theo từng host.
* Cô lập DMZ khỏi LAN.
* Đồng thời vẫn cho phép DMZ truy cập Internet khi được cấu hình phù hợp.

**Tất cả các tình huống kiểm thử đều đạt kết quả PASS.**
