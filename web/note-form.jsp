<%@ include file="/WEB-INF/includes/init.jspf" %>
<%@ include file="/WEB-INF/includes/auth.jspf" %>
<%--TAMBAH & EDIT NOTE (Create + Update)--%>
<%
    int id = toInt(request.getParameter("id"));
    boolean isEdit = id > 0;

    int courseId = 0;
    String title = "", content = "";
    List<String> errors = new ArrayList<>();

    Connection conn = getConnection();

    if ("POST".equals(request.getMethod())) {
        courseId = toInt(request.getParameter("course_id"));
        title = clean(request.getParameter("title"));
        content = clean(request.getParameter("content"));

        if (courseId > 0) {
            PreparedStatement own = conn.prepareStatement("SELECT COUNT(*) FROM courses WHERE id = ? AND user_id = ?");
            own.setInt(1, courseId);
            own.setInt(2, userId);
            ResultSet ownRs = own.executeQuery();
            ownRs.next();
            if (ownRs.getInt(1) == 0) errors.add("The selected course is invalid.");
        }
        if (isEmpty(title) || title.length() > 150) errors.add("Note title is required (max 150 characters).");
        if (isEmpty(content) || content.length() > 5000) errors.add("Note content is required (max 5000 characters).");

        if (errors.isEmpty()) {
            PreparedStatement ps;
            if (isEdit) {
                ps = conn.prepareStatement("UPDATE notes SET course_id=?, title=?, content=? WHERE id=? AND user_id=?");
                ps.setInt(4, id);
                ps.setInt(5, userId);
            } else {
                ps = conn.prepareStatement("INSERT INTO notes (course_id, title, content, user_id) VALUES (?, ?, ?, ?)");
                ps.setInt(4, userId);
            }
            if (courseId > 0) ps.setInt(1, courseId);
            else ps.setNull(1, Types.BIGINT);
            ps.setString(2, title);
            ps.setString(3, content);
            ps.executeUpdate();

            conn.close();
            session.setAttribute("success", isEdit ? "Note updated successfully." : "Note saved successfully.");
            response.sendRedirect("notes.jsp");
            return;
        }
    } else if (isEdit) {
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM notes WHERE id = ? AND user_id = ?");
        ps.setInt(1, id);
        ps.setInt(2, userId);
        ResultSet rs = ps.executeQuery();
        if (!rs.next()) {
            conn.close();
            session.setAttribute("error", "Note not found.");
            response.sendRedirect("notes.jsp");
            return;
        }
        courseId = rs.getInt("course_id");
        title = rs.getString("title");
        content = rs.getString("content");
    }

    PreparedStatement pc = conn.prepareStatement("SELECT id, name FROM courses WHERE user_id = ? ORDER BY name");
    pc.setInt(1, userId);
    ResultSet rsCourses = pc.executeQuery();
    List<String[]> courses = new ArrayList<>();
    while (rsCourses.next()) {
        courses.add(new String[] { String.valueOf(rsCourses.getInt("id")), rsCourses.getString("name") });
    }
    conn.close();
    request.setAttribute("errors", errors);

    String pageTitle = isEdit ? "Edit Note" : "Add Note";
    String bodyClass = "";
    String activeMenu = "notes";
%>
<%@ include file="/WEB-INF/includes/header.jspf" %>

<h1 class="page-title-center"><%= pageTitle %></h1>
<div class="form-card">
    <form method="POST" action="note-form.jsp<%= isEdit ? "?id=" + id : "" %>">
        <label for="course_id">Course (optional)</label>
        <select id="course_id" name="course_id">
            <option value="">— no course —</option>
            <% for (String[] c : courses) { %>
                <option value="<%= c[0] %>" <%= c[0].equals(String.valueOf(courseId)) ? "selected" : "" %>><%= h(c[1]) %></option>
            <% } %>
        </select>

        <label for="title">Note title</label>
        <input id="title" type="text" name="title" value="<%= h(title) %>" required>

        <label for="content">Note content</label>
        <textarea id="content" name="content" rows="7" required><%= h(content) %></textarea>

        <div class="form-actions">
            <button class="btn" type="submit">Save</button>
            <a class="btn btn-outline" href="notes.jsp">Cancel</a>
        </div>
    </form>
</div>

<%@ include file="/WEB-INF/includes/footer.jspf" %>
