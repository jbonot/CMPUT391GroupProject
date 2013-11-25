<%@ page import="java.net.*"%>
<%@ page import="proj1.*"%>
<%@ page import="java.sql.*"%>
<%
	String user = HtmlPrinter.getUserCookie(request.getCookies());
	if (user == null) {
		response.setHeader("Refresh", "0; URL=index.jsp");
		return;
	}

	SQLAdapter adapter = new SQLAdapter();
	QueryHelper helper = new QueryHelper(adapter, user);
	PreparedStatement stmt;
	ResultSet rset;
	String groupName = "";
	String members = "";
	String status = request.getParameter("status");
	int groupId = -1;
	Mode mode;
	String title = "";
	String readonly = "";

	// Check if we are in view/edit mode.
	String viewString = request.getParameter("view");
	if (viewString != null) {
		try {
			String prefix = "";
			groupId = Integer.parseInt(viewString);
			System.out.println("groups.java groupId: " + groupId);
			// Validate access.
			rset = helper.fetchGroupAsEditor(groupId);
			if (rset.next()) {
				// Get group info.
				groupName = rset.getString("group_name");
				rset.close();
				mode = Mode.EDIT;
				System.out.println("groups.java edit");

			} else {
				rset.close();
				rset = helper.fetchGroup(groupId);
				groupName = rset.getString("group_name");
				rset.close();
				mode = Mode.VIEW;
				System.out.println("groups.java view");
			}

			// Get string of members.
			rset = helper.fetchGroupMembers(groupId);
			while (rset.next()) {

				String member = rset.getString("friend_id");
				if (!member.equals(user)) {
					members += prefix + member;
					prefix = ", ";
				}

			}
			rset.close();
		} catch (Exception e) {
			e.printStackTrace();
			mode = Mode.ADD;
		}
	} else {
		mode = Mode.ADD;
	}

	switch (mode) {
	case EDIT:
		title = "View/Edit Group";
		break;
	case VIEW:
		title = "View Group";
		readonly = " readonly";
		break;
	default:
		title = "Add Group";
		break;
	}
%>

<TITLE><%=title%></TITLE>
<table width="100%">
	<tr>
		<td>
			<%
				HtmlPrinter.printHeader(out, user, null, null, null);
			%>
		</td>
	</tr>
	<tr>
		<td>
			<%
				if (status != null) {
					groupName = request.getParameter("group");

					if (status.equals("success")) {
						// Successful add.
						out.println("Successfully added '" + groupName + "'");
						groupName = "";

					} else if (status.equals("updated")) {
						// Successful updated.
						out.println("Successfully updated '" + groupName + "'");
						groupName = "";
					} else {
						members = request.getParameter("members");
						String invalidMembersString = request
								.getParameter("invalid_members");

						String id = request.getParameter("id");

						if (id != null) {
							try {
								// We are editing a group.
								groupId = Integer.parseInt(id);
							} catch (Exception e) {
								e.printStackTrace();
							}
						}

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
			<H3><%=title %></H3>
			<Table width="%100">
				<tr>
					<td valign="top">
						<FORM NAME="RegisterForm"
							ACTION="Groups?<%=(mode == Mode.EDIT ? "Add" : "Update=" + groupId)%>"
							METHOD="post">
							<TABLE>
								<TR VALIGN=TOP ALIGN=LEFT>
									<TD><B><I>Group Name:</I></B></TD>
									<TD><INPUT TYPE="text" NAME="GROUP"
										VALUE="<%=groupName.replaceAll("\"", "&quot;")%>" required
										style="width: 178px;" <%=readonly%>><BR></TD>
								</TR>
								<TR VALIGN=TOP ALIGN=LEFT>
									<TD><B><I>Members:</I></B></TD>
									<TD><textarea name="MEMBERS" cols="40" rows="5"
											<%=readonly%>><%=members%></textarea></TD>
								</TR>
								<%
									if (mode != Mode.VIEW) {

										out.println("<TR><TD></TD>");
										out.println("<TD align=\"right\">");
										out.println("<input type=\"submit\" name=\"SUBMIT\" value=\""
												+ (mode == Mode.EDIT ? "Add Group" : "Update Group")
												+ "\"></TD>");
										out.println("</TR>");
									}
								%>
							</TABLE>
						</FORM>
					</td>
					<td valign="top">
						<table>
							<tr>
								<td valign="top">
									<h3>Existing Members</h3> <%
 	stmt = adapter
 			.prepareStatement("select * from persons where user_name<>?");
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
							</tr>
							<tr>
								<td valign="top"><BR>
									<h3>Existing Groups</h3> <%
 	rset = adapter
 			.executeFetch("select * from groups where group_id<>1 and group_id<>2");
 	out.println("<table border=1>");
 	out.println("<tr>");
 	out.println("<th align=\"center\"\">Group Name</th>");
 	out.println("<th align=\"center\"\">Creator</th>");
 	out.println("<th align=\"center\">Date Created</th>");
 	out.println("</tr>");

 	String creator;
 	while (rset.next()) {
 		creator = rset.getString("user_name");
 		out.println("<tr>");
 		out.println("<td align=\"center\">");
 		out.println("<a href=\"/proj1/groups.jsp?view="
 				+ rset.getInt("group_id") + "\">");
 		out.println(rset.getString("group_name") + "</a></td>");
 		out.println("<td align=\"center\">" + creator + "</td>");
 		out.println("<td align=\"center\">"
 				+ rset.getDate("date_created") + "</td>");
 		out.println("</tr>");
 	}
 	out.println("</table>");

 	adapter.closeConnection();
 %></td>
							</tr>
						</table>
					</td>
				</tr>
			</Table>
		</td>
	</tr>
</table>