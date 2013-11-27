package proj1;

import java.io.IOException;
import java.io.Writer;
import java.sql.Date;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.Cookie;

public class HtmlPrinter {

	public static void printHeader(Writer out, String user, String query,
			Date dateStart, Date dateEnd) throws IOException {
		out.write("<table width=\"100%\"><tr><td VALIGN=TOP>");
		HtmlPrinter.printNavigationButtons(out, user);
		out.write("</td><td VALIGN=TOP align=right>");
		HtmlPrinter.printSearchBar(out, query, dateStart, dateEnd);
		out.write("</td></tr></table>");
		out.write("<hr>");
		out.flush();
	}
	
	public static void printHeader(ServletOutputStream out, String user, String query,
			Date dateStart, Date dateEnd) throws IOException {
		out.println("<table width=\"100%\"><tr><td VALIGN=TOP>");
		HtmlPrinter.printNavigationButtons(out, user);
		out.println("</td><td VALIGN=TOP align=right>");
		HtmlPrinter.printSearchBar(out, query, dateStart, dateEnd);
		out.println("</td></tr></table>");
		out.println("<hr>");
		out.flush();
	}

	public static void accessDenied(Writer out) throws IOException {
		out.write("<html>");
		out.write("<head>");
		out.write("<title>Access Denied</title>");
		out.write("</head>");
		out.write("<body>");
		out.write("<h3>Access Denied</h3>");
		out.write("Page does not exist, or you do not have permission to access it.");
		out.write("</body>");
		out.write("</html>");
		out.flush();
	}

	public static void accessDenied(ServletOutputStream out) throws IOException {
		out.println("<html>");
		out.println("<head>");
		out.println("<title>Access Denied</title>");
		out.println("</head>");
		out.println("<body>");
		out.println("<h3>Access Denied</h3>");
		out.println("Page does not exist or you do not have permission to access it.");
		out.println("</body>");
		out.println("</html>");
		out.flush();
	}

	private static void printNavigationButtons(Writer out, String user)
			throws IOException {
		out.write("<table><tr>");
		out.write("<td><table><tr>");
		out.write("<td><input type=\"button\" value=\"Home\" onClick=\"javascript:window.location='home.jsp';\"></td>");
		out.write("<td><input type=\"button\" value=\"Explore\" onClick=\"javascript:window.location='explore.jsp';\"></td>");
		out.write("<td><input type=\"button\" value=\"Profile\" onClick=\"javascript:window.location='userProfile.jsp';\"></td>");
		out.write("<td><input type=\"button\" value=\"Upload\" onClick=\"javascript:window.location='upload_image.jsp';\"></td>");
		out.write("<td><input type=\"button\" value=\"Groups\" onClick=\"javascript:window.location='groups.jsp';\"></td>");

		if (user.equals("admin")) {
			out.write("<td><input type=\"button\" value=\"Analysis\"onClick=\"javascript:window.location='DataAnalysis.jsp';\"></td>");
		}
		
		out.write("<td><input type=\"button\" value=\"Help Docs\" onClick=\"javascript:window.location='help.jsp';\"></td>");
		out.write("<td><input type=\"button\" value=\"Logout\" onClick=\"javascript:window.location='logout.jsp';\"></td>");
		out.write("</tr></table></td></tr>");
		out.write("<tr><td><table><tr><td>Logged in as " + user + "</td></tr></table></td></tr>");
		out.write("</tr></table>");
		out.flush();
	}

	private static void printNavigationButtons(ServletOutputStream out, String user)
			throws IOException {
		out.println("<table><tr>");
		out.println("<td><table><tr>");
		out.println("<td><input type=\"button\" value=\"Home\" onClick=\"javascript:window.location='home.jsp';\"></td>");
		out.println("<td><input type=\"button\" value=\"Explore\" onClick=\"javascript:window.location='explore.jsp';\"></td>");
		out.println("<td><input type=\"button\" value=\"Profile\" onClick=\"javascript:window.location='userProfile.jsp';\"></td>");
		out.println("<td><input type=\"button\" value=\"Upload\" onClick=\"javascript:window.location='upload_image.jsp';\"></td>");
		out.println("<td><input type=\"button\" value=\"Groups\" onClick=\"javascript:window.location='groups.jsp';\"></td>");

		if (user.equals("admin")) {
			out.println("<td><input type=\"button\" value=\"Analysis\"onClick=\"javascript:window.location='DataAnalysis.jsp';\"></td>");
		}

		out.println("<td><input type=\"button\" value=\"Help Docs\" onClick=\"javascript:window.location='help.jsp';\"></td>");
		out.println("<td><input type=\"button\" value=\"Logout\" onClick=\"javascript:window.location='logout.jsp';\"></td>");
		out.println("</tr></table></td></tr>");
		out.println("<tr><td><table><tr><td>Logged in as " + user + "</td></tr></table></td></tr>");
		out.println("</tr></table>");
		out.flush();
	}

	private static void printSearchBar(Writer out, String query,
			Date dateStart, Date dateEnd) throws IOException {
		String dateFormat = "yyyy-mm-dd";
		out.write("<FORM NAME=\"SearchForm\" ACTION=\"search.jsp\" METHOD=\"get\"><TABLE border=1><TR VALIGN=TOP>");
		out.write("<TD><I>Search:</I></TD>");
		out.write("<TD><INPUT TYPE=\"text\" NAME=\"query\" value=\""
				+ (query != null ? query : "") + "\"></TD>");
		out.write("<TD><I>From:</I><INPUT TYPE=\"date\" NAME=\"DATE_START\" value=\""
				+ (dateStart != null ? dateStart : dateFormat) + "\"></TD>");
		out.write("<TD><I>To:</I><INPUT TYPE=\"date\" NAME=\"DATE_END\" value=\""
				+ (dateEnd != null ? dateEnd : dateFormat) + "\"></TD>");
		out.write("<TD><INPUT TYPE=\"submit\" NAME=\"SEARCH\" VALUE=\"Search\"></TD>");
		out.write("</TR></TABLE></FORM>");
		out.flush();
	}

	private static void printSearchBar(ServletOutputStream out, String query,
			Date dateStart, Date dateEnd) throws IOException {
		String dateFormat = "yyyy-mm-dd";
		out.println("<FORM NAME=\"SearchForm\" ACTION=\"home.jsp\" METHOD=\"get\"><TABLE border=1><TR VALIGN=TOP>");
		out.println("<TD><I>Search:</I></TD>");
		out.println("<TD><INPUT TYPE=\"text\" NAME=\"query\" value=\""
				+ (query != null ? query : "") + "\"></TD>");
		out.println("<TD><I>From:</I><INPUT TYPE=\"date\" NAME=\"DATE_START\" value=\""
				+ (dateStart != null ? dateStart : dateFormat) + "\"></TD>");
		out.println("<TD><I>To:</I><INPUT TYPE=\"date\" NAME=\"DATE_END\" value=\""
				+ (dateEnd != null ? dateEnd : dateFormat) + "\"></TD>");
		out.println("<TD><INPUT TYPE=\"submit\" NAME=\"SEARCH\" VALUE=\"Search\"></TD>");
		out.println("</TR></TABLE></FORM>");
		out.flush();
	}

	public static String getUserCookie(Cookie[] cookies) {
		Cookie userCookie = null;
		if (cookies != null) {
			for (int i = 0; i < cookies.length; i++) {
				if (cookies[i].getName().equals("User")) {
					userCookie = cookies[i];
					break;
				}
			}
		}

		return userCookie == null ? null : userCookie.getValue();
	}
	
	public static String toAttributeString(String value){
		if (value == null){
			return "";
		}
		
		return value.replaceAll("\"", "&quot;");
	}

}
