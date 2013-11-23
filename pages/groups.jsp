<TITLE>Add Group</TITLE>
<h3>Add Group</h3>
<%@ page import="java.net.*"%>
<%@ page import="proj1.*"%>
<%@ page import="java.sql.*"%>
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

	if (UserCookie == null) {
%>
<jsp:forward page="index.html" />
<%
	return;
	}

	String message = request.getQueryString();
	String groupName = "";
	if (message != null) {
		if (message.startsWith("invalid_group")) {
			out.println("Group Name Taken");
			groupName = message.substring("invalid_group".length() + 1);
			groupName = URLDecoder.decode(groupName, "UTF-8");
		} else if (message.startsWith("invalid_members")) {
			out.println("Invalid list of members");
			groupName = message
					.substring("invalid_members".length() + 1);
			groupName = URLDecoder.decode(groupName, "UTF-8");
		} else if (message.startsWith("success")) {
			out.println("Invalid list of members");
			groupName = message.substring("success".length() + 1);
			groupName = URLDecoder.decode(groupName, "UTF-8");
		}
	}
%>
<FORM NAME="RegisterForm" ACTION="Groups" METHOD="post">
	<TABLE>
		<TR VALIGN=TOP ALIGN=LEFT>
			<TD><B><I>Group Name:</I></B></TD>
			<TD><INPUT TYPE="text" NAME="GROUP" VALUE="<%=groupName%>"
				required style="width: 178px;"><BR></TD>
		</TR>
		<TR VALIGN=TOP ALIGN=LEFT>
			<TD><B><I>Members:</I></B></TD>
			<TD><textarea name="MEMBERS" VALUE="" cols="40" rows="5"></textarea></TD>
		</TR>
		<TR>
			<TD></TD>
			<TD align="right"><input type="submit" name="SUBMIT"
				value="Add Group"></TD>
		</TR>
	</TABLE>
</FORM>
<BR>
<BR>

<h3>Existing Groups</h3>
<%
	SQLAdapter adapter = new SQLAdapter();
	ResultSet rset = adapter
			.executeFetch("select * from groups where group_id<>1 and group_id<>2");
	out.println("<table border=1>");
	out.println("<tr>");
	out.println("<th align=\"center\" style=\"width: 178px;\">Group Name</th>");
	out.println("<th align=\"center\" style=\"width: 178px;\">Creator</th>");
	out.println("<th align=\"center\">Date Created</th>");
	out.println("</tr>");
	while (rset.next()) {
		out.println("<tr>");
		out.println("<td align=\"center\">" + rset.getString("group_name") + "</td>");
		out.println("<td align=\"center\">" + rset.getString("user_name") + "</td>");
		out.println("<td align=\"center\">" + rset.getDate("date_created") + "</td>");
		out.println("</tr>");
	}
	out.println("</table>");
	adapter.closeConnection();
%>