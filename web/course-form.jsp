<%@ include file="/WEB-INF/includes/init.jspf" %>
<%@ include file="/WEB-INF/includes/auth.jspf" %>
<%--TAMBAH & EDIT COURSE (Create + Update) dalam satu halaman--%>
<%
    int id = toInt(request.getParameter("id"));   // 0 berarti tambah baru
    boolean isEdit = id > 0;

    // Nilai awal form
    String code = "", name = "", lecturer = "", startTime = "", endTime = "";
    int credits = 3, day = 0;
    List<String> errors = new ArrayList<>();

    Connection conn = getConnection();

    if ("POST".equals(request.getMethod())) {
        code = clean(request.getParameter("code"));
        name = clean(request.getParameter("name"));
        lecturer = clean(request.getParameter("lecturer"));
        credits = toInt(request.getParameter("credits"));
        day = toInt(request.getParameter("day"));
        startTime = clean(request.getParameter("start_time"));
        endTime = clean(request.getParameter("end_time"));

        if (isEmpty(code) || code.length() > 20) errors.add("Course code is required (max 20 characters).");
        if (isEmpty(name) || name.length() > 120) errors.add("Course name is required (max 120 characters).");
        if (lecturer.length() > 120) errors.add("Lecturer name may not be longer than 120 characters.");
        if (credits < 1 || credits > 6) errors.add("Credits must be between 1 and 6.");
        if (day < 1 || day > 7) errors.add("Please select a class day.");
        if (startTime.length() < 5 || endTime.length() < 5) {
            errors.add("Start time and end time are required.");
        } else if (endTime.compareTo(startTime) <= 0) {
            errors.add("End time must be later than start time.");   // "09:30" > "07:00" (dibandingkan sebagai teks HH:mm)
        }

        if (errors.isEmpty()) {
            PreparedStatement ps;
            if (isEdit) {
                ps = conn.prepareStatement("UPDATE courses SET code=?, name=?, lecturer=?, credits=?, day=?, start_time=?, end_time=? WHERE id=? AND user_id=?");
                ps.setInt(8, id);
                ps.setInt(9, userId);
            } else {
                ps = conn.prepareStatement("INSERT INTO courses (code, name, lecturer, credits, day, start_time, end_time, user_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
                ps.setInt(8, userId);
            }
            ps.setString(1, code);
            ps.setString(2, name);
            ps.setString(3, isEmpty(lecturer) ? null : lecturer);
            ps.setInt(4, credits);
            ps.setInt(5, day);
            ps.setString(6, startTime);
            ps.setString(7, endTime);
            ps.executeUpdate();

            conn.close();
            session.setAttribute("success", isEdit ? "Course updated successfully." : "Course added successfully.");
            response.sendRedirect("courses.jsp");
            return;
        }
    } else if (isEdit) {
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM courses WHERE id = ? AND user_id = ?");
        ps.setInt(1, id);
        ps.setInt(2, userId);
        ResultSet rs = ps.executeQuery();
        if (!rs.next()) {
            conn.close();
            session.setAttribute("error", "Course not found.");
            response.sendRedirect("courses.jsp");
            return;
        }
        code = rs.getString("code");
        name = rs.getString("name");
        lecturer = rs.getString("lecturer") == null ? "" : rs.getString("lecturer");
        credits = rs.getInt("credits");
        day = rs.getInt("day");
        startTime = rs.getString("start_time").substring(0, 5);
        endTime = rs.getString("end_time").substring(0, 5);
    }
    conn.close();
    request.setAttribute("errors", errors);

    String pageTitle = isEdit ? "Edit Course" : "Add Course";
    String bodyClass = "";
    String activeMenu = "courses";
%>
<%@ include file="/WEB-INF/includes/header.jspf" %>

<h1 class="page-title-center"><%= pageTitle %></h1>
<div class="form-card">
    <form method="POST" action="course-form.jsp<%= isEdit ? "?id=" + id : "" %>">
        <label for="code">Course code</label>
        <input id="code" type="text" name="code" value="<%= h(code) %>" required>

        <label for="name">Course name</label>
        <input id="name" type="text" name="name" value="<%= h(name) %>" required>

        <label for="lecturer">Lecturer (optional)</label>
        <input id="lecturer" type="text" name="lecturer" value="<%= h(lecturer) %>">

        <label for="credits">Credits</label>
        <input id="credits" type="number" min="1" max="6" name="credits" value="<%= credits %>" required>

        <label for="day">Class day</label>
        <select id="day" name="day" required>
            <option value="">Select a day</option>
            <% for (int d = 1; d <= 7; d++) { %>
                <option value="<%= d %>" <%= d == day ? "selected" : "" %>><%= DAYS[d] %></option>
            <% } %>
        </select>

        <div class="field-row">
            <div>
                <label for="start_time">Start time</label>
                <input id="start_time" type="time" name="start_time" value="<%= h(startTime) %>" required>
            </div>
            <div>
                <label for="end_time">End time</label>
                <input id="end_time" type="time" name="end_time" value="<%= h(endTime) %>" required>
            </div>
        </div>

        <div class="form-actions">
            <button class="btn" type="submit">Save</button>
            <a class="btn btn-outline" href="courses.jsp">Cancel</a>
        </div>
    </form>
</div>

<%@ include file="/WEB-INF/includes/footer.jspf" %>
