SRCS = ./zero.h
OBJS = $(SRCS:.h=.so)

build:
	gcc --shared $(SRCS) -o $(OBJS) && cp *.so ../build/exec/zero_app

clean :
	rm -f *.so
