<%@ include file="/WEB-INF/includes/init.jspf" %>
<%--LOGIN--%>
<%
    // Kalau sudah login, tidak perlu ke halaman login lagi
    if (session.getAttribute("userId") != null) {
        response.sendRedirect("dashboard.jsp");
        return;
    }

    String email = clean(request.getParameter("email"));
    List<String> errors = new ArrayList<>();

    if ("POST".equals(request.getMethod())) {
        String password = request.getParameter("password");

        if (isEmpty(email) || isEmpty(password)) {
            errors.add("Email and password are required.");
        } else {
            Connection conn = getConnection();
            PreparedStatement ps = conn.prepareStatement("SELECT id, name FROM users WHERE email = ? AND password = ?");
            ps.setString(1, email);
            ps.setString(2, hash(password));
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                request.changeSessionId();
                session.setAttribute("userId", rs.getInt("id"));
                session.setAttribute("userName", rs.getString("name"));

                // Remember me 7 hari
                if (request.getParameter("remember") != null) {
                    session.setMaxInactiveInterval(7 * 24 * 60 * 60);
                    Cookie cookie = new Cookie("JSESSIONID", session.getId());
                    cookie.setMaxAge(7 * 24 * 60 * 60);
                    cookie.setPath(request.getContextPath().isEmpty() ? "/" : request.getContextPath());
                    cookie.setHttpOnly(true);
                    response.addCookie(cookie);
                }

                conn.close();
                session.setAttribute("success", "Logged in successfully.");
                response.sendRedirect("dashboard.jsp");
                return;
            }
            conn.close();
            errors.add("Incorrect email or password.");
        }
    }
    request.setAttribute("errors", errors);

    String pageTitle = "Login";
    String bodyClass = "grad";
    String activeMenu = "login";
%>
<%@ include file="/WEB-INF/includes/header.jspf" %>

<div class="hero">
    <h1>Welcome !</h1>
    <p>what do you want to work on today?</p>
</div>

<div class="form-card login-card">
    <form method="POST" action="login.jsp">
        <label for="email">Email</label>
        <input id="email" type="email" name="email" value="<%= h(email) %>" required autofocus>

        <label for="password">Password</label>
        <input id="password" type="password" name="password" required>

        <label class="check-row"><input type="checkbox" name="remember" value="1"> Remember me</label>

        <div class="form-actions">
            <button class="btn" type="submit">Log in</button>
            <a class="btn btn-outline" href="register.jsp">Create account</a>
        </div>
    </form>
</div>

<%@ include file="/WEB-INF/includes/footer.jspf" %>
