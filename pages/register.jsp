<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Login Confirmation</title>
</head>
<body>
	<%@ page import="proj1.*" %>
	<%@ page import="java.sql.*" %>
	<%@ page import="java.util.Date" %>
	<%
		//Get the values from the login and registration page
		String newName = 	request.getParameter("NEWUSERNAME");
		String newPassword = 	request.getParameter("NEWPASSWD");
		String firstName = 	request.getParameter("FRSTNAME");
		String lastName = 	request.getParameter("LASTNAME");
		String address = 	request.getParameter("ADDRESS");
		String email = 	request.getParameter("EMAIL");
		String phonenumber = 	request.getParameter("PHONENUMBER");
		java.util.Date today = new java.util.Date();
		
		//Create the adapter
		SQLAdapter db = new SQLAdapter();//Create a new instance of the SQL Adapter to use 
		
		//Setup the prepared statement to check if the email or username is in use
				PreparedStatement checkEmail = db
						.prepareStatement("SELECT * FROM persons p, users u where p.email = ? or u.user_name = ?");
				checkEmail.setString(1, email);
				checkEmail.setString(2, newName);
				ResultSet rset = db.executeQuery(checkEmail);
				boolean empty = true;
				if (rset.next()) {
				empty = false;
				}
				rset.close();
				
		//If the email and username are not in use		
		if (empty == true){
			
			//Some variables for counting the rows updated
			Integer rows_updated = 0;
			Integer rows_updated_person = 0;
			
			//Setting up and executing the prepared statement
			PreparedStatement registerUser = db.prepareStatement("INSERT INTO users(user_name,password,date_registered) VALUES(?,?,?)");	
			registerUser.setString(1, newName);
			registerUser.setString(2, newPassword);
			registerUser.setDate(3, new java.sql.Date(today.getTime()));
			rows_updated = db.executeUpdate(registerUser);
			registerUser.close();
			//If the username & password creation worked then insert their personal information						
			if (rows_updated == 1){
				PreparedStatement registerPerson = db.prepareStatement("INSERT INTO persons(user_name,first_name,last_name,address,email,phone) VALUES(?,?,?,?,?,?)");
				registerPerson.setString(1,newName);
				registerPerson.setString(2,firstName);
				registerPerson.setString(3,lastName);
				registerPerson.setString(4,address);
				registerPerson.setString(5,email);
				registerPerson.setString(6,phonenumber);
				rows_updated_person = db.executeUpdate(registerPerson);
				registerPerson.close();
				if (rows_updated_person == 1){
					out.print("Registration Successful! Now logged in. You will be redirected in 5 seconds...");
					//Create new cookie for the logged in username
					Cookie UsernameCookie = new Cookie ("User",newName);
					UsernameCookie.setMaxAge(60 * 60);
					response.addCookie(UsernameCookie);
					db.closeConnection();
					//Wait for user to see successfull registration
					response.setHeader("Refresh", "5; URL=home.jsp");
	
				}
				else{
					out.print("Registration Failed! This shouldn't be possible.");
					db.closeConnection();
					response.setHeader("Refresh", "5; URL=index.jsp");
				}
			
			}
			else{
				out.print("Registration Failed!");
				db.closeConnection();
				response.setHeader("Refresh", "5; URL=index.jsp");
				}
		}else{
		out.print("Registration Failed! That username or email address is already in use! You will be redirected in 5 seconds...");
		db.closeConnection();
		response.setHeader("Refresh", "5; URL=index.jsp");}
	%>
</body>
</html>
