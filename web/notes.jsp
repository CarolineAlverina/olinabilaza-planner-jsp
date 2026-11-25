<%@ include file="/WEB-INF/includes/init.jspf" %>
<%@ include file="/WEB-INF/includes/auth.jspf" %>
<%--DAFTAR NOTES (Read) + Search--%>
<%
    String q = clean(request.getParameter("q"));

    Connection conn = getConnection();
    String sql = "SELECT n.*, c.name AS course_name FROM notes n LEFT JOIN courses c ON c.id = n.course_id WHERE n.user_id = ?";
    if (!isEmpty(q)) {
        sql += " AND (n.title LIKE ? OR n.content LIKE ?)";
    }
    sql += " ORDER BY n.created_at DESC, n.id DESC";

    PreparedStatement ps = conn.prepareStatement(sql);
    ps.setInt(1, userId);
    if (!isEmpty(q)) {
        ps.setString(2, "%" + q + "%");
        ps.setString(3, "%" + q + "%");
    }
    ResultSet rs = ps.executeQuery();

    String pageTitle = "Notes";
    String bodyClass = "";
    String activeMenu = "notes";
%>
<%@ include file="/WEB-INF/includes/header.jspf" %>

<div class="page-head">
    <h1>Notes</h1>
    <p>Keep your lecture summaries here</p>
    <a class="btn btn-sm" href="note-form.jsp">+ Add Note</a>
</div>

<form class="filters filters-note" method="GET" action="notes.jsp">
    <div>
        <label for="q">Search notes</label>
        <input id="q" type="text" name="q" value="<%= h(q) %>" placeholder="title or note content">
    </div>
    <div><button class="btn btn-green" type="submit">Search</button></div>
</form>

<div class="grid list">
    <% boolean hasNote = false;
       while (rs.next()) {
           hasNote = true;
           String content = rs.getString("content");
           if (content.length() > 160) content = content.substring(0, 160) + "...";   // potong supaya kartu tidak terlalu panjang
           String courseName = rs.getString("course_name"); %>
        <div class="card">
            <h3><%= h(rs.getString("title")) %></h3>
            <% if (courseName != null) { %> <span class="badge b-course"><%= h(courseName) %></span> <% } %>
            <p class="note-body"><%= h(content) %></p>
            <div class="row-actions">
                <a class="btn btn-sm btn-green" href="note-form.jsp?id=<%= rs.getInt("id") %>">Edit</a>
                <form class="inline" method="POST" action="note-delete.jsp" onsubmit="return confirm('Delete this note?')">
                    <input type="hidden" name="id" value="<%= rs.getInt("id") %>">
                    <button class="btn btn-sm btn-danger" type="submit">Delete</button>
                </form>
            </div>
        </div>
    <% }
       if (!hasNote) { %>
        <div class="empty empty-wide">No notes yet.</div>
    <% } %>
</div>

<% conn.close(); %>
<%@ include file="/WEB-INF/includes/footer.jspf" %>
