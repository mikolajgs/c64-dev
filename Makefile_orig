X64=x64sc
ASM=64tass

all: demo.prg
	x64sc -autostartprgmode 1 -chdir `pwd` -autostart-warp +truedrive +cart $<

demo.prg: demo.s demo.sid
	64tass -C -a -B -i $< -o $@

.PHONY: all clean
clean:
	rm -f demo.prg

