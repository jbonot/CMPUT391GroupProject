<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Login Confirmation</title>
</head>
<body>	
	<%@ page language="java" import="java.util.*"%>
<%
	//Get the users username and password
	String username = 	request.getParameter("USERNAME");
	String password = 	request.getParameter("PASSWD");

	//Get the current date
	Date now = new Date();
	String timestamp = now.toString();
	
	
	Cookie UsernameCookie = new Cookie ("OracleUsername",username);
	UsernameCookie.setMaxAge(365 * 24 * 60 * 60);
	response.addCookie(UsernameCookie);

	
	Cookie PasswordCookie = new Cookie ("OraclePassword",password);
	PasswordCookie.setMaxAge(365 * 24 * 60 * 60);
	response.addCookie(PasswordCookie);
%>
<jsp:forward page="LoginAndRegistration.html" />

<p><a href=LoginAndRegistration.html>Click here to continue.</a></p>
</body>
</html>