/***
 *  A sample program to demonstrate how to use servlet to 
 *  load an image file from the client disk via a web browser
 *  and insert the image into a table in Oracle DB.
 *  
 *  Copyright 2007 COMPUT 391 Team, CS, UofA                             
 *  Author:  Fan Deng
 *                                                                  
 *  Licensed under the Apache License, Version 2.0 (the "License");         
 *  you may not use this file except in compliance with the License.        
 *  You may obtain a copy of the License at                                 
 *      http://www.apache.org/licenses/LICENSE-2.0                          
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *  
 *  Shrink function from
 *  http://www.java-tips.org/java-se-tips/java.awt.image/shrinking-an-image-by-skipping-pixels.html
 *
 *
 *  the table shall be created using the following
      CREATE TABLE images (
           photo_id    int,
           owner_name  varchar(24),
           permitted   int,
           subject     varchar(128),
           place       varchar(128),
           timing      date,
           description varchar(2048),
           thumbnail   blob,
           photo       blob,
           
           PRIMARY KEY(photo_id),
           FOREIGN KEY(owner_name) REFERENCES users,
           FOREIGN KEY(permitted) REFERENCES groups
);
 *
 *  One may also need to create a sequence using the following 
 *  SQL statement to automatically generate a unique pic_id:
 *
 *   CREATE SEQUENCE photo_id_sequence;
 *
 ***/

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import java.util.*;
import java.text.SimpleDateFormat;
import oracle.sql.*;
import oracle.jdbc.*;
import java.awt.Image;
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;

/**
 *  The package commons-fileupload-1.0.jar is downloaded from 
 *         http://jakarta.apache.org/commons/fileupload/ 
 *  and it has to be put under WEB-INF/lib/ directory in your servlet context.
 *  One shall also modify the CLASSPATH to include this jar file.
 */
import org.apache.commons.fileupload.DiskFileUpload;
import org.apache.commons.fileupload.FileItem;

public class UploadImage extends HttpServlet
{
    public String response_message;

    public void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException
    {

        // use a cookie to retrieve oracle database information, as well as current username.
        String cookieUsername = "OracleUsername";
        String cookiePassword = "OraclePassword";
        String currentUser = "Username";
        
        Cookie cookies [] = request.getCookies ();
        Cookie OracleUsernameCookie = null;
        Cookie OraclePasswordCookie = null;
        Cookie currentUserCookie = null;
        
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
        if (cookies != null){
            for (int i = 0; i < cookies.length; i++) {
                if (cookies [i].getName().equals (currentUser)){
                    currentUserCookie = cookies[i];
                    break;
                }
            }
        }
        
        //connect to db
        String username = OracleUsernameCookie.getValue();//Need to get username and password from cookie and/or input
        String password = OraclePasswordCookie.getValue();//**************
        SQLAdapter db = new SQLAdapter(username, password);//Create a new instance of the SQL Adapter to use
        
        //store current user's name in string
        String user = currentUserCookie.getValue();
        
        //Uploaded picture and associated values
        int pic_id;
        String subject, place, day, month, year, description;
        int security;

        try
        {
            //TODO add error handling for blank strings
            //parse string data
            subject = request.getParameter("subject");
            place = request.getParameter("place");
            day = request.getParameter("day");
            month = request.getParameter("month");
            year = request.getParameter("year");
            description = request.getParameter("description");
            security = Integer.parseInt(request.getParameter("security"));
            
            //create SimpleDateFormat object, parse into sql date object
            String date = year + "-" + month + "-" + day;
            SimpleDateFormat sdf = new SimpleDateFormat(yyyy-MM-dd);
            java.util.Date parse = sdf.parse(date);
            java.sql.Date when = new Date(date.getTime());
            
            // Parse the HTTP request to get the image stream
            DiskFileUpload fu = new DiskFileUpload();
            List FileItems = fu.parseRequest(request);

            // Process the uploaded items, assuming only 1 image file uploaded
            Iterator i = FileItems.iterator();
            FileItem item = (FileItem) i.next();
            while (i.hasNext() && item.isFormField())
            {
                item = (FileItem) i.next();
            }

            // Get the image stream
            InputStream instream = item.getInputStream();

            BufferedImage img = ImageIO.read(instream);
            BufferedImage thumbNail = shrink(img, 10);


            /*
             * First, to generate a unique pic_id using an SQL sequence
             */
            PreparedStatement getId = db.PrepareStatement("SELECT photo_id_sequence.nextval from DUAL");
            ResultSet rset1 = db.ExecuteQuery(getId);
            rset1.next();
            pic_id = rset1.getInt(1);
            getId.close();

            // Insert an empty blob into the table first. Note that you have to
            // use the Oracle specific function empty_blob() to create an empty
            // blob
            
            PreparedStatement insertData = db.PrepareStatement("INSERT INTO images VALUES" +
            		"(?, ?, ?, ?, ?, ?, ?, empty_blob(), empty_blob()");
            
            insertData.setString(1, pic_id);
            insertData.setString(2, user);
            insertData.setString(3, security);
            insertData.setString(4, subject);
            insertData.setString(5, place);
            insertData.setDate(6, when);
            insertData.setString(7, description);
            
            //TODO add exception handling for when the insert does not work
            int numRows = db.executeUpdate(insertData);
            insertData.close();

            // to retrieve the lob_locator
            // Note that you must use "FOR UPDATE" in the select statement
            PreparedStatement fillBlobs = "SELECT * FROM images WHERE pic_id = " + pic_id
                    + " FOR UPDATE";
            ResultSet rset = db.executeQuery(fillBlobs);
            rset.next();
            BLOB myblob = ((OracleResultSet) rset).getBLOB(8);

            // Write the thumbnail to the blob object
            OutputStream outstream = myblob.getBinaryOutputStream();
            ImageIO.write(thumbNail, "jpg", outstream);
            
            //write bigger image
            myblob = ((OracleResultSet) rset).getBLOB(9);
            outstream = myblob.getBinaryOutputStream();
            ImageIO.write(img, "jpg", outstream);
            


            /*
             * int size = myblob.getBufferSize(); byte[] buffer = new
             * byte[size]; int length = -1; while ((length =
             * instream.read(buffer)) != -1) outstream.write(buffer, 0, length);
             */
            instream.close();
            outstream.close();
            
            PreparedStatement commit = db.PrepareStatement("commit");
            db.executeUpdate(commit);
            commit.close();
            response_message = " Upload OK!  ";
            db.closeConnection();

        }
        catch (Exception ex)
        {
            // System.out.println( ex.getMessage());
            response_message = ex.getMessage();
        }

        // Output response to the client
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        out.println("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 "
                + "Transitional//EN\">\n" + "<HTML>\n"
                + "<HEAD><TITLE>Upload Message</TITLE></HEAD>\n" + "<BODY>\n"
                + "<H1>" + response_message + "</H1>\n" + "</BODY></HTML>");
    }

    // shrink image by a factor of n, and return the shrinked image
    public static BufferedImage shrink(BufferedImage image, int n)
    {

        int w = image.getWidth() / n;
        int h = image.getHeight() / n;

        BufferedImage shrunkImage = new BufferedImage(w, h, image.getType());

        for (int y = 0; y < h; ++y)
            for (int x = 0; x < w; ++x)
                shrunkImage.setRGB(x, y, image.getRGB(x * n, y * n));

        return shrunkImage;
    }
}
