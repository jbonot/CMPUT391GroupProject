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
public class EditPic extends HttpServlet implements SingleThreadModel {
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
			QueryHelper.accessDenied(out);
			return;
		}
//		PreparedStatement stmt;
//		int permitted;
//		
//		SQLAdapter adapter = new SQLAdapter();
//		QueryHelper helper = new QueryHelper(adapter, user);
//		try {
//			if (helper.hasImageEditingAccess(photoId)) {
//
//				String query = "update from images "
//						+ " set permitted=? subject=? place=? timing=? "
//						+ "description=? thumbnail=? photo=? "
//						+ "where photo_id=?";
//				stmt = adapter.prepareStatement(query);
//				stmt.setInt(1, photoId);
//				adapter.executeUpdate(stmt);
//				adapter.closeConnection();
//				response.setHeader("Refresh", "0; URL=GetBigPic?" + photoId);
//			} else {
//				QueryHelper.accessDenied(out);
//				adapter.closeConnection();
//			}
//		} catch (SQLException e) {
//			e.printStackTrace();
//		}

	}
}
