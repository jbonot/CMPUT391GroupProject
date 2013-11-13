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

		String username = OracleUsernameCookie.getValue();
		String password = OraclePasswordCookie.getValue();

		// construct the query from the client's QueryString
		String picid = request.getQueryString();
		String query;

		if (picid.startsWith("big"))
			query = "select photo from images where photo_id="
					+ picid.substring(3);
		else
			query = "select thumbnail from images where photo_id=" + picid;

		ServletOutputStream out = response.getOutputStream();

		/*
		 * to execute the given query
		 */
		SQLAdapter adapter = new SQLAdapter(username, password);

		try {
			ResultSet rset = adapter.executeFetch(query);

			if (rset.next()) {
				response.setContentType("image/gif");
				InputStream input = rset.getBinaryStream(1);
				int imageByte;
				while ((imageByte = input.read()) != -1) {
					out.write(imageByte);
				}
				input.close();
			} else
				out.println("no picture available");
		} catch (Exception ex) {
			out.println(ex.getMessage());
		}
		// to close the connection
		finally {
			adapter.closeConnection();
		}
	}
}
