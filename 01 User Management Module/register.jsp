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
		SQLAdapter db = new SQLAdapter();//Create a new instance of the SQL Adapter to use 
		
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
		
		
		db.m_userName = OracleUsernameCookie.getValue();//Need to get username and password from cookie and/or input
		db.m_password = OraclePasswordCookie.getValue();//**************
		db.registerDriver();//Try and register the oracle driver with the supplied username and password
		
		
		
		
		ResultSet rset;
		rset = db.executeStatement("Select * from groups");//Execute the statement and get results in rset
		out.print("<br>");
		if (rset != null){
			while (rset.next()) {
			      // It is possible to get the columns via name
			      // also possible to get the columns via the column number
			      // which starts at 1
			      String group_id = rset.getString("group_id");
			      String group_name = rset.getString("group_name");
			      String user_name = rset.getString("user_name");
			      out.print(" Group ID: " + group_id);
			      out.print(" Group Name: " + group_name);
			      out.print(" Username: " + user_name);
			      out.print("<br>");
			 }
		}
	%>
</body>
</html>