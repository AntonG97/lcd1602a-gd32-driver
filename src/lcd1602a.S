.section .text
##################################################################################################################################
#Base adress and offsets
.equ GPIOA, 0x40010800  	#GPIOA base adress
.equ GPIOB, 0x40010c00  	#GPIOB base adress
.equ GPIOC, 0x40011000  	#GPIOC base adress 
.equ GPIOD, 0x40011400  	#GPIOD base adress
.equ GPIOE, 0x40011800  	#GPIOE base adress
##################################################################################################################################
#OFFSETS
.equ CTR0,   0x00           #Port control register 0 offset
.equ CTR1,   0x04	    	#Port control register 1 offset
.equ ISTAT,  0x08           #Port input status register
.equ OCTL,   0x0C           #Port output control register
.equ BOP,    0x10           #Port bit operate register offset
.equ BC,     0x14           #Port bit clear register offset
##################################################################################################################################
#CONF
.equ MI_GPIO_AM, 0x0        #Mode: Input, Analog Mode
.equ MO_GPIO_50, 0x3        #Mode: Output, max speed 50MHz
.equ MO_GPIO_10, 0x1        #Mode: output, speed 10MHz
.equ MO_GPIO_2,  0x2        #Mode: Output, speed 2MHz
.equ CI_GPIO_FI, 0x4        #Conf: (Input) Floating input
.equ CI_GPIO_UD, 0x8        #Conf: (Input) Pull-up/-down
.equ CO_GPIO_PP, 0x0        #Conf: (Output) Push-pull
.equ CO_GPIO_OD, 0x4        #Conf: (Output) Open-drain
##################################################################################################################################
#Initilize GPIOx
#a0 -> target GPIO module
#a1 -> Configuration bits ( << 2 )
#a2 -> Mode bits
#a3 -> Target pin
gpioi:
	mv t0, a0	        #t0 points to base adress
	li t1, 8		
	mv t2, a3	        #Target pins
	blt a3, t1, skip	#If target pin less than 8, skip
	addi t0, t0, 4		#Increase base adress (CTR1)
	sub t2, t2, t1		#Set correct pin. Ex 10 - 8 = 2
	
skip:
	li t3, 0xF		#Create mask		
	#Ex. Pin nb = 1, 1* 4 = 4 shifts
	slli t2, t2, 2		#Mult. pin nb by 4 to get amount to shift
	sll t3, t3, t2		#Shift mask
	not t3,t3		#Invert mask
	
	lw t4, CTR0(t0)		#t4 has CTRx register val
	and t4, t4, t3		#Reset target bits
		
	or t5, a1, a2		#Get 4-bit conf
    sll t5, t5,  t2             #Shift bits to correct pos
	or t4, t4, t5		#Set 4-bit conf
	sw t4, CTR0(t0)
	
	ret
##################################################################################################################################
#GPIOx bit operations
#a0 -> target GPIO module
#a1 -> Bits (1: turn on, 0:s turn off)
#a2 -> Target pins (1 = set)
gpiobo:
    and a1, a1, a2      #make sure that correct pattern
    xor a2, a1, a2      #XOR to invert bits of a1 for GPIO pins to be set
    slli a2, a2, 16     #Shift bits up
    or a1, a1, a2       #t1 contains word
    sw a1, BOP(a0)      #Save config in BOP register

    ret

##################################################################################################################################
#GPIOx clear bits
#a0 -> target GPIO module
#a1 -> Bits
gpioc:
    mv t0, a0           #t0 holds base adress
    li t1, 0x0000FFFF   #Mask
    and a1, a1, t1      #Make sure that MSB not set
    sw a1, BC(t0)       #Write to BC register

    ret

##################################################################################################################################
#GPIOx output control
#a0 -> target GPIO module
#a1 -> Bits
gpiooc:
    mv t0, a0           #t0 holds base adress
    li t1, 0x0000FFFF   #Mask
    and a1, a1, t1      #Make sure that MSB not set
    sw a1, OCTL(t0)     #Write to OCTL register

    ret

##################################################################################################################################
#GPIOx input status
#a0 -> target GPIO module
gpiois:
    mv t0, a0           #t0 bolds base adress
    lw a0, ISTAT(t0)    #Get input status register

    ret
/////////////////////////////////////////////////////////////////////////////////////
// RCU Reset and Clock Unit Subroutine package                         0.91 AC
/////////////////////////////////////////////////////////////////////////////////////
.equ RCU,    0x40021000
.equ APB1EN, 0x1C
.equ APB2EN, 0x18
.equ PAEN,   0x4
.equ PBEN,   0x8
.equ T5EN,   0x10
// RCU1EN Enabel APB1 bus devices //////////////////////////////////// 1.0 / AC ///
rcu1en: li t0,RCU           // t0 points to RCU...
        lw t1,APB1EN(t0)    // ...retrieve current configuration...
        or t1,t1,a0         // ...and update the configuration...
        sw t1,APB1EN(t0)    // ...then save back the updated config...
        ret                 // and go home!

// RCU2EN Enabel APB2 bus devices //////////////////////////////////// 1.0 / AC ///
rcu2en: li t0,RCU           // t0 points to RCU...
        lw t1,APB2EN(t0)    // ...retrieve current configuration...
        or t1,t1,a0         // ...and update the configuration...
        sw t1,APB2EN(t0)    // ...then save back the updated config...
        ret                 // and go home!
        
// RCU Reset and Clock Unit Subroutine package ////////////////////////// END ///////
#################################################################################################################################################
#Timer 5 Unit Subroutine package
.equ TIMER5, 0x40001000         #Base adress
.equ T5CTR0, 0x00               #Counter enable register. Set to x_0 to 1 => Timer 5 ON
.equ UPIF, 0x10                 #Update interrupt flag register. SW set to x_0 to 1 => CNT has reached val in CAR. Reset manually!
.equ CNT, 0x24                  #Counter register. Counts upwards by the frequency decided by value in prescaler register (PSC)
.equ PSC, 0x28                  #Prescaler register. Divides the main clock (108MHz) by 16-bit val used by CNT register
.equ CAR, 0x2C                  #Counter auto reload register. Used to reset CNT whenever CAR == CNT. Also set UPIF = 1

#a0 -> Prescaler (16-bit val)
#a1 -> Counter auto reload (16-bit)
t5init:
        addi sp, sp, -4         #Push: Make room on the stack
        sw ra, 0(sp)            #For another return adress

        mv a2, a0               #a0 holds PSC

        li a0, T5EN     
        call rcu1en             #Turn on clock for Timer 5

        #Set PSC (a0->a2)
        li t0, TIMER5           #t0 has base adress
        sw a2, PSC(t0)          #Set prescaler
        sw a1, CAR(t0)          #Set counter auto reload register

        sw zero, UPIF(t0)       #Clear interrupt flag   
        #li t1, 0x01        
        #sw t1, T5CTR0(t0)       #Enable Timer 5

        lw ra, 0(sp)            #Pop: Get return adress
        addi sp, sp, 4          #Reclame used stack space
        ret

#Check if timer has expired, i.e if UPIF has been set to 1! Reset UPIF
t5exp:
        li t0, TIMER5
        lw a0, UPIF(t0) 
        #andi a0, a0, 0x1        #Mask out flag
        beqz a0, 1f             #If flag has not been set...
        sw zero, UPIF(t0)       #...Else if has been set, reset interrput flag to 0
1:      
        ret

#Enables and waits until t5 expired (30ms)
t5wait:
        addi sp, sp, -4         #Push: Make room on the stack
        sw ra, 0(sp)            #For another return adress

        li t0, TIMER5
        li t1, 0x01        
        sw t1, T5CTR0(t0)       #Enable Timer 5

1:      call t5exp
        beqz a0, 1b

        sw zero, T5CTR0(t0)     #Disable Timer 5

        lw ra, 0(sp)
        addi sp, sp, 4
        ret

#Timer 5 subroutine package end


#####################################################################################################################################################
#LCD subroutine package
#####################################################################################################################################################
#Private LCD functionality 
#####################################################################################################################################################
#Initialize LCD gpio pins
LCDgpioi:
        addi sp, sp, -4        
        sw ra, 0(sp)
        
        li a0, PAEN+PBEN        #Turn on GPIOA and GPIOB
        call rcu2en             #RCU
        
        li a0, GPIOA            #Data pins [a7 - a0]
        li a1, CO_GPIO_PP       #conf push-pull (default pull)
        li a2, MO_GPIO_2        #mode 2MHz speed
        li a3, 0                #target pins [a7 - a0]
        li a4, 8
1:      call gpioi              #Config 
        addi a3, a3, 1      
        bne a3,a4,1b            #Continue until all 8 conf


        li a0, GPIOB            #E, R/W, RS [b2, b1, b0]
        li a1, CO_GPIO_PP       #conf push-pull (default pull)
        li a2, MO_GPIO_2        #mode 2MHz speed
        li a3, 0                #target pins [b2 - b0]
        li a4, 3
1:      call gpioi              #Config 
        addi a3, a3, 1      
        bne a3,a4,1b            #Continue until all 3 conf

        lw ra, 0(sp)
        addi sp, sp, 4

        ret
#Check if LCD driver is busy (BF = 1)
lcdIsBusy:
        addi sp, sp, -4
        sw ra, 0(sp)

        li a0, GPIOA
        li a1, 0x0
        li a2, 0x0FF
        call gpiobo             #Set Data bits to 0

        li a0, GPIOB
        li a1, 0x2
        li a2, 0x2
        call gpiobo             #Set R/W HIGH
        call t5exp

        li a0, GPIOA            #Set data pins [a7 - a0] as inputs!
        li a1, CI_GPIO_UD       #conf push-pull (default pull)
        li a2, 0                
        li a3, 0                #target pins [a7 - a0]
        li a4, 8
1:      call gpioi              #Config 
        addi a3, a3, 1      
        bne a3,a4,1b            #Continue until all 8 conf

        call lcdEN_set          #Set enable HIGH

        #call t5exp              #Wait
1:      li a0, GPIOA
        call gpiois             #a0 holds ISTAT register word
        srli a0, a0, 7          #Get BF at a7
        andi a0, a0, 1          #Mask out BF
        bnez a0, 1b             #Continue while BF = 1

        call t5exp              
        call lcdEn_res          #Set enable low

        li a0, GPIOB
        li a1, 0x0
        li a2, 0x2
        call gpiobo             #Set R/W LOW

        li a0, GPIOA            #Data pins [a7 - a0] => Revert back as outputs
        li a1, CO_GPIO_PP       #conf push-pull (default pull)
        li a2, MO_GPIO_2        #mode 2MHz speed
        li a3, 0                #target pins [a7 - a0]
        li a4, 8
1:      call gpioi              #Config 
        addi a3, a3, 1      
        bne a3,a4,1b            #Continue until all 8 conf

        lw ra, 0(sp)
        addi sp, sp, 4
        ret

#Send LCD instruction. 
.equ OFF,     0x00            #Display off
.equ _ON,      0x0C           #Display ON
.equ CLEAR,   0x01            #Clear display
.equ RET,     0x02            #Return home (DDRAM adress to 0)
.equ MOV,     0x06            #Assign curos moving dir (left)
.equ FUNC,    0x38            #Set 2 8-bit interface and 2 lines
.equ ON,      0x0F            #Display ON. Display curson. Display blinking of cursor
.equ SET_CUR, 0x80            #Set cursor at specific adress
#a0 -> contains instruction
LCD_IR:
        addi sp, sp, -4
        sw ra, 0(sp)

        addi sp,sp,-4
        sw a0, 0(sp)             #Allocate memory for a0

        call lcdIsBusy

        call lcdEN_set
        lw a0, 0(sp)            #Get value stored in allocated mem
        call lcdData_w           
        call t5wait             
        call lcdEn_res
        li a0, 0x0
        call lcdData_w

        addi sp, sp, 4          #Return allocated mem

        lw ra, 0(sp)
        addi sp, sp, 4

        ret

#Send LCD data
#a0 -> contains data
LCD_data:
        addi sp, sp, -4
        sw ra, 0(sp)            #Save return adress

        addi sp,sp,-4
        sw a0, 0(sp)            #Allocate memory for a0
        
        call lcdIsBusy          #Check if busy

        li a0, GPIOB            
        li a1, 0x1
        li a2, 0x1
        call gpiobo             #RS = High
        call t5exp              #WAIT

        call lcdEN_set          #Enable = HIGH
        lw a0, 0(sp)            #Get val stored in allocated mem
        call lcdData_w          #Write data
        call t5wait             #Wait 
        call lcdEn_res
        li a0, 0x0
        call lcdData_w

        li a0, GPIOB            
        li a1, 0x0
        li a2, 0x1
        call gpiobo             #RS = LOW

        addi sp, sp, 4          #Return alloc mem

        lw ra, 0(sp)        
        addi sp, sp, 4
        ret

####################################################################################################################################################
#Followig the flow chart provided in the datasheet
lcdfsm:
        addi sp, sp, -4
        sw ra, 0(sp)

        call t5wait             #Wait for more than 15 ms after Vcc rises to 4.5V

        li a0, 0x006B           #Prescaler
        li a1, 0x03E7           #Counter Auto Reload
        call t5init             #Reinit T5 for 1kHz (1 ms delay)
            
       # li a0, 0x30
        #call LCD_IR             #Function set (I.F is 8-bits long)

        li a0, FUNC
        call LCD_IR             #Set 2 8-bit interface and 2 lines
        call t5wait
        
        li a0, OFF
        call LCD_IR             #Display off
        call t5wait
        
        li a0, CLEAR
        call LCD_IR             #Clear display
        call t5wait

        li a0, MOV
        call LCD_IR             #Assign cursor moving dir (left) 
        call t5wait

        li a0, ON
        call LCD_IR             #Display ON. Display curson. Display blinking of cursor
        call t5wait

        #Setup complete. Change timer config...
        li a0, 0x0000    #Prescaler
        li a1, 0x0018    #Counter Auto Reload
        call t5init      #Reinit t5 on 231.5 ns delays
        #...Done! 

        #Create user icons
        call lcd_createIcon

        #call lcd_writeStr #####DBG

        lw ra, 0(sp)
        addi sp, sp, 4

        ret
#Set enable pin HIGH [b2]
lcdEN_set:
        addi sp, sp, -4
        sw ra, 0(sp)

        li a0, GPIOB
        li a1, 0x4
        li a2, 0x4
        call gpiobo

        lw ra, 0(sp)
        addi sp, sp, 4
        ret
#Set enable pin LOW [b2]
lcdEn_res:
        addi sp, sp, -4
        sw ra, 0(sp)

        li a0, GPIOB
        li a1, 0x0
        li a2, 0x4
        call gpiobo

        lw ra, 0(sp)
        addi sp, sp, 4
        ret

#Write LCD data pins [a7 - a0]
#a0 -> contain data to write
lcdData_w:
        addi sp, sp, -4
        sw ra, 0(sp)

        andi a1, a0, 0x0FF       #Mask out data bits
        li a0, GPIOA
        li a2, 0x0FF             #Target pins [a7 - a0]
        call gpiobo

        lw ra, 0(sp)
        addi sp, sp, 4
        ret

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//User defined icons
.section .data
amount: .byte 8                  #Amount of icons. Increment if added more icons!

.section .rodata
icon:   .word battery_empty
        .word battery_25
        .word battery_50
        .word battery_75
        .word battery_100
        .word temp
        .word add_one
        .word add_two

battery_empty:
        .byte 0b1000000           #CGRAM adress = 0
        .byte 0b00100
        .byte 0b11111
        .byte 0b10001
        .byte 0b10001
        .byte 0b10001
        .byte 0b10001
        .byte 0b11111
        .byte 0b00000
battery_25:
        .byte 0b1001000           #CGRAM adress = 1
        .byte 0b00100
        .byte 0b11111
        .byte 0b10001
        .byte 0b10001
        .byte 0b10001
        .byte 0b11111
        .byte 0b11111
        .byte 0b00000
battery_50:
        .byte 0b1010000           #CGRAM adress = 2
        .byte 0b00100
        .byte 0b11111
        .byte 0b10001
        .byte 0b10001
        .byte 0b11111
        .byte 0b11111
        .byte 0b11111
        .byte 0b00000
battery_75:
        .byte 0b1011000           #CGRAM adress = 3
        .byte 0b00100
        .byte 0b11111
        .byte 0b10001
        .byte 0b11111
        .byte 0b11111
        .byte 0b11111
        .byte 0b11111
        .byte 0b00000
battery_100:
        .byte 0b1100000           #CGRAM adress = 4
        .byte 0b00100
        .byte 0b11111
        .byte 0b11111
        .byte 0b11111
        .byte 0b11111
        .byte 0b11111
        .byte 0b11111
        .byte 0b00000
temp:
        .byte 0b1101000           #CGRAM adress = 5
        .byte 0b00100
        .byte 0b01010
        .byte 0b01010
        .byte 0b01110
        .byte 0b01110
        .byte 0b11111
        .byte 0b11111
        .byte 0b01110
add_one: #Implement new icon
        .byte 0b1110000           #CGRAM adress = 6
        .byte 0b10001
        .byte 0b01010
        .byte 0b00100
        .byte 0b00100
        .byte 0b00100
        .byte 0b01010
        .byte 0b10001
        .byte 0b00000
add_two: #Implement new icon
        .byte 0b1111000           #CGRAM adress = 7
        .byte 0b10001
        .byte 0b01010
        .byte 0b00100
        .byte 0b00100
        .byte 0b00100
        .byte 0b01010
        .byte 0b10001
        .byte 0b00000
//User defined icons END
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
.section .text
lcd_createIcon:
        addi sp, sp, -16        #Create room on stack!
        sw ra, 12(sp)           #...Save return adress
        sw s0, 8(sp)            #...Save contents in s0. S0 = adress to icon
        sw s1, 4(sp)            #...Save contents in s1. s1 = decrement variable
        sw s2, 0(sp)            #...Save contents in s2. s2 = Temp data

       # la s2, amount           
        #lb s2, 0(s2)            #s2 holds amount of icons to write
        #li s2, 0
        li t0, 0
start_loop:
        mv s2, t0
        la s0, icon    #DBG!!!!!!!!!!!!!!! TODO: Fix so that s0 loops through ALL symbols
        add s0, s0, s2          #Add s2 offset to s0
        lw s0, 0(s0)
        lb a0, 0(s0)            #Load a0 with adress of next icon
        call LCD_IR             #Set CGRAM adress 

        li s1, 8                #Loop thorugh icon data bytes
cont:
        addi s0, s0, 1          #Increment icon adress
        lb a0, 0(s0)            #Get next data byte
        call LCD_data           #Write it to LCD
        addi s1, s1, -1         #Decrement loop var
        bnez s1, cont     

        addi s2, s2, 4          #Increase s2 offset by 4 bytes (next icon)
        mv t0, s2               #t0 temp holds s2 offset
        la s2, amount           
        lb s2, 0(s2)            #s2 holds amount of icons to write
        addi s2, s2, -1         #Decrement s2...
        mv t1, s2
        la s2, amount
        sb t1, 0(s2)            #...Save s2
        bnez t1, start_loop     #...Continue until all icons has been written to CGRAM 

        #Set DDRAM adress to 0
        li a0, RET
        call LCD_IR
                
        lw ra, 12(sp)           #Restore all registers...
        lw s0, 8(sp)            #...
        lw s1, 4(sp)            #...
        lw s2, 0(sp)            #...
        addi sp, sp, 16         #POP stack

        ret
#####################################################################################################################################################
#Public LCD functionality
#Init LCD including GPIO pins and internal driver
.globl lcd_init
lcd_init:
        addi sp, sp, -4
        sw ra, 0(sp)

        li a0, 0x006B           #Prescaler
        li a1, 0x4E1F           #Counter Auto Reload
        call t5init             #Init T5 20 ms delays

        call LCDgpioi           #Init gpio pins

        call lcdfsm             #Flowchart datasheet

        lw ra, 0(sp)
        addi sp, sp, 4
        ret

#Clear screen
.globl lcd_clear
lcd_clear:
        addi sp, sp, -4
        sw ra, 0(sp)

        li a0, CLEAR
        call LCD_IR

        lw ra, 0(sp)
        addi sp, sp, 4
        ret

#Return cursor to coordinate (0,0)
.globl lcd_home
lcd_home:
        addi sp, sp, -4
        sw ra, 0(sp)
        
        li a0, RET
        call LCD_IR

        lw ra, 0(sp)
        addi sp, sp, 4
        ret

#Set cursor at arbitrarily coordinates [check bound]
#a0 -> row [0 1]
#a1 -> col [0 - 15]
.globl lcd_set_cursor
lcd_set_cursor:
        addi sp, sp, -4
        sw ra, 0(sp)

        andi a0, a0, 0x01       #make sure that a0 is either 1 or 0
        andi a1, a1, 0x0F       #Make sure that a1 is in range [15 - 0]
        beqz a0, 1f             #If a0 == 0  
        slli a0, a0, 6          #Shift 1 up to 4
1:
        or a0, a0, a1
        or a0, a0, SET_CUR
        call LCD_IR

        lw ra, 0(sp)
        addi sp, sp, 4
        ret

#Writes a character to LCD
#a0 -> Contains char
.globl lcd_writeCh
lcd_writeCh:
        addi sp, sp, -4
        sw ra, 0(sp)

        call LCD_data

        lw ra, 0(sp)
        addi sp, sp, 4
        ret

.section .rodata
stringer:
    .asciz "Hello W!"
#Print a NULL terminated string into LED
#a0 -> contain pointer to char array, NULL terminated
.section .text
.globl lcd_writeStr
lcd_writeStr:

        addi sp, sp, -4
        sw ra, 0(sp)       

        #la a0, stringer #DBG DBG DBG CHANGE when fixing header file. A0 from outside

        addi sp, sp, -4
        sw a0, 0(sp)            #Save pointer to char array on stack
        
loop:
        lw t0, 0(sp)
        lb a0, 0(t0)            #Get next char
        beqz a0, break          #If NULL, break loop
        call LCD_data           #Write data

        lw a0, 0(sp)
        addi a0, a0, 1          #Increment adress
        sw a0, 0(sp)
        j loop                  
break:

        addi sp, sp, 4          #Release allocated mem

        lw ra, 0(sp)
        addi sp, sp, 4
        ret

.globl lcd_display_on
lcd_display_on:
        addi sp, sp, -4
        sw ra, 0(sp)

        li a0, _ON
        call LCD_IR

        lw ra, 0(sp)
        addi sp, sp, 4
        ret

.globl lcd_display_off
lcd_display_off:
        addi sp, sp, -4
        sw ra, 0(sp)

        li a0, OFF
        call LCD_IR

        lw ra, 0(sp)
        addi sp, sp, 4
        ret
#LCD subroutine package end
###################################################################################################################################################