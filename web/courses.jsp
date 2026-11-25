<%@ include file="/WEB-INF/includes/init.jspf" %>
<%@ include file="/WEB-INF/includes/auth.jspf" %>
<%--DAFTAR COURSE (Read)--%>
<%
    Connection conn = getConnection();
    PreparedStatement ps = conn.prepareStatement(
        "SELECT c.*, "
      + " (SELECT COUNT(*) FROM tasks t WHERE t.course_id = c.id) AS task_count, "
      + " (SELECT COUNT(*) FROM notes n WHERE n.course_id = c.id) AS note_count "
      + "FROM courses c WHERE c.user_id = ? ORDER BY c.day, c.start_time");
    ps.setInt(1, userId);
    ResultSet rs = ps.executeQuery();

    String pageTitle = "Courses";
    String bodyClass = "";
    String activeMenu = "courses";
%>
<%@ include file="/WEB-INF/includes/header.jspf" %>

<div class="page-head">
    <h1>Courses</h1>
    <p>List of enrolled courses</p>
    <a class="btn btn-sm" href="course-form.jsp">+ Add Course</a>
</div>

<div class="list">
<% boolean hasCourse = false;
   while (rs.next()) {
       hasCourse = true;
       String lecturer = rs.getString("lecturer"); %>
    <div class="row">
        <div class="row-main">
            <div class="row-title"><%= h(rs.getString("name")) %> <span class="badge b-course"><%= h(rs.getString("code")) %></span></div>
            <div class="row-meta">
                <%= isEmpty(lecturer) ? "Lecturer not set" : h(lecturer) %> <span class="sep">·</span> <%= rs.getInt("credits") %> credits <span class="sep">·</span>
                <%= rs.getInt("task_count") %> tasks <span class="sep">·</span> <%= rs.getInt("note_count") %> notes
            </div>
        </div>
        <div class="row-schedule">
            Every <%= dayName(rs.getInt("day")) %>
            <b><%= shortTime(rs.getString("start_time")) %> - <%= shortTime(rs.getString("end_time")) %></b>
        </div>
        <div class="row-actions">
            <a class="btn btn-sm btn-green" href="course-form.jsp?id=<%= rs.getInt("id") %>">Edit</a>
            <form class="inline" method="POST" action="course-delete.jsp"
                    onsubmit="return confirm('Delete this course? All its tasks will also be deleted.')">
                <input type="hidden" name="id" value="<%= rs.getInt("id") %>">
                <button class="btn btn-sm btn-danger" type="submit">Delete</button>
            </form>
        </div>
    </div>
<% }
   if (!hasCourse) { %>
    <div class="empty">No courses yet. Add your first one!</div>
<% } %>
</div>

<% conn.close(); %>
<%@ include file="/WEB-INF/includes/footer.jspf" %>
