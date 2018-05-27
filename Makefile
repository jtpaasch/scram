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
	ocamlc -I build -c build/tty_str.mli
	ocamlc -I build -c build/tty_str.ml
	ocamlc -I build -c build/tty_table.mli
	ocamlc -I build -c build/tty_table.ml
	ocamlc -I build -c build/logs.mli
	ocamlc -I build -c build/logs.ml
	ocamlc -I build -c build/ps.mli
	ocamlc -I build -c build/ps.ml
	ocamlc -I build -c build/matcher.mli
	ocamlc -I build -c build/matcher.ml
	ocamlc -I build -c build/execution.mli
	ocamlc -I build -c build/execution.ml
	ocamlc -I build -c build/success.mli
	ocamlc -I build -c build/success.ml
	ocamlc -I build -c build/trials.mli
	ocamlc -I build -c build/trials.ml
	ocamlc -I build -c build/token_type.mli
	ocamlc -I build -c build/token_type.ml
	ocamlc -I build -c build/token.mli
	ocamlc -I build -c build/token.ml
	ocamlc -I build -c build/lexer.mli
	ocamlc -I build -c build/lexer.ml
	ocamlc -I build -c build/node.mli
	ocamlc -I build -c build/node.ml
	ocamlc -I build -c build/ast.mli
	ocamlc -I build -c build/ast.ml
	ocamlc -I build -c build/result.mli
	ocamlc -I build -c build/result.ml
	ocamlc -I build -c build/eval.mli
	ocamlc -I build -c build/eval.ml
	ocamlc -I build -c build/printer.mli
	ocamlc -I build -c build/printer.ml
	ocamlc -I build -c build/main.ml
	ocamlc -I build -o bin/$(exe_name) unix.cma str.cma files.cmo tty_str.cmo tty_table.cmo logs.cmo ps.cmo matcher.cmo execution.cmo trials.cmo success.cmo token_type.cmo token.cmo lexer.cmo node.cmo ast.cmo result.cmo eval.cmo printer.cmo main.cmo

docs: build
	rm -rf docs
	mkdir -p docs
	ocamldoc -html -I build -d docs build/files.mli build/tty_str.mli build/tty_table.mli build/logs.mli build/ps.mli build/matcher.mli build/execution.mli build/trials.mli build/success.mli build/token_type.mli build/token.mli build/lexer.mli build/node.mli build/ast.mli build/result.mli build/eval.mli build/printer.mli build/main.ml
