<%@ page import="java.sql.*, com.ecommerce.DBConnection" %>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // If user already logged in, redirect to index.jsp
    if (session.getAttribute("userEmail") != null) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Login - E-Commerce</title>
    <style>
    /* Reset */
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }

    body {
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        min-height: 100vh;
        display: flex;
        justify-content: center;
        align-items: center;

        /* Background gradient with image */
        background: linear-gradient(135deg, rgba(0, 201, 167, 0.85), rgba(0, 132, 255, 0.85)),
                    url('https://images.unsplash.com/photo-1522202195463-8b9da6b77e4a?auto=format&fit=crop&w=1500&q=80') no-repeat center center/cover;
    }

    .login-box {
        background: rgba(255, 255, 255, 0.15);
        backdrop-filter: blur(12px) saturate(180%);
        -webkit-backdrop-filter: blur(12px) saturate(180%);
        border-radius: 18px;
        padding: 40px 30px;
        width: 350px;
        text-align: center;
        animation: fadeIn 1s ease-in-out;
        border: 1px solid rgba(255, 255, 255, 0.25);
        box-shadow: 0 15px 30px rgba(0,0,0,0.25);
    }

    .login-box h2 {
        margin-bottom: 25px;
        color: #ffffff;
        font-size: 2.2em;
        font-weight: 700;
        letter-spacing: 1px;
        text-shadow: 0 2px 8px rgba(0,0,0,0.2);
    }

    input {
        width: 100%;
        padding: 12px 15px;
        margin: 12px 0;
        border: none;
        border-radius: 12px;
        font-size: 1em;
        background: rgba(255,255,255,0.2);
        color: #fff;
        transition: all 0.3s ease;
    }

    input::placeholder {
        color: rgba(255, 255, 255, 0.7);
    }

    input:focus {
        outline: none;
        background: rgba(255,255,255,0.35);
        box-shadow: 0 0 10px rgba(255,255,255,0.4);
    }

    button {
        width: 100%;
        padding: 14px;
        margin-top: 18px;
        background: linear-gradient(135deg, #06beb6, #48b1bf);
        color: white;
        font-weight: bold;
        border: none;
        border-radius: 14px;
        cursor: pointer;
        font-size: 1.05em;
        transition: all 0.3s ease;
    }

    button:hover {
        background: linear-gradient(135deg, #08d3c7, #5cc4cc);
        transform: translateY(-3px) scale(1.02);
        box-shadow: 0 10px 20px rgba(0,0,0,0.25);
    }

    .error {
        color: #ff6b6b;
        margin-top: 15px;
        font-weight: 500;
    }

    .register-link {
        display: block;
        margin-top: 20px;
        font-size: 0.95em;
        color: #ffe97f;
        text-decoration: none;
        transition: color 0.3s ease;
    }

    .register-link:hover {
        text-decoration: underline;
        color: #fff6b3;
    }

    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(-20px); }
        to { opacity: 1; transform: translateY(0); }
    }

    @media(max-width: 400px) {
        .login-box {
            width: 90%;
            padding: 30px 20px;
        }
    }
    </style>
</head>
<body>
    <div class="login-box">
        <h2>Login</h2>
        <form method="post" action="login.jsp">
            <input type="text" name="email" placeholder="Email" required>
            <input type="password" name="password" placeholder="Password" required>
            <button type="submit">Login</button>
        </form>
        <a href="register.jsp" class="register-link">New user? Register here</a>

        <%
            String email = request.getParameter("email");
            String password = request.getParameter("password");

            if (email != null && password != null) {
                Connection conn = null;
                PreparedStatement ps = null;
                ResultSet rs = null;
                try {
                    conn = DBConnection.getConnection();
                    ps = conn.prepareStatement("SELECT * FROM users WHERE email=? AND password=?");
                    ps.setString(1, email);
                    ps.setString(2, password); // plain text for simplicity
                    rs = ps.executeQuery();

                    if (rs.next()) {
                        session.setAttribute("userEmail", email); // store session
                        response.sendRedirect("index.jsp");
                    } else {
                        out.println("<p class='error'>Invalid email or password!</p>");
                    }
                } catch (Exception e) {
                    out.println("<p class='error'>Error: " + e.getMessage() + "</p>");
                    e.printStackTrace();
                } finally {
                    try { if (rs != null) rs.close(); } catch (Exception ex) {}
                    try { if (ps != null) ps.close(); } catch (Exception ex) {}
                    try { if (conn != null) conn.close(); } catch (Exception ex) {}
                }
            }
        %>
    </div>
</body>
</html>
