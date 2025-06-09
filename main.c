#include "lcd1602A_driver.h"
#include <stdio.h>
#include "gd32vf103.h"
#include "dht11.h"

/* 
Replace this file with your code. Put your source files in this directory and any libraries in the lib folder. 
If your main program should be assembly-language replace this file with main.S instead.

Libraries (other than vendor SDK and gcc libraries) must have .h-files in /lib/[library name]/include/ and .c-files in /lib/[library name]/src/ to be included automatically.
*/

int main(void){
    lcd_init();
    DHT11_init(GPIOB, GPIO_PIN_5);

    lcd_writeCh(temp);
    lcd_clear();
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
        DHT11_readData();
        
        sprintf(buf, "Humid=%d", DHT11_getHumid());
        
        lcd_writeStr(buf);
        lcd_set_cursor(1, 0);
        sprintf(buf, "Temp=%d.%d", DHT11_getTempIntegral(), DHT11_getTempDecimal());
        lcd_writeStr(buf);
        lcd_home();
        for(int z = 0; z < 10000000; z++);
    }
    return 0;
}