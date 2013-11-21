package proj1;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.*;

/*
 * An adapter for SQL Oracle.
 */
public class SQLAdapter {

	private static final String m_url = "jdbc:oracle:thin:@gwynne.cs.ualberta.ca:1521:CRS";
	private static final String m_driverName = "oracle.jdbc.driver.OracleDriver";

	private Connection m_con = null;
	private String m_userName;
	private String m_password;

	public SQLAdapter() {
		this("c391g11", "cmputgroup11");
	}

	/*
	 * Initializes a new instance of the SQLAdapter class.
	 */
	public SQLAdapter(String username, String password) {
		m_userName = username;
		m_password = password;
	}

	/*
	 * Executes a fetch statement.
	 */
	public ResultSet executeFetch(String SQLquery) {
		try {
			if (m_con == null) {
				this.registerDriver();
			}

			Statement statement = m_con
					.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE,
							ResultSet.CONCUR_UPDATABLE);
			return statement.executeQuery(SQLquery);
		} catch (SQLException se) {
			System.err.println("SQLException: " + se.getMessage());
			return null;
		} catch (Exception e) {
			System.err.println("Exception: " + e.getMessage());
			return null;
		}

	}

	/*
	 * Executes an update statement.
	 */
	public int executeUpdate(PreparedStatement statement) {
		try {
			return statement.executeUpdate(); // Returns the number of
												// updated/inserted rows
		} catch (SQLException se) {
			System.err.println("SQLException: " + se.getMessage());
			return -1;
		} catch (Exception e) {
			System.err.println("Exception: " + e.getMessage());
			return -1;
		}
	}

	/*
	 * Executes a prepared statement.
	 */
	public ResultSet executeQuery(PreparedStatement statement) {
		try {
			return statement.executeQuery();
		} catch (SQLException se) {
			System.err.println("SQLException: " + se.getMessage());
			return null;
		} catch (Exception e) {
			System.err.println("Exception: " + e.getMessage());
			return null;
		}
	}

	/*
	 * Returns a prepared statement.
	 */
	public PreparedStatement prepareStatement(String sqlQuery) {
		try {
			if (m_con == null) {
				this.registerDriver();
			}

			return m_con.prepareStatement(sqlQuery);
		} catch (SQLException se) {
			System.err.println("SQLException: " + se.getMessage());
			return null;
		} catch (Exception e) {
			System.err.println("Exception: " + e.getMessage());
			return null;
		}
	}

	/*
	 * Closes the existing connection.
	 */
	public void closeConnection() {
		try {
			if (this.m_con != null) {
				this.m_con.close();
			}

		} catch (Exception e) {
			System.err.println("Exception: " + e.getMessage());
		}
	}

	/*
	 * Register the driver and set up the connection.
	 */
	private void registerDriver() {
		try {
			@SuppressWarnings("rawtypes")
			Class drvClass = Class.forName(m_driverName);
			DriverManager.registerDriver((Driver) drvClass.newInstance());
			m_con = DriverManager.getConnection(m_url, m_userName, m_password);

		} catch (Exception e) {
			System.err.print("ClassNotFoundException: ");
			System.err.println(e.getMessage());
		}
	}
}
