OBJECTS = GetBigPic.java GetOnePic.java PictureBrowse.java SQLAdapter.java
PACKAGE = proj1
LIBRARY = $(PACKAGE)/SQLAdapter.class

proj1 : $(LIBRARY)
	jar cf ../lib/proj1.jar $(PACKAGE)/*.class

display : GetBigPic.java GetOnePic.java PictureBrowse.java
	javac $^

$(PACKAGE)/%.class : $(PACKAGE)/%.java
	javac $^
	
clean :
	rm -rf *.class
	rm -rf $(PACKAGE)/*.class
