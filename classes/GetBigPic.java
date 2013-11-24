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
		String user = QueryHelper.getUserCookie(request.getCookies());
		if (user == null) {
			response.setHeader("Refresh", "0; URL=index.jsp");
			return;
		}

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
				QueryHelper.accessDenied(out);
				return;
			}

			SQLAdapter adapter = new SQLAdapter();
			QueryHelper helper = new QueryHelper(adapter, user);
			ImageInfo info = helper.getImageInfo(photoId);
			adapter.closeConnection();

			if (info != null) {

				out.println("<html><head><title>" + info.subject + "</title>");
				QueryHelper.printHeader(out, user, null, null, null);
				out.println("</head>");
				out.println("<body>");
				out.println("<TABLE>");
				out.println("<TR><TD align=center><img src = \"/proj1/GetOnePic?" + picid
						+ "\"></TD><TR>");
				out.println("<TR><TD><TABLE border=1><TR><TD><B><I>Owner:</I></B></TD>");
				out.println("<TD>" + info.owner + "</TD></TR>");
				out.println("<TR><TD><B><I>Visible to:</I></B></TD>");
				out.println("<TD>" + info.group + "</TD></TR>");
				out.println("<TR><TD><B><I>Title:</I></B></TD>");
				out.println("<TD>" + info.subject + "</TD></TR>");
				out.println("<TR><TD><B><I>Place:</I></B></TD>");
				out.println("<TD>" + info.place + "</TD></TR>");
				out.println("<TR><TD><B><I>Date:</I></B></TD>");
				out.println("<TD>" + info.date + "</TD></TR>");
				out.println("<TR><TD><B><I>Description:</I></B></TD>");
				out.println("<TD>" + info.description + "</TD></TR>");
				out.println("</TABLE></TD></TR></TABLE>");
				out.println("</body></html>");

				if (user.equals(info.owner) || user.equals("admin")) {
					out.println("<BR><input type=\"button\" "
							+ "value=\"Edit Image\" name=\"Home\" "
							+ "onclick=\"javascript:window.location='edit_image.jsp?"
							+ photoId + "';\" />");
					out.println("<input type=\"button\" "
							+ "value=\"Delete Image\" name=\"Home\" "
							+ "onclick=\"javascript:window.location='DeletePic?"
							+ photoId + "';\" /><BR>");
				}
			} else {
				QueryHelper.accessDenied(out);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
