<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%@ page import="proj1.*"%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%
	String cookieUsername = "OracleUsername";
	String cookiePassword = "OraclePassword";
	Cookie cookies[] = request.getCookies();
	Cookie OracleUsernameCookie = null;
	Cookie OraclePasswordCookie = null;
	if (cookies != null) {
		for (int i = 0; i < cookies.length; i++) {
			if (cookies[i].getName().equals(cookieUsername)) {
				OracleUsernameCookie = cookies[i];
				break;
			}
		}
	}
	if (cookies != null) {
		for (int i = 0; i < cookies.length; i++) {
			if (cookies[i].getName().equals(cookiePassword)) {
				OraclePasswordCookie = cookies[i];
				break;
			}
		}
	}

	String username = OracleUsernameCookie.getValue();
	String password = OraclePasswordCookie.getValue();

	String user = "matwood";
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
%>
<html>
<head>
<meta http-equiv="content-type"
	content="text/html; charset=windows-1250">
<title>Home</title>
</head>
<H1>
	<CENTER>Home</CENTER>
</H1>
<body>
	<FORM NAME="SearchForm" ACTION="home.jsp" METHOD="post">
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
	<table border=1>
		<tr>
			<td><input type="button" value="Analysis"
				onClick="javascript:window.location='DataAnalysis.jsp';"></td>
			<td><input type="button" value="Upload"
				onClick="javascript:window.location='upload_image.html';"></td>
		</tr>
	</table>
	<br>
	<%
		SQLAdapter adapter = new SQLAdapter(username, password);
		QueryHelper helper = new QueryHelper(adapter, user);
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