package proj1;

import java.io.*;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Date;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.*;

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

	public ResultSet getHomeItems()
	{
	    return adapter.executeFetch("SELECT * FROM image_view WHERE rnk <= 5");
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

	public boolean hasImageEditingAccess(int photoId) {
		if (this.isAdmin) {
			return true;
		}

		try {
			PreparedStatement stmt = adapter
					.prepareStatement("select * from images where photo_id=? and owner_name=?");
			stmt.setInt(1, photoId);
			stmt.setString(2, user);
			ResultSet rset = adapter.executeQuery(stmt);
			return rset.next();
		} catch (SQLException e) {
			e.printStackTrace();
		}

		return false;
	}
	
	public void insertGroupMember(int groupId, String member, Date date) throws SQLException{
		PreparedStatement stmt;
		stmt = adapter
				.prepareStatement("insert into group_lists values(?,?,?,?)");
		stmt.setInt(1, groupId);
		stmt.setString(2, member);
		stmt.setDate(3, date);
		stmt.setString(4, null);
		adapter.executeUpdate(stmt);
		stmt.close();
	}
	
	public void insertGroup(int groupId, String groupName, Date date) throws SQLException{
		PreparedStatement stmt = adapter
				.prepareStatement("insert into groups values(?,?,?,?)");
		stmt.setInt(1, groupId);
		stmt.setString(2, user);
		stmt.setString(3, groupName);
		stmt.setDate(4, date);
		adapter.executeUpdate(stmt);
		stmt.close();
	}
	
	public ResultSet fetchGroupImages(int groupId) throws SQLException{
		PreparedStatement stmt = adapter.prepareStatement("select * from images where permitted=?");
		stmt.setInt(1, groupId);
		return adapter.executeQuery(stmt);
	}
	
	private int setImagesPrivate(List<Integer> photoIds) throws SQLException{
		
		if (photoIds.isEmpty())
		{
			return 0;
		}
		
		String query = "update images set permitted=2 where ";
		String conjunction = "";
		
		for (int i = 0; i < photoIds.size(); i++){
			query += conjunction + "photo_id=? ";
			conjunction = "or ";
		}
		
		PreparedStatement stmt = adapter.prepareStatement(query);
		
		int i = 1;
		for (int id : photoIds){
			stmt.setInt(i++, id);
		}
		
		return adapter.executeUpdate(stmt);
	}
	
	public int deleteGroup(int groupId) throws SQLException{
		PreparedStatement stmt;
		ResultSet rset;
		List<Integer> photoIds = new ArrayList<Integer>();
		
		stmt = adapter.prepareStatement("select * from images where permitted=?");
		stmt.setInt(1, groupId);
		rset = adapter.executeQuery(stmt);
		
		while (rset.next()){
			photoIds.add(rset.getInt("photo_id"));
		}
		
		rset.close();
		stmt.close();
		
		this.setImagesPrivate(photoIds);
		
		stmt = adapter.prepareStatement("delete from group_lists where group_id=?");
		stmt.setInt(1, groupId);
		adapter.executeUpdate(stmt);
		stmt.close();
		
		stmt = adapter.prepareStatement("delete from groups where group_id=?");
		stmt.setInt(1, groupId);
		return adapter.executeUpdate(stmt);
	}
	
	public void updateGroup(int groupId, String groupName) throws SQLException{
		PreparedStatement stmt = adapter
				.prepareStatement("update groups set group_name=? where group_id=?");
		stmt.setString(1, groupName);
		stmt.setInt(2, groupId);
		adapter.executeUpdate(stmt);
		stmt.close();
	}
	
	public void removeGroupMember(int groupId, String member) throws SQLException{
		PreparedStatement stmt;
		stmt = adapter
				.prepareStatement("delete from group_lists where group_id=? and friend_id=?");
		stmt.setInt(1, groupId);
		stmt.setString(2, member);
		adapter.executeUpdate(stmt);
		stmt.close();
	}

	public ResultSet fetchGroupAsEditor(int groupId) {

		try {
			PreparedStatement stmt;
			ResultSet rset;
			if (this.isAdmin) {
				stmt = adapter
						.prepareStatement("select * from groups where group_id=?");
				stmt.setInt(1, groupId);
				rset = adapter.executeQuery(stmt);

				return rset;
			}

			// Check if the user owns the group.
			stmt = adapter
					.prepareStatement("select * from groups where group_id=? and user_name=?");
			stmt.setInt(1, groupId);
			stmt.setString(2, user);
			rset = adapter.executeQuery(stmt);

			return rset;

		} catch (SQLException e) {
			e.printStackTrace();
		}

		return null;
	}

	public ResultSet fetchGroupMembers(int groupId) {
		PreparedStatement stmt;

		try {
			stmt = adapter
					.prepareStatement("select * from group_lists where group_id=?");

			stmt.setInt(1, groupId);

			return adapter.executeQuery(stmt);

		} catch (SQLException e) {
			e.printStackTrace();
		}

		return null;
	}

	public ResultSet fetchGroup(int groupId) {
		PreparedStatement stmt;
		try {
			stmt = adapter
					.prepareStatement("select * from groups where group_id=?");
			stmt.setInt(1, groupId);
			return adapter.executeQuery(stmt);
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return null;
	}

	public ImageInfo getImageInfo(int photoId) {
		int groupId = -1;
		PreparedStatement stmt;
		ResultSet rset;

		try {
			if (this.isAdmin) {
				String permissionQuery = "select subject, place, description, owner_name, timing, permitted "
						+ "from images, group_lists where photo_id=?";
				stmt = this.adapter.prepareStatement(permissionQuery);
				stmt.setInt(1, photoId);
			} else {
				String permissionQuery = "select subject, place, description, owner_name, timing, permitted "
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
				groupId = rset.getInt("permitted");
				String group = null;
				rset.close();

				stmt = adapter
						.prepareStatement("select group_name from groups where group_id=?");
				stmt.setInt(1, groupId);
				rset = adapter.executeQuery(stmt);
				if (rset.next()) {
					group = rset.getString("group_name");
					rset.close();

					ImageInfo info = new ImageInfo();
					info.subject = title;
					info.place = place;
					info.description = description;
					info.owner = owner;
					info.date = date;
					info.group = group;
					info.groupId = groupId;
					return info;
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
		}

		return null;
	}

	public ResultSet getImage(int photoId, boolean big) {
		PreparedStatement stmt;
		String format = big ? "photo" : "thumbnail";

		try {
			if (this.isAdmin) {
				stmt = adapter.prepareStatement("select " + format + " from images where photo_id=?");
				stmt.setInt(1, photoId);

			} else {
				String query = "select " + format
						+ " from images, group_lists where photo_id=? and "
						+ SECURITY_CONDITION;

				stmt = adapter.prepareStatement(query);
				stmt.setInt(1, photoId);
				this.setSecurityParameters(stmt, 2);
			}
			
			return adapter.executeQuery(stmt);

		} catch (SQLException e) {
			e.printStackTrace();
		}
		
		return null;
	}

	public ResultSet getAccessibleGroups() throws SQLException {
		PreparedStatement stmt;

		if (this.isAdmin) {
			return adapter
					.executeFetch("select group_id, group_name from groups where group_id<>1 and group_id<>2");
		} else {
			stmt = adapter
					.prepareStatement("SELECT group_id, group_name FROM groups WHERE user_name = ?");
			stmt.setString(1, user);
			return adapter.executeQuery(stmt);
		}
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
