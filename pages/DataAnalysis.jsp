<%@ page import="java.sql.*" %>
<%@ page import="java.util.*"%>
<%@ page import="proj1.*"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
	<head>
	<meta http-equiv="content-type" content="text/html; charset=windows-1250">
	<title>OLAP Analysis</title>
	</head>
	<body>
	<h1>OLAP Data Analysis</h1>
	<FORM NAME="conditionsForm" ACTION="DataAnalysis.jsp" METHOD="post">
	<P>Set the analysis conditions:</P>
	  	<select name="timeselect">
	  	<option value="day">Day</option>
	  	<option value="month">Month</option>
	  	<option value="year">Year</option>
		</select><br>
		<input type="checkbox" name="gUser" value="cuser">Group by User <br>
		<input type="checkbox" name="gSubject" value="csubject">Group by Subject <br>
		<input type="checkbox" name="gDate" value="cdate">Group by Date <br>
		<INPUT TYPE="submit" NAME="Analyze" VALUE="Analyze">
	</FORM>
	<%
	//Get the parameters set in the boxes
	String gUser = 	request.getParameter("gUser");
	String gSubject = 	request.getParameter("gSubject");
	String gDate = 	request.getParameter("gDate");
	String gTime = 	request.getParameter("timeselect");
	out.println(gUser);
	%>	
		<%
		//Create a new instance of the SQL Adapter to use 	
		SQLAdapter db = new SQLAdapter();
		ResultSet rset = db.executeFetch("select owner_name, subject, timing, count(*) from images group by cube(owner_name,subject,timing)");
		
		//Print the header of the table
		out.println("<table border=1>");
		out.println("<tr>");
		out.println("<th>Owner</th>");
		out.println("<th>Subject</th>");
		out.println("<th>Date</th>");
		out.println("<th>Count</th>");
		out.println("</tr>");
		
		//Check what the current grouping is and do not show rows that do not match that grouping
		while(rset.next())
		{
			if(gUser != null){
				if ((gUser.equals("cuser")) && !(rset.getString(1) != null)){
					continue;
				}
			}
			if(gSubject != null){
				if ((gSubject.equals("csubject")) && !(rset.getString(2) != null)){
					continue;
				}
			}
			if(gDate != null){
				if ((gDate.equals("cdate")) && !(rset.getString(3) != null)){
					continue;
				}
			}
			out.println("<tr>");
			out.println("<td>"); 
			out.println(rset.getString(1));
			out.println("</td>");
			out.println("<td>"); 
			out.println(rset.getString(2)); 
			out.println("</td>");
			out.println("<td>");
			out.println(rset.getObject(3));
			out.println("</td>");
			out.println("<td>");
			out.println(rset.getObject(4));
			out.println("</td>");
			out.println("</tr>");
		} 

		out.println("</table>");
		
		db.closeConnection();
		%>
  </body>
</html>