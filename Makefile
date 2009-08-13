##
# Copyright (C) 2009 Renê de Souza Pinto
# TempOS - Tempos is an Educational and multi purpose Operating System
#
# Makefile - TempOS Build System
#

PWD := $(shell pwd)


# Default files and dirs
kimage     := tempos.elf
fimage     := floppy.img
deptool	   := $(PWD)/build/makedeps

conffile   := .config
config_def := scripts/config.default
config_mk  := scripts/Makefile.config
config_h   := include/config.h

objlist    := objs.list

checkarch  := scripts/checkarch.sh

btools_dir := build


# Default values
CC = gcc
LD = ld
CFLAGS = -Wall


# All object files
obj-y:=

# Export all variables
export

# Pseudo rules
.PHONY: showtitle clean


all: tempos

showtitle:
	@echo " ===================== "
	@echo "[ TempOS Build System ]"
	@echo " ===================== "

buildep:
	@$(MAKE) --quiet -C $(btools_dir)

tempos: showtitle buildep config
	@[ -f $(objlist) ] && rm -f $(objlist) || echo " * Sanity check"
	@echo -n " * Checking architecture..."
	@$(checkarch) $(conffile)


##
# Read configuration file and generate proper files
#
config: $(conffile)
	@echo " + READ $(conffile)"
	 
	@echo " + WRITE $(config_mk)"
	@echo -e "##\n# This file was automatic generated by TempOS Build System\n# WARNING: Do not edit.\n#\n" > $(config_mk)
	@sed -n "s/ \{0,\}\(\w\+\) \{0,\}= \{0,\}y/\1=y\\nexport \1/gp" $(conffile) >> $(config_mk)
	
	@echo " + WRITE $(config_h)"
	@echo -e "/**\n * This file was automatic generated by TempOS Build System\n * WARNING: Do not edit.\n **/\n" > $(config_h)
	@echo -e "#ifndef TEMPOS_CONFIG_H\n\n\t#define TEMPOS_CONFIG_H\n" >> $(config_h)
	@sed -n "s/ \{0,\}\(\w\+\) \{0,\}= \{0,\}y/\t#define \1/gp" $(conffile) >> $(config_h)
	@echo -e "\n#endif /* TEMPOS_CONFIG_H */\n" >> $(config_h)


##
# Use a default configuration file
#
$(conffile):
	@echo "****************************************************************************"
	@echo "* WARNING: Kernel build configuration file not found. Use default options. *"
	@echo "****************************************************************************"
	@cp $(config_def) $(conffile)


##
# test
#
test: showtitle
	@echo -n " * Checking architecture..."
	@$(checkarch) $(conffile) test


##
# install
#
install: showtitle $(fimage)
	@echo -n " * Checking architecture..."
	@$(checkarch) $(conffile) install


$(fimage):
	@scripts/mkdisk_img.sh $(fimage)
	@$(MAKE) install


##
# clean
#
clean: showtitle
	@echo "Cleaning..."
	@[ -f $(config_mk) ] && (rm -f $(config_mk) && echo " - Remove $(config_mk)") || echo " ! $(config_mk) not found."
	@[ -f $(config_h) ] && (rm -f $(config_h) && echo " - Remove $(config_h)") || echo " ! $(config_h) not found."
	@$(MAKE) clean --quiet -C $(btools_dir)
	@echo -n " * Checking architecture..."
	@$(checkarch) $(conffile) clean
	@echo done.

