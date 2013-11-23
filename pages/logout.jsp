<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Logging out...</title>
</head>
<body>
	<%
		Cookie cookies[] = request.getCookies();
		Cookie UserCookie = null;
		String name = null;
		//Set the max age for the cookie to 0 (0 means it should be deleted)
		if (cookies != null) {
			for (int i = 0; i < cookies.length; i++) {
				if (cookies[i].getName().equals("User")) {
					System.out.println("logout.jsp cookie value: " + cookies[i].getValue());
					name = cookies[i].getValue();
					Cookie cookie = new Cookie("User", name);
					cookie.setPath("index.jsp");
					cookie.setMaxAge(0);
					response.addCookie(cookie);
					break;
				}
			}
		}
		response.setHeader("Refresh", "0; URL=index.jsp");
	%>

</body>
</html>
