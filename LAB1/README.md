\# BÁO CÁO THỰC HÀNH: LAB 1 - EXAMINING SSH \& TELNET IN WIRESHARK



\## Thông tin sinh viên

\- \*\*Họ và tên\*\*: Võ Anh Kiệt

\- \*\*Mã số sinh viên\*\*: 1150080143

\- \*\*Lớp\*\*: 11CNPM2

\- \*\*Link Video thực hành YouTube\*\*: \[Dán đường dẫn video YouTube quay lại quá trình làm]



\---



\## 1. Tên bài Lab

\- \*\*Lab 1\*\*: Bắt gói tin Telnet - SSH (Examining SSH \& Telnet in Wireshark)



\## 2. Nội dung đã thực hiện

\- Thiết lập mô hình mạng Client - Server - Attacker.

\- Cấu hình và kích hoạt dịch vụ Telnet trên máy chủ; thực hiện kết nối từ Client qua PuTTY.

\- Bắt và phân tích gói tin Telnet qua Wireshark trên máy Attacker/Client; giải mã thông tin đăng nhập và câu lệnh qua TCP Stream.

\- Cấu hình dịch vụ SSH trên máy chủ; xác thực host key fingerprint và đăng nhập bằng PuTTY.

\- Bắt và phân tích gói tin SSH qua Wireshark; kiểm chứng tính bảo mật và mã hóa payload.

\- Trả lời đầy đủ 11 câu hỏi lý thuyết \& thực nghiệm trong tài liệu Lab.



\## 3. Kết quả thực hiện

\- Thu thập đầy đủ các file lưu vết Wireshark (`.pcapng`) cho cả 2 phiên Telnet và SSH.

\- Chứng minh dữ liệu truyền qua Telnet ở dạng plaintext (đọc được mật khẩu và lệnh `dir`, `mkdir`).

\- Chứng minh dữ liệu truyền qua SSH đã được mã hóa toàn bộ payload, bảo vệ thông tin xác thực.

\- Hoàn thành file báo cáo chi tiết đính kèm trong thư mục.



\## 4. Các lưu ý để kiểm tra / chạy lại bài làm

\- \*\*Môi trường sử dụng\*\*: \[Ví dụ: VMware Workstation / Ubuntu Server / Windows Server / Windows 11].

\- \*\*Địa chỉ IP các máy\*\*:

&#x20; - Server: `10.0.0.1`

&#x20; - Client: `10.0.0.2`

&#x20; - Attacker: `10.0.0.3`

\- \*\*Bộ lọc Wireshark sử dụng\*\*:

&#x20; - Lọc Telnet: `tcp.port == 23`

&#x20; - Lọc SSH: `tcp.port == 22`

