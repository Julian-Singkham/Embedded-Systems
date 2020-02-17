################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include ../makefile.init

RM := rm -rf

# All of the sources participating in the build are defined here
-include sources.mk
-include Startup/subdir.mk
-include Src/subdir.mk
-include subdir.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
endif

-include ../makefile.defs

# Add inputs and outputs from these tool invocations to the build variables 
EXECUTABLES += \
Lab\ 7\ hex\ to\ decimal\ game\ -v2.elf \

SIZE_OUTPUT += \
default.size.stdout \

OBJDUMP_LIST += \
Lab\ 7\ hex\ to\ decimal\ game\ -v2.list \


# All Target
all: Lab\ 7\ hex\ to\ decimal\ game\ -v2.elf secondary-outputs

# Tool invocations
Lab\ 7\ hex\ to\ decimal\ game\ -v2.elf: $(OBJS) $(USER_OBJS) C:\School\Embedded\ 1\Lab\ 7\ hex\ to\ decimal\ game\ -v2\STM32F446RETX_FLASH.ld
	arm-none-eabi-gcc -o "Lab 7 hex to decimal game -v2.elf" @"objects.list" $(USER_OBJS) $(LIBS) -mcpu=cortex-m4 -T"C:\School\Embedded 1\Lab 7 hex to decimal game -v2\STM32F446RETX_FLASH.ld" --specs=nosys.specs -Wl,-Map="Lab 7 hex to decimal game -v2.map" -Wl,--gc-sections -static --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -Wl,--start-group -lc -lm -Wl,--end-group
	@echo 'Finished building target: $@'
	@echo ' '

default.size.stdout: $(EXECUTABLES)
	arm-none-eabi-size  $(EXECUTABLES)
	@echo 'Finished building: $@'
	@echo ' '

Lab\ 7\ hex\ to\ decimal\ game\ -v2.list: $(EXECUTABLES)
	arm-none-eabi-objdump -h -S $(EXECUTABLES) > "Lab 7 hex to decimal game -v2.list"
	@echo 'Finished building: $@'
	@echo ' '

# Other Targets
clean:
	-$(RM) *
	-@echo ' '

secondary-outputs: $(SIZE_OUTPUT) $(OBJDUMP_LIST)

.PHONY: all clean dependents
.SECONDARY:

-include ../makefile.targets
