LAB 1 — MÃ HÓA ĐỐI XỨNG CỔ ĐIỂN: JAVA SWING, MAVEN VÀ MICROSOFT SQL SERVER



1\. Thông tin bài thực hành

\- Họ và tên: Võ Anh Kiệt

\- Mã số sinh viên: 1150080143

\- Mã lớp: 11\_ĐH\_CNPM2

\- Môn học: An toàn và Bảo mật Thông tin

\- Bài thực hành: LAB 1 — Mã hóa đối xứng cổ điển: Xây dựng ứng dụng Java Swing nền tảng Maven tích hợp 6 thuật toán mật mã cổ điển (Caesar, Vigenère, Rail Fence, Playfair, Transposition, Autokey); phát triển form tổng hợp lưu trữ lịch sử thao tác vào Microsoft SQL Server; hiện thực các kỹ thuật thám mã cổ điển gồm vét cạn (Brute-Force), phân tích tần suất (Frequency Analysis) và tấn công biết trước bản rõ (Known Plaintext).

\- Link Video Demo: https://youtu.be/Bt78WBOBcOw



2\. Môi trường và công nghệ sử dụng

\- Ngôn ngữ lập trình: Java (JDK 17)

\- Công cụ phát triển (IDE): Apache NetBeans

\- Quản lý dự án: Apache Maven

\- Hệ quản trị cơ sở dữ liệu: Microsoft SQL Server (TCP Port 14333, Mixed Mode Authentication)

\- Công cụ quản trị CSDL: SQL Server Management Studio (SSMS)

\- Thư viện kết nối CSDL: mssql-jdbc (phiên bản 12.8.1.jre11)



3\. Cấu trúc thư mục dự án

11CNPM2\_1150080143\_VoAnhKiet\_LAB1/

├── 01\_SourceCode/

│   └── LAB1\_TuLam\_VoAnhKiet/

│       ├── pom.xml

│       └── src/main/java/week\_01/

│           ├── FileTextIO.java

│           ├── CaesarCipher.java

│           ├── VigenereCipher.java

│           ├── RailFenceCipher.java

│           ├── PlayfairCipher.java

│           ├── TranspositionCipher.java

│           ├── AutokeyCipher.java

│           ├── CipherTongHop.java

│           ├── DbConfig.java

│           ├── HistoryDao.java

│           ├── AttackDemos.java

│           ├── frm\_Menu.java (.form)

│           ├── frm\_Caesar.java (.form)

│           ├── frm\_Vigenere.java (.form)

│           ├── frm\_RailFence.java (.form)

│           ├── frm\_Playfair.java (.form)

│           ├── frm\_Transposition.java (.form)

│           ├── frm\_Autokey.java (.form)

│           ├── frm\_TongHop.java (.form)

│           ├── frm\_KetNoiSQL.java (.form)

│           ├── frm\_LichSu.java (.form)

│           └── frm\_TanCong.java (.form)

├── 02\_Database/

│   ├── 01\_Tao\_CSDL.sql

│   └── 03\_Kiem\_Tra\_Du\_Lieu.sql

├── 03\_Screenshots/

└── 04\_BaoCao/

&#x20;   └── 11CNPM2\_LAB10\_1150080143\_VoAnhKiet.docx



4\. Các chức năng đã hoàn thành

\- Mã hóa và giải mã 6 thuật toán cổ điển độc lập kèm tính năng đọc và ghi file văn bản UTF-8 (.txt):

&#x20; + Bài 1.1 Caesar Cipher (dịch chuyển ký tự theo khóa số nguyên k).

&#x20; + Bài 1.2 Vigenère Cipher (mã hóa đa bảng theo từ khóa lặp).

&#x20; + Bài 1.3 Rail Fence Cipher (xếp đường zigzag theo số hàng).

&#x20; + Bài 1.4 Playfair Cipher (ma trận khóa 5x5, thay thế theo cặp ký tự).

&#x20; + Bài 1.5 Transposition Cipher (hoán vị theo thứ tự đọc cột).

&#x20; + Bài 1.6 Autokey Cipher (dòng khóa tự sinh nối tiếp bằng bản rõ).

\- Bài nâng cao 01:

&#x20; + Form tổng hợp tích hợp chọn nhanh 6 thuật toán qua JComboBox.

&#x20; + Module kết nối an toàn tới SQL Server sử dụng kết nối mạng TCP cổng 14333.

&#x20; + Tự động lưu vết mọi thao tác Encrypt/Decrypt vào bảng dbo.history và hiển thị lịch sử trên JTable.

\- Bài nâng cao 02:

&#x20; + Tấn công vét cạn (Brute-Force) thử toàn bộ 26 không gian khóa Caesar và tính điểm tự động nhận diện bản rõ có nghĩa.

&#x20; + Phân tích thống kê tần suất ký tự trong bản mã (Frequency Analysis).

&#x20; + Thám mã Vigenère khi biết trước cặp bản rõ và bản mã (Known Plaintext Attack).

\- Menu chính (frm\_Menu) điều hướng toàn bộ ứng dụng độc lập.



5\. Hướng dẫn thiết lập và chạy chương trình

\- Bước 1: Mở SQL Server Management Studio (SSMS), mở và chạy file 01\_Tao\_CSDL.sql để khởi tạo CSDL LAB1\_MaHoaCoDien\_VoAnhKiet và bảng dbo.history.

\- Bước 2: Kích hoạt chế độ Mixed Mode và đảm bảo tài khoản kết nối lab1\_user hoạt động trên cổng TCP 14333.

\- Bước 3: Mở project bằng Apache NetBeans, chọn Clean and Build để Maven tải các dependency.

\- Bước 4: Chạy file frm\_Menu.java (Shift + F6) hoặc chạy toàn bộ project (F6).

\- Bước 5: Tại giao diện menu, mở form Kết nối SQL Server để xác thực kết nối, sau đó truy cập các tính năng mã hóa và thám mã tương ứng.

