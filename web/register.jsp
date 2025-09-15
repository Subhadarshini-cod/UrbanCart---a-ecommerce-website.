<%@ page import="java.sql.*, com.ecommerce.DBConnection" %>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>User Registration</title>
    <style>
    /* Reset and global styles */
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    }

    body {
        min-height: 100vh;
        display: flex;
        justify-content: center;
        align-items: center;

        /* Background with gradient + image overlay */
        background: linear-gradient(135deg, rgba(88, 140, 255, 0.85), rgba(145, 80, 255, 0.85)),
                    url('https://images.unsplash.com/photo-1508780709619-79562169bc64?auto=format&fit=crop&w=1500&q=80') no-repeat center center/cover;
        color: #333;
    }

    /* Glassmorphism card */
    .form-container {
        background: rgba(255, 255, 255, 0.15);
        backdrop-filter: blur(12px) saturate(180%);
        -webkit-backdrop-filter: blur(12px) saturate(180%);
        border-radius: 18px;
        padding: 40px 35px;
        width: 400px;
        box-shadow: 0 15px 30px rgba(0,0,0,0.2);
        animation: fadeIn 1s ease-in-out;
        border: 1px solid rgba(255, 255, 255, 0.25);
    }

    .form-container h2 {
        text-align: center;
        color: #ffffff;
        font-size: 2.2em;
        font-weight: 700;
        margin-bottom: 25px;
        letter-spacing: 1px;
        text-shadow: 0 2px 8px rgba(0,0,0,0.2);
    }

    label {
        display: block;
        margin-top: 15px;
        font-weight: 500;
        color: #f1f1f1;
    }

    input, textarea, select {
        width: 100%;
        padding: 12px 14px;
        margin-top: 6px;
        border: none;
        border-radius: 12px;
        font-size: 0.95em;
        background: rgba(255,255,255,0.2);
        color: #fff;
        transition: all 0.3s ease;
    }

    input::placeholder, textarea::placeholder {
        color: rgba(255, 255, 255, 0.7);
    }

    input:focus, textarea:focus, select:focus {
        outline: none;
        background: rgba(255,255,255,0.35);
        box-shadow: 0 0 10px rgba(255,255,255,0.4);
    }

    /* Button styling */
    button {
        margin-top: 25px;
        padding: 14px;
        width: 100%;
        border: none;
        background: linear-gradient(135deg, #5a67d8, #805ad5);
        color: white;
        font-weight: bold;
        font-size: 1.05em;
        border-radius: 14px;
        cursor: pointer;
        transition: all 0.3s ease;
    }

    button:hover {
        background: linear-gradient(135deg, #6b74e0, #9365e6);
        transform: translateY(-3px) scale(1.02);
        box-shadow: 0 10px 20px rgba(0,0,0,0.25);
    }

    /* Success & error messages */
    .success, .error {
        text-align: center;
        margin-top: 15px;
        font-weight: 500;
        font-size: 0.95em;
    }

    .success { color: #48bb78; }
    .error { color: #f56565; }

    a {
        color: #ffd369;
        text-decoration: none;
        transition: 0.3s;
    }

    a:hover {
        text-decoration: underline;
        color: #ffe97f;
    }

    /* Fade-in animation */
    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(30px); }
        to { opacity: 1; transform: translateY(0); }
    }

    /* Mobile responsive */
    @media(max-width: 480px) {
        .form-container {
            width: 90%;
            padding: 30px 20px;
        }
    }
    </style>
</head>
<body>
    <div class="form-container">
        <h2>User Registration</h2>
        <form method="post" action="register.jsp">
            <label>Full Name:</label>
            <input type="text" name="fullname" placeholder="Enter your full name" required>

            <label>Email:</label>
            <input type="email" name="email" placeholder="Enter your email" required>

            <label>Password:</label>
            <input type="password" name="password" placeholder="Enter your password" required>

            <label>Gender:</label>
            <select name="gender" required>
                <option value="Male">Male</option>
                <option value="Female">Female</option>
            </select>

            <label>Date of Birth:</label>
            <input type="date" name="dob" required>

            <label>Phone:</label>
            <input type="text" name="phone" placeholder="Enter your phone number" required>

            <label>Address:</label>
            <textarea name="address" rows="3" placeholder="Enter your address"></textarea>

            <label>Role:</label>
            <select name="role" required>
                <option value="User" selected>User</option>
                <option value="Admin">Admin</option>
                <option value="Guest">Guest</option>
            </select>

            <button type="submit">Register</button>
        </form>

        <%
            // Process registration only if form is submitted
            String fullname = request.getParameter("fullname");
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            String gender = request.getParameter("gender");
            String dob = request.getParameter("dob");
            String phone = request.getParameter("phone");
            String address = request.getParameter("address");
            String role = request.getParameter("role");

            if (fullname != null && email != null && password != null) {
                Connection conn = null;
                PreparedStatement ps = null;
                try {
                    conn = DBConnection.getConnection();

                    // Check if email already exists
                    ps = conn.prepareStatement("SELECT * FROM users WHERE email=?");
                    ps.setString(1, email);
                    ResultSet rs = ps.executeQuery();
                    if (rs.next()) {
                        out.println("<p class='error'>Email already exists! Try another.</p>");
                    } else {
                        // Insert new user
                        ps = conn.prepareStatement(
                            "INSERT INTO users(fullname,email,password,gender,dob,phone,address,role) VALUES (?,?,?,?,?,?,?,?)"
                        );
                        ps.setString(1, fullname);
                        ps.setString(2, email);
                        ps.setString(3, password); // 🔑 TODO: use hashing in real projects
                        ps.setString(4, gender);
                        ps.setString(5, dob);
                        ps.setString(6, phone);
                        ps.setString(7, address);
                        ps.setString(8, role);

                        int rows = ps.executeUpdate();
                        if (rows > 0) {
                            out.println("<p class='success'>Registration successful! <a href='login.jsp'>Login here</a></p>");
                        }
                    }
                } catch (Exception e) {
                    out.println("<p class='error'>Error: " + e.getMessage() + "</p>");
                    e.printStackTrace(); // ✅ Logs to server console
                } finally {
                    try { if (ps != null) ps.close(); } catch (Exception ex) {}
                    try { if (conn != null) conn.close(); } catch (Exception ex) {}
                }
            }
        %>
    </div>
</body>
</html>
