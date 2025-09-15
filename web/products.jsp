<%@ page import="java.sql.*, com.ecommerce.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Products - ShopSphere</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700&display=swap');

        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Poppins', sans-serif; }

        body {
            min-height: 100vh;
            background: linear-gradient(135deg, #0077b6, #48cae4);
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 20px;
        }

        .navbar {
            width: 90%;
            margin: 20px auto;
            padding: 15px 30px;
            display: flex;
            justify-content: center;
            gap: 25px;
            background: rgba(255, 255, 255, 0.55);
            backdrop-filter: blur(12px);
            border-radius: 15px;
            box-shadow: 0 6px 25px rgba(0,0,0,0.1);
        }

        .navbar a {
            color: #023e8a;
            text-decoration: none;
            font-weight: 600;
            padding: 10px 20px;
            border-radius: 10px;
            transition: all 0.3s ease;
        }

        .navbar a:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: scale(1.05);
        }

        h2 {
            text-align: center;
            margin: 30px 0;
            font-size: 2.5em;
            font-weight: 700;
            background: #fff;
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .products {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 30px;
            padding: 0 40px;
            width: 100%;
            max-width: 1200px;
        }

        /* SQUARE product cards */
        .product-card {
            aspect-ratio: 1 / 1;
            background: rgba(255, 255, 255, 0.75);
            backdrop-filter: blur(12px);
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 8px 25px rgba(0,0,0,0.1);
            transition: all 0.4s ease;
            padding: 20px;
            text-align: center;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }

        .product-card:hover {
            transform: translateY(-8px) scale(1.02);
            box-shadow: 0 15px 40px rgba(0,0,0,0.15);
        }

        .product-card img {
            width: 100%;
            height: 60%;
            object-fit: cover;
            border-radius: 15px;
            margin-bottom: 10px;
        }

        .product-info {
            flex: 1;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }

        .product-info h3 {
            color: #023e8a;
            font-size: 1.1em;
            margin-bottom: 6px;
        }

        .product-info p {
            font-size: 0.9em;
            color: #333;
            margin-bottom: 8px;
            line-height: 1.3;
            flex-grow: 1;
        }

        .price {
            font-size: 1.1em;
            font-weight: 700;
            color: #0077b6;
            margin-bottom: 6px;
        }

        .stock {
            font-size: 0.8em;
            color: #555;
            margin-bottom: 8px;
        }

        .quantity {
            width: 60px;
            padding: 6px;
            border: 1px solid #ccc;
            border-radius: 8px;
            margin-bottom: 10px;
        }

        .btn {
            padding: 8px 16px;
            background: linear-gradient(45deg, #0077b6, #48cae4);
            color: #fff;
            border: none;
            border-radius: 50px;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.3s ease;
            box-shadow: 0 6px 18px rgba(0,119,182,0.2);
        }

        .btn:hover {
            transform: translateY(-4px) scale(1.05);
            box-shadow: 0 10px 25px rgba(0,119,182,0.3);
        }

        @media(max-width: 992px) {
            .products { grid-template-columns: repeat(2, 1fr); }
        }
        @media(max-width: 600px) {
            .products { grid-template-columns: 1fr; }
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

    <h2>🛍️ Explore Our Collection</h2>

    <div class="products">
        <%
            try(Connection conn = DBConnection.getConnection()) {
                Statement st = conn.createStatement();
                ResultSet rs = st.executeQuery("SELECT * FROM products");
                while(rs.next()){
                    int id = rs.getInt("id");
                    String name = rs.getString("name");
                    String desc = rs.getString("description");
                    double price = rs.getDouble("price");
                    int stock = rs.getInt("stock");

                    String imgUrl = "https://via.placeholder.com/300x300.png?text=" + name.replaceAll(" ", "+");
        %>
            <div class="product-card">
                <img src="<%=imgUrl%>" alt="<%=name%>">
                <div class="product-info">
                    <h3><%=name%></h3>
                    <p><%=desc%></p>
                    <div class="price">₹<%=price%></div>
                    <div class="stock">In stock: <%=stock%></div>
                    <form action="cart.jsp" method="get">
                        <input type="hidden" name="productId" value="<%=id%>">
                        <input type="number" name="quantity" value="1" min="1" max="<%=stock%>" class="quantity" required>
                        <br>
                        <button type="submit" class="btn">Add to Cart</button>
                    </form>
                </div>
            </div>
        <%
                }
                rs.close();
                st.close();
            } catch(Exception e){
        %>
            <p style="color:red; text-align:center;">Error: <%=e.getMessage()%></p>
        <%
            }
        %>
    </div>
</body>
</html>
