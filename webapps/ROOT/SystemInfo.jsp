<html>
<head>
<title>System Info Page</title>
</head>
<body bgcolor='#ffffff'>
<%@ page import="java.io.InputStream,
                 java.io.IOException,
                 java.util.*,
                 javax.xml.parsers.SAXParser,
                 javax.xml.parsers.SAXParserFactory"
    session="false" %>
<%!

    /*
     * Happiness tests for axis. These look at the classpath and warn if things
     * are missing. Normally addng this much code in a JSP page is mad
     * but here we want to validate JSP compilation too, and have a drop-in
     * page for easy re-use
     * @author Steve 'configuration problems' Loughran
     */


    /**
     * Get a string providing install information.
     * TODO: make this platform aware and give specific hints
     */
    public String getInstallHints(HttpServletRequest request) {

        String hint=
            "<B><I>Note:</I></B> On Tomcat 4.x, you may need to put libraries that contain "
            +"java.* or javax.* packages into CATALINA_HOME/commons/lib";
        return hint;
    }

    /**
     * test for a class existing
     * @param classname
     * @return class iff present
     */
    Class classExists(String classname) {
        try {
            return Class.forName(classname);
        } catch (ClassNotFoundException e) {
            return null;
        }
    }

    /**
     * test for resource on the classpath
     * @param resource
     * @return true iff present
     */
    boolean resourceExists(String resource) {
        boolean found;
        InputStream instream=this.getClass().getResourceAsStream(resource);
        found=instream!=null;
        if(instream!=null) {
            try {
                instream.close();
            } catch (IOException e) {
            }
        }
        return found;
    }

    /**
     * probe for a class, print an error message is missing
     * @param out stream to print stuff
     * @param category text like "warning" or "error"
     * @param classname class to look for
     * @param jarFile where this class comes from
     * @param errorText extra error text
     * @param homePage where to d/l the library
     * @return the number of missing classes
     * @throws IOException
     */
    int probeClass(JspWriter out,
                   String category,
                   String classname,
                   String jarFile,
                   String description,
                   String errorText,
                   String homePage) throws IOException {

       Class clazz = classExists(classname);
       if(clazz == null)  {
            String url="";
            if(homePage!=null) {
                url="<br>  See <a href="+homePage+">"+homePage+"</a>";
            }
            out.write("<p>"+category+": could not find class "+classname
                    +" from file <b>"+jarFile
                    +"</b><br>  "+errorText
                    +url
                    +"<p>");
            return 1;
        } else {
            String location = getLocation(out, clazz);
            if(location == null) {
                out.write("Found "+ description + " (" + classname + ")<br>");
            }
            else {
                out.write("Found "+ description + " (" + classname + ") at " + location + "<br>");
            }
            return 0;
        }
    }

    /**
     * get the location of a class
     * @param out
     * @param clazz
     * @return the jar file or path where a class was found
     * @throws IOException
     */

    String getLocation(JspWriter out,
                       Class clazz) throws IOException {
        try {
            java.net.URL url = clazz.getProtectionDomain().getCodeSource().getLocation();
            String location = url.toString();
            if(location.startsWith("jar")) {
                url = ((java.net.JarURLConnection)url.openConnection()).getJarFileURL();
                location = url.toString();
            } 
            
            if(location.startsWith("file")) {
                java.io.File file = new java.io.File(url.getFile());
                return file.getAbsolutePath();
            } else {
                return url.toString();
            }
        } catch (Throwable t){
        }
        return null;
    }

    /**
     * a class we need if a class is missing
     * @param out stream to print stuff
     * @param classname class to look for
     * @param jarFile where this class comes from
     * @param errorText extra error text
     * @param homePage where to d/l the library
     * @throws IOException when needed
     * @return the number of missing libraries (0 or 1)
     */
    int needClass(JspWriter out,
                   String classname,
                   String jarFile,
                   String description,
                   String errorText,
                   String homePage) throws IOException {
        return probeClass(out,
                "<b>Error</b>",
                classname,
                jarFile,
                description,
                errorText,
                homePage);
    }

    /**
     * print warning message if a class is missing
     * @param out stream to print stuff
     * @param classname class to look for
     * @param jarFile where this class comes from
     * @param errorText extra error text
     * @param homePage where to d/l the library
     * @throws IOException when needed
     * @return the number of missing libraries (0 or 1)
     */
    int wantClass(JspWriter out,
                   String classname,
                   String jarFile,
                   String description,
                   String errorText,
                   String homePage) throws IOException {
        return probeClass(out,
                "<b>Warning</b>",
                classname,
                jarFile,
                description,
                errorText,
                homePage);
    }

    /**
     * probe for a resource existing,
     * @param out
     * @param resource
     * @param errorText
     * @throws Exception
     */
    int wantResource(JspWriter out,
                      String resource,
                      String errorText) throws Exception {
        if(!resourceExists(resource)) {
            out.write("<p><b>Warning</b>: could not find resource "+resource
                        +"<br>"
                        +errorText);
            return 0;
        } else {
            out.write("found "+resource+"<br>");
            return 1;
        }
    }


    /**
     *  get servlet version string
     *
     */

    public String getServletVersion() {
        ServletContext context=getServletConfig().getServletContext();
        int major = context.getMajorVersion();
        int minor = context.getMinorVersion();
        return Integer.toString(major) + '.' + Integer.toString(minor);
    }

    /**
     *
     * @return the classname of the parser
     */
    public String getParserName() throws Exception {
        // Create a JAXP SAXParser
        SAXParserFactory saxParserFactory = SAXParserFactory.newInstance();
        if(saxParserFactory==null) {
            return "no XML parser factory found";
        }
        SAXParser saxParser = saxParserFactory.newSAXParser();
        if(saxParser==null) {
            return "Could not create an XML Parser";
        }

        // check to what is in the classname
        String saxParserName = saxParser.getClass().getName();
        return saxParserName;
    }

    %>
    <h2>Plattform Information</h2>
<table border=0>
<tr><td bgcolor="#CCCCCC">Servlet Engine</td><td><%= getServletConfig().getServletContext().getServerInfo()  %></td></tr>
<tr><td bgcolor="#CCCCCC">Operating System</td><td><%= System.getProperty("os.name")  %></td></tr>
<tr><td bgcolor="#CCCCCC">OS Version</td><td><%= System.getProperty("os.version")  %></td></tr>
<tr><td bgcolor="#CCCCCC">Client Hostname</td><td><%= java.net.InetAddress.getLocalHost().getHostName()  %></td></tr>
<tr><td bgcolor="#CCCCCC">Java Version</td><td><%= System.getProperty("java.version")  %></td></tr>
<tr><td bgcolor="#CCCCCC">Java FullVersion</td><td><%= System.getProperty("java.fullversion")  %></td></tr>
<tr><td bgcolor="#CCCCCC">Max Memory MB</td><td><%= java.lang.Runtime.getRuntime().maxMemory()/1024/1024  %></td></tr>
<tr><td bgcolor="#CCCCCC">Total Memory MB</td><td><%= (java.lang.Runtime.getRuntime().totalMemory()/1024/1024)  %></td></tr>
<tr><td bgcolor="#CCCCCC">Free Memory MB</td><td><%= java.lang.Runtime.getRuntime().freeMemory()/1024/1024  %></td></tr>
<tr><td bgcolor="#CCCCCC">Used Memory MB</td><td><%= (java.lang.Runtime.getRuntime().totalMemory() - java.lang.Runtime.getRuntime().freeMemory())/1024/1024  %></td></tr>
<tr><td bgcolor="#CCCCCC">Your browser is</td><td><%= request.getHeader("User-Agent") %></td></tr>
<tr><td bgcolor="#CCCCCC">Your IP address</td><td><%= request.getRemoteAddr() %></td></tr>
</table>

    <h2>Examining Application Server</h2>

<table border=0>
<tr><td bgcolor="#CCCCCC">Servlet version</td><td><%= getServletVersion() %></td></tr>
<tr><td bgcolor="#CCCCCC">XML Parser</td><td><%= getParserName() %></td></tr>
</table>

    <h2>Examining System Properties</h2>
<%
    java.util.Enumeration e=null;
    try {
        e = System.getProperties().propertyNames();
    } catch (SecurityException se) {
    }
    if(e!=null) {
        out.println("<table border=0>");
        Properties p = System.getProperties();
        SortedMap sortedp = new TreeMap(p);
        Set keySet = sortedp.keySet();
        Iterator iterator = keySet.iterator();
        //Enumeration e = p.e();
        while (iterator.hasNext()) {
            String propertyName = (String) iterator.next();
            String propertyValue = p.getProperty(propertyName);
            out.println("<tr><td bgcolor=\"#CCCCCC\">");
            out.println(propertyName);
            out.println("</td><td>");
            out.println(propertyValue);
            out.println("</td></tr>");
        }
        out.println("</table>");
    } else {
        out.write("System properties are not accessible<p>");
    }
%>



</body>
</html>
