<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Login Confirmation</title>
</head>
<body>
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
</body>
</html>