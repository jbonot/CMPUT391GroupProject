<HTML>
<HEAD>
<SCRIPT type="text/javascript">
function getCookie(c_name)
{
var c_value = document.cookie;
var c_start = c_value.indexOf(" " + c_name + "=");
if (c_start == -1)
  {
  c_start = c_value.indexOf(c_name + "=");
  }
if (c_start == -1)
  {
  c_value = null;
  }
else
  {
  c_start = c_value.indexOf("=", c_start) + 1;
  var c_end = c_value.indexOf(";", c_start);
  if (c_end == -1)
  {
c_end = c_value.length;
}
c_value = unescape(c_value.substring(c_start,c_end));
}
return c_value;
}

function checkCookie()
{
var username=getCookie("User");
if (username!=null && username!="")
  {
	alert(username);
  }
}
</SCRIPT>
<TITLE>CMPUT 391 Login/Registration</TITLE>
</HEAD>
<BODY>
	<!--This is the login page-->
	<%
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

		if (UserCookie != null) {
			if (UserCookie.getMaxAge() != 0) {
				response.setHeader("Refresh", "0; URL=home.jsp");
			}
		}
	%>
	<H1>Login</H1>

	<FORM NAME="LoginForm" ACTION="login.jsp" METHOD="post">

		<P>To login successfully, you need to submit a valid username and
			password</P>
		<TABLE>
			<TR VALIGN=TOP ALIGN=LEFT>
				<TD><B><I>Username:</I></B></TD>
				<TD><INPUT TYPE="text" NAME="USERNAME" VALUE=""><BR></TD>
			</TR>
			<TR VALIGN=TOP ALIGN=LEFT>
				<TD><B><I>Password:</I></B></TD>
				<TD><INPUT TYPE="password" NAME="PASSWD" VALUE=""></TD>
			</TR>
		</TABLE>

		<INPUT TYPE="submit" NAME="Submit" VALUE="LOGIN">
	</FORM>

	<H1>Register</H1>

	<FORM NAME="RegisterForm" ACTION="register.jsp" METHOD="post">

		<P>To register fill out and submit the form below.</P>
		<TABLE>
			<TR VALIGN=TOP ALIGN=LEFT>
				<TD><B><I>Username:</I></B></TD>
				<TD><INPUT TYPE="text" NAME="NEWUSERNAME" VALUE=""><BR></TD>
			</TR>
			<TR VALIGN=TOP ALIGN=LEFT>
				<TD><B><I>Password:</I></B></TD>
				<TD><INPUT TYPE="password" NAME="NEWPASSWD" VALUE=""></TD>
			</TR>
			<TR VALIGN=TOP ALIGN=LEFT>
				<TD><B><I>First Name:</I></B></TD>
				<TD><INPUT TYPE="text" NAME="FRSTNAME" VALUE=""></TD>
			</TR>
			<TR VALIGN=TOP ALIGN=LEFT>
				<TD><B><I>Last Name:</I></B></TD>
				<TD><INPUT TYPE="text" NAME="LASTNAME" VALUE=""></TD>
			</TR>
			<TR VALIGN=TOP ALIGN=LEFT>
				<TD><B><I>Address:</I></B></TD>
				<TD><INPUT TYPE="text" NAME="ADDRESS" VALUE=""></TD>
			</TR>
			<TR VALIGN=TOP ALIGN=LEFT>
				<TD><B><I>Email:</I></B></TD>
				<TD><INPUT TYPE="text" NAME="EMAIL" VALUE=""></TD>
			</TR>
			<TR VALIGN=TOP ALIGN=LEFT>
				<TD><B><I>Phone Number:</I></B></TD>
				<TD><INPUT TYPE="text" NAME="PHONENUMBER" VALUE=""></TD>
			</TR>
		</TABLE>

		<INPUT TYPE="submit" NAME="Register" VALUE="REGISTER">
	</FORM>

</BODY>
</HTML>

