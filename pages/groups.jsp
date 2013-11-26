<%@ page import="java.net.*"%>
<%@ page import="proj1.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.sql.Date"%>
<%@ page import="java.util.*"%>
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
	String status = request.getParameter("status");
	int groupId = -1;
	Mode mode = Mode.ADD;
	String title = "";
	String readonly = "";
	String groupCreator = user;
	Date date = null;

	List<String> members = new ArrayList<String>();

	// Check if we are in view/edit mode.
	String viewString = request.getParameter("view");
	if (viewString != null) {
		try {
			String prefix = "";
			groupId = Integer.parseInt(viewString);
			// Validate access.
			rset = helper.fetchGroupAsEditor(groupId);
			if (rset.next()) {
				// Get group info.
				groupName = rset.getString("group_name");
				groupCreator = rset.getString("user_name");
				date = rset.getDate("date_created");
				rset.close();
				mode = Mode.EDIT;

			} else {
				rset.close();
				rset = helper.fetchGroup(groupId);
				if (rset.next()) {
					groupName = rset.getString("group_name");
					groupCreator = rset.getString("user_name");
					date = rset.getDate("date_created");
					rset.close();
					mode = Mode.VIEW;
				}
			}

			// Get list of members.
			rset = helper.fetchGroupMembers(groupId);
			while (rset.next()) {
				String member = rset.getString("friend_id");
				members.add(member);
			}
			rset.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
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
		date = new Date(Calendar.getInstance().getTimeInMillis());
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
		<td><input type="button" name="create" value="Create a New Group"
			onClick="javascript:window.location='groups.jsp';" /><BR> <%
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

 				if (members == null) {
 					out.println("A group needs a list of members.<BR>");
 				}
 			}
 		}
 	}
 %>
			<Table width="%100">
				<tr>
					<td valign="top" style="padding: 0px 100px 0px 0px;">
						<FORM NAME="GroupForm"
							ACTION="Groups?<%=(mode == Mode.EDIT ? "Add" : "Update=" + groupId)%>"
							METHOD="post">
							<H3><%=title%></H3>
							<TABLE>
								<TR VALIGN=TOP ALIGN=LEFT>
									<TD><B><I>Group Name:</I></B></TD>
									<TD><INPUT TYPE="text" NAME="GROUP"
										VALUE="<%=HtmlPrinter.toAttributeString(groupName)%>" required
										style="width: 178px;" <%=readonly%>></TD>
								</TR>
								<TR VALIGN=TOP ALIGN=LEFT>
									<TD><B><I>Created by:</I></B></TD>
									<TD><INPUT TYPE="text" NAME="GROUP"
										VALUE="<%=HtmlPrinter.toAttributeString(groupCreator)%>"
										required style="width: 178px;" readonly></TD>
								</TR>
								<TR VALIGN=TOP ALIGN=LEFT>
									<TD><B><I>Date:</I></B></TD>
									<TD><INPUT TYPE="text" NAME="GROUP" VALUE="<%=date%>"
										required style="width: 178px;" readonly></TD>
								</TR>
								<TR VALIGN=TOP ALIGN=LEFT>
									<TD><B><I>Members:</I></B></TD>
									<TD>
										<%
											stmt = adapter
													.prepareStatement("select * from persons where user_name<>?");
											stmt.setString(1, "admin");
											rset = adapter.executeQuery(stmt);
										%>
										<table border=1 style="width: 100%;">
											<tr>
												<th></th>
												<th align="center" style="width: 178px;">User Name</th>
												<th align="center" style="width: 178px;">Full Name</th>
											</tr>
											<%
												while (rset.next()) {
													String username = rset.getString("user_name");
													boolean isCreator = username.equals(user);
													boolean isMember = members.contains(username);
													String checkboxReadonly = (!readonly.isEmpty() || isCreator) ? " onClick=\"return false\""
															: "";
													String checked = isMember || (members.isEmpty() && isCreator) ? " checked=\"checked\""
															: "";

													out.println("<tr>");
													out.println("<td align=\"center\">");
													out.println("<input type=\"checkbox\" name=\"GROUPMEMBERS\" value=\""
															+ HtmlPrinter.toAttributeString(username)
															+ "\""
															+ checkboxReadonly + checked + "/></td>");
													out.println("<td align=\"center\">" + username + "</td>");
													out.println("<td align=\"center\">"
															+ rset.getString("first_name") + " "
															+ rset.getString("last_name") + "</td>");
													out.println("</tr>");
												}
											%>
										</table>
									</TD>
								</TR>
								<%
									if (mode != Mode.VIEW) {

										out.println("<TR><TD></TD>");
										out.println("<TD align=\"right\">");
										out.println("<input type=\"submit\" name=\"SUBMIT\" value=\""
												+ (mode == Mode.ADD ? "Add Group" : "Update Group")
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
 %>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</Table></td>
	</tr>
</table>