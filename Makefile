#=======================================================================
# Makefile for riscv-tests/isa
#-----------------------------------------------------------------------

XLEN ?= 32

src_dir := .

include $(src_dir)/rv32ui/Makefrag

default: all

#--------------------------------------------------------------------
# Build rules
#--------------------------------------------------------------------

RISCV_PREFIX ?= riscv$(XLEN)-unknown-linux-gnu-
RISCV_GCC ?= $(RISCV_PREFIX)gcc
RISCV_GCC_OPTS ?= -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles
RISCV_OBJDUMP ?= $(RISCV_PREFIX)objdump --disassemble-all --disassemble-zeroes --section=.text --section=.text.startup --section=.text.init --section=.data -D
RISCV_OBJCOPY ?= $(RISCV_PREFIX)objcopy -O binary 

vpath %.S $(src_dir)

#------------------------------------------------------------
# Build assembly tests

%.dump: %
	$(RISCV_OBJDUMP) $< > $@

%.bin: %
	$(RISCV_OBJCOPY) $< $<.bin
	
define compile_template

$$($(1)_p_tests): %: $(1)/%.S
	mkdir -p build
	$$(RISCV_GCC) $(2) $$(RISCV_GCC_OPTS) -I$(src_dir)/env/p -I$(src_dir)/macros/scalar -T$(src_dir)/env/p/link.ld $$< -o $$@
$(1)_tests += $$($(1)_p_tests)

$(1)_tests_dump = $$(addsuffix .dump, $$($(1)_tests))
$(1)_tests_bin = $$(addsuffix .bin, $$($(1)_tests))

$(1): $$($(1)_tests_dump) $(1)_tests_bin

.PHONY: $(1)

tests = $$($(1)_tests)

endef

$(eval $(call compile_template,rv32ui,-march=rv32g -mabi=ilp32))

tests_dump = $(addsuffix .dump, $(tests))
tests_bin = $(addsuffix .bin, $(tests))
tests_hex = $(addsuffix .hex, $(tests))
tests_out = $(addsuffix .out, $(filter rv64%,$(tests)))
tests32_out = $(addsuffix .out32, $(filter rv32%,$(tests)))

run: $(tests_out) $(tests32_out)

junk += $(tests) $(tests_dump) $(tests_hex) $(tests_out) $(tests32_out)
targets += $(tests) $(tests_dump) $(tests_bin)
stu_targets += $(tests_dump) $(tests_bin)

#------------------------------------------------------------
# Default

all: $(tests_dump) $(tests_bin)
	@mkdir -p build
	@rm -rf $(tests)
	@mv $(stu_targets) build
	@mkdir -p build/bin build/asm
	@mv build/*.bin build/bin
	@mv build/*.dump build/asm

#------------------------------------------------------------
# Clean up

clean:
	@rm -rf build
