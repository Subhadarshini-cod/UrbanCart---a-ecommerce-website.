<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Invalidate the session to log out
    session.invalidate();

    // Redirect user to login page
    response.sendRedirect("login.jsp");
%>