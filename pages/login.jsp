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
		String fUsername = request.getParameter("USERNAME");
		String fPassword = request.getParameter("PASSWD");
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

		java.util.Date today = new java.util.Date();
		String user = UserCookie != null ? UserCookie.getValue() : null;
		Integer maxAge = UserCookie != null ? UserCookie.getMaxAge() : null;
		SQLAdapter db = new SQLAdapter();//Create a new instance of the SQL Adapter to use 	
		System.out.println(user);
		//Check if a user is already logged in and cookie isnt expired
		if ((user != null) && (maxAge > 0)) {
	%>
	<jsp:forward page="home.jsp" />
	<%
		} else {
			PreparedStatement loginUser = db
					.prepareStatement("SELECT * FROM users where user_name = ? and password = ?");
			loginUser.setString(1, fUsername);
			loginUser.setString(2, fPassword);
			ResultSet rset = db.executeQuery(loginUser);

			out.print("<br>");
			boolean empty = true;
			if (rset.next()) {
				// Successful login.
				Cookie userCookie = new Cookie("User",
						rset.getString("user_name"));
				userCookie.setMaxAge(30 * 60); // 30 minutes
				response.addCookie(userCookie);
				loginUser.close();
				db.closeConnection();
				empty = false;
	%>
	<jsp:forward page="home.jsp" />
	<%
		} else {
				out.println("Login Failed! You will be redirected in 5 seconds...");
				out.print("<br>");
				out.print("<p><a href=index.html>Click here to be redirected now.</a></p>");
				loginUser.close();
				db.closeConnection();
				response.setHeader("Refresh", "5; URL=index.html");
			}
		}
	%>
</body>
</html>
