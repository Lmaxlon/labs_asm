CROSS_COMPILE ?= aarch64-linux-gnu-

AS = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)ld

ASFLAGS = -g
LDFLAGS = -g -static

SRCS = main.s
OBJS = $(SRCS:.s=.o)

EXE = prog1
BASENAME = $(EXE)

clean:
	rm -rf $(EXE) $(OBJS)

$(EXE): $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o $@

.s.o:
	$(AS) $(ASFLAGS) $< -o $@

.PHONY: default
default: drop

.PHONY: drop
drop:
	$(AS) $(ASFLAGS) $(SRCS) -o $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o $(EXE)

.PHONY: rise
rise:
	$(AS) $(ASFLAGS) $(SRCS) -o $(OBJS) --defsym rev=1
	$(LD) $(LDFLAGS) $(OBJS) -o $(EXE)

