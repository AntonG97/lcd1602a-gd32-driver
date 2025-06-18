
#ifndef LCD1602A_DRIVER_H
#define LCD1602A_DRIVER_H

#include "gd32vf103.h"

/**
 * Driver for LCD1602A for RISC-V processor Archirecture
 * Dependencies: Timer 5
 * 
 * User defined characters at CGRAM position 0 - 7. Accessed
 * by writing character bit pattern 0-7
 * 
 * E   = GPIOB2
 * R/W = GPIOB1
 * RS  = GPIOB0
 * 
 * Datapins [D7 - D0] = GPIO[a7 - a0]
 */


/**
 * ENUM for user defined characters
 */
typedef enum{
    battery_empty   = 0,
    battery_25      = 1,
    battery_50      = 2,
    battery_75      = 3,
    battery_100     = 4,
    temp            = 5,
    extra_one       = 6,
    extra_two       = 7  
}lcd_Pattern;

typedef enum{
    upper_row       = 0,
    lower_row       = 1,
}Cursor_row;

typedef enum {
    ONE             = 0,
    TWO             = 1,
    THREE           = 2,
    FOUR            = 3,
    FIVE            = 4,
    SIX             = 5,
    SEVEN           = 6,
    EIGHT           = 7,
    NINE            = 8,
    TEN             = 9,
    ELEVEN          = 10,
    TWELVE          = 11,
    THIRTEEN        = 12,
    FOURTEEN        = 13,
    FIFTEEN         = 14,
    SIXTEEN         = 15
} Cursor_col;

//Initialize LCD
void lcd_init(void);
//Clear screen
void lcd_clear(void);
//Return cursor to start position
void lcd_home(void);
//Set cursor at specified position
void lcd_set_cursor(const Cursor_row, const Cursor_col col);
//Writes a character to the next postion at current line
void lcd_writeCh(const char ch);
//Writes a string to LCD. Has to be NULL terminated!
void lcd_writeStr(char* str);
//Turn on LCD display
void lcd_display_on(void);
//Turn off LCD display
void lcd_display_off(void);

#endif