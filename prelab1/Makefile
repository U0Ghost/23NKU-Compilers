CFLAGS = -O0
LDFLAGS = -O0

SRC = main.c
OBJ = main.o
EXE = main
ASM = main.S
ANTI_OBJ = main-anti-obj.S
NM_OBJ = main-nm-obj.txt
ANTI_EXE = main-anti-exe.S
NM_EXE = main-nm-exe.txt

.PHONY: all lexer ast-gcc ast-llvm cfg ir-gcc ir-llvm asm obj antiobj exe antiexe clean clean-all

all: exe

lexer:
	clang -E -Xclang -dump-tokens $(SRC)

ast-gcc:
	gcc -fdump-tree-original-raw $(SRC)

ast-llvm:
	clang -E -Xclang -ast-dump $(SRC)

cfg:
	gcc $(CFLAGS) -fdump-tree-all-graph $(SRC)

ir-gcc:
	gcc $(CFLAGS) -fdump-rtl-all-graph $(SRC)

ir-llvm:
	clang -S -emit-llvm $(SRC)

asm: main.i
	gcc $(CFLAGS) -o $(ASM) -S -masm=att main.i

obj: main.S
	gcc $(CFLAGS) -c -o $(OBJ) $(ASM)

antiobj: main.o
	objdump -d $(OBJ) > $(ANTI_OBJ)
	nm $(OBJ) > $(NM_OBJ)

exe: main.o
	gcc $(LDFLAGS) -o $(EXE) $(OBJ)

antiexe: exe
	objdump -d $(EXE) > $(ANTI_EXE)
	nm $(EXE) > $(NM_EXE)

clean:

clean-all:

