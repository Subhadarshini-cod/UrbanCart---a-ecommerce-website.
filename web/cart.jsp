<%@ page import="java.util.*, java.sql.*, com.ecommerce.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Ensure user is logged in
    String userEmail = (String) session.getAttribute("userEmail");
    if(userEmail == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Retrieve or create cart from session
    Map<Integer, Integer> cart = (Map<Integer, Integer>) session.getAttribute("cart");
    if(cart == null) cart = new HashMap<>();

    // Add product to cart if coming from products.jsp
    String prodIdStr = request.getParameter("productId");
    String qtyStr = request.getParameter("quantity");
    if(prodIdStr != null && qtyStr != null) {
        int prodId = Integer.parseInt(prodIdStr);
        int qty = Integer.parseInt(qtyStr);
        cart.put(prodId, cart.getOrDefault(prodId, 0) + qty);

        // Save cart back to session
        session.setAttribute("cart", cart);

        // Redirect to avoid duplicate add on refresh
        response.sendRedirect("cart.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Shopping Cart</title>
  <style>
    /* ===== Background ===== */
    body { 
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
        margin: 0; 
        padding: 0; 
        color: #2d3748;
        background: linear-gradient(135deg, #e0f7fa, #e6fffa); 
        background-attachment: fixed;
    }

    h2 { 
        text-align: center; 
        color: #2b6cb0; 
        margin: 30px 0; 
        font-size: 2em;
        text-shadow: 1px 1px 3px rgba(0,0,0,0.1);
    }

    /* ===== Navbar (unchanged) ===== */
    .navbar {
        background: #667eea;
        padding: 15px 0;
        text-align: center;
        box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        border-radius: 0 0 15px 15px;
        margin-bottom: 30px;
    }

    .navbar a {
        color: white;
        margin: 0 20px;
        text-decoration: none;
        font-weight: 600;
        font-size: 16px;
        transition: 0.3s;
    }

    .navbar a:hover {
        color: #ffebc7;
    }

    /* ===== Cart Table ===== */
    table {
        width: 85%;
        margin: auto;
        border-collapse: collapse;
        background: #ffffff;
        border-radius: 15px;
        overflow: hidden;
        box-shadow: 0 6px 20px rgba(0,0,0,0.12);
        margin-bottom: 30px;
    }

    th, td {
        padding: 15px;
        text-align: center;
    }

    th {
        background: linear-gradient(90deg, #4299e1, #38b2ac);
        color: white;
        font-weight: 600;
        font-size: 15px;
    }

    tr:nth-child(even) {
        background: #f7fafc;
    }

    tr:hover {
        background: #ebf8ff;
    }

    /* ===== Buttons ===== */
    .btn {
        padding: 8px 15px;
        background: #e53e3e;
        color: white;
        border: none;
        border-radius: 6px;
        cursor: pointer;
        font-weight: 600;
        transition: all 0.3s;
        text-decoration: none;
        display: inline-block;
    }

    .btn:hover {
        background: #c53030;
        transform: scale(1.05);
    }

    .checkout-btn {
        display: inline-block;
        margin-top: 20px;
        padding: 14px 28px;
        background: linear-gradient(90deg, #48bb78, #38a169);
        color: white;
        font-weight: 600;
        border-radius: 10px;
        text-decoration: none;
        transition: all 0.3s;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    }

    .checkout-btn:hover {
        background: linear-gradient(90deg, #38a169, #2f855a);
        transform: translateY(-3px);
    }

    /* ===== Empty Cart ===== */
    p {
        text-align: center;
        font-size: 1.2em;
        margin-top: 40px;
    }

    p a {
        color: #2b6cb0;
        font-weight: 600;
        text-decoration: none;
    }

    p a:hover {
        text-decoration: underline;
    }

    /* ===== Responsive ===== */
    @media(max-width:768px){
        table { width: 95%; font-size: 14px; }
        .navbar a { margin: 0 10px; font-size: 14px; }
        .checkout-btn { padding: 12px 20px; font-size: 15px; }
    }
</style>
</head>
<body>
    <div class="navbar">
        <a href="index.jsp">Home</a>
        <a href="products.jsp">Products</a>
        <a href="cart.jsp">Cart</a>
        <a href="myOrders.jsp">My Orders</a>
        <a href="logout.jsp">Logout</a>
    </div>

    <h2>Your Shopping Cart</h2>

    <%
        double grandTotal = 0.0;

        if(cart.isEmpty()) {
    %>
        <p>🛒 Your cart is empty. <a href="products.jsp">Shop now</a></p>
    <%
        } else {
    %>
    <table>
        <tr>
            <th>Product</th>
            <th>Price (₹)</th>
            <th>Quantity</th>
            <th>Total (₹)</th>
            <th>Action</th>
        </tr>
        <%
            try(Connection conn = DBConnection.getConnection()) {
                for(Map.Entry<Integer,Integer> entry : cart.entrySet()) {
                    int pid = entry.getKey();
                    int qty = entry.getValue();

                    String sql = "SELECT name, price FROM products WHERE id=?";
                    try(PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setInt(1, pid);
                        try(ResultSet rs = ps.executeQuery()) {
                            if(rs.next()) {
                                String name = rs.getString("name");
                                double price = rs.getDouble("price");
                                double total = price * qty;
                                grandTotal += total;
        %>
        <tr>
            <td><%=name%></td>
            <td>₹<%=price%></td>
            <td><%=qty%></td>
            <td>₹<%=total%></td>
            <td>
                <a class="btn" href="cart.jsp?remove=<%=pid%>">Remove</a>
            </td>
        </tr>
        <%
                            }
                        }
                    }
                }

                // Remove product if requested
                String removeIdStr = request.getParameter("remove");
                if(removeIdStr != null) {
                    int removeId = Integer.parseInt(removeIdStr);
                    cart.remove(removeId);
                    session.setAttribute("cart", cart);
                    response.sendRedirect("cart.jsp");
                    return;
                }

            } catch(Exception e) {
                out.println("<tr><td colspan='5' style='color:red;'>Error: "+e.getMessage()+"</td></tr>");
            }
        %>
        <tr>
            <th colspan="3">Grand Total</th>
            <th colspan="2">₹ <%=grandTotal%></th>
        </tr>
    </table>
    <div style="text-align:center; margin-top:20px;">
        <a class="checkout-btn" href="checkout.jsp">Proceed to Checkout</a>
    </div>
    <%
        }
    %>
</body>
</html>
