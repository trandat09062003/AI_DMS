# Driver Monitoring System (DMS) - Hệ Thống Cảnh Báo Buồn Ngủ & Giám Sát Tài Xế Thời Gian Thực

Hệ thống giám sát người lái xe (Driver Monitoring System - DMS) được phát triển nhằm phát hiện sớm các dấu hiệu mệt mỏi, buồn ngủ và mất tập trung của tài xế khi tham gia giao thông. Hệ thống kết hợp các thuật toán thị giác máy tính cổ điển (Heuristic) cùng mô hình mạng nơ-ron học máy tuần hoàn (LSTM PyTorch) để phân tích chuỗi thời gian, đưa ra cảnh báo đa tầng không trễ.

---

## 📌 Tổng Quan Giải Pháp

Hệ thống hoạt động dựa trên việc khai thác dữ liệu từ Camera cabin để phân tích các đặc trưng khuôn mặt của tài xế theo thời gian thực:
* **Độ mở mắt (EAR - Eye Aspect Ratio)**: Xác định trạng thái chớp mắt, nhắm mắt.
* **Độ mở miệng (MAR - Mouth Aspect Ratio)**: Phát hiện hành vi ngáp.
* **Tư thế đầu (Head Pose via SolvePnP)**: Tính toán góc cúi/ngửa (`Pitch`), quay trái/phải (`Yaw`), nghiêng đầu (`Roll`) dựa trên việc giải bài toán phối cảnh 3 điểm (Perspective-n-Point) từ các tọa độ Landmark khuôn mặt.
* **Chỉ số PERCLOS (Percentage of Eye Closure)**: Tính tỷ lệ thời gian mắt nhắm trong một khoảng thời gian trượt (5 giây) để đánh giá trạng thái vi ngủ (Microsleep).
* **Mô hình LSTM (Long Short-Term Memory)**: Dự báo nguy cơ buồn ngủ sớm dựa trên chuỗi biến động các chỉ số trong vòng 60 giây gần nhất.

---

## ✨ Các Tính Năng Chính

* **Nhận diện thời gian thực**: Xử lý mượt mà lên tới 30 FPS trên các thiết bị CPU phổ thông nhờ luồng xử lý luân phiên và tối ưu hóa MediaPipe Face Mesh.
* **Hiệu chuẩn động tự động & thủ công (Calibration)**: 
  * Tự động tính toán các chỉ số cơ bản (baseline) của từng người lái trong 3 giây đầu tiên khởi động.
  * Hỗ trợ phím tắt **`r`** để tài xế hiệu chuẩn lại bất cứ lúc nào khi đã ngồi đúng tư thế chuẩn.
* **Cảnh báo khẩn cấp tức thì (Safety Overrides)**: Bỏ qua điểm tích lũy để còi hú báo động ngay lập tức nếu phát hiện nhắm mắt liên tục > 1.0 giây hoặc gục đầu/lệch đầu nguy hiểm > 1.0 giây.
* **Cảnh báo âm thanh đa tầng**: Sử dụng giải pháp đa luồng (Multi-threading) điều khiển còi bíp (`winsound`) riêng biệt, đảm bảo cảnh báo kêu to mà không gây đứng hình hay giật lag khung hình camera.
* **Ghi nhật ký lịch sử SQLite**: Tự động ghi nhận thông số (EAR, MAR, Pitch, Yaw, Roll, Risk Score) mỗi giây một lần vào database `dms_history.db` phục vụ mục đích hậu kiểm và phân tích.
* **Chế độ giả lập (Simulation Mode)**: Tự động chuyển sang luồng dữ liệu giả lập sinh động khi không kết nối webcam, hỗ trợ demo nhanh sản phẩm.

---

## 📂 Cấu Trúc Dự Án

```text
├── drowsiness_detector.py # Script chạy chính thời gian thực (Webcam + Dashboard UI)
├── lstm_model.py          # Kiến trúc mạng LSTM dự báo Microsleep (PyTorch)
├── train_lstm.py          # Script huấn luyện mô hình LSTM & Tạo tập dữ liệu giả lập
├── requirements.txt       # Danh sách thư viện phụ thuộc của dự án
├── SUMMARY.txt            # Tài liệu tổng kết chi tiết kết quả thực hiện
└── dms_history.db         # Database SQLite lưu log chạy hệ thống (Tự động sinh ra)
```

---

## 🛠️ Hướng Dẫn Cài Đặt & Khởi Chạy

### 1. Chuẩn bị môi trường
Yêu cầu hệ thống đã cài đặt **Python 3.10** hoặc các phiên bản tương thích. Mở cửa sổ dòng lệnh tại thư mục gốc của dự án và chạy:

```bash
pip install -r requirements.txt
```

### 2. Huấn luyện mô hình dự báo LSTM
Để huấn luyện mô hình học máy nhận diện chuỗi thời gian Microsleep:

```bash
python train_lstm.py
```
*Sau khi chạy, file trọng số `lstm_drowsiness.pth` sẽ được tạo ra trong thư mục dự án.*

### 3. Chạy hệ thống giám sát
Khởi động hệ thống nhận diện từ camera:

```bash
python drowsiness_detector.py
```

---

## 🎮 Hướng Dẫn Sử Dụng & Test Case

1. **Hiệu chuẩn Baseline**: Khi camera mở lên, hãy ngồi thẳng lưng và nhìn thẳng vào camera trong khoảng **3 giây đầu (100 frames)** để hệ thống học tư thế và kích thước mắt/miệng của bạn.
2. **Hiệu chuẩn lại (Khi cần)**: Nếu hệ thống báo nhạy quá mức hoặc vị trí ngồi của bạn thay đổi, hãy ngồi thẳng lưng nhìn camera và nhấn phím **`r`** trên bàn phím.
3. **Các tình huống kiểm thử (Test Cases)**:
   * **Nhắm mắt lâu**: Thử nhắm mắt trong hơn 1 giây, hệ thống sẽ kích hoạt báo động đỏ khẩn cấp: **`NGUY HIEM - NHAM MAT!`**.
   * **Gục đầu / Ngửa đầu quá mức**: Cúi đầu sâu hoặc ngửa hẳn cổ ra sau trong hơn 1 giây, hệ thống sẽ báo: **`NGUY HIEM - LECH DAU!`**.
   * **Ngáp liên tục**: Thực hiện ngáp to, thanh MAR sẽ tăng kịch khung và tăng điểm cảnh báo mệt mỏi trên Dashboard.
4. **Thoát chương trình**: Click chọn cửa sổ camera và nhấn phím **`q`** để dừng ứng dụng.
