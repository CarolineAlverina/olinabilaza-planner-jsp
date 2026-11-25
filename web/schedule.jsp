<%@ include file="/WEB-INF/includes/init.jspf" %>
<%@ include file="/WEB-INF/includes/auth.jspf" %>
<%--JADWAL MINGGUAN (Read) --%>
<%
    Connection conn = getConnection();
    PreparedStatement ps = conn.prepareStatement(
        "SELECT name, code, lecturer, credits, day, start_time, end_time FROM courses WHERE user_id = ? ORDER BY day, start_time");
    ps.setInt(1, userId);
    ResultSet rs = ps.executeQuery();

    List<String[]> courses = new ArrayList<>();
    int totalCredits = 0;
    while (rs.next()) {
        courses.add(new String[] {
            rs.getString("name"), rs.getString("code"), rs.getString("lecturer"),
            String.valueOf(rs.getInt("day")), shortTime(rs.getString("start_time")), shortTime(rs.getString("end_time"))
        });
        totalCredits += rs.getInt("credits");
    }
    conn.close();

    int todayNumber = LocalDate.now(ZoneId.of("Asia/Jakarta")).getDayOfWeek().getValue();

    String pageTitle = "Weekly Schedule";
    String bodyClass = "";
    String activeMenu = "schedule";
%>
<%@ include file="/WEB-INF/includes/header.jspf" %>

<div class="page-head">
    <h1>Weekly Schedule</h1>
    <p><%= courses.size() %> courses · <%= totalCredits %> credits this semester</p>
    <a class="btn btn-sm" href="course-form.jsp">+ Add Course</a>
</div>

<div class="week">
    <% for (int d = 1; d <= 7; d++) { %>
        <div class="day-col <%= d == todayNumber ? "today" : "" %>">
            <div class="day-head">
                <%= DAYS[d] %>
                <% if (d == todayNumber) { %><span class="today-chip">Today</span><% } %>
            </div>
            <% int countThisDay = 0;
                for (String[] c : courses) {
                   if (Integer.parseInt(c[3]) != d) continue;   // lewati course yang bukan hari ini
                    countThisDay++; %>
                <div class="class-card">
                    <div class="class-time"><%= c[4] %> - <%= c[5] %></div>
                    <div class="class-name"><%= h(c[0]) %></div>
                    <div class="class-meta"><%= h(c[1]) %><%= isEmpty(c[2]) ? "" : " · " + h(c[2]) %></div>
                </div>
            <% }
                if (countThisDay == 0) { %>
                <div class="day-free">Free day ☆</div>
            <% } %>
        </div>
    <% } %>
</div>

<%@ include file="/WEB-INF/includes/footer.jspf" %>
