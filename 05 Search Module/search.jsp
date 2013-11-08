<%@ page import="java.sql.*" %>
<%@ page import="java.util.*"%>
<%@ page import="proj1.*"%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%
		String dateFormat = "yyyy-mm-dd";
		StringBuilder queryString = new StringBuilder("SELECT subject, place, description, timing FROM images ");
		java.sql.Date dateStart = null;
		java.sql.Date dateEnd = null;
		String query = request.getParameter("query");

		try {
			dateStart = java.sql.Date.valueOf(request.getParameter("DATE_START"));
			Calendar c = Calendar.getInstance();
			c.setTime(dateStart);
			c.set(Calendar.HOUR_OF_DAY, 0);
			c.set(Calendar.MINUTE, 0);
			c.set(Calendar.SECOND, 0);
			c.set(Calendar.MILLISECOND, 0);
			dateStart = new java.sql.Date(c.getTimeInMillis());
		} catch (IllegalArgumentException e) {
		}

		try {
			dateEnd = java.sql.Date.valueOf(request.getParameter("DATE_END"));
			Calendar c = Calendar.getInstance();
			c.setTime(dateEnd);
			c.set(Calendar.HOUR_OF_DAY, 23);
			c.set(Calendar.MINUTE, 59);
			c.set(Calendar.SECOND, 59);
			c.set(Calendar.MILLISECOND, 999);
			dateEnd = new java.sql.Date(c.getTimeInMillis());
			out.println(new java.util.Date(c.getTimeInMillis()));
		} catch (IllegalArgumentException e) {
			out.println(e.getMessage());
		}

		query = query == null || query.equals("") ? null : query;
%>
<html>
	<head>
	<meta http-equiv="content-type" content="text/html; charset=windows-1250">
	<title>Search Results</title>
	</head>
	<H1><CENTER>Search</CENTER></H1>
  <body>
	<FORM NAME="SearchForm" ACTION="search.jsp" METHOD="post" >
		<P>Search for images.</P>
		<TABLE>
		<TR VALIGN=TOP ALIGN=LEFT>
		<TD><B><I>Keywords:</I></B></TD>
		<TD><INPUT TYPE="text" NAME="query" value="<%=query != null ? query : new String()%>"><BR></TD>
		</TR>
		<TR VALIGN=TOP ALIGN=LEFT>
		<TD><B><I>Time Periods:</I></B></TD>
		<TD><I>From:</I><INPUT TYPE="date" NAME="DATE_START" value="<%=dateStart != null ? dateStart : dateFormat%>"></TD>
		<TD><I>To:</I><INPUT TYPE="date" NAME="DATE_END" value="<%=dateEnd != null ? dateEnd : dateFormat%>"></TD>
		</TR>
		</TABLE>

		<INPUT TYPE="submit" NAME="SEARCH" VALUE="Search">
	</FORM>

	<br>
    
    <%

	SQLAdapter adapter = new SQLAdapter("", "");
	String addItemError = "";

	String selectString = "select subject, place, description from images";
	ResultSet rset = adapter.executeFetch(selectString);

	if (rset == null)
	{
		out.println("Need to run setup.sql<br>");
	}
	else
	{

		out.println("<table border=1>");
		out.println("<tr>");
		out.println("<th>Subject</th>");
		out.println("<th>Place</th>");
		out.println("<th>Description</th>");
		out.println("</tr>"); 

		while(rset.next()) { 
			out.println("<tr>");
			out.println("<td>"); 
			out.println(rset.getString(1));
			out.println("</td>");
			out.println("<td>"); 
			out.println(rset.getString(2)); 
			out.println("</td>");
			out.println("<td>"); 
			out.println(rset.getString(3)); 
			out.println("</td>");
			out.println("</tr>"); 
		}

		out.println("</table>"); 
	}
      
    %>
    
    <br>
    <b><%=addItemError%></b><br>
	<%
	if (request.getParameter("SEARCH") != null)
	{

		boolean firstCondition = true;

		out.println("<br>");
		out.println("Query is \"" + request.getParameter("query") + "\"");
		out.println("<br>");
          
		if (dateStart != null)
		{
			queryString.append("where timing >= ? ");
			firstCondition = false;
		}
          
		if (dateEnd != null)
		{
			queryString.append(firstCondition ? "where " : "and ");
			queryString.append("timing <= ? ");
			firstCondition = false;
		}

		if(query != null)
		{
			queryString.append(firstCondition ? "where " : "and ");
			queryString.append("(contains(subject, ?, 6) > 0 or contains(place, ?, 3) > 0 or contains(description, ?, 1) > 0) order by score(6) * 6 + score(3) * 3 + score(1) desc");
			firstCondition = false;
		}
		else
		{
			out.println("<br><b>Please enter text for quering</b>");
			queryString.append("order by timing desc");
		}

		if (!firstCondition)
		{
			PreparedStatement doSearch = adapter.prepareStatement(queryString.toString());	
		
			int i = 1;
		
			if (dateStart != null)
			{
				doSearch.setDate(i++, dateStart);
			}

			if (dateEnd != null)
			{
				doSearch.setDate(i++, dateEnd);
			}

			if (query != null)
			{
				doSearch.setString(i++, query);
				doSearch.setString(i++, query);
				doSearch.setString(i++, query);
			}

			ResultSet rset2 = adapter.executeQuery(doSearch);
	
			out.println("<table border=1>");
			out.println("<tr>");
			out.println("<th>Subject</th>");
			out.println("<th>Place</th>");
			out.println("<th>Description</th>");
			out.println("<th>Date</th>");
			out.println("</tr>");
	
			while(rset2.next())
			{
				out.println("<tr>");
				out.println("<td>"); 
				out.println(rset2.getString(1));
				out.println("</td>");
				out.println("<td>"); 
				out.println(rset2.getString(2)); 
				out.println("</td>");
				out.println("<td>");
				out.println(rset2.getObject(3));
				out.println("</td>");
				out.println("<td>");
				out.println(rset2.getObject(4));
				out.println("</td>");
				out.println("</tr>");
			} 

			out.println("</table>");
			out.println("<br><b>" + queryString + "</b>");
   		}
	}

	adapter.closeConnection();
	%>
  </body>
</html>
