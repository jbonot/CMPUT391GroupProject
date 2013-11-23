import java.io.*;
import java.net.URLEncoder;

import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import java.util.*;
import java.sql.Date;
import proj1.*;

public class Groups extends HttpServlet implements SingleThreadModel {
	/**
	 * This method first gets the query string indicating PHOTO_ID, and then
	 * executes the query select image from yuan.photos where photo_id =
	 * PHOTO_ID Finally, it sends the picture to the client
	 */

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
			response.setHeader("Refresh", "0; URL=index.html");
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
			if (!member.isEmpty()) {
				members.add(member);
			}
		}

		SQLAdapter adapter = new SQLAdapter();

		try {

			String[] splitMembers = this.splitMembers(adapter, members);
			String[] validMembers = splitMembers[0].split(",");
			String invalidMembers = splitMembers[1];

			System.out.println(invalidMembers);
			if (this.isValidGroup(adapter, groupName, user)) {

				if (validMembers.length == members.size()) {
					// Insert new group
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

			if (validMembers.length != members.size()) {

				// Invalid list of members.
				if (!status.isEmpty()) {
					status += "+";
				}

				status += "invmembers";

			}

			String encodedHeader = "0; URL=groups.jsp?group="
					+ URLEncoder.encode(groupName, "UTF-8");

			// Set the status.
			encodedHeader += "&status=" + status;

			if (!status.equals("success")) {
				membersText = "";

				// Set the list of members.
				String prefix = "";
				for (String member : members) {
					if (!member.isEmpty()) {
						membersText += prefix + member;
						prefix = ",";
					}
				}

				if (!membersText.isEmpty()) {
					encodedHeader += "&members="
							+ URLEncoder.encode(membersText, "UTF-8");
				}

				if (!invalidMembers.isEmpty()) {
					encodedHeader += "&invalid_members="
							+ URLEncoder.encode(invalidMembers, "UTF-8");
				}
			}
			response.setHeader("Refresh", encodedHeader);
			adapter.closeConnection();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	public void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// Invoke doGet to process this request
		doGet(request, response);
	}

	private int getNextId(SQLAdapter adapter) throws SQLException {
		ResultSet rset = adapter
				.executeFetch("select group_sequence.nextVal from dual");
		return rset.getInt(1);
	}

	private String[] splitMembers(SQLAdapter adapter, List<String> members)
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
