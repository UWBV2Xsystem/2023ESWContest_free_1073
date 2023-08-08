################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (10.3-2021.10)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Core/Inc/PDOA_uwb.c \
../Core/Inc/TWR_uwb.c \
../Core/Inc/config_options.c \
../Core/Inc/deca_mutex.c \
../Core/Inc/deca_probe_interface.c \
../Core/Inc/deca_sleep.c \
../Core/Inc/deca_spi.c \
../Core/Inc/ds_twr_initiator.c \
../Core/Inc/ds_twr_responder.c \
../Core/Inc/example_info.c \
../Core/Inc/pll_cal.c \
../Core/Inc/port.c \
../Core/Inc/read_dev_id.c \
../Core/Inc/shared_functions.c \
../Core/Inc/simple_rx.c \
../Core/Inc/simple_rx_nlos.c \
../Core/Inc/simple_rx_pdoa.c \
../Core/Inc/ss_twr_initiator.c \
../Core/Inc/ss_twr_responder.c 

OBJS += \
./Core/Inc/PDOA_uwb.o \
./Core/Inc/TWR_uwb.o \
./Core/Inc/config_options.o \
./Core/Inc/deca_mutex.o \
./Core/Inc/deca_probe_interface.o \
./Core/Inc/deca_sleep.o \
./Core/Inc/deca_spi.o \
./Core/Inc/ds_twr_initiator.o \
./Core/Inc/ds_twr_responder.o \
./Core/Inc/example_info.o \
./Core/Inc/pll_cal.o \
./Core/Inc/port.o \
./Core/Inc/read_dev_id.o \
./Core/Inc/shared_functions.o \
./Core/Inc/simple_rx.o \
./Core/Inc/simple_rx_nlos.o \
./Core/Inc/simple_rx_pdoa.o \
./Core/Inc/ss_twr_initiator.o \
./Core/Inc/ss_twr_responder.o 

C_DEPS += \
./Core/Inc/PDOA_uwb.d \
./Core/Inc/TWR_uwb.d \
./Core/Inc/config_options.d \
./Core/Inc/deca_mutex.d \
./Core/Inc/deca_probe_interface.d \
./Core/Inc/deca_sleep.d \
./Core/Inc/deca_spi.d \
./Core/Inc/ds_twr_initiator.d \
./Core/Inc/ds_twr_responder.d \
./Core/Inc/example_info.d \
./Core/Inc/pll_cal.d \
./Core/Inc/port.d \
./Core/Inc/read_dev_id.d \
./Core/Inc/shared_functions.d \
./Core/Inc/simple_rx.d \
./Core/Inc/simple_rx_nlos.d \
./Core/Inc/simple_rx_pdoa.d \
./Core/Inc/ss_twr_initiator.d \
./Core/Inc/ss_twr_responder.d 


# Each subdirectory must supply rules for building sources it contributes
Core/Inc/%.o Core/Inc/%.su Core/Inc/%.cyclo: ../Core/Inc/%.c Core/Inc/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m4 -std=gnu11 -g3 -DDEBUG -DUSE_HAL_DRIVER -DSTM32F411xE -c -I../Core/Inc -I../Drivers/STM32F4xx_HAL_Driver/Inc -I../Drivers/STM32F4xx_HAL_Driver/Inc/Legacy -I../Drivers/CMSIS/Device/ST/STM32F4xx/Include -I../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@"

clean: clean-Core-2f-Inc

clean-Core-2f-Inc:
	-$(RM) ./Core/Inc/PDOA_uwb.cyclo ./Core/Inc/PDOA_uwb.d ./Core/Inc/PDOA_uwb.o ./Core/Inc/PDOA_uwb.su ./Core/Inc/TWR_uwb.cyclo ./Core/Inc/TWR_uwb.d ./Core/Inc/TWR_uwb.o ./Core/Inc/TWR_uwb.su ./Core/Inc/config_options.cyclo ./Core/Inc/config_options.d ./Core/Inc/config_options.o ./Core/Inc/config_options.su ./Core/Inc/deca_mutex.cyclo ./Core/Inc/deca_mutex.d ./Core/Inc/deca_mutex.o ./Core/Inc/deca_mutex.su ./Core/Inc/deca_probe_interface.cyclo ./Core/Inc/deca_probe_interface.d ./Core/Inc/deca_probe_interface.o ./Core/Inc/deca_probe_interface.su ./Core/Inc/deca_sleep.cyclo ./Core/Inc/deca_sleep.d ./Core/Inc/deca_sleep.o ./Core/Inc/deca_sleep.su ./Core/Inc/deca_spi.cyclo ./Core/Inc/deca_spi.d ./Core/Inc/deca_spi.o ./Core/Inc/deca_spi.su ./Core/Inc/ds_twr_initiator.cyclo ./Core/Inc/ds_twr_initiator.d ./Core/Inc/ds_twr_initiator.o ./Core/Inc/ds_twr_initiator.su ./Core/Inc/ds_twr_responder.cyclo ./Core/Inc/ds_twr_responder.d ./Core/Inc/ds_twr_responder.o ./Core/Inc/ds_twr_responder.su ./Core/Inc/example_info.cyclo ./Core/Inc/example_info.d ./Core/Inc/example_info.o ./Core/Inc/example_info.su ./Core/Inc/pll_cal.cyclo ./Core/Inc/pll_cal.d ./Core/Inc/pll_cal.o ./Core/Inc/pll_cal.su ./Core/Inc/port.cyclo ./Core/Inc/port.d ./Core/Inc/port.o ./Core/Inc/port.su ./Core/Inc/read_dev_id.cyclo ./Core/Inc/read_dev_id.d ./Core/Inc/read_dev_id.o ./Core/Inc/read_dev_id.su ./Core/Inc/shared_functions.cyclo ./Core/Inc/shared_functions.d ./Core/Inc/shared_functions.o ./Core/Inc/shared_functions.su ./Core/Inc/simple_rx.cyclo ./Core/Inc/simple_rx.d ./Core/Inc/simple_rx.o ./Core/Inc/simple_rx.su ./Core/Inc/simple_rx_nlos.cyclo ./Core/Inc/simple_rx_nlos.d ./Core/Inc/simple_rx_nlos.o ./Core/Inc/simple_rx_nlos.su ./Core/Inc/simple_rx_pdoa.cyclo ./Core/Inc/simple_rx_pdoa.d ./Core/Inc/simple_rx_pdoa.o ./Core/Inc/simple_rx_pdoa.su ./Core/Inc/ss_twr_initiator.cyclo ./Core/Inc/ss_twr_initiator.d ./Core/Inc/ss_twr_initiator.o ./Core/Inc/ss_twr_initiator.su ./Core/Inc/ss_twr_responder.cyclo ./Core/Inc/ss_twr_responder.d ./Core/Inc/ss_twr_responder.o ./Core/Inc/ss_twr_responder.su

.PHONY: clean-Core-2f-Inc

