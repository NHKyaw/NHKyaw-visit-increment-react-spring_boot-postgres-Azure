package com.example.demo;

import org.springframework.context.annotation.Configuration;
import jakarta.annotation.PostConstruct;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

@Configuration
public class DatabaseConfig {

    @PostConstruct
    public void init() {
        // 1. Connect to the default 'postgres' database first
        String rootUrl = "jdbc:postgresql://postgres-db:5432/my_database";
        String user = "postgres";
        String pass = "12345678";
        String dbName = "my_database";

        try (Connection conn = DriverManager.getConnection(rootUrl, user, pass);
             Statement stmt = conn.createStatement()) {
            
            // 2. Check if our database exists, if not, create it
            stmt.executeUpdate("CREATE DATABASE " + dbName);
            System.out.println("Database '" + dbName + "' created successfully.");
            
        } catch (Exception e) {
            // If it already exists, it will throw an error, which we can ignore
            System.out.println("Database already exists or error occurred: " + e.getMessage());
        }
    }
}