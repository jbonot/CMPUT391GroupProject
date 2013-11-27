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
public class GetOnePic extends HttpServlet implements SingleThreadModel {
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

		// construct the query from the client's QueryString
		String picid = request.getQueryString();
		boolean big = picid.startsWith("big");
		int photoId = -1;

		try {

			if (big) {
				photoId = Integer.parseInt(picid.substring(3));
			} else {
				photoId = Integer.parseInt(picid);
			}
		} catch (NumberFormatException e) {
			e.printStackTrace();
			out.println("no picture available");
			return;
		}

		SQLAdapter adapter = new SQLAdapter();
		QueryHelper helper = new QueryHelper(adapter, user);
		InputStream input = helper.getImage(photoId, big);
		adapter.closeConnection();

		if (input != null) {
			response.setContentType("image/jpg");

			int imageByte;
			while ((imageByte = input.read()) != -1) {
				out.write(imageByte);
			}
			
			input.close();
		} else {
			out.println("no picture available");
		}
	}
}
