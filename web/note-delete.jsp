<%@ include file="/WEB-INF/includes/init.jspf" %>
<%@ include file="/WEB-INF/includes/auth.jspf" %>
<%-- HAPUS NOTE (Delete) --%>
<%
    if ("POST".equals(request.getMethod())) {
        Connection conn = getConnection();
        PreparedStatement ps = conn.prepareStatement("DELETE FROM notes WHERE id = ? AND user_id = ?");
        ps.setInt(1, toInt(request.getParameter("id")));
        ps.setInt(2, userId);
        int deleted = ps.executeUpdate();
        conn.close();
        session.setAttribute(deleted > 0 ? "success" : "error", deleted > 0 ? "Note deleted." : "Note not found.");
    }
    response.sendRedirect("notes.jsp");
%>
