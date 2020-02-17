################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
S_SRCS += \
../src/Main.s \
../src/delay_ms.s \
../src/num_to_ASCII.s \
../src/num_to_LED.s \
../src/num_to_LED_init.s 

OBJS += \
./src/Main.o \
./src/delay_ms.o \
./src/num_to_ASCII.o \
./src/num_to_LED.o \
./src/num_to_LED_init.o 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.s
	@echo 'Building file: $<'
	@echo 'Invoking: MCU GCC Assembler'
	@echo $(PWD)
	arm-none-eabi-as -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 -g -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


