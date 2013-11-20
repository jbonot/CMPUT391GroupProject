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

	// Select photos the user has access to.
	StringBuilder queryString = new StringBuilder(
			"SELECT photo_id, thumbnail, subject, place, description, timing "
					+ "FROM images, group_lists "
					+ "where ((permitted=2 and owner_name='" + user
					+ "') or (group_id=permitted and friend_id='"
					+ user + "')) ");

	java.sql.Date dateStart = null;
	java.sql.Date dateEnd = null;
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
<title>Search Results</title>
</head>
<H1>
	<CENTER>Search</CENTER>
</H1>
<body>
	<FORM NAME="SearchForm" ACTION="home.jsp" METHOD="post">
		<P>Search for images.</P>
		<TABLE>
			<TR VALIGN=TOP ALIGN=LEFT>
				<TD><B><I>Keywords:</I></B></TD>
				<TD><INPUT TYPE="text" NAME="query"
					value="<%=query != null ? query : new String()%>"><BR></TD>
			</TR>
			<TR VALIGN=TOP ALIGN=LEFT>
				<TD><B><I>Time Periods:</I></B></TD>
				<TD><I>From:</I><INPUT TYPE="date" NAME="DATE_START"
					value="<%=dateStart != null ? dateStart : dateFormat%>"></TD>
				<TD><I>To:</I><INPUT TYPE="date" NAME="DATE_END"
					value="<%=dateEnd != null ? dateEnd : dateFormat%>"></TD>
			</TR>
		</TABLE>

		<INPUT TYPE="submit" NAME="SEARCH" VALUE="Search">
	</FORM>

	<br>
	<%
		SQLAdapter adapter = new SQLAdapter(username, password);
		ResultSet rset = null;
		out.println("<a href=\"/proj1/DataAnalysis.jsp\">Analysis</a><br>");

		rset = adapter
				.executeFetch("select group_id, friend_id from group_lists");
		int count = 0;
		while (rset.next()) {
			out.println(rset.getInt("group_id") + "\t"
					+ rset.getString("friend_id") + "<br>");
			count++;
		}
		out.println("found " + count + " rows in group_lists");

		PreparedStatement doSearch;
		if (request.getParameter("SEARCH") != null
				&& (dateStart != null || dateEnd != null || query != null)) {

			out.println("<br>");

			if (dateStart != null) {
				queryString.append("and timing >= ? ");
			}

			if (dateEnd != null) {
				queryString.append("and timing <= ? ");
			}

			if (query != null) {
				queryString.append("and (contains(subject, ?, 6) > 0 ");
				queryString.append("or contains(place, ?, 3) > 0 ");
				queryString.append("or contains(description, ?, 1) > 0) ");
				queryString
						.append("order by score(6) * 6 + score(3) * 3 + score(1) desc");
			} else {
				queryString.append("order by timing desc");
			}

			doSearch = adapter.prepareStatement(queryString.toString());

			int i = 1;

			if (dateStart != null) {
				doSearch.setDate(i++, dateStart);
			}

			if (dateEnd != null) {
				doSearch.setDate(i++, dateEnd);
			}

			if (query != null) {
				doSearch.setString(i++, query);
				doSearch.setString(i++, query);
				doSearch.setString(i++, query);
			}
		} else {
			doSearch = adapter.prepareStatement(queryString.toString());
		}
		rset = adapter.executeQuery(doSearch);

		out.println("<table border=1>");
		String p_id;
		boolean done = false;
		while (!done) {
			out.println("<tr>");
			for (int j = 0; j < 4; j++) {
				if (!rset.next()) {
					done = true;
					break;
				}
				p_id = rset.getString("photo_id");
				out.println("<td>");
				out.println("<a href=\"/proj1/GetBigPic?big" + p_id + "\">");
				out.println("<img src=\"/proj1/GetOnePic?" + p_id + "\">");
				out.println(rset.getString("subject"));
				out.println("<br>");
				out.println(rset.getString("place"));
				out.println("<br>");
				out.println(rset.getString("timing"));
				out.println("</a>");
				out.println("</td>");
			}
			out.println("</tr>");
		}

		out.println("</table>");
		out.println("<br><b>" + queryString + "</b>");

		adapter.closeConnection();
	%>
</body>
</html>
