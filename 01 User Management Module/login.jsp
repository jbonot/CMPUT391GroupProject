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
	<%
		String fUsername = 	request.getParameter("USERNAME");
	%>
	<%
		String fPassword = 	request.getParameter("PASSWD");
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
			
				
		PreparedStatement loginUser = db.prepareStatement("SELECT * FROM users where user_name = ? and password = ?");	
		loginUser.setString(1, fUsername);
		loginUser.setString(2, fPassword);
		ResultSet rset = db.executeQuery(loginUser);
		
		out.print("<br>");
		boolean empty = true;
		while(rset.next()){
			out.println("Login Successfull!");
			empty = false;
		}
		if (empty){
			out.println("Login Failed! You will be redirected in 5 seconds...");
			out.print("<br>");
			out.print("<p><a href=LoginAndRegistration.html>Click here to be redirected now.</a></p>");
			
			response.setHeader("Refresh", "5; URL=LoginAndRegistration.html");
		}else{//FORWARD UPON SUCCESSFULL LOGIN
			Cookie UsernameCookie = new Cookie ("Username",fUsername);
			UsernameCookie.setMaxAge(365 * 24 * 60 * 60);
			response.addCookie(UsernameCookie);
		%>
			<jsp:forward page="LoginAndRegistration.html" />
		<%}
		
		db.closeConnection();

	%>
</body>
</html>