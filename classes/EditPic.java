import java.io.*;

import javax.servlet.*;
import javax.servlet.http.*;

import java.sql.*;
import java.util.Calendar;

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
		String user = HtmlPrinter.getUserCookie(request.getCookies());
		if (user == null) {
			response.setHeader("Refresh", "0; URL=index.jsp");
			return;
		}

		ServletOutputStream out = response.getOutputStream();
		int photoId = -1;
		photoId = Integer.parseInt(request.getQueryString());

		if (photoId == -1 || request.getParameter("UPDATE") == null) {
			HtmlPrinter.accessDenied(out);
			return;
		}

		PreparedStatement stmt;
		SQLAdapter adapter = new SQLAdapter();
		QueryHelper helper = new QueryHelper(adapter, user);

		try {
			if (helper.hasImageEditingAccess(photoId)) {
				String query = "update images "
						+ "set permitted=?, subject=?, place=?, timing=?, description=? "
						+ "where photo_id=?";

				int year = Integer.parseInt(request.getParameter("year"));
				int month = Integer.parseInt(request.getParameter("month"));
				int day = Integer.parseInt(request.getParameter("day"));

				Calendar cal = Calendar.getInstance();
				cal.set(year, month, day);
				Date date = new Date(cal.getTimeInMillis());
				
				stmt = adapter.prepareStatement(query);
				stmt.setInt(1,
						Integer.parseInt(request.getParameter("security")));
				stmt.setString(2, request.getParameter("subject"));
				stmt.setString(3, request.getParameter("place"));
				stmt.setDate(4, date);
				stmt.setString(5, request.getParameter("description"));
				stmt.setInt(6, photoId);
				adapter.executeUpdate(stmt);
				
				adapter.closeConnection();

				response.setHeader("Refresh", "0; URL=GetBigPic?big" + photoId);
			} else {

				HtmlPrinter.accessDenied(out);
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
}
