SRCS = ./libzero.h
OBJS = $(SRCS:.h=.so)

build:
	gcc --shared $(SRCS) -o $(OBJS) && mv *.so ../build/exec/zero_app

clean :
	rm -f *.so
