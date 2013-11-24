<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<head>
<title>Edit Image Info</title>
</head>
<body>

	<%@ page import="proj1.*"%>
	<%@ page import="java.sql.*"%>
	<%@ page import="java.sql.Date"%>
	<%@ page import="java.util.*"%>

	<%
		/* COOKIE RETRIEVAL */
	    // use a cookie to retrieve oracle database information, as well as current username.
		String user = HtmlPrinter.getUserCookie(request.getCookies());
		int photoId = -1;
		if (user == null) {
			response.setHeader("Refresh", "0; URL=index.jsp");
			return;
		}
		
		try {
			photoId = Integer.parseInt(request.getQueryString());
		} catch (NumberFormatException e) {
			HtmlPrinter.accessDenied(out);
			return;
		}
		
		
		// Print the header.
		HtmlPrinter.printHeader(out, user, null, null, null);
        
        //connect to db
        SQLAdapter adapter = new SQLAdapter();
        QueryHelper helper = new QueryHelper(adapter, user);
        if (!helper.hasImageEditingAccess(photoId))
        {
        	HtmlPrinter.accessDenied(out);
        	return;
        }
        
        
        ImageInfo image = helper.getImageInfo(photoId);
		String selected = " selected=\"selected\"";
        %>

	<h1>Edit Image Info</h1>
	<hr>

	<form NAME="Edit-image" METHOD="POST" ACTION="EditPic?<%=photoId %>">
		<table>
			<tr>
				<td><b>Subject:</b></td>
				<td><INPUT TYPE="text" NAME="subject"
					VALUE="<%=image.subject.replaceAll("\"", "&quot;") %>"
					style="width: 346px;"></td>
			</tr>
			<tr>
				<td><b>Place:</b></td>
				<td><INPUT TYPE="text" NAME="place"
					VALUE="<%=image.place.replaceAll("\"", "&quot;") %>"
					style="width: 346px;"></td>
			</tr>
			<tr>
				<td><b>When:</b></td>
				<td><select name="month">
						<% 	//fill day dropdown all the way from January to December
						Calendar cal = Calendar.getInstance();
						cal.setTime(image.date);
						
						String[] str = {"January", "February", "March", "April",        
   										"May", "June", "July", "August",       
   										"September", "October", "November", "December"};
						
						for(int i = 0; i < 12; i++)
						{
							out.println("<option value=\"" + (i + 1) + "\"" + (i == cal.get(Calendar.MONTH) ? selected : "") + ">" + str[i]);
						}
					%>
				</select> <select name="day">
						<% 	//fill day dropdown all the way from 1 to 31
						for(int i = 1; i < 32; i++)
						{
							out.println("<option value=\"" + i + "\"" + (i == cal.get(Calendar.DAY_OF_MONTH) ? selected : "") + ">" + i);
						}
					%>
				</select> <select name="year">
						<% 	//fill year dropdown all the way from 1900 to 2013
						for(int i = 1900; i < 2014; i++)
						{
							out.println("<option value=\"" + i + "\"" + (i == cal.get(Calendar.YEAR) ? selected : "") + ">" + i);
						}
					%>
				</select></td>
			</tr>
			<tr>
				<td><b>Description:</b></td>
				<td><textarea name="description" rows="10" cols="30"
						style="width: 346px;">
<%=image.description %></textarea></td>
			</tr>
			<tr>

				<td><b>Security Level:</b></td>
				<td><select name="security" style="width: 342px;">
						<% 	
							
							out.println("<option value=\"1\"" + (image.groupId == 1 ? selected : "") + ">Public (Everyone can see it)</option>");
							out.println("<option value=\"2\"" + (image.groupId == 2 ? selected : "") + ">Private (Only you can see it)</option>");
							
							//need to dynamically fill the security dropdown with groups
							ResultSet rset = helper.getAccessibleGroups();

							String groupName;
							int groupId;
							
							while(rset.next())
							{
								groupId = rset.getInt(1);
								groupName = rset.getString(2);
								out.println("<option value=\"" + groupId + "\"" + (image.groupId == groupId ? selected : "") + ">Visible to " + groupName + "</option>");
						 	}
							
						 	adapter.closeConnection();
						 	
						 %>

				</select></td>
			</tr>
			<tr>
				<td ALIGN="Right" COLSPAN="2"><input type="submit"
					name="UPDATE" value="Save" /></td>
			</tr>
		</table>
	</form>
</body>
</html>
