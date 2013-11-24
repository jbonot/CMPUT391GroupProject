<HTML>
<HEAD>
<TITLE>User Profile</TITLE>
</HEAD>

<BODY>

<%@ page import="proj1.*" %>
<%
	String user = QueryHelper.getUserCookie(request.getCookies());
	if (user == null) {
		response.setHeader("Refresh", "0; URL=index.jsp");
		return;
	}
	
	QueryHelper.printHeader(out, user, null, null, null);
%>
<FORM NAME="UpdateForm" ACTION="updateProfile.jsp" METHOD="post" >
<P>To change your profile fill out the form below. Anything left blank will not be changed.</P>
<TABLE>
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

<INPUT TYPE="submit" NAME="Update" VALUE="UPDATE">
</FORM>

</BODY>
</HTML>

