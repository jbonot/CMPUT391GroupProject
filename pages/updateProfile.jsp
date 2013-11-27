<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Profile Update</title>
</head>
<body>
	<%@ page import="proj1.*" %>
	<%@ page import="java.sql.*" %>
	<%@ page import="java.util.Date" %>
	<%
		//Get the values from the login and registration page
		String newPassword = 	request.getParameter("NEWPASSWD");
		String firstName = 	request.getParameter("FRSTNAME");
		String lastName = 	request.getParameter("LASTNAME");
		String address = 	request.getParameter("ADDRESS");
		String email = 	request.getParameter("EMAIL");
		String phonenumber = 	request.getParameter("PHONENUMBER");
		
		//Do some string cleanup
		phonenumber = phonenumber.replaceAll("[^a-zA-Z0-9\\s]", "");
		phonenumber = phonenumber.substring(0, Math.min(phonenumber.length(), 10));
				
		//Create the adapter
		SQLAdapter db = new SQLAdapter();//Create a new instance of the SQL Adapter to use 
		
		//Get logged in user
		Cookie cookies[] = request.getCookies();
		Cookie UserCookie = null;
		if (cookies != null) {
			for (int i = 0; i < cookies.length; i++) {
				if (cookies[i].getName().equals("User")) {
					UserCookie = cookies[i];
					break;
				}
			}
		}
		String username = UserCookie.getValue();
		
		//Some variables for counting the rows updated
		Integer rows_updated = 0;
		Integer rows_updated_person = 0;
				
		boolean uPassword = (newPassword.isEmpty()) ? false : true;
		
		String preparePassword = "UPDATE users SET password = ? WHERE user_name = ?";
		Integer rows_updated_password = 0;
		if (uPassword){
			PreparedStatement updatePassword = db.prepareStatement(preparePassword);
			updatePassword.setString(1,newPassword);
			updatePassword.setString(2,username);
			rows_updated_password = db.executeUpdate(updatePassword);
			if (rows_updated_password == 1){
				out.print("Password Change Successful! ");
				updatePassword.close();
			}
			else{
				out.print("Password Change Failed! ");
				updatePassword.close();
			}
		}
		
		
		String prepareString = "UPDATE persons SET first_name=?, last_name=?, address=?, email=?, phone=? where user_name=?";
		PreparedStatement stmt = db.prepareStatement(prepareString);
		stmt.setString(1, firstName);
		stmt.setString(2, lastName);
		stmt.setString(3, address);
		stmt.setString(4, email);
		stmt.setString(5, phonenumber);
		stmt.setString(6, username);
		
		rows_updated_person = db.executeUpdate(stmt);
		stmt.close();
		if (rows_updated_person == 1){
			out.print("Update successfull! You will be redirected in 5 seconds...");
			db.closeConnection();
			//Wait for user to see successfull registration
			response.setHeader("Refresh", "5; URL=home.jsp");
		}
		else{
			out.print("Update Failed. You will be redirected in 5 seconds...");
			db.closeConnection();
			response.setHeader("Refresh", "5; URL=userProfile.jsp");
		}
		db.closeConnection();

	%>
</body>
</html>