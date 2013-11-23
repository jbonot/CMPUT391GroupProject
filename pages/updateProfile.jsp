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
		String lastName = 	request.getParameter("FRSTNAME");
		String address = 	request.getParameter("ADDRESS");
		String email = 	request.getParameter("EMAIL");
		String phonenumber = 	request.getParameter("PHONENUMBER");
		
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
		boolean uLastName = (lastName.isEmpty()) ? false : true;
		boolean uFirstName = (firstName.isEmpty()) ? false : true;
		boolean uAddress= (address.isEmpty()) ? false : true;
		boolean uEmail = (email.isEmpty()) ? false : true;
		boolean uPhone = (phonenumber.isEmpty()) ? false : true;
		
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
		
		
		String prepareString = "UPDATE persons SET ";
		if (uLastName){
			prepareString = prepareString + " last_name = ?,";
		}
		if (uFirstName){
			prepareString = prepareString + " first_name = ?,";
		}
		if (uAddress){
			prepareString = prepareString + " address = ?,";
		}
		if (uEmail){
			prepareString = prepareString + " email = ?,";
		}
		if (uPhone){
			prepareString = prepareString + " phone = ?,";
		}
		if (prepareString.length() > 0 && prepareString.charAt(prepareString.length()-1)==',') {
			prepareString = prepareString.substring(0, prepareString.length()-1);
		 }
		prepareString = prepareString + " WHERE user_name = ?";
		PreparedStatement updatePerson = db.prepareStatement(prepareString);
		
		//Set the variable depending on what is set to be updated
		Integer count = 1;
		if (uLastName){
			updatePerson.setString(count,lastName);
			count++;
		}
		if (uFirstName){
			updatePerson.setString(count,firstName);
			count++;
		}
		if (uAddress){
			updatePerson.setString(count,address);
			count++;
		}
		if (uEmail){
			updatePerson.setString(count,email);
			count++;
		}
		if (uPhone){
			updatePerson.setString(count,phonenumber);
			count++;
		}
		updatePerson.setString(count,username);
		rows_updated_person = db.executeUpdate(updatePerson);
		updatePerson.close();
		if (rows_updated_person == 1){
			out.print("Update successfull! You will be redirected in 5 seconds...");
			db.closeConnection();
			//Wait for user to see successfull registration
			response.setHeader("Refresh", "5; URL=home.jsp");
		}
		else{
			out.print("Update Failed. You will be redirected in 5 seconds...");
			db.closeConnection();
			response.setHeader("Refresh", "5; URL=userProfile.html");
		}
		db.closeConnection();

	%>
</body>
</html>