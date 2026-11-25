<%@ include file="/WEB-INF/includes/init.jspf" %>
<%--LOGOUT:--%>
<%
    session.invalidate();
    request.getSession(true).setAttribute("success", "You have been logged out.");
    response.sendRedirect("login.jsp");
%>
