exe_name = scram
compiler = ocamlopt
libextension = cmxa
objextension = cmx
build_dir = build

all: clean $(build_dir) docs

clean:
	rm -rf docs
	rm -rf bin
	rm -rf $(build_dir)
	rm -rf *~
	rm -rf *.swp
	rm -rf src/*~
	rm -rf src/*.swp

$(build_dir):
	mkdir -p bin
	rm -rf $(build_dir)
	cp -R src $(build_dir)
	$(compiler) -I $(build_dir) -c build/tty_str.mli
	$(compiler) -I $(build_dir) -c build/tty_str.ml
	$(compiler) -I $(build_dir) -c build/tty_table.mli
	$(compiler) -I $(build_dir) -c build/tty_table.ml
	$(compiler) -I $(build_dir) -c build/logs.mli
	$(compiler) -I $(build_dir) -c build/logs.ml
	$(compiler) -I $(build_dir) -c build/ps.mli
	$(compiler) -I $(build_dir) -c build/ps.ml
	$(compiler) -I $(build_dir) -c build/matcher.mli
	$(compiler) -I $(build_dir) -c build/matcher.ml
	$(compiler) -I $(build_dir) -c build/files.mli
	$(compiler) -I $(build_dir) -c build/files.ml
	$(compiler) -I $(build_dir) -c build/file_printer.mli
	$(compiler) -I $(build_dir) -c build/file_printer.ml
	$(compiler) -I $(build_dir) -c build/execution.mli
	$(compiler) -I $(build_dir) -c build/execution.ml
	$(compiler) -I $(build_dir) -c build/success.mli
	$(compiler) -I $(build_dir) -c build/success.ml
	$(compiler) -I $(build_dir) -c build/trials.mli
	$(compiler) -I $(build_dir) -c build/trials.ml
	$(compiler) -I $(build_dir) -c build/token_type.mli
	$(compiler) -I $(build_dir) -c build/token_type.ml
	$(compiler) -I $(build_dir) -c build/token.mli
	$(compiler) -I $(build_dir) -c build/token.ml
	$(compiler) -I $(build_dir) -c build/token_printer.mli
	$(compiler) -I $(build_dir) -c build/token_printer.ml
	$(compiler) -I $(build_dir) -c build/lexer.mli
	$(compiler) -I $(build_dir) -c build/lexer.ml
	$(compiler) -I $(build_dir) -c build/node.mli
	$(compiler) -I $(build_dir) -c build/node.ml
	$(compiler) -I $(build_dir) -c build/node_printer.mli
	$(compiler) -I $(build_dir) -c build/node_printer.ml
	$(compiler) -I $(build_dir) -c build/ast.mli
	$(compiler) -I $(build_dir) -c build/ast.ml
	$(compiler) -I $(build_dir) -c build/result.mli
	$(compiler) -I $(build_dir) -c build/result.ml
	$(compiler) -I $(build_dir) -c build/result_printer.mli
	$(compiler) -I $(build_dir) -c build/result_printer.ml
	$(compiler) -I $(build_dir) -c build/eval.mli
	$(compiler) -I $(build_dir) -c build/eval.ml
	$(compiler) -I $(build_dir) -c build/printer.mli
	$(compiler) -I $(build_dir) -c build/printer.ml
	$(compiler) -I $(build_dir) -c build/main.ml
	$(compiler) -I $(build_dir) -o bin/$(exe_name) unix.$(libextension) str.$(libextension) tty_str.$(objextension) tty_table.$(objextension) logs.$(objextension) ps.$(objextension) matcher.$(objextension) files.$(objextension) file_printer.$(objextension) execution.$(objextension) trials.$(objextension) success.$(objextension) token_type.$(objextension) token.$(objextension) token_printer.$(objextension) lexer.$(objextension) node.$(objextension) node_printer.$(objextension) ast.$(objextension) result.$(objextension) result_printer.$(objextension) eval.$(objextension) printer.$(objextension) main.$(objextension)

docs: $(build_dir)
	rm -rf docs
	mkdir -p docs
	ocamldoc -html -I $(build_dir) -d docs build/tty_str.mli build/tty_table.mli build/logs.mli build/ps.mli build/matcher.mli build/files.mli build/file_printer.mli build/execution.mli build/trials.mli build/success.mli build/token_type.mli build/token.mli build/token_printer.mli build/lexer.mli build/node.mli build/node_printer.mli build/ast.mli build/result.mli build/result_printer.mli build/eval.mli build/printer.mli build/main.ml
