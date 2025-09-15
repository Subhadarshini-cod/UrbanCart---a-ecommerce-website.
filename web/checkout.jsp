<%@ page import="java.util.*,java.sql.*,com.ecommerce.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String userEmail = (String) session.getAttribute("userEmail");
    if(userEmail == null) { response.sendRedirect("login.jsp"); return; }

    Map<Integer,Integer> cart = (Map<Integer,Integer>) session.getAttribute("cart");
    if(cart == null || cart.isEmpty()) { response.sendRedirect("cart.jsp"); return; }

    double grandTotal = 0.0;
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Checkout - Confirm Order</title>
   <style>
    body {
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        background: #f9f9f9;
        color: #333;
        margin: 0;
        padding: 20px;
    }

    h2 {
        text-align: center;
        color: #5a67d8; /* soft purple */
        margin-bottom: 40px;
        font-size: 2em;
    }

    table {
        width: 80%;
        margin: auto;
        border-collapse: collapse;
        border-radius: 10px;
        overflow: hidden;
        box-shadow: 0 8px 20px rgba(0,0,0,0.1);
        background: #ffffff;
    }

    th, td {
        padding: 12px;
        text-align: center;
    }

    th {
        background: #5a67d8; /* header color */
        color: white;
        font-weight: 600;
    }

    tr:nth-child(even) {
        background: #f5f5fa;
    }

    textarea, select {
        width: 50%;
        padding: 10px;
        border: 1px solid #ccc;
        border-radius: 8px;
        font-size: 1em;
        margin-top: 5px;
    }

    textarea:focus, select:focus {
        outline: none;
        border-color: #5a67d8;
        box-shadow: 0 0 5px rgba(90,103,216,0.5);
    }

    .btn {
        display: inline-block;
        padding: 12px 25px;
        margin-top: 20px;
        background: #ff6f61; /* soft reddish */
        color: white;
        text-decoration: none;
        border-radius: 8px;
        font-weight: bold;
        transition: all 0.3s ease;
        border: none;
        cursor: pointer;
        font-size: 1em;
    }

    .btn:hover {
        background: #ff4c3b;
        transform: translateY(-2px);
        box-shadow: 0 4px 10px rgba(0,0,0,0.2);
    }

    form {
        text-align: center;
        margin-top: 30px;
    }

    label {
        font-weight: 600;
        display: block;
        margin-top: 15px;
        margin-bottom: 5px;
        color: #555;
    }

    @media(max-width: 768px) {
        table { width: 95%; }
        textarea, select { width: 80%; }
    }
</style>

</head>
<body>
    <h2 style="text-align:center;">Confirm Your Order</h2>

    <table>
        <tr><th>Product</th><th>Quantity</th><th>Price (₹)</th><th>Total (₹)</th></tr>
        <%
            try(Connection conn = DBConnection.getConnection()) {
                for(Map.Entry<Integer,Integer> entry : cart.entrySet()){
                    int pid = entry.getKey();
                    int qty = entry.getValue();

                    PreparedStatement ps = conn.prepareStatement("SELECT name, price FROM products WHERE id=?");
                    ps.setInt(1, pid);
                    ResultSet rs = ps.executeQuery();
                    if(rs.next()){
                        String name = rs.getString("name");
                        double price = rs.getDouble("price");
                        double total = price * qty;
                        grandTotal += total;
        %>
                        <tr>
                            <td><%=name%></td>
                            <td><%=qty%></td>
                            <td>₹<%=price%></td>
                            <td>₹<%=total%></td>
                        </tr>
        <%
                    }
                    rs.close(); ps.close();
                }
            } catch(Exception e){ out.println("<tr><td colspan='4'>Error: "+e.getMessage()+"</td></tr>"); }
        %>
        <tr><th colspan="3">Grand Total</th><th>₹<%=grandTotal%></th></tr>
    </table>

    <form action="placeOrder.jsp" method="post" style="text-align:center; margin-top:30px;">
        <label>Shipping Address:</label><br>
        <textarea name="address" rows="3" cols="50" required></textarea><br><br>

        <label>Payment Method:</label><br>
        <select name="payment" required>
            <option value="Cash on Delivery">Cash on Delivery</option>
            <option value="Online Payment">Online Payment</option>
        </select><br><br>

        <button type="submit" class="btn">Confirm & Pay</button>
    </form>
</body>
</html>