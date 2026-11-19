\# LAB 2 - MÃ HÓA ĐỐI XỨNG HIỆN ĐẠI



\- \*\*Họ và tên:\*\* Võ Anh Kiệt

\- \*\*MSSV:\*\* 1150080143

\- \*\*Lớp:\*\* 11CNPM2

\- \*\*Học phần:\*\* An toàn và Bảo mật Hệ thống Thông tin

\- \*\*LINK Youtube:\*\* https://youtu.be/pDRud87fHVE



\---



\## 1. Giới thiệu bài thực hành

Chương trình xây dựng ứng dụng Java Swing (Maven) kết hợp Python (Tkinter) và Microsoft SQL Server nhằm minh họa các thuật toán mã hóa đối xứng hiện đại, quản lý đăng ký/đăng nhập người dùng và lưu vết lịch sử thao tác:

\- \*\*2.1 DES:\*\* Chế độ CBC, đệm PKCS5, khóa 8 byte, IV ngẫu nhiên 8 byte.

\- \*\*2.2 TripleDES (3DES):\*\* Chế độ CBC, đệm PKCS5, khóa 24 byte, IV ngẫu nhiên 8 byte.

\- \*\*2.3 AES-256-GCM + Login:\*\* Dẫn xuất khóa bằng PBKDF2-HMAC-SHA256 (120.000 vòng), xác thực người dùng qua SQL Server, cấp phiên làm việc (Ticket) và lưu lịch sử thao tác.

\- \*\*2.4 RC4:\*\* Mã dòng KSA + PRGA, hiển thị bản mã dạng HEX.

\- \*\*2.5 Twofish:\*\* Sử dụng thư viện BouncyCastle, chế độ CBC + PKCS7, khóa SHA-256, IV 16 byte HEX, hỗ trợ lưu và khôi phục IV từ tệp.

\- \*\*2.6 Nâng cao 01 - AES-256-CTR (Java):\*\* Biến AES thành mã dòng, không cần đệm, dùng Key 256-bit và Nonce 96-bit ngẫu nhiên.

\- \*\*2.6 Nâng cao 02 - AES-256-CBC (Python):\*\* Giao diện Tkinter sử dụng thư viện `cryptography`, hỗ trợ tự kiểm thử (`--self-test`).



\---



\## 2. Yêu cầu môi trường

\- \*\*JDK:\*\* 17 trở lên

\- \*\*IDE:\*\* Apache NetBeans 20+ (Maven)

\- \*\*CSDL:\*\* Microsoft SQL Server Express \& SSMS (bật TCP/IP cổng `14333` và Mixed Mode Authentication)

\- \*\*Python:\*\* Python 3.10+ và thư viện `cryptography`



\---



\## 3. Hướng dẫn cấu hình và chạy chương trình



\### Bước 1: Khởi tạo cơ sở dữ liệu SQL Server

1\. Mở \*\*SQL Server Management Studio (SSMS)\*\* bằng quyền quản trị.

2\. Mở và thực thi tệp `01\_Tao\_CSDL.sql` để tạo cơ sở dữ liệu `LAB2\_MaHoaHienDai` cùng hai bảng `dbo.app\_users` và `dbo.crypto\_history`.

3\. Mở và thực thi tệp `02\_Tao\_Tai\_Khoan\_SQL.sql` (cập nhật mật khẩu tài khoản SQL theo cấu hình máy cá nhân trước khi chạy).

4\. Sử dụng tệp `03\_Kiem\_Tra\_Du\_Lieu.sql` để kiểm tra dữ liệu người dùng và lịch sử thao tác sau khi chạy ứng dụng.



\### Bước 2: Chạy ứng dụng Java Swing (NetBeans)

1\. Mở project Maven `LAB2\_MaHoaHienDai` trong Apache NetBeans.

2\. Nhấp chuột phải vào project → chọn \*\*Clean and Build\*\* (`Shift + F11`) để Maven tải thư viện `mssql-jdbc` và `bcprov-jdk18on`.

3\. Nhấp chuột phải vào project → chọn \*\*Run\*\* (`F6`) để khởi chạy giao diện chính `week\_02.frm\_Menu`.

4\. Chọn \*\*Kết nối SQL Server\*\*, nhập thông tin kết nối (`127.0.0.1`, port `14333`, database `LAB2\_MaHoaHienDai`, user và password đã cấu hình) → bấm \*\*Test Connection\*\*, sau đó trải nghiệm các chức năng từ `2.1` đến `2.6`.



\### Bước 3: Chạy chương trình Python (Bài nâng cao 02)

Mở terminal/PowerShell tại thư mục chứa tệp `aes\_cbc\_gui.py` và thực hiện:

```bash

\# Cài đặt thư viện mã hóa (nếu chưa cài)

py -m pip install cryptography



\# Chạy bộ tự kiểm thử

py aes\_cbc\_gui.py --self-test



\# Chạy giao diện đồ họa

py aes\_cbc\_gui.py

