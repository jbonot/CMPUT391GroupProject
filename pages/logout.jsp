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
	Cookie cookies[] = request.getCookies();
	Cookie UserCookie = null;
	//Set the max age for the cookie to 0 (0 means it should be deleted)
	if (cookies != null) {
		for (int i = 0; i < cookies.length; i++) {
			if (cookies[i].getName().equals("User")) {
				cookies[i].setMaxAge(0);
				break;
			}
		}
	}
	out.println("Logout Successful! You will be redirected in 3 seconds...");
	response.setHeader("Refresh", "3; URL=index.html");
	%>

</body>
</html>
