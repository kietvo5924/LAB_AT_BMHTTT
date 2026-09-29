# BÁO CÁO THỰC HÀNH LAB 4: KHẢO SÁT VÀ ĐÁNH GIÁ BỀ MẶT MẠNG BẰNG NMAP

## 1. THÔNG TIN SINH VIÊN
- **Họ và tên:** Võ Anh Kiệt
- **Mã số sinh viên (MSSV):** 1150080143
- **Môn học:** An toàn hệ thống thông tin
- **Tên bài Lab:** LAB 4 - Khảo sát và đánh giá bề mặt mạng bằng Nmap
- **Repository GitHub:** `LAB_AT_BMHTTT` (Chế độ Public)
- **Thư mục bài làm:** `LAB4`
- **Link youtube:** https://youtu.be/396p2s8oaQk

---

## 2. PHIÊN BẢN MÔI TRƯỜNG THỰC HÀNH
- **Máy thật (Host OS):** Windows 11 / Windows 10 64-bit (`192.168.56.1`)
- **Phần mềm ảo hóa:** Oracle VM VirtualBox (v7.x)
- **Máy quét chính (VM 1):** Kali Linux - IP Host-Only: `192.168.56.102`
- **Máy đích lỗ hổng (VM 2):** Metasploitable 2 - IP Host-Only: `192.168.56.103`
- **Công cụ sử dụng:** Nmap v7.99, xsltproc, Python3 HTTP Server, iptables

---

## 3. CÁCH DỰNG MÔI TRƯỜNG & KIỂM TRA KẾT NỐI
1. **Thiết lập Mạng VirtualBox Host-Only:**
   - Tạo card mạng `VirtualBox Host-Only Ethernet Adapter` với dải địa chỉ IPv4 `192.168.56.0/24`.
2. **Cấu hình Card mạng VM:**
   - Đặt cả 2 VM (Kali Linux và Metasploitable 2) ở chế độ `Host-Only Adapter`.
3. **Xác định địa chỉ IP thực tế:**
   - Trên Metasploitable 2: Gõ `ifconfig` $\rightarrow$ Nhận IP `192.168.56.103`.
   - Trên Kali Linux: Gõ `ip -br addr` $\rightarrow$ Nhận IP `192.168.56.102`.
4. **Kiểm tra kết nối mạng (Ping):**
   - Từ Kali Linux chạy lệnh: `ping -c 4 192.168.56.103` (Thành công 100%, 0% packet loss).

---

## 4. DANH SÁCH TÌNH HUỐNG THỰC HIỆN VÀ KẾT QUẢ

| STT | Nhiệm vụ / Tình huống | Cú pháp lệnh thực hiện | Kết quả | Ghi chú |
| :---: | :--- | :--- | :---: | :--- |
| **1** | Phát hiện Host đang hoạt động (Host Discovery) | `sudo nmap -sn 192.168.56.0/24` | **PASS** | Phát hiện 4 host active (`.1`, `.100`, `.102`, `.103`) |
| **2** | Quét SYN Scan (Stealth Scan) | `sudo nmap -sS 192.168.56.103` | **PASS** | Báo cáo 22 cổng TCP `open` nhanh chóng (0.19s) |
| **3** | Quét UDP có kiểm soát | `sudo nmap -sU --top-ports 20 192.168.56.103` | **PASS** | Phát hiện các dịch vụ UDP (DNS 53, RPC 111, NetBIOS 137) |
| **4** | Nhận diện phiên bản dịch vụ (Version Detection) | `sudo nmap -sV 192.168.56.103` | **PASS** | Xác định vsftpd 2.3.4, OpenSSH 4.7p1, Apache 2.2.8, Samba 3.X |
| **5** | Nhận diện hệ điều hành (OS Fingerprinting) | `sudo nmap -O 192.168.56.103` | **PASS** | Nhận diện chính xác hệ điều hành `Linux 2.6.X` |
| **6** | Kiểm tra thông tin & Lỗ hổng SMB (NSE Scripts) | `sudo nmap -p 445 --script smb-os-discovery,smb-vuln-ms17-010 192.168.56.103` | **PASS** | Trả về thông tin OS Unix Samba 3.0.20-Debian; MS17-010 N/A |
| **7** | Đánh giá Before / After Hardening | **Before:** `sudo nmap -sV 192.168.56.103 -oN before_hardening.txt`<br>**Hardening:** `sudo iptables -A INPUT -p tcp --dport 23 -j DROP`<br>**After:** `sudo nmap -sV 192.168.56.103 -oN after_hardening.txt` | **PASS** | Port `23/tcp` (Telnet) chuyển thành công từ `open` sang `filtered` |
| **8** | Xuất kết quả ra các tệp Log & Báo cáo HTML | `sudo nmap -sV -O 192.168.56.103 -oX ket_qua.xml`<br>`xsltproc ket_qua.xml -o bao_cao.html`<br>`sudo nmap -p 445 192.168.56.0/24 -oG smb.txt` | **PASS** | Xuất đầy đủ các tệp `.txt`, `.xml`, `.html`, `.txt` (Grepable) |
| **9** | Kiểm tra tính nguyên vẹn dữ liệu (Checksum) | `sha256sum *.txt *.xml *.html > evidence_sha256.csv` | **PASS** | Tạo tệp mã hóa SHA-256 đối chiếu toàn bộ tệp bằng chứng |

---

## 5. LỖI GẶP PHẢI VÀ CÁCH KHẮC PHỤC

1. **Lỗi sai IP máy đích khi Ping (`Destination Host Unreachable`):**
   - *Nguyên nhân:* Ping nhầm sang IP `.101` theo mặc định lý thuyết thay vì IP thực tế DHCP cấp cho Metasploitable 2.
   - *Cách khắc phục:* Mở máy Metasploitable 2 gõ `ifconfig` kiểm tra và xác định lại IP chính xác là `192.168.56.103`.
2. **Lỗi biên dịch HTML (`xsltproc parser error : Start tag expected, '<' not found`):**
   - *Nguyên nhân:* Do dùng nhầm tham số `-oN` (Normal text) ghi đè lên file `ket_qua.xml` thay vì dùng tham số `-oX` (XML format).
   - *Cách khắc phục:* Chạy lại lệnh Nmap với đúng tham số `-oX ket_qua.xml`, sau đó chuyển đổi bằng `xsltproc ket_qua.xml -o bao_cao.html` thành công.
3. **Lỗi kết quả Before/After Hardening không đổi:**
   - *Nguyên nhân:* Lệnh dừng `openbsd-inetd` chưa giải phóng hẳn cổng Telnet đang lắng nghe.
   - *Cách khắc phục:* Sử dụng Firewall `iptables` trên Metasploitable 2 để chặn gói tin kết nối vào cổng 23: `sudo iptables -A INPUT -p tcp --dport 23 -j DROP`. Cổng `23/tcp` ngay lập tức chuyển sang trạng thái `filtered`.

---

## 6. DANH MỤC CÁC TỆP TRONG THƯ MỤC `LAB4/`

- `README.md`: File tổng quan hướng dẫn và tổng hợp kết quả thực hành.
- `[D20-AT01]-LAB3_1150080143-VoAnhKiet.docx`: File báo cáo thuyết minh đầy đủ kèm ảnh minh chứng.
- `evidence_sha256.csv`: File chứa mã hash SHA-256 bảo vệ tính nguyên vẹn của các file log và báo cáo.
- `ket_qua.txt`: Log quét chi tiết dịch vụ/OS dạng văn bản.
- `ket_qua.xml`: Log quét cấu trúc XML.
- `bao_cao.html`: Báo cáo kết quả quét dạng giao diện Web HTML.
- `smb.txt`: Tệp lọc thông tin rà soát cổng SMB 445 dạng Grepable.
- `before_hardening.txt`: Bằng chứng quét trước khi thực hiện phòng thủ (Port 23 Open).
- `after_hardening.txt`: Bằng chứng quét sau khi thực hiện phòng thủ (Port 23 Filtered).
