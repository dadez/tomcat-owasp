<%@ page import="java.lang.management.*" %>
<%@ page import="java.util.*" %>

<title>Tomcat host + memory information: <%= java.net.InetAddress.getLocalHost().getHostName() %> </title>

<table border=0>
<tr><td bgcolor="#CCCCCC">Client Hostname</td><td><%= java.net.InetAddress.getLocalHost().getHostName() %></td></tr>
<tr><td bgcolor="#CCCCCC">Max Memory MB</td><td><%= java.lang.Runtime.getRuntime().maxMemory()/1024/1024 %></td></tr>
<tr><td bgcolor="#CCCCCC">Total Memory MB</td><td><%= (java.lang.Runtime.getRuntime().totalMemory()/1024/1024)  %></td></tr>
<tr><td bgcolor="#CCCCCC">Free Memory MB</td><td><%= java.lang.Runtime.getRuntime().freeMemory()/1024/1024  %></td></tr>
<tr><td bgcolor="#CCCCCC">Used Memory MB</td><td><%= (java.lang.Runtime.getRuntime().totalMemory() - java.lang.Runtime.getRuntime().freeMemory())/1024/1024  %></td></tr>
<tr><td bgcolor="#CCCCCC">Your browser is</td><td><%= request.getHeader("User-Agent") %></td></tr>
<tr><td bgcolor="#CCCCCC">Your IP address</td><td><%= request.getRemoteAddr() %></td></tr>
</table>



<h2 style="text-decoration: underline;">JVM Memory Monitor</h2>

<h3>Memory MXBean</h3>
<table border=0>
<tr><td bgcolor="#CCCCCC">Heap Memory Usage</td><td><%= ManagementFactory.getMemoryMXBean().getHeapMemoryUsage() %><br></td></tr>
<tr><td bgcolor="#CCCCCC">Non-Heap Memory Usage</td><td><%= ManagementFactory.getMemoryMXBean().getNonHeapMemoryUsage() %><br></td></tr>
</table>


<h3>Memory Pool MXBeans</h3>
<%
out.println("<table border=0>");
Iterator iter = ManagementFactory.getMemoryPoolMXBeans().iterator();
while (iter.hasNext()) {
MemoryPoolMXBean item = (MemoryPoolMXBean) iter.next();
            out.println("<tr><td bgcolor=\"#CCCCCC\">");
            out.println("Name");
            out.println("</td><td>");
            out.println("<b>" + item.getName() + "</b>");
            out.println("</td></tr>");
            out.println("<tr><td bgcolor=\"#CCCCCC\">");
            out.println("Type");
            out.println("</td><td>");
            out.println(item.getType());
            out.println("</td></tr>");
            out.println("<tr><td bgcolor=\"#CCCCCC\">");
            out.println("Usage");
            out.println("</td><td>");
            out.println(item.getUsage());
            out.println("</td></tr>");
            out.println("<tr><td bgcolor=\"#CCCCCC\">");
            out.println("Peak usage");
            out.println("</td><td>");
            out.println(item.getPeakUsage());
            out.println("</td></tr>");
            out.println("<tr><td bgcolor=\"#CCCCCC\">");
            out.println("Collection usage");
            out.println("</td><td>");
            out.println(item.getCollectionUsage());
            out.println("</td></tr>");
            out.println("<tr><td colspan=\"2\"></td></tr>");
            out.println("<tr><td colspan=\"2\"></td></tr>");
        }
        out.println("</table>");
%>

