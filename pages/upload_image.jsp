<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<head>
<title>Upload an image</title> 
</head>
<body> 

<%@ page import="proj1.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*" %>

		<%
		/* COOKIE RETRIEVAL */
	    // use a cookie to retrieve oracle database information, as well as current username.
        String cookieUsername = "OracleUsername";
        String cookiePassword = "OraclePassword";
        String currentUser = "Username";
        
        Cookie cookies [] = request.getCookies ();
        Cookie OracleUsernameCookie = null;
        Cookie OraclePasswordCookie = null;
        Cookie currentUserCookie = null;
        
        if (cookies != null){
            for (int i = 0; i < cookies.length; i++) {
                if (cookies [i].getName().equals (cookieUsername)){
                    OracleUsernameCookie = cookies[i];
                break;
                }
            }
        }
        if (cookies != null){
            for (int i = 0; i < cookies.length; i++) {
                if (cookies [i].getName().equals (cookiePassword)){
                    OraclePasswordCookie = cookies[i];
                break;
                }
            }
        }
        if (cookies != null){
            for (int i = 0; i < cookies.length; i++) {
                if (cookies [i].getName().equals (currentUser)){
                    currentUserCookie = cookies[i];
                    break;
                }
            }
        }
        
        //connect to db
        String username = OracleUsernameCookie.getValue();//Need to get username and password from cookie and/or input
        String password = OraclePasswordCookie.getValue();//**************
        SQLAdapter db = new SQLAdapter(username, password);//Create a new instance of the SQL Adapter to use
        
        //store current user's name in string
        String user = currentUserCookie.getValue();
        %>
        
<h1>Upload an image...</h1><hr>
<form name="upload-image" method="POST" enctype="multipart/form-data" action="classes/UploadImage.java">
		<table>
			<tr>
				<th>Image path:</th>
				<td><input name="file-path" type="file" size="30"></input></td>
			</tr>

			<tr>
				<td><b>Subject:</b></td>
				<td><INPUT TYPE="text" NAME="subject" VALUE=""
					style="width: 346px;"></td>
			</tr>
			<tr>
				<td><b>Place:</b></td>
				<b> </b>
				<td><INPUT TYPE="text" NAME="place" VALUE=""
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
						String[] str = {"January", "February", "March", "April",        
   										"May", "June", "July", "August",       
   										"September", "October", "November", "December"};
						for(int i = 1; i < 13; i++)
						{
							if(i == cal.get(Calendar.MONTH))
								System.out.println("<option selected=\"selected\" value=\"" + i + "\">" + str[i]);
							else
								System.out.println("<option value=\"" + i + "\">" + str[i]);
						}
					%>
					</select>
					<select name="day">
					<% 	//fill day dropdown all the way from 1 to 31
						for(int i = 1; i < 32; i++)
						{
							if(i == cal.get(Calendar.DAY_OF_MONTH))
								System.out.println("<option selected=\"selected\" value=\"" + i + "\">" + i);
							else
								System.out.println("<option value=\"" + i + "\">" + i);
						}
					%>
					</select>
					<select name="year">
					<% 	//fill year dropdown all the way from 1900 to 2013
						for(int i = 1900; i < 2014; i++)
						{
							if(i == cal.get(Calendar.YEAR))
								System.out.println("<option selected=\"selected\" value=\"" + i + "\">" + i);
							else
								System.out.println("<option value=\"" + i + "\">" + i);
						}
					%>
	</select>
				</td>
				<b> </b>
			</tr>
			<b> </b>
			<tr>
				<b> </b>
				<td><b>Description:</b></td>
				<b> </b>
				<td><textarea name="description" rows="10" cols="30" style="width: 346px;">
</textarea></td>
				<b> </b>
			</tr>
			<b> </b>
			<tr>
				<b> </b>
				<td><b>Security Level:</b></td>
				<td>
						<select name="security" style="width: 342px;">
						<% 	//need to dynamically fill this dropdown with groups
							PreparedStatement getGroups = db.PreparedStatement("SELECT group_id, group_name FROM groups WHERE user_name = ?");
							getGroups.setString(1, user);
							ResultSet rset1 = db.ExecuteQuery(getGroups);
							while(rset1.next())
							{
						 %>
							<option value="1">Private (Everyone can see it)</option>
						 <% System.out.println("<option value=\"" + rset1.getInt(1) + "\">Group: " + rset1.getString(2) + "</option>");
						 	}
						 	getGroups.close();
						 %>
							<option value="2">Public (Only you can see it)</option>

						</select>
				</td>
			</tr>
			<tr>
				<td ALIGN="CENTER" COLSPAN="2"><input type="submit" name=".submit" value="Upload"/></td>
			</tr>
		</table>
	</form>
</body> 
</html>
