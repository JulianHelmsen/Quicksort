a:	Main.o
	gcc -g Main.o

Main.o: Main.s
	as -g -o Main.o Main.s

clean:
	rm Main.o

