<%-- Halaman error. Sengaja TIDAK meng-include init.jspf supaya tetap tampil walaupun database bermasalah. --%>
<%@ page contentType="text/html; charset=UTF-8" isErrorPage="true" %>
<%
    Object code = request.getAttribute("jakarta.servlet.error.status_code");
    boolean notFound = code != null && code.toString().equals("404");
    String message = "";
    if (exception != null) {
        Throwable cause = exception;
        while (cause.getCause() != null) cause = cause.getCause();
        message = cause.toString().replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Oops · OliNabilAza Planner</title>
    <link rel="icon" type="image/svg+xml" href="favicon.svg">
    <link rel="stylesheet" href="css/style.css">
</head>
<body class="grad">
<div class="page">
    <header class="nav"><a class="logo" href="dashboard.jsp">OliNabilAza Planner</a></header>
    <main>
        <div class="hero">
            <h1><%= notFound ? "Page Not Found" : "Oops!" %></h1>
            <p><%= notFound ? "The page you are looking for does not exist." : "Something went wrong on the server." %></p>
        </div>
        <% if (!message.isEmpty()) { %>
            <div class="alert alert-err">Detail: <%= message %></div>
        <% } %>
        <p class="empty"><a class="btn" href="dashboard.jsp">Back to Dashboard</a></p>
    </main>
    <footer class="footer">OliNabilAza Planner ☆ KEEP GOING</footer>
</div>
</body>
</html>
