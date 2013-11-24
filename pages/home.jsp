<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%@ page import="proj1.*"%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%
	Cookie cookies[] = request.getCookies();
	Cookie UserCookie = null;
	if (cookies != null) {
		for (int i = 0; i < cookies.length; i++) {
			if (cookies[i].getName().equals("User")) {
				UserCookie = cookies[i];
				break;
			}
		}
	}

	if (UserCookie == null || UserCookie.getMaxAge() == 0) {
		response.setHeader("Refresh", "0; URL=index.jsp");
	return;
	}

	String user = UserCookie.getValue();
	String dateFormat = "yyyy-mm-dd";
	String query = request.getParameter("query");

	java.sql.Date dateStart = null;
	java.sql.Date dateEnd = null;

	// Validate Start Date
	try {
		dateStart = java.sql.Date.valueOf(request
				.getParameter("DATE_START"));
		Calendar c = Calendar.getInstance();
		c.setTime(dateStart);
		c.set(Calendar.HOUR_OF_DAY, 0);
		c.set(Calendar.MINUTE, 0);
		c.set(Calendar.SECOND, 0);
		c.set(Calendar.MILLISECOND, 0);
		dateStart = new java.sql.Date(c.getTimeInMillis());
	} catch (IllegalArgumentException e) {
	}

	// Validate End Date
	try {
		dateEnd = java.sql.Date.valueOf(request
				.getParameter("DATE_END"));
		Calendar c = Calendar.getInstance();
		c.setTime(dateEnd);
		c.set(Calendar.HOUR_OF_DAY, 23);
		c.set(Calendar.MINUTE, 59);
		c.set(Calendar.SECOND, 59);
		c.set(Calendar.MILLISECOND, 999);
		dateEnd = new java.sql.Date(c.getTimeInMillis());
	} catch (IllegalArgumentException e) {
	}

	query = query == null || query.equals("") ? null : query;
	SQLAdapter adapter = new SQLAdapter();
	QueryHelper helper = new QueryHelper(adapter, user);
	String firstName = helper.getFirstName();
%>
<html>
<head>
<meta http-equiv="content-type"
	content="text/html; charset=windows-1250">
<title>Home</title>
</head>
<table border=1>
	<tr>
		<td><input type="button" value="Home"
			onClick="javascript:window.location='home.jsp';"></td>
		<td><input type="button" value="Profile"
			onClick="javascript:window.location='userProfile.html';"></td>
		<td><input type="button" value="Upload"
			onClick="javascript:window.location='upload_image.jsp';"></td>
		<td><input type="button" value="Groups"
			onClick="javascript:window.location='groups.jsp';"></td>
		<%
			if (user.equals("admin"))
			{
				out.println("<td><input type=\"button\" value=\"Analysis\"onClick=\"javascript:window.location='DataAnalysis.jsp';\"></td>");
			}
		%>

		<td><input type="button" value="Logout"
			onClick="javascript:window.location='logout.jsp';"></td>
	</tr>
</table>
<H1>
	<CENTER>
		Welcome,
		<%=firstName%>!
	</CENTER>
</H1>
<body>
	<FORM NAME="SearchForm" ACTION="home.jsp" METHOD="get">
		<TABLE border=1>
			<TR VALIGN=TOP ALIGN=LEFT>
				<TD><I>Search:</I></TD>
				<TD><INPUT TYPE="text" NAME="query"
					value="<%=query != null ? query : new String()%>"><BR></TD>
				<TD><I>From:</I><INPUT TYPE="date" NAME="DATE_START"
					value="<%=dateStart != null ? dateStart : dateFormat%>"></TD>
				<TD><I>To:</I><INPUT TYPE="date" NAME="DATE_END"
					value="<%=dateEnd != null ? dateEnd : dateFormat%>"></TD>
				<TD><INPUT TYPE="submit" NAME="SEARCH" VALUE="Search"></TD>
			</TR>
		</TABLE>
	</FORM>
	<br>
	<%
		ResultSet rset = null;
		String p_id;
		boolean done = false;

		if (request.getParameter("SEARCH") != null
				&& (dateStart != null || dateEnd != null || query != null)) {
			rset = helper.getSearchItems(query, dateStart, dateEnd);
		} else {
			rset = helper.getHomeItems();
		}

		if (rset != null) {
			try {
				out.println("<table border=1>");
				while (!done) {
					out.println("<tr>");
					for (int j = 0; j < 4; j++) {
						if (!rset.next()) {
							done = true;
							break;
						}
						p_id = rset.getString("photo_id");
						out.println("<td>");
						out.println("<a href=\"/proj1/GetBigPic?big" + p_id
								+ "\">");
						out.println("<img src=\"/proj1/GetOnePic?" + p_id
								+ "\">");
						out.println(rset.getString("subject"));
						out.println("</a>");
						out.println("</td>");
					}
					out.println("</tr>");
				}

				out.println("</table>");
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}

		adapter.closeConnection();
	%>
</body>
</html>
