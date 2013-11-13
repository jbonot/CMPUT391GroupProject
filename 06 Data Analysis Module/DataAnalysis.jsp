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
	<form>
	<P>Set the analysis conditions:</P>
	  	<select>
	  	<option value="day">Day</option>
	  	<option value="month">Month</option>
	  	<option value="year">Year</option>
		</select><br>
		<input type="checkbox" name="gUser" value="cuser">Group by User <br>
		<input type="checkbox" name="gSubject" value="csubject">Group by Subject <br>
		<input type="checkbox" name="gDate" value="cdate">Group by Date <br>
	</form>
	<%
	String cookieUsername = "OracleUsername";
		String cookiePassword = "OraclePassword";
		Cookie cookies [] = request.getCookies ();
		Cookie OracleUsernameCookie = null;
		Cookie OraclePasswordCookie = null;
		if (cookies != null){
			for (int i = 0; i < cookies.length; i++) {
				if (cookies [i].getName().equals (cookieUsername)){
					OracleUsernameCookie = cookies[i];
				break;
				}
			}
		}
		if (cookies != null){
			for (int i = 0; i < cookies.length; i++) {
				if (cookies [i].getName().equals (cookiePassword)){
					OraclePasswordCookie = cookies[i];
				break;
				}
			}
		}%>
		
		<%
		String username = "jukna";//OracleUsernameCookie.getValue();//Need to get username and password from cookie and/or input
		String password = "math30pure";//OraclePasswordCookie.getValue();//**************
		SQLAdapter db = new SQLAdapter(username, password);//Create a new instance of the SQL Adapter to use 	
		
		ResultSet rset = db.executeFetch("select owner_name, subject, timing, count(*) from images group by cube(owner_name,subject,timing)");
		
		out.println("<table border=1>");
		out.println("<tr>");
		out.println("<th>Owner</th>");
		out.println("<th>Subject</th>");
		out.println("<th>Date</th>");
		out.println("<th>Count</th>");
		out.println("</tr>");
	
		while(rset.next())
		{
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