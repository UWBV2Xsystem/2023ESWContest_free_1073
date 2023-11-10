################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (10.3-2021.10)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Core/Inc/Pdoa_tx.c \
../Core/Inc/TWR_uwb.c \
../Core/Inc/config_options.c \
../Core/Inc/deca_mutex.c \
../Core/Inc/deca_probe_interface.c \
../Core/Inc/deca_sleep.c \
../Core/Inc/deca_spi.c \
../Core/Inc/port.c \
../Core/Inc/read_dev_id.c \
../Core/Inc/shared_functions.c 

OBJS += \
./Core/Inc/Pdoa_tx.o \
./Core/Inc/TWR_uwb.o \
./Core/Inc/config_options.o \
./Core/Inc/deca_mutex.o \
./Core/Inc/deca_probe_interface.o \
./Core/Inc/deca_sleep.o \
./Core/Inc/deca_spi.o \
./Core/Inc/port.o \
./Core/Inc/read_dev_id.o \
./Core/Inc/shared_functions.o 

C_DEPS += \
./Core/Inc/Pdoa_tx.d \
./Core/Inc/TWR_uwb.d \
./Core/Inc/config_options.d \
./Core/Inc/deca_mutex.d \
./Core/Inc/deca_probe_interface.d \
./Core/Inc/deca_sleep.d \
./Core/Inc/deca_spi.d \
./Core/Inc/port.d \
./Core/Inc/read_dev_id.d \
./Core/Inc/shared_functions.d 


# Each subdirectory must supply rules for building sources it contributes
Core/Inc/%.o Core/Inc/%.su Core/Inc/%.cyclo: ../Core/Inc/%.c Core/Inc/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m4 -std=gnu11 -g3 -DDEBUG -DUSE_HAL_DRIVER -DSTM32F411xE -c -I../Core/Inc -I../Drivers/STM32F4xx_HAL_Driver/Inc -I../Drivers/STM32F4xx_HAL_Driver/Inc/Legacy -I../Drivers/CMSIS/Device/ST/STM32F4xx/Include -I../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@"

clean: clean-Core-2f-Inc

clean-Core-2f-Inc:
	-$(RM) ./Core/Inc/Pdoa_tx.cyclo ./Core/Inc/Pdoa_tx.d ./Core/Inc/Pdoa_tx.o ./Core/Inc/Pdoa_tx.su ./Core/Inc/TWR_uwb.cyclo ./Core/Inc/TWR_uwb.d ./Core/Inc/TWR_uwb.o ./Core/Inc/TWR_uwb.su ./Core/Inc/config_options.cyclo ./Core/Inc/config_options.d ./Core/Inc/config_options.o ./Core/Inc/config_options.su ./Core/Inc/deca_mutex.cyclo ./Core/Inc/deca_mutex.d ./Core/Inc/deca_mutex.o ./Core/Inc/deca_mutex.su ./Core/Inc/deca_probe_interface.cyclo ./Core/Inc/deca_probe_interface.d ./Core/Inc/deca_probe_interface.o ./Core/Inc/deca_probe_interface.su ./Core/Inc/deca_sleep.cyclo ./Core/Inc/deca_sleep.d ./Core/Inc/deca_sleep.o ./Core/Inc/deca_sleep.su ./Core/Inc/deca_spi.cyclo ./Core/Inc/deca_spi.d ./Core/Inc/deca_spi.o ./Core/Inc/deca_spi.su ./Core/Inc/port.cyclo ./Core/Inc/port.d ./Core/Inc/port.o ./Core/Inc/port.su ./Core/Inc/read_dev_id.cyclo ./Core/Inc/read_dev_id.d ./Core/Inc/read_dev_id.o ./Core/Inc/read_dev_id.su ./Core/Inc/shared_functions.cyclo ./Core/Inc/shared_functions.d ./Core/Inc/shared_functions.o ./Core/Inc/shared_functions.su

.PHONY: clean-Core-2f-Inc

