# BÁO CÁO THỰC HÀNH: LAB 1 - EXAMINING SSH & TELNET IN WIRESHARK

## Thông tin sinh viên
- **Họ và tên**: Võ Anh Kiệt
- **Mã số sinh viên**: 1150080143
- **Lớp**: 11CNPM2
- **Link Video thực hành YouTube**: [Dán đường dẫn video YouTube của bạn vào đây]

---

## 1. Tên bài Lab
- **Lab 1**: Bắt gói tin Telnet - SSH (Examining SSH & Telnet in Wireshark)
- **Học phần**: An toàn hệ thống thông tin / Bảo mật hệ thống thông tin

---

## 2. Mô hình và Môi trường triển khai
- **Nền tảng ảo hóa**: Oracle VM VirtualBox.
- **Cấu hình card mạng**: `Host-only Adapter` (`VirtualBox Host-Only Ethernet Adapter`) – Mạng cô lập nội bộ an toàn, không định tuyến ra Internet.
- **Phân bổ vai trò & Địa chỉ IP**:
  - **Server (10.0.0.1/24)**: Máy ảo Ubuntu Server (chạy đồng thời dịch vụ `inetutils-telnetd` cổng 23 và `openssh-server` cổng 22).
  - **Client & Attacker (10.0.0.2/24)**: Máy vật lý Windows (vừa đóng vai trò máy trạm khách dùng PuTTY để kết nối, vừa đóng vai trò Attacker/Giám sát sử dụng Wireshark để bắt và phân tích gói tin).

---

## 3. Nội dung đã thực hiện
1. **Thiết lập môi trường**:
   - Cấu hình IP tĩnh `10.0.0.1/24` cho Ubuntu Server bằng Netplan và `10.0.0.2/24` cho Windows Client.
   - Kiểm tra kết nối hai chiều thành công bằng lệnh `ping` (tỷ lệ mất gói 0%).
   - Khởi tạo tài khoản người dùng kiểm thử (`kietvo5924` / `uitlab`) với mật khẩu sinh viên.
2. **Thực nghiệm giao thức Telnet (Cổng 23)**:
   - Kích hoạt dịch vụ Telnet daemon (`inetutils-telnetd`) ở trạng thái `LISTEN` trên cổng 23.
   - Kết nối từ máy Client qua PuTTY (Telnet mode) và thực thi các câu lệnh (`ls`, `mkdir telnet_test`).
   - Sử dụng Wireshark bắt gói tin và dùng tính năng `Follow TCP Stream` để khôi phục toàn bộ username, password và lệnh dạng Plaintext.
   - **Thử nghiệm mật khẩu phức tạp**: Đổi mật khẩu thành chuỗi ký tự dài, phức tạp (>10 ký tự: `P@ssw0rd#2026!Secured`), chứng minh giao thức Telnet vẫn để lộ nguyên văn dữ liệu qua mạng.
3. **Thực nghiệm giao thức SSH (Cổng 22)**:
   - Kích hoạt dịch vụ OpenSSH Server trên cổng 22.
   - Kết nối từ Client qua PuTTY SSH, ghi nhận và phân tích hộp thoại cảnh báo `PuTTY Security Alert` xác thực Host-Key Fingerprint.
   - Bắt gói tin SSH bằng Wireshark, chứng minh toàn bộ dữ liệu tải trọng (Payload) đều được mã hóa thành Ciphertext (Encrypted Packet).
4. **Mở rộng - Xác thực SSH bằng Public-Key Authentication**:
   - Sử dụng `PuTTYgen` tạo cặp khóa bất đối xứng RSA 2048-bit.
   - Đưa Public Key lên server (`~/.ssh/authorized_keys`) và phân quyền bảo mật (`chmod 600`).
   - Đăng nhập SSH thành công từ PuTTY bằng Private Key (`.ppk`) mà không cần nhập mật khẩu truyền thống.
5. **Báo cáo lý thuyết & Phân tích**:
   - Hoàn thành đầy đủ 11 câu hỏi đánh giá theo yêu cầu tài liệu Lab.

---

## 4. Cấu trúc thư mục nộp bài
```text
LAB_AT_BMHTTT/
│
└── LAB1/
    ├── README.md                                # File tóm tắt này
    ├── Lab1_11CNPM2_1150080143_VoAnhKiet.docx   # File báo cáo Word chi tiết
    ├── captures/                                # Thư mục chứa bằng chứng thực nghiệm
    │   ├── telnet_capture.pcapng                 # File lưu vết Wireshark Telnet
    │   └── ssh_capture.pcapng                    # File lưu vết Wireshark SSH