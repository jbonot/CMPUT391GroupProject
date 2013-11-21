package proj1;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Date;

/*
 * A query helper.
 */
public class QueryHelper {
	private static String FETCH_THUMBNAILS = "SELECT photo_id, subject "
			+ "FROM images, group_lists "
			+ "where ((permitted=2 and owner_name=?) "
			+ "or (group_id=permitted and friend_id=?)) ";
	private SQLAdapter adapter;
	private String user;

	public QueryHelper(SQLAdapter adapter, String user) {
		this.adapter = adapter;
		this.user = user;
	}

	public ResultSet getHomeItems() {
		PreparedStatement stmt = adapter.prepareStatement(FETCH_THUMBNAILS);
		try {
			stmt.setString(1, user);
			stmt.setString(2, user);
			return adapter.executeQuery(stmt);
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return null;
	}

	public ResultSet getSearchItems(String query, Date dateStart, Date dateEnd) {
		StringBuilder queryString = new StringBuilder(FETCH_THUMBNAILS);
		int i = 1;
		
		if (dateStart != null) {
			queryString.append("and timing >= ? ");
		}

		if (dateEnd != null) {
			queryString.append("and timing <= ? ");
		}

		if (query != null) {
			queryString.append("and (contains(subject, ?, 6) > 0 ");
			queryString.append("or contains(place, ?, 3) > 0 ");
			queryString.append("or contains(description, ?, 1) > 0) ");
			queryString
					.append("order by score(6) * 6 + score(3) * 3 + score(1) desc");
		} else {
			queryString.append("order by timing desc");
		}

		PreparedStatement doSearch = adapter.prepareStatement(queryString
				.toString());

		try {
			doSearch.setString(i++, user);
			doSearch.setString(i++, user);

			if (dateStart != null) {
				doSearch.setDate(i++, dateStart);
			}

			if (dateEnd != null) {
				doSearch.setDate(i++, dateEnd);
			}

			if (query != null) {
				doSearch.setString(i++, query);
				doSearch.setString(i++, query);
				doSearch.setString(i++, query);
			}

			return adapter.executeQuery(doSearch);
			
		} catch (SQLException e) {
			e.printStackTrace();
		}
		
		return null;
	}
}
