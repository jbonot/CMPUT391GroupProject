<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<head>
<title>User Documentation</title>
</head>
<body>

	<%@ page import="proj1.*"%>
	<%
		/* COOKIE RETRIEVAL */
	    // use a cookie to retrieve oracle database information, as well as current username.
		String user = HtmlPrinter.getUserCookie(request.getCookies());
		if (user == null) {
			response.setHeader("Refresh", "0; URL=index.jsp");
			return;
		}
		
		// Print the header.
		HtmlPrinter.printHeader(out, user, null, null, null);
	%>
	<h1>Installation</h1>
	<p>
		The following steps will show the user how to install this system, for setting up the SQL database,
		as well as putting all website files in their proper place. This installation guide already assumes that
		the catalina server is installed on the system, as well as the SQL/Oracle database (not the actual tables).
		This guide also assumes you have the project source files, all unzipped to a folder named 'project'.
	</p>
	<h3>SQL Server and Tables</h3>
	<p>
	</p>
	<h3>Web Pages and Servlets</h3>
	<p>
		Once the SQL tables have been set up, it is now time to move onto the actual web content.
		Navigate to your catalina/webapps/proj1/ directory, and copy all .jsp files from the pages folder of the project
		to this location.
		<br><br>
		Now go into the WEB-INF folder for the server, and copy web.xml to this location from the project folder.
		<br><br>
		Next, navigate into the lib/ directory, and copy all .jar files from the lib folder of the project
		to this location.
		<br><br>
		Then for a last copy operation, first navigate up one directory so that now you reside in the WEB-INF folder
		once again. Create a new folder called classes, and navigate into it. Grab all files/folders from the classes folder
		of the project, and drag them to the newly created classes folder. This concludes the copying of files.
		<br><br>
		What now must be done is the compilation process. A Makefile will exist in the classes folder, which upon
		executing will compile all java files in this folder (and in subfolder proj1). The user must open a terminal,
		navigate to the classes directory, and simply type "make" (without quotations) to compile the servlets.
	</p>
	
</body>
</html>