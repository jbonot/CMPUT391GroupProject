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

		boolean delete = request.getParameter("DELETE") != null;
		if (request.getParameter("SUBMIT") == null && !delete) {
			response.setHeader("Refresh", "0; URL=groups.jsp");
			return;
		}

		Mode mode = Mode.ADD;
		String groupName = request.getParameter("GROUP");

		String status = "";

		SQLAdapter adapter = new SQLAdapter();
		QueryHelper helper = new QueryHelper(adapter, user);

		String encodedHeader = "0; URL=groups.jsp?group="
				+ URLEncoder.encode(groupName, "UTF-8");

		ResultSet rset;
		int groupId = -1;
		List<String> storedMembers = null;
		String storedGroupName = null;

		String[] groupMembers = request.getParameterValues("GROUPMEMBERS");
		String editGroup = request.getParameter("Update");
		if (editGroup != null || delete) {
			try {
				groupId = Integer.parseInt(editGroup);

				// Validate access.
				rset = helper.fetchGroupAsEditor(groupId);
				if (rset.next()) {

					if (delete) {
						rset.close();
						helper.deleteGroup(groupId);
					} else {

						// Get group info.
						storedGroupName = rset.getString("group_name");
						rset.close();

						storedMembers = this.getStoredMembers(helper, groupId,
								user);
						mode = Mode.EDIT;
					}
				} else {
					groupId = -1;
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}

		if (!delete) {
			try {
				boolean hasMembers = groupMembers != null
						&& groupMembers.length > 1;

				if (this.isValidGroup(adapter, groupName, user)) {
					Date date = new Date(System.currentTimeMillis());

					if (hasMembers) {
						if (mode == Mode.ADD) {
							// Insert a new group.
							groupId = this.getNextId(adapter);
							helper.insertGroup(groupId, groupName, date);

						} else if (!groupName.equals(storedGroupName)) {
							// Update the group name.
							helper.updateGroup(groupId, groupName);
						}

						if (mode == Mode.ADD) {
							for (String member : groupMembers) {
								// Insert member into group
								helper.insertGroupMember(groupId, member, date);
							}

						} else {

							List<String> newMembers = new ArrayList<String>();
							for (String member : groupMembers) {
								if (!storedMembers.remove(member)) {
									newMembers.add(member);
								}
							}

							// Remaining members in the list are to be deleted.
							for (String member : storedMembers) {
								helper.removeGroupMember(groupId, member);
							}

							// Add new members.
							for (String member : newMembers) {
								helper.insertGroupMember(groupId, member, date);
							}
						}
						
						// Success
						status = mode == Mode.ADD ? "success" : "updated";
					}

				} else {
					// Invalid group name.
					status = "invgroup";
				}

				if (!hasMembers) {
					// Invalid members.
					status += status.isEmpty() ? "invmembers" : "+invmembers";
				}

				if (mode == Mode.EDIT) {
					encodedHeader += "&id=" + groupId;
				}

				// Set the status.
				encodedHeader += "&status=" + status;

			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		else
		{
			encodedHeader += "&status=deleted";
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
