import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.*;

public class SQLAdapter {

	public String host;
	public String m_userName;
	public String m_password;
	private static final String m_url = "jdbc:oracle:thin:@gwynne.cs.ualberta.ca:1521:CRS";
    	private static final String m_driverName = "oracle.jdbc.driver.OracleDriver";
	
	private Connection m_con = null;
	private Statement statement = null;
	private PreparedStatement preparedStatement = null;
	private ResultSet resultSet = null;

	public void registerDriver(){
		try
	       {
	              @SuppressWarnings("rawtypes")
				  Class drvClass = Class.forName(m_driverName);
	              DriverManager.registerDriver((Driver)
	              drvClass.newInstance());
	              m_con = DriverManager.getConnection(m_url, m_userName,m_password);
	              
	       } catch(Exception e)
	       {
	              System.err.print("ClassNotFoundException: ");
	              System.err.println(e.getMessage());
	       }
	}
	
	public ResultSet executeStatement(String SQLquery) throws Exception {
		registerDriver();
		try
	       {

	              statement = m_con.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
	              ResultSet rset = statement.executeQuery(SQLquery);
	              return rset;
	              

	       } catch(SQLException ex) {

	              System.err.println("SQLException: " +
	              ex.getMessage());
	              return null;
	       }
  
	}
	
	public ResultSet executePreparedStatementFetch() throws Exception {
		registerDriver();
		try
	       {

	              resultSet = preparedStatement.executeQuery();
	              closeStatementandConnection();
	              return resultSet;
	              

	       } catch(SQLException ex) {

	              System.err.println("SQLException: " +
	              ex.getMessage());
	              return null;
	       }
  
	}
	
	public void executePreparedStatementUpdate() throws SQLException{
		preparedStatement.executeUpdate();
	}
	
	public void preparePreparedStatement(String SQLquery) throws SQLException{
		preparedStatement = m_con.prepareStatement(SQLquery);
	}
	
	
	private void closeStatementandConnection(){
		try {
	
		      if (statement != null) {
		        statement.close();
		      }
	
		      if (m_con != null) {
		        m_con.close();
		      }
		    } catch (Exception e) {
	
		    }
	}
	
	private void closeResultSet(){
		try {
			if (resultSet != null) {
				resultSet.close();
			}

		} catch (Exception e) {
			
	    }
	}
}
