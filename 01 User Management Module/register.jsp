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
	Username:
	<%
		String newName = 	request.getParameter("NEWUSERNAME");
		out.print(newName);
	%>
	Password:
	<%
		String newPassword = 	request.getParameter("NEWPASSWD");
		out.print(newPassword);
	%>
	First Name:
	<%
		String firstName = 	request.getParameter("FRSTNAME");
		out.print(firstName);
	%>
	Last Name:
	<%
		String lastName = 	request.getParameter("FRSTNAME");
		out.print(lastName);
	%>
	Address:
	<%
		String address = 	request.getParameter("ADDRESS");
		out.print(address);
	%>
	Email:
	<%
		String email = 	request.getParameter("EMAIL");
		out.print(email);
	%>
	Phone Number:
	<%
		String phonenumber = 	request.getParameter("PHONENUMBER");
		out.print(phonenumber);
	%>
	<%
		String cookieUsername = "OracleUsername";
		String cookiePassword = "OraclePassword";
		Cookie cookies [] = request.getCookies ();
		Cookie OracleUsernameCookie = null;
		Cookie OraclePasswordCookie = null;
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
		
		java.util.Date today = new java.util.Date();
		String username = OracleUsernameCookie.getValue();//Need to get username and password from cookie and/or input
		String password = OraclePasswordCookie.getValue();//**************
		SQLAdapter db = new SQLAdapter(username, password);//Create a new instance of the SQL Adapter to use 
		Integer rows_updated = 0;
		Integer rows_updated_person = 0;
		PreparedStatement registerUser = db.prepareStatement("INSERT INTO users(user_name,password,date_registered) VALUES(?,?,?)");	
		registerUser.setString(1, newName);
		registerUser.setString(2, newPassword);
		registerUser.setDate(3, new java.sql.Date(today.getTime()));
		rows_updated = db.executeUpdate(registerUser);
		
								
		out.print("<br>");
		if (rows_updated == 1){
			PreparedStatement registerPerson = db.prepareStatement("INSERT INTO persons(user_name,first_name,last_name,address,email,phone) VALUES(?,?,?,?,?,?)");
			registerPerson.setString(1,newName);
			registerPerson.setString(2,firstName);
			registerPerson.setString(3,lastName);
			registerPerson.setString(4,address);
			registerPerson.setString(5,email);
			registerPerson.setString(6,phonenumber);
			rows_updated_person = db.executeUpdate(registerPerson);
			if (rows_updated_person == 1){
				out.print("Registration Successfull!");
			}
		
		}
			else{
				out.print("Registration Failed ! "+ rows_updated);}
		
		db.closeConnection();

	%>
</body>
</html>
