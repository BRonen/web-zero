SRCS = ./c_utils.c
OBJS = $(SRCS:.c=.so)

build:
	gcc --shared $(SRCS) -o $(OBJS)

clean :
	rm -f *.so
