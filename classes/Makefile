.PHONY: proj1

proj1 :
	javac -cp :../lib/* proj1/*.java
	jar cf ../lib/proj1.jar proj1/*.class
	javac -cp :../lib/* *.java
	rm -rf proj1/*.class
	
clean :
	rm -rf proj1/*.class
	rm -rf *.class
	rm -rf ../lib/proj1.jar
