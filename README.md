Driver for LCD1602A for GD32VF103CBTx MCU (Used in HE1028 Embedded Systems course)
The driver is written in Assembly. 

## Dependencies: Timer 5. Blocks when writing data (for about 230 ns)
## LCD-koppling (8-bitars HD44780-liknande LCD)

| LCD Pin | Funktion       | GPIO Port | Pin        | Beskrivning                      |
|---------|----------------|-----------|------------|----------------------------------|
| D0      | Data bit 0     | GPIOA     | A0         | Lägsta databiten                 |
| D1      | Data bit 1     | GPIOA     | A1         |                                  |
| D2      | Data bit 2     | GPIOA     | A2         |                                  |
| D3      | Data bit 3     | GPIOA     | A3         |                                  |
| D4      | Data bit 4     | GPIOA     | A4         |                                  |
| D5      | Data bit 5     | GPIOA     | A5         |                                  |
| D6      | Data bit 6     | GPIOA     | A6         |                                  |
| D7      | Data bit 7     | GPIOA     | A7         | Högsta databiten                 |
| RS      | Register Select| GPIOB     | B0         | 0 = kommando, 1 = data           |
| R/W     | Read/Write     | GPIOB     | B1         | 0 = skriv, 1 = läs               |
| E       | Enable         | GPIOB     | B2         | Latchar data vid hög->låg flank  |
| VSS     | GND            | -         | -          | Jord                             |
| VDD     | 5V / 3.3V      | -         | -          | Matningsspänning                 |
| VO      | Kontrast       | -         | Potentiometer (10Kohm) -> Justera kontrast    |
| A       | Anode. Add resistor        |                                               |
| K       | Cathode. Add to GND                                                        |
