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
	String user = HtmlPrinter.getUserCookie(request.getCookies());
	if (user == null) {
		response.setHeader("Refresh", "0; URL=index.jsp");
		return;
	}

	HtmlPrinter.printHeader(out, user, null, null, null);
	SQLAdapter adapter = new SQLAdapter();
	QueryHelper helper = new QueryHelper(adapter, user);
	String firstName = helper.getFirstName();

	ResultSet rset;
	String p_id;
	boolean done = false;
%>
</head>
<body>
	<TABLE align="center">
		<TR align="center">
			<TD align="center"><H3>Top Rated</H3></TD>
		</TR>
		<TR align="center">
			<TD align="center">
				<%
					rset = helper.getTopFive();

					if (rset != null) {
						try {
							out.println("<table style=\"align:center;\">");
							while (!done) {
								out.println("<tr>");
								for (int j = 0; j < 5; j++) {

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

					rset.close();
				%>
			</TD>
		</TR>
		<TR align="center">
			<TD align="center"><H3>Explore</H3> <I>Chosen at
					random.</I></TD>
		</TR>
		<TR align="center">
			<TD align="center">
				<%
					done = false;
					// Get at most 35 public images.
					rset = helper.fetchGroupImagesRandom(1, 35);

					try {
						int row = 0;
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
				%>
			</TD>
		</TR>
	</TABLE>
	<%
		adapter.closeConnection();
	%>
</body>
</html>
