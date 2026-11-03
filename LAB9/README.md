# LAB 9 — REMOTE DNS ATTACK: REMOTE DNS CACHE POISONING TRONG MẠNG ẢO CÔ LẬP

## 1. Thông tin bài thực hành

- **Họ và tên:** Võ Anh Kiệt
- **Mã số sinh viên:** 1150080143
- **Mã lớp:** 11_ĐH_CNPM2
- **Môn học:** An toàn và Bảo mật Hệ thống Thông tin
- **Bài thực hành:** LAB 9 — Remote DNS Attack: Phân đoạn mạng ATTACKNET, thực thi tấn công Remote DNS Cache Poisoning (Kaminsky-style) nhắm vào Recursive Resolver trong môi trường ảo cô lập; đánh giá cơ chế phòng thủ Source Port Randomization và DNSSEC.
- **Link Video Demo:** https://youtu.be/XyNU5y_eL8s

---

## 2. Môi trường thực hành

### pfSense Firewall

- **Phiên bản:** pfSense Community Edition 2.7.2-RELEASE
- **WAN (em0 / Card 1):** Bridged / NAT (DHCP/Tĩnh)
- **MGMT (em1 / Card 2):** Host-Only Adapter
  - IP: `192.168.56.254/24`
  - Host: `192.168.56.1`
  - Mục đích: Quản trị WebGUI độc lập, chống khóa quản trị (Anti-lockout).
- **LAN (em2 / Card 3):** Internal Network `lab-lan` (`10.6.0.1/24`)
- **DMZ (em3 / Card 4):** Internal Network `lab-dmz` (`172.16.6.1/24`)
- **DNSLAB (em4 / Card 5):** Internal Network `dns-lab` (`10.9.0.1/24`)
- **ATTACKNET (em5 / Card 6):** Internal Network `attack-net` (`10.10.0.1/24`)

### DNS Server (DNS-SERVER)

- **Hệ điều hành:** Ubuntu Server 24.04 LTS
- **Network:** Internal Network `dns-lab`
- **IP:** `10.9.0.10/24`
- **Gateway:** `10.9.0.1`
- **Dịch vụ:** BIND9 (`named`) đóng vai trò Caching Resolver, forward zone `example.lab10.test` sang `172.16.6.20`.
- Sử dụng thêm `vuln_resolver_lab10.py` để mô phỏng resolver có cấu hình yếu, phục vụ việc tái hiện điều kiện tấn công Kaminsky trong môi trường kiểm thử.

### Máy nạn nhân (VICTIM)

- **Hệ điều hành:** Ubuntu Desktop / Server 24.04 LTS
- **Network:** Internal Network `dns-lab`
- **IP:** `10.9.0.100/24`
- **Gateway:** `10.9.0.1`
- **DNS Server:** `10.9.0.10`

### Máy tấn công (ATTACKER - Kali Linux)

- **Hệ điều hành:** Kali Linux
- **Network:** Internal Network `attack-net`
- **IP:** `10.10.0.200/24`
- **Gateway:** `10.10.0.1`
- **Promiscuous Mode:** Deny
- **Công cụ:** Kaminsky attack script, Evil DNS Server và Fake Web Server.

### AUTH-DNS / APP-TEST

- **IP:** `172.16.6.20/24`
- **Gateway:** `172.16.6.1`
- Đóng vai trò Authoritative DNS và Race Relay phục vụ mô phỏng quá trình Remote DNS Cache Poisoning.

### DMZ Web Server (DMZ-WEB)

- **IP:** `172.16.6.10/24`
- **Gateway:** `172.16.6.1`
- Phục vụ website hợp lệ để đối chiếu trước và sau khi DNS Cache Poisoning.

---

## 3. Mô hình mạng (Topology)

Mô hình sử dụng pfSense để phân đoạn các mạng LAN, DMZ, DNSLAB và ATTACKNET. Máy Kali được đặt trong ATTACKNET, tách biệt với DNSLAB để mô phỏng tình huống attacker thực hiện tấn công từ xa mà không thể sniff trực tiếp lưu lượng DNS của Resolver.

| Thành phần | Địa chỉ IP | Vai trò |
|---|---|---|
| pfSense DNSLAB | `10.9.0.1/24` | Gateway DNSLAB |
| DNS-SERVER | `10.9.0.10` | BIND9 / Recursive Resolver |
| VICTIM | `10.9.0.100` | DNS Client |
| pfSense ATTACKNET | `10.10.0.1/24` | Gateway mạng attacker |
| ATTACKER Kali | `10.10.0.200` | Remote Attacker |
| AUTH-DNS / APP-TEST | `172.16.6.20` | Authoritative DNS / Race Relay |
| DMZ-WEB | `172.16.6.10` | Website hợp lệ |
| HOST MGMT | `192.168.56.1` | Quản trị pfSense |

---

## 4. Mục tiêu thực hành

1. Hiểu sự khác nhau giữa Local DNS Spoofing và Remote DNS Cache Poisoning (Kaminsky-style).
2. Phân đoạn ATTACKER khỏi DNSLAB bằng pfSense để attacker không thể sniff trực tiếp query hoặc transaction ID của Resolver.
3. Quan sát vai trò của Transaction ID, UDP Source Port, DNS Cache và bản ghi NS trong quá trình poisoning.
4. Thực hiện mô phỏng Cache Poisoning trong mạng ảo cô lập bằng domain thử nghiệm và địa chỉ IP private.
5. Kiểm chứng hậu quả bằng DNS Query và website mô phỏng.
6. Phục hồi cấu hình BIND9 và đánh giá các biện pháp hardening như Source Port Randomization và DNSSEC.

---

## 5. Quy trình thực hiện

### Bước 1: Chuẩn bị môi trường

- Tạo snapshot cho các máy ảo trước khi thực hiện.
- Cấu hình thêm interface ATTACKNET trên pfSense.
- Chuyển Kali sang mạng `attack-net`.
- Đặt IP tĩnh cho các máy theo mô hình mạng.
- Kiểm tra các firewall rule cần thiết.

### Bước 2: Chuẩn bị DNS Server

- Sao lưu cấu hình BIND9.
- Thiết lập baseline resolver.
- Cấu hình forward zone cho domain thử nghiệm.
- Kiểm tra DNS resolution từ máy VICTIM trước khi tấn công.

### Bước 3: Mô phỏng Remote DNS Cache Poisoning

- Khởi chạy Authoritative DNS và Race Relay.
- Khởi chạy resolver mô phỏng có chủ đích.
- Từ máy Kali, kích hoạt truy vấn subdomain ngẫu nhiên và mô phỏng quá trình dự đoán Transaction ID.
- Quan sát các log PENDING, HIT và CACHE để xác định trạng thái mô phỏng.

### Bước 4: Kiểm chứng kết quả

- Truy vấn DNS từ máy VICTIM.
- So sánh kết quả phân giải tên miền trước và sau khi poisoning.
- Kiểm tra website được truy cập.
- Phân tích các gói tin DNS bằng Wireshark.

### Bước 5: Khôi phục và Hardening

- Dừng các dịch vụ mô phỏng tấn công.
- Khôi phục cấu hình BIND9 ban đầu.
- Kiểm tra Source Port Randomization và DNSSEC.
- Xóa hoặc vô hiệu hóa các firewall rule chỉ phục vụ quá trình mô phỏng.
- Xác nhận hệ thống trở lại trạng thái bình thường.

---

## 6. Kết quả thực nghiệm

Kết quả được đánh giá thông qua việc so sánh DNS resolution trước và sau quá trình mô phỏng:

| Nội dung | Trước mô phỏng | Sau poisoning |
|---|---|---|
| `www.example.lab10.test` | `172.16.6.10` | `10.10.0.200` |
| DNS upstream của Resolver | `172.16.6.20` | `10.10.0.200` |
| Website hiển thị | DMZ-WEB hợp lệ | LAB Fake Site |
| Kali sniff DNSLAB | Không | Không |

Kết quả mô phỏng cho thấy việc kiểm soát Transaction ID, UDP Source Port và DNS Cache có vai trò quan trọng đối với khả năng chống Remote DNS Cache Poisoning.

---

## 7. Phạm vi an toàn

Toàn bộ bài thực hành được triển khai trong môi trường máy ảo cô lập bằng VirtualBox và pfSense.

- Chỉ sử dụng các subnet nội bộ được cấu hình cho bài LAB.
- Sử dụng domain thử nghiệm, không sử dụng website thật.
- Không thực hiện tấn công trên Wi-Fi, mạng trường học, mạng doanh nghiệp hoặc Internet.
- Không sử dụng các script mô phỏng trên hệ thống không thuộc quyền quản trị.

---

## 8. Kết luận

Qua bài thực hành LAB 9, sinh viên tìm hiểu được cơ chế Remote DNS Cache Poisoning theo hướng Kaminsky-style, vai trò của Transaction ID, UDP Source Port và DNS Cache trong quá trình phân giải tên miền.

Bài thực hành cũng giúp hiểu rõ hơn về tầm quan trọng của việc phân đoạn mạng, Source Port Randomization, DNSSEC và các biện pháp hardening nhằm hạn chế nguy cơ DNS Cache Poisoning.