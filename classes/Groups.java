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

		Cookie cookies[] = request.getCookies();
		Cookie userCookie = null;
		if (cookies != null) {
			for (int i = 0; i < cookies.length; i++) {
				if (cookies[i].getName().equals("User")) {
					userCookie = cookies[i];
					break;
				}
			}
		}

		if (userCookie == null) {
			response.setHeader("Refresh", "0; URL=index.jsp");
			return;
		}

		if (request.getParameter("SUBMIT") == null) {
			response.setHeader("Refresh", "0; URL=groups.jsp");
			return;
		}

		String user = userCookie.getValue();
		String groupName = request.getParameter("GROUP");
		String membersText = request.getParameter("MEMBERS");

		String status = "";
		List<String> members = new ArrayList<String>();
		String membersWithBlanks[] = membersText.split("[\\s,;]");

		for (String member : membersWithBlanks) {
			if (!member.isEmpty() && !member.equals("admin") && !member.equals(user)) {
				members.add(member);
			}
		}

		SQLAdapter adapter = new SQLAdapter();
		String encodedHeader = "0; URL=groups.jsp?group="
				+ URLEncoder.encode(groupName, "UTF-8");
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
						// Add the creator to the group if the user is not admin.
						validMembers = splitMembers[0].concat("," + user)
								.split(",");
					}

					Date date = new Date(System.currentTimeMillis());
					int groupId = this.getNextId(adapter);

					PreparedStatement stmt = adapter
							.prepareStatement("insert into groups values(?,?,?,?)");
					stmt.setInt(1, groupId);
					stmt.setString(2, user);
					stmt.setString(3, groupName);
					stmt.setDate(4, date);
					adapter.executeUpdate(stmt);
					stmt.close();

					for (String member : validMembers) {
						// Insert member into group
						stmt = adapter
								.prepareStatement("insert into group_lists values(?,?,?,?)");
						stmt.setInt(1, groupId);
						stmt.setString(2, member);
						stmt.setDate(3, date);
						stmt.setString(4, null);
						adapter.executeUpdate(stmt);
						stmt.close();
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
							+ URLEncoder.encode(splitMembers[0], "UTF-8");
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

	private int getNextId(SQLAdapter adapter) throws SQLException {
		ResultSet rset = adapter
				.executeFetch("select group_sequence.nextVal from dual");
		return rset.next() ? rset.getInt(1) : -1;
	}

	private String[] splitMembers(SQLAdapter adapter, List<String> members, String user)
			throws SQLException {
		List<String> valid = new ArrayList<String>();
		List<String> invalid = new ArrayList<String>();

		String validMembers = "";
		String invalidMembers = "";
		String prefix;

		for (String member : members) {
			if (this.isValidUser(adapter, member)) {
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
