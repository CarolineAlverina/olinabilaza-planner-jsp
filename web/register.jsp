<%@ include file="/WEB-INF/includes/init.jspf" %>
<%--REGISTER
GET  : tampilkan form pendaftaran
POST : validasi -> simpan user baru (password di-hash) -> langsung login -> ke dashboard
--%>
<%
    if (session.getAttribute("userId") != null) {
        response.sendRedirect("dashboard.jsp");
        return;
    }

    String name = clean(request.getParameter("name"));
    String email = clean(request.getParameter("email"));
    List<String> errors = new ArrayList<>();

    if ("POST".equals(request.getMethod())) {
        String password = request.getParameter("password");
        String confirm = request.getParameter("password_confirmation");
        if (password == null) password = "";

        if (isEmpty(name)) errors.add("Name is required.");
        if (name.length() > 100) errors.add("Name may not be longer than 100 characters.");
        if (isEmpty(email) || !email.contains("@") || email.length() > 150) errors.add("Please enter a valid email address.");
        if (password.length() < 6) errors.add("Password must be at least 6 characters.");
        if (!password.equals(confirm)) errors.add("Password confirmation does not match.");

        Connection conn = getConnection();

        // Email harus unik
        if (errors.isEmpty()) {
            PreparedStatement check = conn.prepareStatement("SELECT COUNT(*) FROM users WHERE email = ?");
            check.setString(1, email);
            ResultSet rs = check.executeQuery();
            rs.next();
            if (rs.getInt(1) > 0) errors.add("This email is already registered.");
        }

        //save
        if (errors.isEmpty()) {
            PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO users (name, email, password) VALUES (?, ?, ?)", Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, hash(password));
            ps.executeUpdate();
            ResultSet key = ps.getGeneratedKeys();
            key.next();

            request.changeSessionId();
            session.setAttribute("userId", key.getInt(1));
            session.setAttribute("userName", name);
            session.setAttribute("success", "Account created successfully. Welcome!");
            conn.close();
            response.sendRedirect("dashboard.jsp");
            return;
        }
        conn.close();
    }
    request.setAttribute("errors", errors);

    String pageTitle = "Register";
    String bodyClass = "grad";
    String activeMenu = "register";
%>
<%@ include file="/WEB-INF/includes/header.jspf" %>

<div class="hero">
    <h1>Create a New Account</h1>
    <p>Start organizing your courses, tasks, and notes.</p>
</div>

<div class="form-card login-card">
    <form method="POST" action="register.jsp">
        <label for="name">Full name</label>
        <input id="name" type="text" name="name" value="<%= h(name) %>" required autofocus>

        <label for="email">Email</label>
        <input id="email" type="email" name="email" value="<%= h(email) %>" required>

        <label for="password">Password (min. 6 characters)</label>
        <input id="password" type="password" name="password" required>

        <label for="password_confirmation">Confirm password</label>
        <input id="password_confirmation" type="password" name="password_confirmation" required>

        <div class="form-actions">
            <button class="btn" type="submit">Register</button>
            <a class="btn btn-outline" href="login.jsp">Already have an account</a>
        </div>
    </form>
</div>

<%@ include file="/WEB-INF/includes/footer.jspf" %>
