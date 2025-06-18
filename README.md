# LCD1602A Parallel Driver for GD32VF103CBTx (RISC-V)

This is a low-level driver written in RISC-V assembly for interfacing an **HD44780-compatible LCD1602A** display via **8-bit parallel mode** on the **GD32VF103** MCU.

![image](https://github.com/user-attachments/assets/a05768a3-a40b-469b-9073-a33f3f222423)


## ⚙️ Features

- 8-bit parallel interface
- Written entirely in RISC-V assembly (for author learning purpose)
- Uses **Timer 5** for accurate delays (~230 ns blocking time)
- Includes custom symbols:
  - Battery icons
  - Temperature icon

## 🔧 Pin Configuration (LCD ↔️ GD32VF103CBTx)

| LCD Pin | Function        | GPIO Port | Pin | Description                           |
|---------|------------------|-----------|-----|---------------------------------------|
| D0      | Data bit 0       | GPIOA     | A0  | Least significant data bit            |
| D1      | Data bit 1       | GPIOA     | A1  |                                       |
| D2      | Data bit 2       | GPIOA     | A2  |                                       |
| D3      | Data bit 3       | GPIOA     | A3  |                                       |
| D4      | Data bit 4       | GPIOA     | A4  |                                       |
| D5      | Data bit 5       | GPIOA     | A5  |                                       |
| D6      | Data bit 6       | GPIOA     | A6  |                                       |
| D7      | Data bit 7       | GPIOA     | A7  | Most significant data bit             |
| RS      | Register Select  | GPIOB     | B0  | 0 = Command, 1 = Data                 |
| R/W     | Read/Write       | GPIOB     | B1  | 0 = Write, 1 = Read                   |
| E       | Enable           | GPIOB     | B2  | Latches data on high-to-low edge     |
| VSS     | GND              | -         | -   | Ground                                |
| VDD     | 5V / 3.3V        | -         | -   | Power supply                          |
| VO      | Contrast         | -         | -   | 10kΩ potentiometer → Adjust contrast |
| A       | Anode (LED +)    | -         | -   | Add resistor                          |
| K       | Cathode (LED -)  | -         | -   | Connect to GND                        |


## 🧱 Dependencies

- General purpose timer 5
- Assumes blocking delay (~230 ns) when writing to the display.


## 🚀 Getting Started

1. Connect the LCD1602A as shown in the pin table.
2. Include the assembly driver in your project.
3. Call the initialization routine.
4. Use provided routines to write data/commands or custom symbols.
