.PHONY: exprres, exproper, clean

exprres:
	bison -d expr1.y
	gcc -o exprres.out expr1.tab.c
	
exproper:
	bison -d expr2.y
	gcc -o exproper.out expr2.tab.c

clean:
	rm -fr *.out
