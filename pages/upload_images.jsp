<html><head><title>Upload multiple images</title></head><body>
<h1>Upload Multiple Images...</h1>

	

<applet code="applet-basic_files/wjhk.JUploadApplet" name="JUpload" archive="applet-basic_files/wjhk.jar" mayscript="" height="300" width="640">
    <param name="CODE" value="wjhk.jupload2.JUploadApplet">
    <param name="ARCHIVE" value="wjhk.jupload.jar">
    <param name="type" value="application/x-java-applet;version=1.4">
    <param name="scriptable" value="false">    
    <param name="postURL"
    value="http://luscar.cs.ualberta.ca:8080/yuan/parseRequest.jsp?URLParam=URL+Parameter+Value">
    <param name="nbFilesPerRequest" value="2">    
Java 1.4 or higher plugin required.
</applet>

			</td>
		</tr>
        </tbody></table>
        
      <form name="upload-image" method="POST" enctype="multipart/form-data" action="UploadImage.jsp">
		<table>
			<tr>
				<th>Image path:</th>
				<td><input name="file-path" type="file" size="30"></input></td>
			</tr>

			<tr>
				<td><b>Subject:</b></td>
				<td><INPUT TYPE="text" NAME="subject" VALUE=""
					style="width: 346px;"></td>
			</tr>
			<tr>
				<td><b>Place:</b></td>
				<b> </b>
				<td><INPUT TYPE="text" NAME="place" VALUE=""
					style="width: 346px;"></td>
				<b> </b>
			</tr>
			<b> </b>
			<tr>
				<b> </b>
				<td><b>When:</b></td>
				<b> </b>
				<td><select name="month">
					<option value="01">January
					<option value="02">February
					<option value="03">March
					<option value="04">April
					<option value="05">May
					<option value="06">June
					<option value="07">July
					<option value="08">August
					<option value="09">September
					<option value="10">October
					<option value="11">November
					<option value="12">December
					</select>
					<select name="day">
	<option value="01">1
	<option value="02">2
	<option value="03">3
	<option value="04">4
	<option value="05">5
	<option value="06">6
	<option value="07">7
	<option value="08">8
	<option value="09">9
	<option value="10">10
	<option value="11">11
	<option value="12">12
	<option value="13">13
	<option value="14">14
	<option value="15">15
	<option value="16">16
	<option value="17">17
	<option value="18">18
	<option value="19">19
	<option value="20">20
	<option value="21">21
	<option value="22">22
	<option value="23">23
	<option value="24">24
	<option value="25">25
	<option value="26">26
	<option value="27">27
	<option value="28">28
	<option value="29">29
	<option value="30">30
	<option value="31">31
</select>
					<select name="year">
			<option value="1991">1991
			<option value="1992">1992
			<option value="1993">1993
			<option value="1994">1994
			<option value="1995">1995
			<option value="1996">1996
			<option value="1997">1997
			<option value="1998">1998
			<option value="1999">1999
			<option value="2000">2000
			<option value="2001">2001
			<option value="2002">2002		
			<option value="2002">2002
			<option value="2003">2003
			<option value="2004">2004
			<option value="2005">2005
			<option value="2006">2006
			<option value="2007">2007
			<option value="2008">2008
			<option value="2009">2009
			<option value="2010">2010
			<option value="2011">2011
			<option value="2012">2012
			<option value="2013">2013
	</select>
				</td>
				<b> </b>
			</tr>
			<b> </b>
			<tr>
				<b> </b>
				<td><b>Description:</b></td>
				<b> </b>
				<td><textarea name="description" rows="10" cols="30" style="width: 346px;">
</textarea></td>
				<b> </b>
			</tr>
			<b> </b>
			<tr>
				<b> </b>
				<td><b>Security Level:</b></td>
				<td>
						<select name="security" style="width: 342px;">
							<option value="1">Public (Everyone can see it)</option>
							<option value="2">Private (Only you can see it)</option>

						</select>
				</td>
			</tr>
			<tr>
				<td ALIGN="CENTER" COLSPAN="2"><input type="submit" name=".submit" value="Submit"/></td>
			</tr>
		</table>
	</form>


 </body></html>