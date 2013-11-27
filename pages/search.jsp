<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%@ page import="proj1.*"%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Home</title>
<meta http-equiv="content-type"
	content="text/html; charset=windows-1250">
<%
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

	String user = HtmlPrinter.getUserCookie(request.getCookies());
	if (user == null) {
		response.setHeader("Refresh", "0; URL=index.jsp");
		return;
	}

	HtmlPrinter.printHeader(out, user, query, dateStart, dateEnd);
	SQLAdapter adapter = new SQLAdapter();
	QueryHelper helper = new QueryHelper(adapter, user);
	String firstName = helper.getFirstName();
	ResultSet rset;
	String p_id;
	boolean done = false;
%>
</head>
<H1>
	<CENTER>
		Welcome,
		<%=firstName == null ? user : firstName%>!
	</CENTER>
</H1>
<body>
	<TABLE align="center">
		<TR  align="center">
			<TD  align="center"><H3>Search Results</H3></TD>
		</TR>
		<TR  align="center">
			<TD  align="center">
				<%
					if (request.getParameter("SEARCH") != null
							&& (dateStart != null || dateEnd != null || query != null)) {
						rset = helper.getSearchItems(query, dateStart, dateEnd);
					} else {
						response.setHeader("Refresh", "0; URL=home.jsp");
						return;
					}

					if (rset != null) {
						try {
							out.println("<table style=\"align:center;\">");
							while (!done) {
								out.println("<tr>");
								for (int j = 0; j < 7; j++) {

									if (!rset.next()) {
										done = true;
										break;
									}

									p_id = rset.getString("photo_id");
									out.println("<td style='width:150px;height:150px;max-width:150px;max-height:150px;min-width:150px;min-height:150px;overflow:hidden;'>");
									out.println("<a href=\"/proj1/GetBigPic?big" + p_id
											+ "\">");
									out.println("<img src=\"/proj1/GetOnePic?" + p_id
											+ "\">");
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
				%>
			</TD>
		</TR>
	</TABLE>
	<%
		adapter.closeConnection();
	%>
</body>
</html>
