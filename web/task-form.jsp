<%@ include file="/WEB-INF/includes/init.jspf" %>
<%@ include file="/WEB-INF/includes/auth.jspf" %>
<%--TAMBAH & EDIT TUGAS (Create + Update)
task-form.jsp - tambah tugas
task-form.jsp?id=7 - edit tugas id 7
--%>
<%
    int id = toInt(request.getParameter("id"));
    boolean isEdit = id > 0;

    int courseId = 0;
    String title = "", description = "", deadline = "", priority = "medium";
    List<String> errors = new ArrayList<>();

    Connection conn = getConnection();

    if ("POST".equals(request.getMethod())) {
        courseId = toInt(request.getParameter("course_id"));
        title = clean(request.getParameter("title"));
        description = clean(request.getParameter("description"));
        deadline = clean(request.getParameter("deadline"));
        priority = clean(request.getParameter("priority"));

        PreparedStatement own = conn.prepareStatement("SELECT COUNT(*) FROM courses WHERE id = ? AND user_id = ?");
        own.setInt(1, courseId);
        own.setInt(2, userId);
        ResultSet ownRs = own.executeQuery();
        ownRs.next();
        if (ownRs.getInt(1) == 0) errors.add("Please select one of your courses.");

        if (isEmpty(title) || title.length() > 150) errors.add("Task title is required (max 150 characters).");
        if (description.length() > 2000) errors.add("Description may not be longer than 2000 characters.");
        if (!deadline.matches("\\d{4}-\\d{2}-\\d{2}")) errors.add("Please enter a valid deadline.");
        if (!priority.equals("low") && !priority.equals("medium") && !priority.equals("high")) errors.add("Please select a priority.");

        //save
        if (errors.isEmpty()) {
            PreparedStatement ps;
            if (isEdit) {
                ps = conn.prepareStatement("UPDATE tasks SET course_id=?, title=?, description=?, deadline=?, priority=? WHERE id=? AND user_id=?");
                ps.setInt(6, id);
                ps.setInt(7, userId);
            } else {
                ps = conn.prepareStatement("INSERT INTO tasks (course_id, title, description, deadline, priority, user_id) VALUES (?, ?, ?, ?, ?, ?)");
                ps.setInt(6, userId);
            }
            ps.setInt(1, courseId);
            ps.setString(2, title);
            ps.setString(3, isEmpty(description) ? null : description);
            ps.setDate(4, java.sql.Date.valueOf(deadline));
            ps.setString(5, priority);
            ps.executeUpdate();

            conn.close();
            session.setAttribute("success", isEdit ? "Task updated successfully." : "Task added successfully.");
            response.sendRedirect("tasks.jsp");
            return;
        }
    } else if (isEdit) {
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM tasks WHERE id = ? AND user_id = ?");
        ps.setInt(1, id);
        ps.setInt(2, userId);
        ResultSet rs = ps.executeQuery();
        if (!rs.next()) {
            conn.close();
            session.setAttribute("error", "Task not found.");
            response.sendRedirect("tasks.jsp");
            return;
        }
        courseId = rs.getInt("course_id");
        title = rs.getString("title");
        description = rs.getString("description") == null ? "" : rs.getString("description");
        deadline = rs.getDate("deadline").toString();   // format yyyy-MM-dd, cocok untuk <input type="date">
        priority = rs.getString("priority");
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

    String[][] priorities = { {"low", "Low"}, {"medium", "Medium"}, {"high", "High"} };

    String pageTitle = isEdit ? "Edit Task" : "Add Task";
    String bodyClass = "";
    String activeMenu = "tasks";
%>
<%@ include file="/WEB-INF/includes/header.jspf" %>

<h1 class="page-title-center"><%= pageTitle %></h1>

<% if (courses.isEmpty()) { %>
    <div class="empty">You don't have any courses yet. <a href="course-form.jsp">Add a course first</a>.</div>
<% } else { %>
    <div class="form-card">
        <form method="POST" action="task-form.jsp<%= isEdit ? "?id=" + id : "" %>">
            <label for="course_id">Course</label>
            <select id="course_id" name="course_id" required>
                <option value="">— select a course —</option>
                <% for (String[] c : courses) { %>
                    <option value="<%= c[0] %>" <%= c[0].equals(String.valueOf(courseId)) ? "selected" : "" %>><%= h(c[1]) %></option>
                <% } %>
            </select>

            <label for="title">Task title</label>
            <input id="title" type="text" name="title" value="<%= h(title) %>" required>

            <label for="description">Description (optional)</label>
            <textarea id="description" name="description" rows="3"><%= h(description) %></textarea>

            <label for="deadline">Deadline</label>
            <input id="deadline" type="date" name="deadline" value="<%= h(deadline) %>" required>

            <label for="priority">Priority</label>
            <select id="priority" name="priority" required>
                <% for (String[] p : priorities) { %>
                    <option value="<%= p[0] %>" <%= p[0].equals(priority) ? "selected" : "" %>><%= p[1] %></option>
                <% } %>
            </select>

            <div class="form-actions">
                <button class="btn" type="submit">Save</button>
                <a class="btn btn-outline" href="tasks.jsp">Cancel</a>
            </div>
        </form>
    </div>
<% } %>

<%@ include file="/WEB-INF/includes/footer.jspf" %>
