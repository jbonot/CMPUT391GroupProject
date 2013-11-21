OBJECTS = GetBigPic.java GetOnePic.java PictureBrowse.java SQLAdapter.java
LIBRARY = proj1/SQLAdapter.class proj1/QueryHelper.class

proj1 : $(LIBRARY)
	jar cf ../lib/proj1.jar proj1/*.class

%.class : %.java
	javac $^
	
clean :
	rm -rf *.class
	rm -rf proj1/*.class
	rm -rf ../lib/proj1.jar
