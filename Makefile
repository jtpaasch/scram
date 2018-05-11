exe_name = scram

all: clean build docs

clean:
	rm -rf docs
	rm -rf bin
	rm -rf build
	rm -rf *~
	rm -rf *.swp
	rm -rf src/*~
	rm -rf src/*.swp

build:
	mkdir -p bin
	rm -rf build
	cp -R src build
	ocamlc -I build -c build/files.mli
	ocamlc -I build -c build/files.ml
	ocamlc -I build -c build/logs.mli
	ocamlc -I build -c build/logs.ml
	ocamlc -I build -c build/ps.mli
	ocamlc -I build -c build/ps.ml
	ocamlc -I build -c build/main.ml
	ocamlc -I build -o bin/$(exe_name) unix.cma files.cmo logs.cmo ps.cmo main.cmo

docs: build
	rm -rf docs
	mkdir -p docs
	ocamldoc -html -I build -d docs build/files.mli build/logs.mli build/ps.mli build/main.ml
