#include "lcd1602A_driver.h"
#include <stdio.h>
#include "gd32vf103.h"


int main(void){
    lcd_init();

    lcd_writeCh(temp);
    //lcd_clear();
    char buf[16];
    float temp = 25.223f;
    int temp_int = (int)temp;
    int temp_frac = (int)((temp - temp_int) * 100);
    //gpio_init()

    //sprintf(buf, "Temp=%d.%02d", temp_int, temp_frac);
    //lcd_writeStr(buf);

    int max = 1000000;
    int y = 0;
    while(1){
        sprintf(buf, "Temp=%d",y);
        y = (y + 1) % max;
        lcd_writeStr(buf);
        lcd_home();
    }
    return 0;
}