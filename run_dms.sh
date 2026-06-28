#!/bin/bash
# Script to run the Driver Monitoring System (DMS)

# Navigate to the script's directory
cd "$(dirname "$0")"

# Check if venv exists
if [ ! -d "venv" ]; then
    echo "[INFO] Creating virtual environment..."
    python3 -m venv venv
    if [ $? -ne 0 ]; then
        echo "[ERROR] Failed to create virtual environment. Please check your Python installation."
        exit 1
    fi
fi

# Install/Update requirements
echo "[INFO] Installing / updating dependencies..."
venv/bin/pip install -r requirements.txt
if [ $? -ne 0 ]; then
    echo "[ERROR] Failed to install dependencies."
    exit 1
fi

# Tự động cài đặt RPi.GPIO nếu chạy trên Raspberry Pi
if grep -q "Raspberry Pi" /proc/device-tree/model 2>/dev/null; then
    echo "[INFO] Phat hien chay tren Raspberry Pi. Dang tu dong cai dat RPi.GPIO..."
    venv/bin/pip install RPi.GPIO
fi

# Run the program
echo "[INFO] Starting Driver Monitoring System..."
venv/bin/python3 drowsiness_detector.py
