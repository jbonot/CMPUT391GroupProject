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
import java.sql.Date;
import java.util.*;
import java.text.SimpleDateFormat;
import oracle.sql.*;
import oracle.jdbc.*;
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;
import proj1.*;

/**
 *  The package commons-fileupload-1.0.jar is downloaded from 
 *         http://jakarta.apache.org/commons/fileupload/ 
 *  and it has to be put under WEB-INF/lib/ directory in your servlet context.
 *  One shall also modify the CLASSPATH to include this jar file.
 */
import org.apache.commons.fileupload.DiskFileUpload;
import org.apache.commons.fileupload.FileItem;

@SuppressWarnings("deprecation")
public class UploadImage extends HttpServlet
{
    /**
     * 
     */
    private static final long serialVersionUID = 8458915138413468330L;
    public String response_message;

    public void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException
    {   
        //html printer
        PrintWriter out = response.getWriter();
        
        //connect to db
        SQLAdapter db = new SQLAdapter();//Create a new instance of the SQL Adapter to use
        
        //store current user's name in string from the cookie
        String user = HtmlPrinter.getUserCookie(request.getCookies());
        //if cookie no longer valid, send back to login page
        if (user.equals(null)) {
            response.setHeader("Refresh", "0; URL=index.jsp");
            return;
        }
        
        //declare and initialize all needed form values to default
        int pic_id;
        String subject = "", place = "", description = "",
                day = "", month = "", year = "";
        int security = 0;
        
        //declare array of input streams, images, and image thumbnails
        Vector<InputStream> instream = new Vector<InputStream>();
        Vector<BufferedImage> img = new Vector<BufferedImage>();
        Vector<BufferedImage> thumbNail = new Vector<BufferedImage>();

        try
        {   
            // Parse the HTTP request to get the image stream
            DiskFileUpload fu = new DiskFileUpload();
            @SuppressWarnings("rawtypes")
            List FileItems = fu.parseRequest(request);

            // Process the uploaded items and form fields
            @SuppressWarnings("rawtypes")
            Iterator i = FileItems.iterator();
            FileItem item = (FileItem) i.next();
            while (i.hasNext())
            {
                //parse form data for photo
                if(item.isFormField())
                {
                    if(item.getFieldName().equals("subject"))
                        subject = item.getString();
                    
                    else if(item.getFieldName().equals("place"))
                        place = item.getString();
                    
                    else if(item.getFieldName().equals("day"))
                        day = item.getString();
                    
                    else if(item.getFieldName().equals("month"))
                        month = item.getString();
                    
                    else if(item.getFieldName().equals("year"))
                        year = item.getString();
                    
                    else if(item.getFieldName().equals("description"))
                        description = item.getString();
                    
                    else if(item.getFieldName().equals("security"))
                        security = Integer.parseInt(item.getString());

                }
                //parse photos themselves
                else
                {
                    //check if file is a jpg or png. if not, refresh page.
                    String type = item.getContentType();
                    if(type.equals("image/jpeg") || type.equals("image/gif"))
                    {
                        //get image stream, put into array
                        instream.add(item.getInputStream());
                        img.add(ImageIO.read(instream.lastElement()));
                        thumbNail.add(shrink(img.lastElement(), 5));
                    }
                    else if(type.equals("application/octet-stream"))
                    {
                        response_message = " Nothing submitted for files!  ";
                        writeResponse(response, out);
                        response.setHeader("Refresh", "2; URL=upload_image.jsp");
                        return;
                    }
                    else
                    {
                        response_message = " Improper file type(s) uploaded!  ";
                        writeResponse(response, out);
                        response.setHeader("Refresh", "2; URL=upload_image.jsp");
                        return;
                    }
                }
                item = (FileItem) i.next();
            }

            //create SimpleDateFormat object, parse into sql date object
            java.sql.Date when;
            try
            {
                String date = year + "-" + month + "-" + day;
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                sdf.setLenient(false);
                java.util.Date parse = sdf.parse(date);
                when = new Date(parse.getTime());
            }
            catch(Exception e)
            {
                response_message = " Invalid Date Entered!  ";
                writeResponse(response, out);
                response.setHeader("Refresh", "2; URL=upload_image.jsp");
                return;
            }
            
            for(int j = 0; j < img.size(); j++)
            {
                //generate a unique pic_id using photo_id_sequence
                PreparedStatement getId = db.prepareStatement("SELECT photo_id_sequence.nextval from DUAL");
                ResultSet rset1 = db.executeQuery(getId);
                rset1.next();
                pic_id = rset1.getInt(1);
                rset1.close();
                getId.close();
    
                //Prepare an INSERT statement, then embed gathered values into statement
                PreparedStatement insertData = db.prepareStatement("INSERT INTO images VALUES" +
                		"(?, ?, ?, ?, ?, ?, ?, empty_blob(), empty_blob())");
                
                insertData.setInt(1, pic_id);
                insertData.setString(2, user);
                insertData.setInt(3, security);
                insertData.setString(4, subject);
                insertData.setString(5, place);
                insertData.setDate(6, when);
                insertData.setString(7, description);
                db.executeUpdate(insertData);
                insertData.close();
                
                //now select empty blobs from the row, and update them
                PreparedStatement fillBlobs = db.prepareStatement("SELECT * FROM images WHERE photo_id = ? FOR UPDATE");
                fillBlobs.setInt(1, pic_id);
                ResultSet rset2 = db.executeQuery(fillBlobs);
                rset2.next();

                // Write the thumbnail to the blob object
                BLOB myThumbnail = ((OracleResultSet) rset2).getBLOB(8);
                OutputStream outstreamThumb = myThumbnail.setBinaryStream(0);
                ImageIO.write(thumbNail.elementAt(j), "jpg", outstreamThumb);
                
                //write bigger image to next blob
                BLOB myImg = ((OracleResultSet) rset2).getBLOB(9);
                OutputStream outstreamImg = myImg.setBinaryStream(0);
                ImageIO.write(img.elementAt(j), "jpg", outstreamImg);
                
                instream.elementAt(j).close();
                outstreamThumb.close();
                outstreamImg.close();
                    
                //close streams and commit the row change
                rset2.close();
                fillBlobs.close();
            }
            
            db.closeConnection();
            response_message = " Upload OK!  ";
        }
        catch (Exception ex)
        {
            response_message = ex.getMessage();
            ex.printStackTrace();
        }

        writeResponse(response, out);
        response.setHeader("Refresh", "2; URL=home.jsp");
        return;
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
    
    //give user response after clicking submit button
    public void writeResponse(HttpServletResponse response, PrintWriter out)
    {
        // Output response to the client
        response.setContentType("text/html");
        out.println("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 "
                + "Transitional//EN\">\n" + "<HTML>\n"
                + "<HEAD><TITLE>Upload Message</TITLE></HEAD>\n" + "<BODY>\n"
                + "<H1>" + response_message + "</H1>\n" + "</BODY></HTML>");
    }
}
