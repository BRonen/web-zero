SRCS = zero.c
OBJS = $(SRCS:.c=.so)

build:
	gcc -lsqlite3 -fpic -shared ./$(SRCS) -o lib$(OBJS) && mv *.so ../build/exec/zero_app

clean :
	rm -f *.so
