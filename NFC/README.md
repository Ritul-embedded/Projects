# RFID-Based Tree Lifecycle Management System

This project implements an **RFID-based tree tracking system** using **Arduino Nano and PN532 NFC module**. The system is designed to track the lifecycle of trees used for commercial purposes such as paper production and furniture manufacturing.

## Description
Each tree is attached with an **RFID tag** that stores important lifecycle information including the planting date, expected cutting date, and the next planting date. The system reads and writes this data using an RFID reader, enabling automated tracking and sustainable forest management.

## Features
- RFID-based identification of trees
- Storage of lifecycle information on RFID tags
- Reading and writing data using Arduino
- Automated tracking of planting and harvesting cycles

## Hardware Components
- Arduino Nano
- PN532 NFC / RFID Module
- RFID Tags
- Breadboard and jumper wires
- USB cable for programming and power

## Software
- Arduino IDE
- Adafruit PN532 Library

## System Workflow
1. **Planting Phase**  
   RFID tags are attached to trees and lifecycle data is stored.

2. **Tracking Phase**  
   RFID reader scans the tag to retrieve planting and harvesting information.

3. **Replanting Phase**  
   The system recommends planting a new tree after harvesting.

## Output
The system writes tree lifecycle information such as planting date, expected cutting date, and next planting date to RFID memory blocks and reads the stored data for monitoring.

## Skills Demonstrated

- Embedded Systems
- RFID and NFC Communication
- Arduino Programming
- Embedded C
- Hardware Interfacing
