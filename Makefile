run:
	idris2 --build zero.ipkg && ./build/exec/zero && rm -r build

tests:
	gcc -lsqlite3 -O3 -g test/tests.c -o tests && gdb ./tests && rm tests

build:
	idris2 --build zero.ipkg

clean:
	rm -r build