################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
S_SRCS += \
../Src/Convert.s \
../Src/Lcd.s \
../Src/Main.s \
../Src/adc.s \
../Src/keypad.s \
../Src/temp.s \
../Src/timer.s 

OBJS += \
./Src/Convert.o \
./Src/Lcd.o \
./Src/Main.o \
./Src/adc.o \
./Src/keypad.o \
./Src/temp.o \
./Src/timer.o 


# Each subdirectory must supply rules for building sources it contributes
Src/%.o: ../Src/%.s
	arm-none-eabi-gcc -mcpu=cortex-m4 -g3 -c -x assembler-with-cpp --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@" "$<"

