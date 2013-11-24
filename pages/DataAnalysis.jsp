<%@ page import="java.sql.*" %>
<%@ page import="java.util.*"%>
<%@ page import="proj1.*"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%
	String user = QueryHelper.getUserCookie(request.getCookies());
	if (user == null) {
		response.setHeader("Refresh", "0; URL=index.jsp");
		return;
	}
	
	QueryHelper.printHeader(out, user, null, null, null);
	
	//Get the username and check if they are an admin
	if (!user.equals("admin")){
		response.setHeader("Refresh", "0; URL=home.jsp");
	}
	%>
<html>
	<head>
	<meta http-equiv="content-type" content="text/html; charset=windows-1250">
	<title>OLAP Analysis</title>
	</head>
	<body>

	<h1>OLAP Data Analysis</h1>
	<FORM NAME="conditionsForm" ACTION="DataAnalysis.jsp" METHOD="post">
	<P>Set the Roll-up conditions:</P>
	  	<select NAME="timeselect">
	  	<option VALUE="none">None</option>
	  	<option VALUE="week">Week</option>
	  	<option VALUE="month">Month</option>
	  	<option VALUE="year">Year</option>
		</select><br>
		<P>Set the Drill-down conditions:</P>
		<TABLE>
		<TR VALIGN=TOP ALIGN=LEFT>
		<TD><B><I>Year (YYYY):</I></B></TD>
		<TD><INPUT TYPE="text" NAME="dYear" VALUE=""><BR></TD>
		</TR>
		<TR VALIGN=TOP ALIGN=LEFT>
		<TD><B><I>Month (01-12):</I></B></TD>
		<TD><INPUT TYPE="text" NAME="dMonth" VALUE=""></TD>
		</TR>
		<TR VALIGN=TOP ALIGN=LEFT>
		<TD><B><I>Week (1-53):</I></B></TD>
		<TD><INPUT TYPE="text" NAME="dWeek" VALUE=""></TD>
		</TR></TABLE><br>
		<!--<P>Set the grouping conditions:</P>
		<input TYPE="checkbox" NAME="gUser" VALUE="cuser">Group by User <br>
		<input TYPE="checkbox" NAME="gSubject" VALUE="csubject">Group by Subject <br>
		<input TYPE="checkbox" NAME="gDate" VALUE="cdate">Group by Date <br>-->
		<INPUT TYPE="submit" NAME="Analyze" VALUE="Analyze"><br>
	</FORM>
	<%
	//Get the parameters set in the controls
	String gUser = 	request.getParameter("gUser");
	String gSubject = 	request.getParameter("gSubject");
	String gDate = 	request.getParameter("gDate");
	String gTime = 	request.getParameter("timeselect");
	String dYear = 	request.getParameter("dYear");
	String dMonth = request.getParameter("dMonth");
	String dWeek = 	request.getParameter("dWeek");
	String rTime =  request.getParameter("timeselect");
	boolean uYear = (!(dYear != null) || dYear.isEmpty()) ? false : true;
	boolean uMonth = (!(dMonth != null) || dMonth.isEmpty()) ? false : true;
	boolean uWeek = (!(dWeek != null) || dWeek.isEmpty()) ? false : true;
	
	%>	
		<%
		//Create a new instance of the SQL Adapter to use 	
		SQLAdapter db = new SQLAdapter();
		
		//Initialize the prepared statement string
 		String prepareString = "select owner_name, subject,";
		
		//Set the proper timing value and aggregate sum value if there is a roll-up operation
 		if (rTime != null){
 			if (rTime.equals("none") || rTime.equals("null")){
 	 			prepareString = prepareString + "timing, count from sum_cube ";
 	 		}
 	 		else{
 	 			if (rTime.equals("year")){prepareString = prepareString + "year as timing, sum(count) from sum_cube ";}
 	 			if (rTime.equals("month")){prepareString = prepareString + "month as timing, sum(count) from sum_cube ";}
 	 			if (rTime.equals("week")){prepareString = prepareString + "week as timing, sum(count) from sum_cube ";}
 	 		}
 		}
 		else{
 			prepareString = prepareString + "timing, count from sum_cube ";
 		}
		
 		//Check and see if the drill-down parameters are specified
		if (uYear || uMonth || uWeek){prepareString = prepareString + "where";}
		if (uYear){
			prepareString = prepareString + " year = ? and";
		}
		if (uMonth){
			prepareString = prepareString + " month = ? and";
		}
		if (uWeek){
			prepareString = prepareString + " week = ? and";
		}
		if (prepareString.length() > 0 && prepareString.charAt(prepareString.length()-1)=='d' && prepareString.charAt(prepareString.length()-2)=='n' && prepareString.charAt(prepareString.length()-3)=='a') {
 			prepareString = prepareString.substring(0, prepareString.length()-3);
 		 }
		
		//Check the Roll-up level and set the proper groupings
		if (rTime != null){
 			if (rTime.equals("none") || rTime.equals("null")){

 	 		}
 	 		else{
 	 			if (rTime.equals("year")){prepareString = prepareString + "group by owner_name, subject, year order by owner_name";}
 	 			if (rTime.equals("month")){prepareString = prepareString + "group by owner_name, subject, month order by owner_name ";}
 	 			if (rTime.equals("week")){prepareString = prepareString + "group by owner_name, subject, week order by owner_name";}
 	 		}
 		}
		//out.println(prepareString + "<br>");
		
		//Set the prepared statement values for drill-down
		PreparedStatement olap = db.prepareStatement(prepareString);
		Integer count = 1;
		if (uYear){
			olap.setString(count,dYear);
			out.println("Year =" + dYear + "<br>");
 			count++;
		}
		if (uMonth){
			olap.setString(count,dMonth);
			out.println("Month =" + dMonth + "<br>");
 			count++;
		}
		if (uWeek){
			olap.setString(count,dWeek);
			out.println("Week =" + dWeek + "<br>");
			count++;
		}
		ResultSet rset = db.executeQuery(olap);
		
		//Print the header of the table
		out.println("<table border=1>");
		out.println("<tr>");
		out.println("<th>Owner</th>");
		out.println("<th>Subject</th>");
		out.println("<th>Date</th>");
		out.println("<th>Count</th>");
		out.println("</tr>");
		
		//Print out the result table
		while(rset.next())
		{
			//DO NOT BELIEVE THIS IS VALID ANYMORE, LEAVE IN CASE WE NEED TO RESTORE
// 			if(gUser != null){
// 				if ((gUser.equals("cuser")) && !(rset.getString(1) != null)){
// 					continue;
// 				}
// 			}
// 			if(gSubject != null){
// 				if ((gSubject.equals("csubject")) && !(rset.getString(2) != null)){
// 					continue;
// 				}
// 			}
// 			if(gDate != null){
// 				if ((gDate.equals("cdate")) && !(rset.getString(3) != null)){
// 					continue;
// 				}
// 			}
			out.println("<tr>");
			out.println("<td>"); 
			if (rset.getString(1) != null){
				out.println(rset.getString(1));
			}else{
				out.println("Any User");
			}
			out.println("</td>");
			out.println("<td>"); 
			if (rset.getString(2) != null){
				out.println(rset.getString(2));
			}else{
				out.println("Any Subject");
			}
			out.println("</td>");
			out.println("<td>");
			if (rset.getString(3) != null){
				out.println(rset.getString(3));
			}else{
				out.println("Any Date");
			}
			out.println("</td>");
			out.println("<td>");
			out.println(rset.getString(4));
			out.println("</td>");
			out.println("</tr>");
		} 

		out.println("</table>");
		
		//Close the prepared statement and the connection
		olap.close();	
		db.closeConnection();
		%>
  </body>
</html>