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
		String cookieUsername = "OracleUsername";
		String cookiePassword = "OraclePassword";
		Cookie cookies[] = request.getCookies();
		Cookie OracleUsernameCookie = null;
		Cookie OraclePasswordCookie = null;
		if (cookies != null) {
			for (int i = 0; i < cookies.length; i++) {
				if (cookies[i].getName().equals(cookieUsername)) {
					OracleUsernameCookie = cookies[i];
					break;
				}
			}
		}
		if (cookies != null) {
			for (int i = 0; i < cookies.length; i++) {
				if (cookies[i].getName().equals(cookiePassword)) {
					OraclePasswordCookie = cookies[i];
					break;
				}
			}
		}
		PrintWriter out = response.getWriter();
		try {
			response.setContentType("text/html");

			String username = OracleUsernameCookie.getValue();
			String password = OraclePasswordCookie.getValue();
			String user = "matwood";
			int photoId;
			// construct the query from the client's QueryString
			String picid = request.getQueryString().substring(3);
			String permissionQuery;

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

			SQLAdapter adapter = new SQLAdapter(username, password);
			permissionQuery = "select subject, place, description, owner_name, timing, g.group_name "
					+ "from images, group_lists l, groups g "
					+ "where photo_id="
					+ photoId
					+ " and ((permitted=2 and owner_name='"
					+ user
					+ "') or (l.group_id=permitted and l.friend_id='"
					+ user
					+ "'))" + "and l.group_id=g.group_id";

			out.println(permissionQuery + "<BR>");
			try {
				ResultSet rset = adapter.executeFetch(permissionQuery);
				if (rset.next()) {
					String title, place, description, owner, group;
					java.sql.Date date;
					try {
						title = rset.getString(1);
						place = rset.getString(2);
						description = rset.getString(3);
						owner = rset.getString(4);
						date = rset.getDate(5);
						group = rset.getString(6);
						out.println("<html><head><title>" + title
								+ "</title></head>");
						out.println("<body>");
						out.println("<img src = \"/proj1/GetOnePic?" + picid
								+ "\">");
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
					} catch (SQLException e) {
						e.printStackTrace();
					}
				} else {

					out.println("<html><head><title>Access Denied</title></head>");
					out.println("<body>");
					out.println("<h3>Access Denied</h3>");
					out.println("Image does not exist or you do not have permission to view this image.");
					out.println("</body></html>");
				}
			} catch (SQLException e1) {
				e1.printStackTrace();
			}
			adapter.closeConnection();
		} catch (Exception e) {
			out.println(e.getStackTrace().toString());
		}
	}
}
