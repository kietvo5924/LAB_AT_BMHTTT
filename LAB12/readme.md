# LAB 3 - MÃ HÓA KHÓA CÔNG KHAI

- **Họ và tên:** Võ Anh Kiệt
- **MSSV:** 1150080143
- **Lớp:** 11CNPM2
- **Học phần:** An toàn và Bảo mật Hệ thống Thông tin
- **LINK Youtube:** https://youtu.be/-VOuaOO2eYw

---

## 1. Giới thiệu bài thực hành
Chương trình xây dựng ứng dụng Java Swing (Maven) kết hợp Microsoft SQL Server nhằm minh họa các thuật toán mật mã khóa công khai, hệ mã lai, chữ ký số và lưu vết lịch sử thao tác:
- **3.1 RSA Console (`RSADemo`):** Sinh cặp khóa RSA (2048-bit và 3072-bit), mã hóa/giải mã với đệm OAEP (SHA-256) trên cửa sổ Console, đo thời gian tạo khóa và kiểm tra giới hạn kích thước bản rõ (190 byte / 318 byte).
- **3.2 RSA Swing (`frm_RSA`):** Giao diện đồ họa thực hiện tạo cặp khóa RSA-2048 / RSA-3072, mã hóa bằng khóa công khai, giải mã bằng khóa riêng và ghi nhận lịch sử thao tác.
- **3.3 ECC (`frm_ECC`):** Mã hóa theo sơ đồ ECIES trên đường cong `secp256r1` (kết hợp trao đổi khóa ECDH, dẫn xuất khóa HKDF-SHA256 và mã hóa xác thực AES-256-GCM), hỗ trợ lưu/nạp tệp khóa (`Save Keys` / `Load Keys`).
- **3.4 Hệ mã lai RSA + AES (`frm_RSA_AES`):** Sử dụng AES-256-GCM để mã hóa văn bản dài (> 1.000 ký tự) và RSA-OAEP (2048-bit) để bọc khóa phiên AES 32 byte, tích hợp chức năng kiểm tra tính toàn vẹn (`Sửa 1 ký tự bản mã`).
- **3.5 Nâng cao - Chữ ký số ECDSA (`frm_ECC_Signature`):** Ký số thông điệp bằng khóa riêng và xác minh tính hợp lệ (`VALID` / `INVALID`) bằng khóa công khai với thuật toán `SHA256withECDSA` trên đường cong `secp256r1`.
- **Quản lý kết nối & Lịch sử (`frm_KetNoiSQL`, `frm_LichSu`):** Kết nối JDBC tới SQL Server và lưu nhật ký các thao tác (`ENCRYPT`, `DECRYPT`, `SIGN`, `VERIFY`) vào bảng `dbo.History`.

---

## 2. Yêu cầu môi trường
- **JDK:** 17 trở lên
- **IDE:** Apache NetBeans 20+ (Maven)
- **CSDL:** Microsoft SQL Server Express & SSMS (bật TCP/IP cổng `14333` và Mixed Mode Authentication)
- **Thư viện:** `mssql-jdbc` phiên bản `12.8.1.jre11` (tự động tải qua `pom.xml`)

---

## 3. Hướng dẫn cấu hình và chạy chương trình

### Bước 1: Khởi tạo cơ sở dữ liệu SQL Server
1. Mở **SQL Server Management Studio (SSMS)** bằng quyền quản trị (Windows Authentication).
2. Mở và thực thi tệp `01_Tao_CSDL.sql` để tạo cơ sở dữ liệu `LAB3_MaHoaKhoaCongKhai` cùng bảng `dbo.History`.
3. Mở và thực thi tệp `02_Tao_TaiKhoan_LAB.sql` để tạo tài khoản SQL `lab3_user` (chỉ cấp quyền `SELECT`, `INSERT` trên `dbo.History`).
4. Sau khi thao tác trên ứng dụng, chạy tệp `03_KiemTra_LichSu.sql` để kiểm tra danh sách bản ghi và thống kê số lần thực hiện theo từng thuật toán.

### Bước 2: Chạy ứng dụng Java Swing (NetBeans)
1. Mở project Maven `LAB3_MaHoaKhoaCongKhai` tại thư mục `C:\BaoMat\LAB3_MaHoaKhoaCongKhai` trong Apache NetBeans.
2. Nhấp chuột phải vào project → chọn **Clean and Build** (`Shift + F11`) để Maven tải thư viện `mssql-jdbc`.
3. **Chạy Bài 3.1 (Console):** Nhấp chuột phải vào tệp `week_03/RSADemo.java` → chọn **Run File** (`Shift + F6`), nhập kích thước khóa (`2048` hoặc `3072`) và bản rõ trực tiếp trong cửa sổ Output.
4. **Chạy giao diện chính (Bài 3.2 – 3.5):** Nhấp chuột phải vào project → chọn **Run** (`F6`) để mở cửa sổ `week_03.frm_Menu`.
5. Bấm **Kết nối SQL Server**, nhập thông tin kết nối (`127.0.0.1`, port `14333`, database `LAB3_MaHoaKhoaCongKhai`, user `lab3_user` và mật khẩu đã cấu hình trên máy) → bấm **Test Connection**, sau đó trải nghiệm lần lượt các chức năng từ `3.2` đến `3.5` và kiểm tra kết quả tại **Xem lịch sử**.