run:
	idris2 --build zero.ipkg && ./build/exec/zero && rm -r build

tests:
	gcc -lsqlite3 test/tests.c -o tests && ./tests && rm tests

build:
	idris2 --build zero.ipkg

clean:
	rm -r build