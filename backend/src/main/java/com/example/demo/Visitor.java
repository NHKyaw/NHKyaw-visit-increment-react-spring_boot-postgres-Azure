package com.example.demo;

import jakarta.persistence.*;

@Entity
@Table(name = "visitors")
public class Visitor {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String visitTime;

    public Visitor() {}
    public Visitor(String visitTime) { this.visitTime = visitTime; }
    public Long getId() { return id; }
}