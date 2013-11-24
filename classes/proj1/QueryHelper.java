package proj1;

import java.io.*;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Date;

/*
 * A query helper.
 */
public class QueryHelper {
	public static String SECURITY_CONDITION = "((owner_name=?) "
			+ "or (permitted=group_id and friend_id=?)) ";

	private static String FETCH_USER_ADMIN = "SELECT distinct photo_id, subject from images ";
	private static String FETCH_USER_THUMBNAILS = "SELECT distinct photo_id, subject FROM images, group_lists ";
	private SQLAdapter adapter;
	private String user;
	private String firstName;
	private boolean isAdmin;

	public QueryHelper(SQLAdapter adapter, String user) {
		this.adapter = adapter;
		this.user = user;
		this.isAdmin = user.equals("admin");
	}

	public ResultSet getHomeItems() {
		if (this.isAdmin) {

			return adapter.executeFetch(FETCH_USER_ADMIN);

		} else {
			try {
				String query = FETCH_USER_THUMBNAILS + "where "
						+ SECURITY_CONDITION;
				PreparedStatement stmt = adapter.prepareStatement(query);
				this.setSecurityParameters(stmt, 1);
				return adapter.executeQuery(stmt);
			} catch (SQLException e) {
				return null;
			}
		}
	}

	public ResultSet getSearchItems(String query, Date dateStart, Date dateEnd) {
		PreparedStatement stmt;
		String queryString;
		String conjunction;

		if (this.isAdmin) {
			queryString = FETCH_USER_ADMIN;
			conjunction = "where ";
		} else {
			queryString = FETCH_USER_THUMBNAILS + "where " + SECURITY_CONDITION;
			conjunction = "and ";
		}

		if (dateStart != null) {
			queryString += conjunction + "timing >= ? ";
			conjunction = "and ";
		}

		if (dateEnd != null) {
			queryString += conjunction + "timing <= ? ";
			conjunction = "and ";
		}

		if (query != null) {
			queryString += conjunction + "(contains(subject, ?, 6) > 0 ";
			queryString += "or contains(place, ?, 3) > 0 ";
			queryString += "or contains(description, ?, 1) > 0) ";
			queryString += "order by score(6) * 6 + score(3) * 3 + score(1) desc";
		} else {
			queryString += "order by timing desc";
		}

		stmt = adapter.prepareStatement(queryString.toString());

		try {
			int index = this.isAdmin ? 1 : this.setSecurityParameters(stmt, 1);

			if (dateStart != null) {
				stmt.setDate(index++, dateStart);
			}

			if (dateEnd != null) {
				stmt.setDate(index++, dateEnd);
			}

			if (query != null) {
				stmt.setString(index++, query);
				stmt.setString(index++, query);
				stmt.setString(index++, query);
			}

			return adapter.executeQuery(stmt);

		} catch (SQLException e) {
			e.printStackTrace();
		}

		return null;
	}

	public String[] getImageInfo(int photoId) {
		int groupId = -1;
		PreparedStatement stmt;
		ResultSet rset;

		try {
			if (this.isAdmin) {
				String permissionQuery = "select subject, place, description, owner_name, timing, group_id "
						+ "from images, group_lists where photo_id=?";
				stmt = this.adapter.prepareStatement(permissionQuery);
				stmt.setInt(1, photoId);
			} else {
				String permissionQuery = "select subject, place, description, owner_name, timing, group_id "
						+ "from images, group_lists "
						+ "where photo_id=? and "
						+ SECURITY_CONDITION;
				stmt = this.adapter.prepareStatement(permissionQuery);
				stmt.setInt(1, photoId);
				this.setSecurityParameters(stmt, 2);
			}

			rset = adapter.executeQuery(stmt);
			if (rset.next()) {
				String title = rset.getString("subject");
				String place = rset.getString("place");
				String description = rset.getString("description");
				String owner = rset.getString("owner_name");
				Date date = rset.getDate("timing");
				groupId = rset.getInt("group_id");
				String group = null;
				rset.close();

				stmt = adapter
						.prepareStatement("select group_name from groups where group_id=?");
				stmt.setInt(1, groupId);
				rset = adapter.executeQuery(stmt);
				if (rset.next()) {
					group = rset.getString("group_name");
					rset.close();

					return new String[] { title, place, description, owner,
							date.toString(), group, Integer.toString(groupId) };
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}

		return null;
	}

	public InputStream getImage(int photoId, boolean big) {
		ResultSet rset;
		PreparedStatement stmt;
		String format = big ? "photo" : "thumbnail";

		try {
			if (this.isAdmin) {
				stmt = adapter.prepareStatement("select " + format
						+ " from images where photo_id=?");
				stmt.setInt(1, photoId);

			} else {
				String query = "select " + format
						+ " from images, group_lists where photo_id=? and "
						+ SECURITY_CONDITION;

				stmt = adapter.prepareStatement(query);
				stmt.setInt(1, photoId);
				this.setSecurityParameters(stmt, 2);
			}

			rset = adapter.executeQuery(stmt);
			if (rset.next()) {
				return rset.getBinaryStream(1);
			}

		} catch (SQLException e) {
			e.printStackTrace();
		}
		return null;
	}

	public String getFirstName() {
		if (this.firstName == null) {
			try {
				PreparedStatement stmt = adapter
						.prepareStatement("select first_name from persons where user_name=?");
				stmt.setString(1, this.user);
				ResultSet rset = adapter.executeQuery(stmt);

				if (rset.next()) {
					this.firstName = rset.getString("first_name");
				}

			} catch (SQLException e) {
				e.printStackTrace();
			}
		}

		return this.firstName;
	}

	private int setSecurityParameters(PreparedStatement stmt, int startIndex)
			throws SQLException {
		int i = startIndex;
		stmt.setString(i++, user);
		stmt.setString(i++, user);
		return i;
	}
}
