run:
	idris2 --build zero.ipkg && ./build/exec/zero && rm -r build

build:
	idris2 --build zero.ipkg

clean:
	rm -r build