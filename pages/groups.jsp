<TITLE>Add Group</TITLE>
<%@ page import="java.net.*"%>
<%@ page import="proj1.*"%>
<%@ page import="java.sql.*"%>
<%

	String user = HtmlPrinter.getUserCookie(request.getCookies());
	if (user == null) {
		response.setHeader("Refresh", "0; URL=index.jsp");
		return;
	}
	
	HtmlPrinter.printHeader(out, user, null, null, null);
%>
<h3>Add Group</h3>
<BR>
<%

	String groupName = "";
	String members = "";
	String status = request.getParameter("status");

	if (status != null) {
		groupName = request.getParameter("group");

		if (status.equals("success")) {
			// Successful add.
			out.println("Successfully added '" + groupName + "'");
			groupName = "";
			
		} else {
			members = request.getParameter("members");
			String invalidMembersString = request
					.getParameter("invalid_members");

			if (status.contains("invgroup")) {
				// Invalid group name.
				out.println("'" + groupName + "' is already taken.<BR>");
			}

			if (status.contains("invmembers")) {
				// Invalid list of members.

				if (members == null && invalidMembersString == null) {
					out.println("A group needs a list of members.<BR>");
				} else if (invalidMembersString != null) {
					String[] invalidMembers = invalidMembersString
							.split(",");
					out.println("The following usernames are invalid:<BR>");
					for (int i = 0; i < invalidMembers.length; i++) {
						out.println(invalidMembers[i] + "<BR>");
					}
				}
			}
		}

		if (members != null) {
			members = members.replace(",", ", ");
		} else {
			members = "";
		}
	}
%>

<Table>
	<tr>
		<td valign="top">
			<FORM NAME="RegisterForm" ACTION="Groups" METHOD="post">
				<TABLE>
					<TR VALIGN=TOP ALIGN=LEFT>
						<TD><B><I>Group Name:</I></B></TD>
						<TD><INPUT TYPE="text" NAME="GROUP" VALUE="<%=groupName.replaceAll("\"", "&quot;")%>"
							required style="width: 178px;"><BR></TD>
					</TR>
					<TR VALIGN=TOP ALIGN=LEFT>
						<TD><B><I>Members:</I></B></TD>
						<TD><textarea name="MEMBERS" cols="40"
								rows="5"><%=members%></textarea></TD>
					</TR>
					<TR>
						<TD></TD>
						<TD align="right"><input type="submit" name="SUBMIT"
							value="Add Group"></TD>
					</TR>
				</TABLE>
			</FORM>
		</td>
	</tr>
	<tr>
		<td valign="top">
			<%
				SQLAdapter adapter = new SQLAdapter();
				ResultSet rset;
			%>
			<table>
				<tr>
					<td valign="top">
						<h3>Existing Members</h3> <%
 	PreparedStatement stmt = adapter.prepareStatement("select * from persons where user_name<>?");
	stmt.setString(1, "admin");
	rset = adapter.executeQuery(stmt);
	
 	out.println("<table border=1>");
 	out.println("<tr>");
 	out.println("<th align=\"center\" style=\"width: 178px;\">User Name</th>");
 	out.println("<th align=\"center\" style=\"width: 178px;\">Full Name</th>");
 	out.println("</tr>");
 	while (rset.next()) {
 		out.println("<tr>");
 		out.println("<td align=\"center\">"
 				+ rset.getString("user_name") + "</td>");
 		out.println("<td align=\"center\">"
 				+ rset.getString("first_name") + " "
 				+ rset.getString("last_name") + "</td>");
 		out.println("</tr>");
 	}
 	out.println("</table>");
 %>

					</td>
					<td valign="top">
						<h3>Existing Groups</h3> <%
 	rset = adapter
 			.executeFetch("select * from groups where group_id<>1 and group_id<>2");
 	out.println("<table border=1>");
 	out.println("<tr>");
 	out.println("<th align=\"center\"\">Group Name</th>");
 	out.println("<th align=\"center\"\">Creator</th>");
 	out.println("<th align=\"center\">Date Created</th>");
 	out.println("</tr>");
 	while (rset.next()) {
 		out.println("<tr>");
 		out.println("<td align=\"center\">"
 				+ rset.getString("group_name") + "</td>");
 		out.println("<td align=\"center\">"
 				+ rset.getString("user_name") + "</td>");
 		out.println("<td align=\"center\">"
 				+ rset.getDate("date_created") + "</td>");
 		out.println("</tr>");
 	}
 	out.println("</table>");

 	adapter.closeConnection();
 %>

					</td>
				</tr>
			</table>
		</td>
	</tr>
</Table>
