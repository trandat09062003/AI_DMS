# Hệ thống Cảnh báo Ngủ gật Thông minh AI (DMS)

Dự án này triển khai hệ thống giám sát người lái xe (Driver Monitoring System - DMS) thời gian thực sử dụng thị giác máy tính và học máy (PyTorch LSTM). Hệ thống phân tích đa đặc trưng bao gồm tỷ lệ mở mắt (EAR), tỷ lệ mở miệng (MAR), tư thế góc quay đầu (Head Pose), tỷ lệ nhắm mắt tích lũy (PERCLOS), tần suất chớp mắt (Blink Rate) và ngáp (Yawning) để tính toán điểm mệt mỏi Fatigue Score (FS) và dự báo nguy cơ vi ngủ (Microsleep).

---

## Tính năng nổi bật
1. **Phân tích Đa đặc trưng**: Kết hợp đồng thời EAR, MAR, Head Pose (Pitch, Yaw, Roll), PERCLOS, Blink Rate và đếm số lần ngáp để tránh báo động giả so với chỉ dùng EAR đơn lẻ.
2. **Cá nhân hóa Ngưỡng (Calibration)**: Tự động học thói quen mở mắt/miệng của từng tài xế trong 5 giây đầu tiên khi bắt đầu chạy hệ thống để tính toán các ngưỡng cảnh báo riêng biệt.
3. **Mô hình Dự báo LSTM**: Sử dụng mạng nơ-ron LSTM (PyTorch) phân tích chuỗi thời gian 60 giây để dự báo sớm nguy cơ xảy ra Microsleep.
4. **Cảnh báo Đa tầng Không trễ**: Sử dụng luồng chạy ngầm riêng (threading) phát âm thanh bíp (`winsound.Beep`) để cảnh báo tài xế ở các mức độ mệt mỏi khác nhau mà không làm giật/lag hình ảnh camera.
5. **Chế độ Giả lập (Simulation Mode)**: Tự động chuyển sang chế độ giả lập nếu máy tính không kết nối webcam, giúp chạy thử nghiệm thuật toán và kiểm tra giao diện trực quan ngay lập tức.

---

## Cấu trúc thư mục
- `requirements.txt`: Chứa danh sách các thư viện cần cài đặt.
- `lstm_model.py`: Khai báo cấu trúc mạng LSTM dự báo Microsleep sử dụng PyTorch.
- `train_lstm.py`: Huấn luyện mô hình LSTM với dữ liệu giả lập hành vi buồn ngủ và lưu trọng số vào `lstm_drowsiness.pth`.
- `drowsiness_detector.py`: Kịch bản chạy chính thời gian thực kết nối với camera và chạy dashboard thống kê chỉ số.

---

## Hướng dẫn cài đặt & Chạy thử nghiệm

### Bước 1: Cài đặt thư viện
Mở terminal (PowerShell hoặc Command Prompt) tại thư mục dự án và chạy lệnh sau để cài đặt các thư viện phụ thuộc:
```bash
pip install -r requirements.txt
```

### Bước 2: Huấn luyện mô hình LSTM
Chạy file huấn luyện để tạo trọng số mô hình dự báo Microsleep:
```bash
python train_lstm.py
```
*Lưu ý: Chương trình sẽ sinh dữ liệu giả lập cho trạng thái tỉnh táo & buồn ngủ, chạy huấn luyện 20 epochs và lưu file trọng số `lstm_drowsiness.pth` ngay trong thư mục.*

### Bước 3: Chạy ứng dụng nhận diện
Bật camera lên và chạy file phát hiện ngủ gật chính:
```bash
python drowsiness_detector.py
```

* Hướng dẫn khi chạy:
  1. Trong **5 giây đầu tiên (100 frames)**: Hệ thống sẽ tiến hành **Hiệu chuẩn (Calibrating)**. Bạn hãy nhìn thẳng vào camera, mở mắt bình thường và không ngáp hay cúi đầu để hệ thống học trạng thái tỉnh táo chuẩn của bạn.
  2. Sau khi hiệu chuẩn hoàn tất, hệ thống bắt đầu giám sát thời gian thực.
  3. Để kiểm tra còi báo động:
     * Nhắm mắt lại trong 3-4 giây (EAR giảm, PERCLOS tăng), còi cảnh báo sẽ bíp liên tục và viền màn hình nhấp nháy đỏ.
     * Cúi đầu thấp xuống hoặc ngáp to để xem Fatigue Score và cảnh báo thay đổi màu sắc trên Dashboard.
  4. Nhấn phím **'q'** trên cửa sổ video để tắt và thoát chương trình một cách an toàn.
