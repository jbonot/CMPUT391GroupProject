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
 * picture in sm_image with photo_id = 12 GetOnePicture?big12: sends the picture
 * in image with photo_id = 12
 * 
 * @author Li-Yan Yuan
 * 
 */
public class GetBigPic extends HttpServlet implements SingleThreadModel {

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

		if (userCookie == null) {
			response.setHeader("Refresh", "0; URL=index.jsp");
			return;
		}

		String user = userCookie.getValue();
		PrintWriter out = response.getWriter();
		try {
			response.setContentType("text/html");
			int photoId;
			// construct the query from the client's QueryString
			String picid = request.getQueryString().substring(3);

			try {
				photoId = Integer.parseInt(request.getQueryString()
						.substring(3));
			} catch (NumberFormatException e) {
				out.println("<html><head><title>Not Found</title></head>");
				out.println("<body>");
				out.println("<h3>Error</h3>");
				out.println("Image does not exist or you do not have permission to view this image.");
				out.println("</body></html>");
				return;
			}

			SQLAdapter adapter = new SQLAdapter();
			QueryHelper helper = new QueryHelper(adapter, user);
			String[] info = helper.getImageInfo(photoId);
			adapter.closeConnection();
			
			if (info != null) {

				String title = info[0];
				String place = info[1];
				String description = info[2];
				String owner = info[3];
				String date = info[4];
				String group = info[5];

				out.println("<html><head><title>" + title + "</title></head>");
				out.println("<body>");
				out.println("<input type=\"button\" "
						+ "value=\"Home\" name=\"Home\" "
						+ "onclick=\"javascript:window.location='home.jsp';\" /><BR>");
				out.println("<img src = \"/proj1/GetOnePic?" + picid
						+ "\"><BR>");
				out.println("<TABLE border=1>");
				out.println("<TR><TD><B><I>Owner:</I></B></TD>");
				out.println("<TD>" + owner + "</TD></TR>");
				out.println("<TR><TD><B><I>Visible to:</I></B></TD>");
				out.println("<TD>" + group + "</TD></TR>");
				out.println("<TR><TD><B><I>Title:</I></B></TD>");
				out.println("<TD>" + title + "</TD></TR>");
				out.println("<TR><TD><B><I>Place:</I></B></TD>");
				out.println("<TD>" + place + "</TD></TR>");
				out.println("<TR><TD><B><I>Date:</I></B></TD>");
				out.println("<TD>" + date + "</TD></TR>");
				out.println("<TR><TD><B><I>Description:</I></B></TD>");
				out.println("<TD>" + description + "</TD></TR>");
				out.println("</TABLE>");
				out.println("</body></html>");
			} else {

				out.println("<html><head><title>Access Denied</title></head>");
				out.println("<body>");
				out.println("<h3>Access Denied</h3>");
				out.println("Image does not exist or you do not have permission to view this image.");
				out.println("</body></html>");
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
