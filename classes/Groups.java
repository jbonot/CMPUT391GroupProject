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

		PrintWriter out = response.getWriter();
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
		String members[] = membersText.split("[\\s,]");
		SQLAdapter adapter = new SQLAdapter();
		String addError;
		try {
			if (this.isValidGroup(adapter, groupName, user)) {
				List<String> validMembers = this.getValidMembers(adapter,
						members);
				if (validMembers.size() > 0) {
					// Insert new group
					Date date = new Date(System.currentTimeMillis());
					int groupId = -1; // TODO: Get group id
					if (groupId != -1) {
						
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
						response.setHeader(
								"Refresh",
								"0; URL=groups.jsp?success="
										+ URLEncoder.encode(groupName, "UTF-8"));
					}
					else
					{
						response.setHeader(
								"Refresh",
								"0; URL=groups.jsp?debug=did-not-insert-value");
					}
					adapter.closeConnection();
				} else {
					response.setHeader(
							"Refresh",
							"0; URL=groups.jsp?invalid_members="
									+ URLEncoder.encode(groupName, "UTF-8"));
					adapter.closeConnection();
				}
			} else {
				response.setHeader(
						"Refresh",
						"0; URL=groups.jsp?invalid_group="
								+ URLEncoder.encode(groupName, "UTF-8"));
				adapter.closeConnection();
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	public void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// Invoke doGet to process this request
		doGet(request, response);
	}

	private List<String> getValidMembers(SQLAdapter adapter, String[] members)
			throws SQLException {
		List<String> valid = new ArrayList<String>();
		for (int i = 0; i < members.length; i++) {
			if (this.isValidUser(adapter, members[i])) {
				valid.add(members[i]);
			}
		}

		return valid;
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
