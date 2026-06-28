# Driver Monitoring System (DMS)

Dự án giám sát trạng thái tài xế (phát hiện buồn ngủ, ngáp, mất tập trung) thời gian thực. Hệ thống kết hợp thư viện MediaPipe Face Mesh để trích xuất đặc trưng khuôn mặt và mô hình LSTM (PyTorch) để dự báo sớm Microsleep (vi ngủ) dựa trên chuỗi thời gian 60 giây.

Dự án được phát triển, tối ưu và thử nghiệm chạy ổn định trên cả **Windows** và **Ubuntu** (bao gồm cả PC thông thường và dòng mạch đơn board như Raspberry Pi 4).

---

## Tính năng chính
* **Nhận diện thời gian thực**: Tính toán EAR (độ mở mắt), MAR (độ mở miệng) và Head Pose (góc cúi, ngửa, nghiêng đầu bằng SolvePnP).
* **Đo lường PERCLOS**: Đánh giá chỉ số nhắm mắt tích lũy trong 5 giây gần nhất để đưa ra cảnh báo chính xác.
* **Dự báo sớm bằng mạng LSTM**: Sử dụng chuỗi dữ liệu 60 giây trượt để dự đoán sớm nguy cơ buồn ngủ.
* **Cảnh báo khẩn cấp (Safety Overrides)**: Kích hoạt báo động đỏ ngay lập tức nếu nhắm mắt liên tục > 1.0 giây hoặc lệch đầu/gục đầu quá giới hạn > 1.0 giây.
* **Ghi log SQLite**: Lưu dữ liệu phân tích mỗi giây một lần vào `dms_history.db` phục vụ mục đích kiểm tra lại.

---

## Hướng dẫn cài đặt và chạy ứng dụng

### 1. Chạy trên máy tính thông thường (Windows / Ubuntu)

Dự án đã đính kèm sẵn file trọng số model trained (`lstm_drowsiness.pth`) nên bạn có thể chạy luôn ứng dụng mà không cần huấn luyện lại model.

#### Cách chạy trên Ubuntu:
Chỉ cần chạy file script tự động cài đặt môi trường ảo và chạy app:
```bash
./run_dms.sh
```

#### Cách chạy trên Windows:
Mở CMD hoặc PowerShell tại thư mục dự án:
```cmd
# Tạo và kích hoạt môi trường ảo
python -m venv venv
venv\Scripts\activate

# Cài đặt thư viện
pip install -r requirements.txt
pip install mediapipe==0.10.14

# Chạy chương trình
python drowsiness_detector.py
```
*(Nếu muốn huấn luyện lại model từ đầu, bạn chạy lệnh `python train_lstm.py`)*

#### Thiết lập tự động khởi động khi bật máy (Ubuntu):
File cấu hình khởi động đã được thiết lập sẵn tại đường dẫn `~/.config/autostart/ai_dms.desktop`. Sau khi bật máy tính lên và đăng nhập vào màn hình desktop Ubuntu, ứng dụng nhận diện sẽ tự động được chạy sau 3 giây.

---

### 2. Chạy trên Raspberry Pi 4 (Ubuntu / Raspberry Pi OS)

#### Sơ đồ đấu nối linh kiện ngoại vi:
* **Động cơ rung**: Nối chân điều khiển vào **GPIO 17** (BCM pin 17 / Vật lý pin 11).
* **Còi chíp (Buzzer)**: Nối chân điều khiển vào **GPIO 27** (BCM pin 27 / Vật lý pin 13).

#### Kích hoạt phần cứng trong code:
Mặc định hệ thống chạy ở chế độ PC thường (bỏ qua còi và rung). Để kích hoạt lại còi và rung khi cắm vào Pi:
1. Mở file `drowsiness_detector.py`.
2. Tìm dòng 16 và sửa thành: `GPIO_AVAILABLE = True`.

#### Khởi chạy trên Pi:
* Nếu dùng USB Webcam thông thường: Chạy `./run_dms.sh`.
* Nếu dùng Pi Camera Module 3: Cấu hình `dtoverlay=imx708` trong file `/boot/firmware/config.txt`, khởi động lại Pi và chạy lệnh:
  ```bash
  libcamerify python3 drowsiness_detector.py
  ```

---

## Các phím bấm khi test chương trình
* **Hiệu chuẩn (Calibration)**: Khi camera mở lên, hãy ngồi thẳng lưng và nhìn thẳng camera trong **3 giây đầu tiên (100 frames)** để hệ thống học tư thế chuẩn làm gốc (Baseline).
* **Hiệu chuẩn lại**: Nhấn phím **`r`** trên bàn phím nếu bạn thay đổi góc ngồi.
* **Thoát chương trình**: Click chuột vào cửa sổ camera và nhấn phím **`q`**.
