<HTML>
<HEAD>
<TITLE>User Profile</TITLE>
</HEAD>

<BODY>

	<%@ page import="proj1.*"%>
	<%@ page import="java.sql.*"%>
	<%
		String user = HtmlPrinter.getUserCookie(request.getCookies());
		if (user == null) {
			response.setHeader("Refresh", "0; URL=index.jsp");
			return;
		}

		HtmlPrinter.printHeader(out, user, null, null, null);

		SQLAdapter adapter = new SQLAdapter();
		QueryHelper helper = new QueryHelper(adapter, user);
		ResultSet rset = helper.fetchUserInfo(user);

		String firstName = "";
		String lastName = "";
		String address = "";
		String email = "";
		String phone = "";

		if (rset.next()) {
			firstName = rset.getString("first_name");
			lastName = rset.getString("last_name");
			address = rset.getString("address");
			email = rset.getString("email");
			phone = rset.getString("phone");
		}
	%>
	<FORM NAME="UpdateForm" ACTION="updateProfile.jsp" METHOD="post">
		<TABLE>
			<TR VALIGN=TOP ALIGN=LEFT>
				<TD><B><I>Password:</I></B></TD>
				<TD><INPUT TYPE="password" NAME="NEWPASSWD" VALUE=""></TD>
			</TR>
			<TR VALIGN=TOP ALIGN=LEFT>
				<TD><B><I>First Name:</I></B></TD>
				<TD><INPUT TYPE="text" NAME="FRSTNAME"
					VALUE="<%=HtmlPrinter.toAttributeString(firstName)%>"></TD>
			</TR>
			<TR VALIGN=TOP ALIGN=LEFT>
				<TD><B><I>Last Name:</I></B></TD>
				<TD><INPUT TYPE="text" NAME="LASTNAME"
					VALUE="<%=HtmlPrinter.toAttributeString(lastName)%>"></TD>
			</TR>
			<TR VALIGN=TOP ALIGN=LEFT>
				<TD><B><I>Address:</I></B></TD>
				<TD><INPUT TYPE="text" NAME="ADDRESS"
					VALUE="<%=HtmlPrinter.toAttributeString(address)%>"></TD>
			</TR>
			<TR VALIGN=TOP ALIGN=LEFT>
				<TD><B><I>Email:</I></B></TD>
				<TD><INPUT TYPE="text" NAME="EMAIL"
					VALUE="<%=HtmlPrinter.toAttributeString(email)%>"></TD>
			</TR>
			<TR VALIGN=TOP ALIGN=LEFT>
				<TD><B><I>Phone Number:</I></B></TD>
				<TD><INPUT TYPE="text" NAME="PHONENUMBER"
					VALUE="<%=HtmlPrinter.toAttributeString(phone)%>"></TD>
			</TR>
		</TABLE>

		<INPUT TYPE="submit" NAME="Update" VALUE="UPDATE">
	</FORM>
	<CENTER>
	<%
		String p_id;
		boolean done = false;

		rset = helper.fetchUserImages(user);

		if (rset != null) {
			try {
				out.println("<table>");
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
	</CENTER>
	<%
		adapter.closeConnection();
	%>
</BODY>
</HTML>

