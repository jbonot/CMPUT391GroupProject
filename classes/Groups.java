import java.io.*;
import java.net.URLEncoder;

import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import java.util.*;
import java.sql.Date;
import proj1.*;

public class Groups extends HttpServlet implements SingleThreadModel {

	public void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String user = HtmlPrinter.getUserCookie(request.getCookies());
		if (user == null) {
			response.setHeader("Refresh", "0; URL=index.jsp");
			return;
		}

		if (request.getParameter("SUBMIT") == null) {
			response.setHeader("Refresh", "0; URL=groups.jsp");
			return;
		}

		String groupName = request.getParameter("GROUP");
		String membersText = request.getParameter("MEMBERS");

		String status = "";
		List<String> members = new ArrayList<String>();
		String membersWithBlanks[] = membersText.split("[\\s,;]");

		SQLAdapter adapter = new SQLAdapter();
		QueryHelper helper = new QueryHelper(adapter, user);

		String encodedHeader = "0; URL=groups.jsp?group="
				+ URLEncoder.encode(groupName, "UTF-8");

		for (String member : membersWithBlanks) {
			if (!member.isEmpty()) {
				members.add(member);
			}
		}

		ResultSet rset;
		int groupId = -1;
		List<String> storedMembers = null;
		String storedGroupName = null;

		String editGroup = request.getParameter("Update");
		if (editGroup != null) {
			try {
				groupId = Integer.parseInt(editGroup);

				// Validate access.
				rset = helper.fetchGroupAsEditor(groupId);
				if (rset.next()) {
					// Get group info.
					storedGroupName = rset.getString("group_name");
					rset.close();

					storedMembers = this
							.getStoredMembers(helper, groupId, user);
				} else {
					groupId = -1;
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}

		try {

			String[] splitMembers = this.splitMembers(adapter, members, user);

			// There must be at least one valid member and no invalid members.
			boolean invMembers = splitMembers[0].isEmpty()
					|| !splitMembers[1].isEmpty();

			if (this.isValidGroup(adapter, groupName, user)) {

				// There must be at least one valid member and no invalid
				// members.
				if (!invMembers) {
					// Insert new group

					String[] validMembers;
					if (user.equals("admin")) {
						validMembers = splitMembers[0].split(",");
					} else {
						// Add the creator to the group if the user is not
						// admin.
						validMembers = splitMembers[0].concat("," + user)
								.split(",");
					}

					Date date = new Date(System.currentTimeMillis());
					groupId = this.getNextId(adapter);

					if (groupId == -1) {
						helper.insertGroup(groupId, groupName, date);
					} else if (!groupName.equals(storedGroupName)) {
						helper.updateGroup(groupId, groupName);
					}

					if (storedMembers == null) {
						for (String member : validMembers) {
							// Insert member into group
							helper.insertGroupMember(groupId, member, date);
						}
					} else {
						List<String> newMembers = new ArrayList<String>();
						for (String member : validMembers) {
							if (!storedMembers.remove(member)) {
								newMembers.add(member);
							}
						}
						
						for (String member : storedMembers){
							helper.removeGroupMember(groupId, member);
						}
						
						for (String member : newMembers){
							helper.insertGroupMember(groupId, member, date);
						}
					}

					// Success
					status = "success";
				}
			} else {
				// Invalid group name.
				status = "invgroup";
			}

			if (invMembers) {
				// Invalid members.
				status += status.isEmpty() ? "invmembers" : "+invmembers";
			}

			// Set the status.
			encodedHeader += "&status=" + status;

			if (!status.equals("success")) {

				if (!membersText.isEmpty()) {
					encodedHeader += "&members="
							+ URLEncoder.encode(membersText, "UTF-8");
				}

				if (!splitMembers[1].isEmpty()) {
					encodedHeader += "&invalid_members="
							+ URLEncoder.encode(splitMembers[1], "UTF-8");
				}
			}
			adapter.closeConnection();
		} catch (SQLException e) {
			e.printStackTrace();
		}

		response.setHeader("Refresh", encodedHeader);
	}

	public void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// Invoke doGet to process this request
		doGet(request, response);
	}

	private List<String> getStoredMembers(QueryHelper helper, int groupId,
			String creator) {
		ResultSet rset = helper.fetchGroupMembers(groupId);
		List<String> oldMembers = new ArrayList<String>();
		try {

			while (rset.next()) {
				String member = rset.getString("friend_id");
				oldMembers.add(member);
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return oldMembers;
	}

	private int getNextId(SQLAdapter adapter) throws SQLException {
		ResultSet rset = adapter
				.executeFetch("select group_sequence.nextVal from dual");
		return rset.next() ? rset.getInt(1) : -1;
	}

	private String[] splitMembers(SQLAdapter adapter, List<String> members,
			String user) throws SQLException {
		List<String> valid = new ArrayList<String>();
		List<String> invalid = new ArrayList<String>();

		String validMembers = "";
		String invalidMembers = "";
		String prefix;

		for (String member : members) {
			if (!member.equals(user) && !member.equals("admin")
					&& this.isValidUser(adapter, member)) {
				valid.add(member);
			} else {
				invalid.add(member);
			}
		}

		// Set the string of valid members.
		prefix = "";
		for (String member : valid) {
			validMembers += prefix + member;
			prefix = ",";
		}

		// Set the string of invalid members.
		prefix = "";
		for (String member : invalid) {
			invalidMembers += prefix + member;
			prefix = ",";
		}

		return new String[] { validMembers, invalidMembers };
	}

	private boolean isValidUser(SQLAdapter adapter, String username)
			throws SQLException {
		PreparedStatement stmt = adapter
				.prepareStatement("select * from users where user_name=?");
		stmt.setString(1, username);
		ResultSet rset = adapter.executeQuery(stmt);
		return rset.next();
	}

	private boolean isValidGroup(SQLAdapter adapter, String groupname,
			String creator) throws SQLException {
		PreparedStatement stmt = adapter
				.prepareStatement("select * from groups where group_name=? and user_name=?");
		stmt.setString(1, groupname);
		stmt.setString(2, creator);
		ResultSet rset = adapter.executeQuery(stmt);
		return !rset.next();
	}
}
