<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Login Confirmation</title>
</head>
<body>


	<%@ page import="proj1.*"%>
	<%@ page import="java.sql.*"%>
	<%
		//Get the provided username and password
		String fUsername = request.getParameter("USERNAME");
		String fPassword = request.getParameter("PASSWD");

		//Get the current date and get the user and maxage if there is a cookie
		java.util.Date today = new java.util.Date();
		
		//Create a new instance of the SQL Adapter to use 	
		SQLAdapter db = new SQLAdapter();

		//Setup the prepared statement and try to log in
		PreparedStatement loginUser = db
				.prepareStatement("SELECT * FROM users where user_name = ? and password = ?");
		loginUser.setString(1, fUsername);
		loginUser.setString(2, fPassword);
		ResultSet rset = db.executeQuery(loginUser);

		boolean empty = true;
		if (rset.next()) {
			// Successful login.
			Cookie userCookie = new Cookie("User",
					rset.getString("user_name"));
			userCookie.setMaxAge(60 * 60); // 1 hour
			response.addCookie(userCookie);
			loginUser.close();
			db.closeConnection();
			empty = false;
			response.setHeader("Refresh", "0; URL=home.jsp");
		} else {
				//If the login information is wrong notify the user and redirect them
				out.println("Login Failed! You will be redirected in 5 seconds...");
				out.print("<br>");
				out.print("<p><a href=index.jsp>Click here to be redirected now.</a></p>");
				loginUser.close();
				db.closeConnection();
				response.setHeader("Refresh", "5; URL=/");
		}
	%>
</body>
</html>
