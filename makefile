MCU				:= atmega328p
FORMAT			:= ihex

PREFIX			:= avr-

CC				:= $(PREFIX)gcc
OBJCOPY			:= $(PREFIX)objcopy
OBJDUMP			:= $(PREFIX)objdump
SIZE			:= $(PREFIX)size --format=avr --mcu=$(MCU) 

PORT			:= /dev/ttyUSB1

AVRDUDE_FLAGS 	:= -c arduino -p m328p -P $(PORT) -b 57600

AVRDUDE			:= avrdude

SRC_DIR			:= src/
INC_DIR			:= include/
BUILD_DIR		:= build/

SRCS			:= $(wildcard $(SRC_DIR)*.c)
OBJS			:= $(patsubst $(SRC_DIR)%.c,$(BUILD_DIR)%.o, $(SRCS)) 

TARGET			:= app
OUT				:= $(BUILD_DIR)$(TARGET)

WARNINGS		:= -Wall -Wextra
CFLAGS			:= -I$(INC_DIR) $(WARNINGS) -mmcu=$(MCU) -D F_CPU=16000000 -g -Os

.PHONY: dir flash all clean

dir:
	@mkdir -p $(BUILD_DIR)

flash: all
	$(AVRDUDE) $(AVRDUDE_FLAGS) -U flash:w:$(OUT).hex:i

all: dir $(OUT).elf $(OUT).hex
	@echo $(SRCS)
	@echo $(OBJS)

$(OUT).hex: $(OUT).elf
	$(OBJCOPY) -j .text -j .data -O ihex $(OUT).elf $(OUT).hex 
	$(SIZE) $@

$(OUT).elf: $(OBJS)
	$(CC) $(CFLAGS) $^ -o $@

$(BUILD_DIR)%.o: $(SRC_DIR)%.c  
	$(CC) $(CFLAGS) -c $< -o $@

clean: 
	rm -r build/
