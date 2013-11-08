

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.util.*;
import java.sql.Date;
import java.sql.*;
import proj1.*;

/**
 * Demonstrates session management mechanisms built into the Servlet API. A
 * session is established with the client and user is prompted to enter his/her
 * name. User's name along with the number of times he/she visited the site is
 * stored in the session. This sample uses rewritten URLs for storing session
 * information.
 * 
 * NOTE: Cookie support must be turned off in the browser. Refer to your browser
 * documentation on how to turn off cookies From
 * "Java Servlet Programming Bible" Suresh Rajagopalan et al. John Wiley & Sons
 * 2002.
 * 
 */

public class Home extends HttpServlet {

	private static String DATE_FORMAT = "yyyy-mm-dd";
	private PrintWriter out;
	private static String PARAM_DATE_START = "DATE_START";
	private static String PARAM_DATE_END = "DATE_END";
	private static String PARAM_SEARCH = "SEARCH";
	private SQLAdapter adapter;

	/**
	 * Handles HTTP GET request
	 */
	public void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String title = "Search";
		response.setContentType("text/html");
		out = response.getWriter();

		Date dateStart = null;
		Date dateEnd = null;
		String query = null;
		boolean search = request.getParameter(PARAM_SEARCH) != null;

		if (search) {
			dateStart = this.getStartDate(request);
			dateEnd = this.getEndDate(request);
			query = request.getParameter("query");
		}

		query = query == null || query.equals("") ? null : query;

		out.println("<HTML>");
		out.println("<HEAD><TITLE>" + title + "</TITLE></HEAD>");
		out.println("<BODY>");
		out.println("<H1><CENTER>" + title + "</CENTER></H1>");
		out.println("</BODY>");
		adapter = new SQLAdapter("jbonot", "knowy0urneen");
		this.printSearchForm(query, dateStart, dateEnd);

		if (search) {
			this.getSearchResults(query, dateStart, dateEnd);
		}
		adapter.closeConnection();
		out.println("</HTML>");
		out.flush();
		out.close();
	}

	/**
	 * Handles HTTP POST request
	 */
	public void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// Invoke doGet to process this request
		doGet(request, response);
	}

	/**
	 * Returns a brief description about this servlet
	 */
	public String getServletInfo() {
		return "Servlet that stores user's name in the Session";
	}

	private Date getStartDate(HttpServletRequest request) {
		try {
			Date dateStart = java.sql.Date.valueOf(request
					.getParameter(PARAM_DATE_START));
			if (dateStart == null) {
				return null;
			}
			Calendar c = Calendar.getInstance();
			c.setTime(dateStart);
			c.set(Calendar.HOUR_OF_DAY, 0);
			c.set(Calendar.MINUTE, 0);
			c.set(Calendar.SECOND, 0);
			c.set(Calendar.MILLISECOND, 0);
			return new java.sql.Date(c.getTimeInMillis());
		} catch (IllegalArgumentException e) {
			return null;
		}
	}

	private Date getEndDate(HttpServletRequest request) {
		try {
			Date dateEnd = java.sql.Date.valueOf(request
					.getParameter(PARAM_DATE_END));
			if (dateEnd == null) {
				return null;
			}
			Calendar c = Calendar.getInstance();
			c.setTime(dateEnd);
			c.set(Calendar.HOUR_OF_DAY, 23);
			c.set(Calendar.MINUTE, 59);
			c.set(Calendar.SECOND, 59);
			c.set(Calendar.MILLISECOND, 999);
			return new java.sql.Date(c.getTimeInMillis());
		} catch (IllegalArgumentException e) {
			return null;
		}
	}

	private void printSearchForm(String query, java.sql.Date dateStart,
			java.sql.Date dateEnd) {
		out.println("<FORM NAME=\"SearchForm\" ACTION=\"search.jsp\" METHOD=\"post\" >");
		out.println("<P>Search for images.</P>");
		out.println("<TABLE>");
		out.println("<TR VALIGN=TOP ALIGN=LEFT>");
		out.println("<TD><B><I>Keywords:</I></B></TD>");
		out.println("<TD><INPUT TYPE=\"text\" NAME=\"query\" value=\"" + query != null ? query
				: new String() + "\"><BR></TD>");
		out.println("</TR>");
		out.println("<TR VALIGN=TOP ALIGN=LEFT>");
		out.println("<TD><B><I>Time Periods:</I></B></TD>");
		out.println("<TD><I>From:</I><INPUT TYPE=\"date\" NAME=\""+PARAM_DATE_START+"\" value=\""
				+ dateStart != null ? dateStart : DATE_FORMAT + "\"></TD>");
		out.println("<TD><I>To:</I><INPUT TYPE=\"date\" NAME=\""+PARAM_DATE_END+"\" value=\""
				+ dateEnd != null ? dateEnd : DATE_FORMAT + "\"></TD>");
		out.println("</TR>");
		out.println("</TABLE>");

		out.println("<INPUT TYPE=\"submit\" NAME=\""+PARAM_SEARCH+"\" VALUE=\"Search\">");
		out.println("</FORM>");
	}

	private void getSearchResults(String query, Date dateStart, Date dateEnd) {

		try {

			StringBuilder queryString = new StringBuilder(
					"SELECT subject, place, description, timing FROM images ");
			boolean firstCondition = true;

			if (dateStart != null) {
				queryString.append("where timing >= ? ");
				firstCondition = false;
			}

			if (dateEnd != null) {
				queryString.append(firstCondition ? "where " : "and ");
				queryString.append("timing <= ? ");
				firstCondition = false;
			}

			if (query != null) {
				queryString.append(firstCondition ? "where " : "and ");
				queryString
						.append("(contains(subject, ?, 6) > 0 or contains(place, ?, 3) > 0 or contains(description, ?, 1) > 0) order by score(6) * 6 + score(3) * 3 + score(1) desc");
				firstCondition = false;
			} else {
				out.println("<br><b>Please enter text for quering</b>");
				queryString.append("order by timing desc");
			}

			if (!firstCondition) {
				PreparedStatement doSearch = adapter
						.prepareStatement(queryString.toString());

				int i = 1;

				if (dateStart != null) {
					doSearch.setDate(i++, dateStart);
				}

				if (dateEnd != null) {
					doSearch.setDate(i++, dateEnd);
				}

				if (query != null) {
					doSearch.setString(i++, query);
					doSearch.setString(i++, query);
					doSearch.setString(i++, query);
				}

				ResultSet rset = adapter.executeQuery(doSearch);

				out.println("<table border=1>");
				out.println("<tr>");
				out.println("<th>Subject</th>");
				out.println("<th>Place</th>");
				out.println("<th>Description</th>");
				out.println("<th>Date</th>");
				out.println("</tr>");

				while (rset.next()) {
					out.println("<tr>");
					out.println("<td>");
					out.println(rset.getString(1));
					out.println("</td>");
					out.println("<td>");
					out.println(rset.getString(2));
					out.println("</td>");
					out.println("<td>");
					out.println(rset.getObject(3));
					out.println("</td>");
					out.println("<td>");
					out.println(rset.getObject(4));
					out.println("</td>");
					out.println("</tr>");
				}

				out.println("</table>");
				out.println("<br><b>" + queryString + "</b>");
			}
		} catch (Exception e) {
			out.println(e.getStackTrace());
		}
	}
}
