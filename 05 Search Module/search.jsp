<%@ page import="java.sql.*" %>
<%@ page import="java.util.*"%>
<%@ page import="proj1.*"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
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
		<TD><INPUT TYPE="text" NAME="query"><BR></TD>
		</TR>
		<TR VALIGN=TOP ALIGN=LEFT>
		<TD><B><I>Time Periods:</I></B></TD>
		<TD><I>From:</I><INPUT TYPE="date" NAME="DATE_START"></TD>
		<TD><I>To:</I><INPUT TYPE="date" NAME="DATE_END"></TD>
		</TR>
		</TABLE>

		<INPUT TYPE="submit" NAME="SEARCH" VALUE="SEARCH">
	</FORM>

	<p>Structure of Photos Table<br> 
	<table border=1>
		<tr>
			<th>photo_id</th>
			<th>owner_name</th>
			<th>subject</th>
			<th>place</th>
			<th>when</th>
			<th>description</th>
			<th>thumbnail</th>
			<th>photo</th>
		</tr>
	</table>

	<br>
    
    <%
	
	SQLAdapter adapter = new SQLAdapter("username", "password");
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
    <form name=SearchData method=post action=search.jsp> 
    
      Query the database to see relevant items
      <table>
        <tr>
          <td>
            <input type=text name=query>
          </td>
          <td>
            <input type=submit value="Search" name="SEARCH">
          </td>
        </tr>
      </table>
	<%
        
	if (request.getParameter("SEARCH") != null)
	{
          
		out.println("<br>");
		out.println("Query is \"" + request.getParameter("query") + "\"");
		out.println("<br>");
          
		if(!(request.getParameter("query").equals("")))
		{
			String query = request.getParameter("query");
			PreparedStatement doSearch = adapter.prepareStatement("SELECT subject, place, description FROM images WHERE contains(subject, ?, 6) > 0 or contains(place, ?, 3) > 0  or contains(description, ?, 1) > 0 order by score(6) desc, score(3) desc, score(1) desc");	

			doSearch.setString(1, query);
			doSearch.setString(2, query);
			doSearch.setString(3, query);
			ResultSet rset2 = adapter.executeQuery(doSearch);
		
			out.println("<table border=1>");
			out.println("<tr>");
			out.println("<th>Subject</th>");
			out.println("<th>Place</th>");
			out.println("<th>Description</th>");
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
				out.println("</tr>");
			} 

			out.println("</table>");
		}
		else
		{
			out.println("<br><b>Please enter text for quering</b>");
		}            
	}
	else
	{
		out.println("<br>");
		out.println("SEARCH parameter not found.");
		out.println("<br>");
	}
	%>
    </form>
  </body>
</html>
