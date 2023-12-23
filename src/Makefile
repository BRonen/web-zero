SRCS = ./zero.h
OBJS = $(SRCS:.h=.so)

build:
	gcc --shared $(SRCS) -o $(OBJS)

clean :
	rm -f *.so
