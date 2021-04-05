PWD := $(shell pwd)
MODULE_NAME = msT
obj-m := $(MODULE_NAME).o

all: systab.h app
	make -C /lib/modules/`uname -r`/build M=$(PWD) modules

# record address of system call table
systab.h:
	(grep -w sys_call_table /boot/System.map-`uname -r` | \
	  sed 's/\([^ ]*\) .*/#define scTab ((char *)0x\1UL)/'; \
	 grep -w system_wq      /boot/System.map-`uname -r` | \
	  sed 's/\([^ ]*\) .*/#define sysWQ ((char *)0x\1UL)/') > systab.h
app:
	gcc app.c -o app

testing:
	@sudo insmod $(MODULE_NAME).ko
	@rm -f tmp.out
	@python3 exe.py > tmp.out
	@python3 analy.py
	@sudo rmmod $(MODULE_NAME)
	@rm -f tmp.out

.PHONY: app clean
clean:
	make -C /lib/modules/`uname -r`/build M=$(PWD) clean
	rm systab.h
	rm app