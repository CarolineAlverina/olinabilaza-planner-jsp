<%@ include file="/WEB-INF/includes/init.jspf" %>
<%@ include file="/WEB-INF/includes/auth.jspf" %>
<%--PROFIL (Update)
action=profile   -> ubah nama & email
action=password  -> ganti password (wajib memasukkan password lama)
--%>
<%
    List<String> errors = new ArrayList<>();
    Connection conn = getConnection();

    if ("POST".equals(request.getMethod())) {
        String action = clean(request.getParameter("action"));

        if (action.equals("profile")) {
            String newName = clean(request.getParameter("name"));
            String newEmail = clean(request.getParameter("email"));

            if (isEmpty(newName) || newName.length() > 100) errors.add("Name is required (max 100 characters).");
            if (isEmpty(newEmail) || !newEmail.contains("@") || newEmail.length() > 150) errors.add("Please enter a valid email address.");
            if (errors.isEmpty()) {
                PreparedStatement check = conn.prepareStatement("SELECT COUNT(*) FROM users WHERE email = ? AND id <> ?");
                check.setString(1, newEmail);
                check.setInt(2, userId);
                ResultSet rs = check.executeQuery();
                rs.next();
                if (rs.getInt(1) > 0) errors.add("This email is already used by another account.");
            }
            if (errors.isEmpty()) {
                PreparedStatement ps = conn.prepareStatement("UPDATE users SET name = ?, email = ? WHERE id = ?");
                ps.setString(1, newName);
                ps.setString(2, newEmail);
                ps.setInt(3, userId);
                ps.executeUpdate();
                session.setAttribute("userName", newName);   // nama di session ikut diperbarui
                session.setAttribute("success", "Profile updated successfully.");
            }
        } else if (action.equals("password")) {
            String current = request.getParameter("current_password");
            String newPass = request.getParameter("password");
            String confirm = request.getParameter("password_confirmation");
            if (current == null) current = "";
            if (newPass == null) newPass = "";

            PreparedStatement check = conn.prepareStatement("SELECT COUNT(*) FROM users WHERE id = ? AND password = ?");
            check.setInt(1, userId);
            check.setString(2, hash(current));
            ResultSet rs = check.executeQuery();
            rs.next();
            if (rs.getInt(1) == 0) errors.add("Your current password is incorrect.");
            if (newPass.length() < 6) errors.add("New password must be at least 6 characters.");
            if (!newPass.equals(confirm)) errors.add("Password confirmation does not match.");

            if (errors.isEmpty()) {
                PreparedStatement ps = conn.prepareStatement("UPDATE users SET password = ? WHERE id = ?");
                ps.setString(1, hash(newPass));
                ps.setInt(2, userId);
                ps.executeUpdate();
                session.setAttribute("success", "Password changed successfully.");
            }
        }

        if (errors.isEmpty()) {
            conn.close();
            response.sendRedirect("profile.jsp");
            return;
        }
    }

    PreparedStatement ps = conn.prepareStatement("SELECT name, email FROM users WHERE id = ?");
    ps.setInt(1, userId);
    ResultSet user = ps.executeQuery();
    user.next();
    String name = user.getString("name");
    String email = user.getString("email");
    conn.close();
    request.setAttribute("errors", errors);

    String pageTitle = "Profile";
    String bodyClass = "";
    String activeMenu = "profile";
%>
<%@ include file="/WEB-INF/includes/header.jspf" %>

<h1 class="page-title-center">My Profile</h1>

<div class="form-card form-gap">
    <h2>Account Details</h2>
    <form method="POST" action="profile.jsp">
        <input type="hidden" name="action" value="profile">
        <label for="name">Name</label>
        <input id="name" type="text" name="name" value="<%= h(name) %>" required>

        <label for="email">Email</label>
        <input id="email" type="email" name="email" value="<%= h(email) %>" required>

        <div class="form-actions"><button class="btn" type="submit">Save Profile</button></div>
    </form>
</div>

<div class="form-card">
    <h2>Change Password</h2>
    <form method="POST" action="profile.jsp">
        <input type="hidden" name="action" value="password">
        <label for="current_password">Current password</label>
        <input id="current_password" type="password" name="current_password" required>

        <label for="password">New password</label>
        <input id="password" type="password" name="password" required>

        <label for="password_confirmation">Confirm new password</label>
        <input id="password_confirmation" type="password" name="password_confirmation" required>

        <div class="form-actions"><button class="btn btn-green" type="submit">Change Password</button></div>
    </form>
</div>

<%@ include file="/WEB-INF/includes/footer.jspf" %>
