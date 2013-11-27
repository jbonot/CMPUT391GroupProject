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
	<blockquote>
	
	</blockquote>
	</p>
	<h3>Web Pages and Servlets</h3>
	<p>
	<blockquote>
		1. Once the SQL tables have been set up, it is now time to move onto the actual web content.
		Navigate to your <i>catalina/webapps/proj1/</i> directory, and copy all <b>.jsp</b> files from the pages folder of the project
		to this location.
		<br><br>
		2. Now go into the <i>WEB-INF/</i> folder for the server, and copy <b>web.xml</b> to this location from the project folder.
		<br><br>
		3. Next, navigate into the <i>lib/</i> directory, and copy all <b>.jar</b> files from the lib folder of the project
		to this location.
		<br><br>
		4. Then for a last copy operation, first navigate up one directory so that now you reside in the <i>WEB-INF/</i> folder
		once again. Create a new folder called <i>classes</i>, and navigate into it. Grab all files/folders from the classes folder
		of the project, and drag them to the newly created classes folder. This concludes the copying of files.
		<br><br>
		5. To make sure the website will be connecting to the right SQL database, the user must now edit the file
		<b>SQLAdapter.java</b>, located within the classes/proj1 folder. At the top of this file are four variables:
		<b>'m_url'</b>, <b>'m_driverName'</b>, <b>'m_userName'</b>, and <b>'m_password'</b>. Each one must be edited so 
		that not only is the right database is being accessed, but the right username and password are used as well. Hard code
		these values, then save the file.
		<br><br>
		6. What now must be done is the compilation process. A Makefile now exists in the <i>classes/</i> folder, which upon
		executing will compile all java files in this folder (and in subfolder <i>proj1/</i>). The user must open a terminal,
		navigate to the classes directory, and simply type <b><i>make</i></b> to compile the servlets.
		<br><br>
		The installation is now complete, and the user may now run the server with the command <b><i>starttomcat</i></b>.
	</blockquote>
	</p>
	
	<h1>Using the Modules</h1>
	<p>
		Using the actual website is pretty straight-forward, and is broken down into several different modules that are essential
		for the website to function as intended. Below is a description of each module, and how to use them.
	</p>
	<h3>User Management Module</h3>
	<p>
	<blockquote>
		
	</blockquote>
	</p>
	<h3>Security Module</h3>
	<p>
	<blockquote>
		
	</blockquote>
	</p>
	<h3>Uploading Module</h3>
	<p>
	<blockquote>
		This module is used simply to upload images to the database. It is accessed by clicking <b>Upload</b>
		at the top of the page. Here, the user can choose a file (or multiple picture files if they want), and
		set descriptive information for the picture(s) (a subject, place, date, description, and security level).
		Once all information and pictures are chosen, the user clicks upload at the bottom to save the picture(s)
		and relative information to the database. Once the operation is complete, the user will get a message indicating
		if the upload was a success, or if there was a problem.
		<br><br>
		Possible error messages: Invalid file type, Invalid date, or no pictures selected. Note that the user can upload images
		without adding descriptive info for subject, place, or description.
		<br><br>
		If the upload was a success, then the user is taken back to home page, where they can see the image. If the user wants to either
		edit the picture info, or delete the picture entirely, they can do so by clicking on the picture (Leads to display module).
	</blockquote>
	</p>
	<h3>Display Module</h3>
	<p>
	<blockquote>
		
	</blockquote>
	</p>
	<h3>Search Module</h3>
	<p>
	<blockquote>
		
	</blockquote>
	</p>
	<h3>Data Analysis Module</h3>
	<p>
	<blockquote>
		
	</blockquote>
	</p>
	
</body>
</html>