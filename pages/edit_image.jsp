<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<head>
<title>Edit image(s)</title>
</head>
<body>

	<%@ page import="proj1.*"%>
	<%@ page import="java.sql.*"%>
	<%@ page import="java.sql.Date"%>
	<%@ page import="java.util.*"%>

	<%
		/* COOKIE RETRIEVAL */
	    // use a cookie to retrieve oracle database information, as well as current username.
		String user = QueryHelper.getUserCookie(request.getCookies());
		int photoId = -1;
		if (user == null) {
			response.setHeader("Refresh", "0; URL=index.jsp");
			return;
		}
		
		try {
			photoId = Integer.parseInt(request.getQueryString());
		} catch (NumberFormatException e) {
			QueryHelper.accessDenied(out);
			return;
		}
		
		
		// Print the header.
		QueryHelper.printHeader(out, user, null, null, null);
        
        //connect to db
        SQLAdapter adapter = new SQLAdapter();
        QueryHelper helper = new QueryHelper(adapter, user);
        if (!helper.hasImageEditingAccess(photoId))
        {
        	QueryHelper.accessDenied(out);
        	return;
        }
        
        
        ImageInfo image = helper.getImageInfo(photoId);
        %>

	<h1>Edit image(s)...</h1>
	<hr>

	<form NAME="Edit-image" METHOD="POST" ACTION="EditPic?<%=photoId %>">
		<table>
			<tr>
				<td><b>Subject:</b></td>
				<td><INPUT TYPE="text" NAME="subject" VALUE="<%=image.subject %>"
					style="width: 346px;"></td>
			</tr>
			<tr>
				<td><b>Place:</b></td>
				<b> </b>
				<td><INPUT TYPE="text" NAME="place" VALUE="<%=image.place %>"
					style="width: 346px;"></td>
				<b> </b>
			</tr>
			<b> </b>
			<tr>
				<b> </b>
				<td><b>When:</b></td>
				<b> </b>
				<td><select name="month">
						<% 	//fill day dropdown all the way from January to December
						Calendar cal = Calendar.getInstance();
						cal.setTime(image.date);
						String[] str = {"January", "February", "March", "April",        
   										"May", "June", "July", "August",       
   										"September", "October", "November", "December"};
						for(int i = 0; i < 12; i++)
						{
							if(i == cal.get(Calendar.MONTH))
							{
								out.println("<option selected=\"selected\" value=\"" + (i + 1) + "\">" + str[i]);
							}
							else
								out.println("<option value=\"" + (i + 1) + "\">" + str[i]);
						}
					%>
				</select> <select name="day">
						<% 	//fill day dropdown all the way from 1 to 31
						for(int i = 1; i < 32; i++)
						{
							if(i == cal.get(Calendar.DAY_OF_MONTH))
								out.println("<option selected=\"selected\" value=\"" + i + "\">" + i);
							else
								out.println("<option value=\"" + i + "\">" + i);
						}
					%>
				</select> <select name="year">
						<% 	//fill year dropdown all the way from 1900 to 2013
						for(int i = 1900; i < 2014; i++)
						{
							if(i == cal.get(Calendar.YEAR))
								out.println("<option selected=\"selected\" value=\"" + i + "\">" + i);
							else
								out.println("<option value=\"" + i + "\">" + i);
						}
					%>
				</select></td>
				<b> </b>
			</tr>
			<b> </b>
			<tr>
				<b> </b>
				<td><b>Description:</b></td>
				<b> </b>
				<td><textarea name="description" rows="10" cols="30"
						style="width: 346px;">
</textarea></td>
				<b> </b>
			</tr>
			<b> </b>
			<tr>
				<b> </b>
				<td><b>Security Level:</b></td>
				<td><select name="security" style="width: 342px;">
						<% 	//need to dynamically fill the security dropdown with groups
							PreparedStatement getGroups = adapter.prepareStatement("SELECT group_id, group_name FROM groups WHERE user_name = ?");
							getGroups.setString(1, user);
							ResultSet rset1 = adapter.executeQuery(getGroups);
							while(rset1.next())
							{
								out.println("<option value=\"" + rset1.getInt(1) + "\">Group: " + rset1.getString(2) + "</option>");
						 	}
						 	getGroups.close();
						 	adapter.closeConnection();
						 %>
						<option value="1">Private (Only you can see it)</option>
						<option value="2">Public (Everyone can see it)</option>

				</select></td>
			</tr>
			<tr>
				<td ALIGN="CENTER" COLSPAN="2"><input type="submit"
					name="SUBMIT" value="Save" /></td>
			</tr>
		</table>
	</form>
</body>
</html>
