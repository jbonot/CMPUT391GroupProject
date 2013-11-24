import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;

import java.sql.*;

import proj1.*;

/**
 * This servlet sends one picture stored in the table below to the client who
 * requested the servlet.
 * 
 * picture( photo_id: integer, title: varchar, place: varchar, sm_image: blob,
 * image: blob )
 * 
 * The request must come with a query string as follows: GetOnePic?12: sends the
 * picture in sm_image with photo_id = 12 GetOnePic?big12: sends the picture in
 * image with photo_id = 12
 * 
 * @author Li-Yan Yuan
 * 
 */
public class DeletePic extends HttpServlet implements SingleThreadModel {
	/**
	 * This method first gets the query string indicating PHOTO_ID, and then
	 * executes the query select image from yuan.photos where photo_id =
	 * PHOTO_ID Finally, it sends the picture to the client
	 */
	public void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		String user = QueryHelper.getUserCookie(request.getCookies());
		if (user == null) {
			response.setHeader("Refresh", "0; URL=index.jsp");
			return;
		}

		ServletOutputStream out = response.getOutputStream();

		// construct the query from the client's QueryString
		String picid = request.getQueryString();
		int photoId = -1;

		try {
			photoId = Integer.parseInt(picid);
		} catch (NumberFormatException e) {
			out.println("no picture available");
			return;
		}
		PreparedStatement stmt;
		ResultSet rset;

		SQLAdapter adapter = new SQLAdapter();
		try {
			boolean okToDelete = user.equals("admin");
			if (!okToDelete) {
				stmt = adapter
						.prepareStatement("select * from images where photo_id=? and owner_name=?");
				stmt.setInt(1, photoId);
				stmt.setString(2, user);
				rset = adapter.executeQuery(stmt);
				okToDelete = rset.next();
				rset.close();
			}
			if (okToDelete) {
				stmt = adapter
						.prepareStatement("delete from images where photo_id=?");
				stmt.setInt(1, photoId);
				adapter.executeUpdate(stmt);
				adapter.closeConnection();
				response.setHeader("Refresh", "0; URL=home.jsp?deletesuccess");
			} else {
				adapter.closeConnection();
			}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}
}
