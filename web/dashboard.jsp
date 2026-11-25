<%@ include file="/WEB-INF/includes/init.jspf" %>
<%@ include file="/WEB-INF/includes/auth.jspf" %>
<%--DASHBOARD (Read)--%>
<%
    Connection conn = getConnection();

    String[] countQueries = {
        "SELECT COUNT(*) FROM courses WHERE user_id = ?",
        "SELECT COUNT(*) FROM tasks WHERE user_id = ? AND is_done = 0",
        "SELECT COUNT(*) FROM tasks WHERE user_id = ? AND is_done = 1",
        "SELECT COUNT(*) FROM notes WHERE user_id = ?"
    };
    int[] counts = new int[4];
    for (int i = 0; i < countQueries.length; i++) {
        PreparedStatement ps = conn.prepareStatement(countQueries[i]);
        ps.setInt(1, userId);
        ResultSet rs = ps.executeQuery();
        rs.next();
        counts[i] = rs.getInt(1);
    }
    int courseCount = counts[0], pendingCount = counts[1], doneCount = counts[2], noteCount = counts[3];
    int totalTasks = pendingCount + doneCount;
    int progress = totalTasks > 0 ? Math.round(doneCount * 100f / totalTasks) : 0;

    PreparedStatement up = conn.prepareStatement(
        "SELECT t.title, t.deadline, t.priority, c.name AS course_name "
      + "FROM tasks t JOIN courses c ON c.id = t.course_id "
      + "WHERE t.user_id = ? AND t.is_done = 0 ORDER BY t.deadline LIMIT 5");
    up.setInt(1, userId);
    ResultSet upcoming = up.executeQuery();

    Object[][] stats = {
        {courseCount, "Courses", "star-pink", -3},
        {pendingCount, "Tasks Left", "star-yellow", 3},
        {doneCount, "Tasks Done", "star-green", -2},
        {noteCount, "Notes", "star-blue", 3}
    };
    java.sql.Date todayDate = today();

    String pageTitle = "Dashboard";
    String bodyClass = "grad";
    String activeMenu = "dashboard";
%>
<%@ include file="/WEB-INF/includes/header.jspf" %>

<div class="hero hero-dash">
    <h1>Hello, <%= h(userName) %></h1>
    <a class="btn btn-yellow btn-lg" href="task-form.jsp">+ Add Task</a>
</div>

<div class="stars">
    <% for (Object[] s : stats) { %>
        <div class="star <%= s[2] %>">
            <svg viewBox="0 0 180 150" aria-hidden="true" style="transform: rotate(<%= s[3] %>deg)">
                <polygon points="90.0,10.0 121.6,44.7 169.9,59.7 141.1,96.2 139.4,140.2 90.0,128.1 40.6,140.2 38.9,96.2 10.1,59.7 58.4,44.7"
                        fill="currentColor" stroke="currentColor" stroke-width="20" stroke-linejoin="round"/>
            </svg>
            <div class="star-in">
                <span class="num"><%= s[0] %></span>
                <span class="lbl"><%= s[1] %></span>
            </div>
        </div>
    <% } %>
</div>

<div class="progress-card">
    <h3>Task Progress : <%= progress %>%</h3>
    <div class="progress"><span style="width: <%= progress %>%"></span></div>
</div>

<div class="panel-green">
    <h2>Deadlines</h2>
    <% boolean hasTask = false;
       while (upcoming.next()) {
        hasTask = true;
        java.sql.Date deadline = upcoming.getDate("deadline");
        String priority = upcoming.getString("priority"); %>
        <div class="row">
            <div class="row-main">
                <div class="row-title"><%= h(upcoming.getString("title")) %></div>
                <div class="row-meta">
                    <%= h(upcoming.getString("course_name")) %> <span class="sep">·</span> <%= formatDate(deadline) %>
                    <% if (deadline.before(todayDate)) { %> <span class="badge b-late">Overdue</span> <% } %>
                </div>
            </div>
            <span class="badge b-<%= priority %>"><%= priorityLabel(priority) %></span>
        </div>
    <% }
       if (!hasTask) { %>
        <p class="empty-msg">Yay, no tasks yet</p>
    <% } %>
</div>

<% conn.close(); %>
<%@ include file="/WEB-INF/includes/footer.jspf" %>
