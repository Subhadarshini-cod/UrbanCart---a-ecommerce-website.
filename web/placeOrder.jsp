<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.ecommerce.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String userEmail = (String) session.getAttribute("userEmail");
    if(userEmail == null){
        response.sendRedirect("login.jsp");
        return;
    }

    Map<Integer, Integer> cart = (Map<Integer, Integer>) session.getAttribute("cart");
    if(cart == null || cart.isEmpty()){
        response.sendRedirect("cart.jsp");
        return;
    }

    String address = request.getParameter("address");
    String payment = request.getParameter("payment");

    int orderId = 0;
    double grandTotal = 0.0;
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Order Confirmation</title>
    <style>
        /* Background */
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea, #764ba2); /* Blue to Purple gradient */
            margin: 0;
            padding: 0;
            color: #333;
        }

        /* Container */
        .container {
            max-width: 850px;
            margin: 70px auto;
            background: #ffffff;
            border-radius: 15px;
            box-shadow: 0 15px 40px rgba(0,0,0,0.15);
            padding: 40px 30px;
            text-align: center;
            animation: fadeIn 1s ease-in-out;
        }

        /* Header */
        .container h1 {
            font-size: 2.5rem;
            color: #5a67d8; /* Elegant Indigo */
            margin-bottom: 15px;
        }
        .container p {
            font-size: 1.1rem;
            color: #666;
            margin-bottom: 35px;
        }

        /* Order ID */
        .order-id {
            font-size: 1.4rem;
            color: #9f7aea; /* Soft Purple */
            font-weight: bold;
            margin-bottom: 25px;
        }

        /* Buttons */
        .btn {
            display: inline-block;
            background: #667eea;
            color: #fff;
            padding: 12px 25px;
            border-radius: 8px;
            font-weight: 600;
            margin: 10px;
            transition: 0.3s ease;
            box-shadow: 0 5px 15px rgba(102,126,234,0.3);
        }
        .btn:hover {
            background: #5a67d8;
            transform: translateY(-3px);
            box-shadow: 0 10px 25px rgba(90,103,216,0.4);
        }

        /* Table */
        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 30px;
        }
        th, td {
            padding: 14px 16px;
            border-bottom: 1px solid #eee;
            text-align: center;
        }
        th {
            background: #764ba2; /* Deep purple */
            color: #fff;
            font-weight: 600;
        }
        td {
            color: #444;
        }
        tr:nth-child(even) {
            background: #f9f7fd; /* soft lavender */
        }

        /* Animations */
        @keyframes fadeIn {
            0% {opacity: 0; transform: translateY(-20px);}
            100% {opacity: 1; transform: translateY(0);}
        }

        /* Responsive */
        @media(max-width: 768px){
            .container { padding: 25px 20px; }
            .container h1 { font-size: 2rem; }
            .order-id { font-size: 1.1rem; }
            table { font-size: 0.9rem; }
        }
    </style>
</head>
<body>
<%
    try (Connection conn = DBConnection.getConnection()) {
        conn.setAutoCommit(false);

        // Calculate grand total
        for(Map.Entry<Integer,Integer> entry : cart.entrySet()){
            int pid = entry.getKey();
            int qty = entry.getValue();
            try (PreparedStatement ps = conn.prepareStatement("SELECT price FROM products WHERE id=?")) {
                ps.setInt(1, pid);
                try (ResultSet rs = ps.executeQuery()) {
                    if(rs.next()) grandTotal += rs.getDouble("price") * qty;
                }
            }
        }

        // Insert order
        try (PreparedStatement psOrder = conn.prepareStatement(
            "INSERT INTO orders(user_email,address,payment_method,total) VALUES(?,?,?,?)",
            Statement.RETURN_GENERATED_KEYS
        )) {
            psOrder.setString(1, userEmail);
            psOrder.setString(2, address);
            psOrder.setString(3, payment);
            psOrder.setDouble(4, grandTotal);
            psOrder.executeUpdate();

            try (ResultSet rsOrder = psOrder.getGeneratedKeys()) {
                if(rsOrder.next()) orderId = rsOrder.getInt(1);
            }
        }

        // Insert order_items
        for(Map.Entry<Integer,Integer> entry : cart.entrySet()){
            int pid = entry.getKey();
            int qty = entry.getValue();
            double price = 0;
            try (PreparedStatement psPrice = conn.prepareStatement("SELECT price FROM products WHERE id=?")) {
                psPrice.setInt(1, pid);
                try (ResultSet rsPrice = psPrice.executeQuery()) {
                    if(rsPrice.next()) price = rsPrice.getDouble("price");
                }
            }

            try (PreparedStatement psItem = conn.prepareStatement(
                "INSERT INTO order_items(order_id,product_id,quantity,price) VALUES(?,?,?,?)"
            )) {
                psItem.setInt(1, orderId);
                psItem.setInt(2, pid);
                psItem.setInt(3, qty);
                psItem.setDouble(4, price);
                psItem.executeUpdate();
            }
        }

        conn.commit();
        session.removeAttribute("cart");
%>

    <div class="container">
        <h1>✅ Order Confirmed!</h1>
        <p class="order-id">Your Order ID is <strong>#<%=orderId%></strong></p>

        <table>
            <tr><th>Product ID</th><th>Quantity</th><th>Price (₹)</th><th>Total (₹)</th></tr>
            <%
                for(Map.Entry<Integer,Integer> entry : cart.entrySet()){
                    int pid = entry.getKey();
                    int qty = entry.getValue();
                    double price = 0;
                    try (PreparedStatement psPrice = conn.prepareStatement("SELECT price FROM products WHERE id=?")) {
                        psPrice.setInt(1, pid);
                        try (ResultSet rsPrice = psPrice.executeQuery()) {
                            if(rsPrice.next()) price = rsPrice.getDouble("price");
                        }
                    }
                    double total = price * qty;
            %>
            <tr>
                <td><%=pid%></td>
                <td><%=qty%></td>
                <td>₹<%=price%></td>
                <td>₹<%=total%></td>
            </tr>
            <% } %>
            <tr>
                <th colspan="3">Grand Total</th>
                <th>₹<%=grandTotal%></th>
            </tr>
        </table>

        <a href="products.jsp" class="btn">🛍 Continue Shopping</a>
        <a href="myOrders.jsp" class="btn">📦 View My Orders</a>
    </div>

<%
    } catch(Exception e){
        out.println("<p style='color:red; text-align:center; margin-top:50px;'>Error placing order: "+e.getMessage()+"</p>");
        e.printStackTrace();
    }
%>
</body>
</html>
