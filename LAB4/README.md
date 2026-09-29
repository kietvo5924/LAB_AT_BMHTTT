\# BÁO CÁO THỰC HÀNH LAB 4: KHẢO SÁT VÀ ĐÁNH GIÁ BỀ MẶT MẠNG BẰNG NMAP



\## 1. THÔNG TIN SINH VIÊN

\- \*\*Họ và tên:\*\* Võ Anh Kiệt

\- \*\*Mã số sinh viên (MSSV):\*\* 1150080143

\- \*\*Môn học:\*\* An toàn hệ thống thông tin

\- \*\*Tên bài Lab:\*\* LAB 4 - Khảo sát và đánh giá bề mặt mạng bằng Nmap

\- \*\*Repository GitHub:\*\* `LAB\_AT\_BMHTTT` (Chế độ Public)

\- \*\*Thư mục bài làm:\*\* `LAB4`



\---



\## 2. PHIÊN BẢN MÔI TRƯỜNG THỰC HÀNH

\- \*\*Máy thật (Host OS):\*\* Windows 11 / Windows 10 64-bit

\- \*\*Phần mềm ảo hóa:\*\* Oracle VM VirtualBox (v7.x)

\- \*\*Máy quét chính (VM 1):\*\* Kali Linux (Kernel 6.x) - IP Host-Only: `192.168.56.10`

\- \*\*Máy đích lỗ hổng (VM 2):\*\* Metasploitable 2 - IP Host-Only: `192.168.56.101`

\- \*\*Công cụ sử dụng:\*\* Nmap (v7.9x), Npcap, Zenmap, xsltproc



\---



\## 3. CÁCH DỰNG MÔI TRƯỜNG

1\. \*\*Thiết lập Mạng VirtualBox Host-Only:\*\*

&#x20;  - Tạo mạng Host-Only Network trong VirtualBox Manager với dải địa chỉ IPv4 `192.168.56.0/24`.

2\. \*\*Cấu hình VM 1 (Kali Linux - Máy quét):\*\*

&#x20;  - Đặt Adapter 1 thuộc chế độ `Host-Only Adapter`. (Chỉ bật NAT tạm thời để cài gói/cập nhật `nmap`, sau đó ngắt kết nối NAT).

3\. \*\*Cấu hình VM 2 (Metasploitable 2 - Máy đích):\*\*

&#x20;  - Đặt Adapter 1 thuộc chế độ `Host-Only Adapter` (Tuyệt đối không dùng Bridged để tránh rủi ro an ninh mạng bên ngoài).

4\. \*\*Kiểm tra kết nối:\*\*

&#x20;  - Sử dụng lệnh `ping -c 4 192.168.56.101` từ Kali Linux tới Metasploitable 2 để đảm bảo thông mạng trước khi thực hiện các bài quét.

5\. \*\*Snapshot:\*\*

&#x20;  - Tạo Snapshot tên `Before-LAB4` trên VirtualBox cho cả Kali Linux và Metasploitable 2 trước khi bắt đầu thực hành.



\---



\## 4. DANH SÁCH TÌNH HUỐNG THỰC HIỆN VÀ KẾT QUẢ



| STT | Tình huống / Nhiệm vụ | Cú pháp lệnh thực hiện | Kết quả (PASS/FAIL) | Ghi chú |

| :---: | :--- | :--- | :---: | :--- |

| 1 | Phát hiện Host đang hoạt động (Host Discovery) | `sudo nmap -sn 192.168.56.0/24` | \*\*PASS\*\* | Phát hiện các host đang bật trong dải Host-Only |

| 2 | Quét cổng TCP Connect Scan | `nmap -sT 192.168.56.101` | \*\*PASS\*\* | Xác định danh sách các cổng TCP open/closed |

| 3 | Quét SYN Scan (Stealth Scan) | `sudo nmap -sS 192.168.56.101` | \*\*PASS\*\* | Yêu cầu quyền root, tốc độ quét nhanh hơn `-sT` |

| 4 | Nhận diện phiên bản dịch vụ (Version Detection) | `sudo nmap -sV 192.168.56.101` | \*\*PASS\*\* | Liệt kê chi tiết phiên bản các dịch vụ đang chạy |

| 5 | Nhận diện hệ điều hành (OS Fingerprinting) | `sudo nmap -O 192.168.56.101` | \*\*PASS\*\* | Xác định chính xác OS của máy đích |

| 6 | Kiểm tra thông tin \& Lỗ hổng SMB (NSE Scripts) | `sudo nmap -p 445 --script smb-os-discovery,smb-vuln-ms17-010 192.168.56.101` | \*\*PASS\*\* | Phát hiện dấu hiệu lỗ hổng MS17-010 trên SMB |

| 7 | Xuất kết quả ra các tệp log \& chuyển đổi HTML | `sudo nmap -sV -O 192.168.56.101 -oA ket\_qua` <br> `xsltproc ket\_qua.xml -o bao\_cao.html` | \*\*PASS\*\* | Xuất đầy đủ các file `.txt`, `.xml`, `.gnmap`, `.html` |



\---



\## 5. LỖI GẶP PHẢI VÀ CÁCH KHẮC PHỤC



1\. \*\*Lỗi thiếu quyền thi hành Nmap (`Requested operation requires superuser privileges`):\*\*

&#x20;  - \*Nguyên nhân:\* Các kỹ thuật quét raw socket như SYN scan (`-sS`), OS detection (`-O`), Host discovery (`-sn`) đòi hỏi quyền cao nhất.

&#x20;  - \*Cách khắc phục:\* Thêm tiền tố `sudo` trước câu lệnh Nmap trên Terminal Kali Linux.

2\. \*\*Lỗi không kết nối được giữa máy quét và máy đích:\*\*

&#x20;  - \*Nguyên nhân:\* Nhầm lẫn card mạng (đang để NAT thay vì Host-Only).

&#x20;  - \*Cách khắc phục:\* Kiểm tra lại phần Network Settings trong VirtualBox, đưa cả 2 VM về cùng adapter `VirtualBox Host-Only Ethernet Adapter`\[cite: 1].

3\. \*\*Lỗi không tìm thấy công cụ `xsltproc` khi chuyển XML sang HTML:\*\*

&#x20;  - \*Nguyên nhân:\* Gói `xsltproc` chưa được cài sẵn trên Kali\[cite: 1].

&#x20;  - \*Cách khắc phục:\* Bật tạm card NAT, chạy `sudo apt update \&\& sudo apt install xsltproc -y`\[cite: 1], sau đó ngắt NAT và chạy lại lệnh biến đổi\[cite: 1].



\---



\## 6. DANH MỤC CÁC TỆP TRONG THƯ MỤC `LAB4/`

\- `README.md`: File tổng quan hướng dẫn và kết quả thực hành\[cite: 1].

\- `\[MãLớp]-LAB3\_1150080143-VoAnhKiet.docx`: File báo cáo chính dạng Word\[cite: 1].

\- `evidence\_sha256.csv`: Bảng chứa mã hash SHA-256 kiểm tra tính nguyên vẹn của toàn bộ ảnh minh chứng và file output/log\[cite: 1].

\- `ket\_qua.txt`: Log xuất dạng văn bản thường\[cite: 1].

\- `ket\_qua.xml`: Log xuất dạng cấu trúc XML\[cite: 1].

\- `bao\_cao.html`: File báo cáo giao diện web được chuyển đổi từ file XML\[cite: 1].

\- `smb.txt`: File lọc kết quả cổng 445 từ Grepable output\[cite: 1].

