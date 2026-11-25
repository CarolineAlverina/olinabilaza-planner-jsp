<%@ include file="/WEB-INF/includes/init.jspf" %>
<%@ include file="/WEB-INF/includes/auth.jspf" %>
<%--DAFTAR TUGAS (Read) + PENCARIAN + FILTER--%>
<%
    String q = clean(request.getParameter("q"));
    int courseFilter = toInt(request.getParameter("course_id"));
    String status = clean(request.getParameter("status"));

    Connection conn = getConnection();

    //query sesuai filter yang diisi
    StringBuilder sql = new StringBuilder(
        "SELECT t.*, c.name AS course_name FROM tasks t JOIN courses c ON c.id = t.course_id WHERE t.user_id = ?");
    List<Object> params = new ArrayList<>();
    params.add(userId);

    if (!isEmpty(q)) {
        sql.append(" AND t.title LIKE ?");
        params.add("%" + q + "%");
    }
    if (courseFilter > 0) {
        sql.append(" AND t.course_id = ?");
        params.add(courseFilter);
    }
    if (status.equals("done")) {
        sql.append(" AND t.is_done = 1");
    } else if (status.equals("pending")) {
        sql.append(" AND t.is_done = 0");
    }
    sql.append(" ORDER BY t.is_done, t.deadline");   // yang belum selesai di atas

    PreparedStatement ps = conn.prepareStatement(sql.toString());
    for (int i = 0; i < params.size(); i++) {
        ps.setObject(i + 1, params.get(i));
    }
    ResultSet rs = ps.executeQuery();

    // Daftar course untuk dropdown filter
    PreparedStatement pc = conn.prepareStatement("SELECT id, name FROM courses WHERE user_id = ? ORDER BY name");
    pc.setInt(1, userId);
    ResultSet courseList = pc.executeQuery();

    java.sql.Date todayDate = today();

    String pageTitle = "Tasks";
    String bodyClass = "";
    String activeMenu = "tasks";
%>
<%@ include file="/WEB-INF/includes/header.jspf" %>

<div class="page-head">
    <h1>Tasks</h1>
    <p>Search, filter, and mark your tasks as done</p>
    <a class="btn btn-sm" href="task-form.jsp">+ Add Task</a>
</div>

<form class="filters" method="GET" action="tasks.jsp">
    <div>
        <label for="q">Search title</label>
        <input id="q" type="text" name="q" value="<%= h(q) %>" placeholder="e.g. ERD">
    </div>
    <div>
        <label for="f_course">Course</label>
        <select id="f_course" name="course_id">
            <option value="">All</option>
            <% while (courseList.next()) { %>
                <option value="<%= courseList.getInt("id") %>" <%= courseList.getInt("id") == courseFilter ? "selected" : "" %>><%= h(courseList.getString("name")) %></option>
            <% } %>
        </select>
    </div>
    <div>
        <label for="f_status">Status</label>
        <select id="f_status" name="status">
            <option value="">All</option>
            <option value="pending" <%= status.equals("pending") ? "selected" : "" %>>Not done</option>
            <option value="done" <%= status.equals("done") ? "selected" : "" %>>Done</option>
        </select>
    </div>
    <div>
        <button class="btn btn-green" type="submit">Apply</button>
    </div>
</form>

<div class="list">
<% boolean hasTask = false;
    while (rs.next()) {
        hasTask = true;
        int taskId = rs.getInt("id");
        boolean done = rs.getInt("is_done") == 1;
        java.sql.Date deadline = rs.getDate("deadline");
        String priority = rs.getString("priority"); %>
    <div class="row <%= done ? "done" : "" %>">
        <form class="inline" method="POST" action="task-toggle.jsp">
            <input type="hidden" name="id" value="<%= taskId %>">
            <button class="check <%= done ? "on" : "" %>" type="submit" title="Mark as done / not done"></button>
        </form>

        <div class="row-main">
            <div class="row-title"><%= h(rs.getString("title")) %></div>
            <div class="row-meta">
                <span class="badge b-course"><%= h(rs.getString("course_name")) %></span>
                <span class="sep">·</span> <%= formatDate(deadline) %>
                <% if (!done && deadline.before(todayDate)) { %> <span class="badge b-late">Overdue</span> <% } %>
            </div>
        </div>

        <span class="badge b-<%= priority %>"><%= priorityLabel(priority) %></span>

        <div class="row-actions">
            <a class="btn btn-sm btn-green" href="task-form.jsp?id=<%= taskId %>">Edit</a>
            <form class="inline" method="POST" action="task-delete.jsp" onsubmit="return confirm('Delete this task?')">
                <input type="hidden" name="id" value="<%= taskId %>">
                <button class="btn btn-sm btn-danger" type="submit">Delete</button>
            </form>
        </div>
    </div>
<% }
    if (!hasTask) { %>
    <div class="empty">No matching tasks.</div>
<% } %>
</div>

<% conn.close(); %>
<%@ include file="/WEB-INF/includes/footer.jspf" %>
