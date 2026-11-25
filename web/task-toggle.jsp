<%@ include file="/WEB-INF/includes/init.jspf" %>
<%@ include file="/WEB-INF/includes/auth.jspf" %>
<%--TANDAI SELESAI / BELUM SELESAI (Update)--%>
<%
    if ("POST".equals(request.getMethod())) {
        int id = toInt(request.getParameter("id"));
        Connection conn = getConnection();

        PreparedStatement ps = conn.prepareStatement("UPDATE tasks SET is_done = 1 - is_done WHERE id = ? AND user_id = ?");
        ps.setInt(1, id);
        ps.setInt(2, userId);
        ps.executeUpdate();

        // Baca status terbaru untuk pesan
        PreparedStatement check = conn.prepareStatement("SELECT is_done FROM tasks WHERE id = ? AND user_id = ?");
        check.setInt(1, id);
        check.setInt(2, userId);
        ResultSet rs = check.executeQuery();
        if (rs.next()) {
            session.setAttribute("success", rs.getInt("is_done") == 1 ? "Task marked as done." : "Task marked as not done.");
        }
        conn.close();
    }

    // Kembali ke halaman sebelumnya (filter pencarian tetap terjaga)
    String back = request.getHeader("Referer");
    response.sendRedirect(back != null ? back : "tasks.jsp");
%>
