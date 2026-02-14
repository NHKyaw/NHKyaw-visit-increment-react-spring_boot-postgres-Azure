package com.example.demo;

import org.springframework.web.bind.annotation.*;
import java.time.LocalDateTime;
import java.util.Map;

@RestController
@CrossOrigin(origins = "http://localhost:3000")
public class VisitorController {
    
    private final VisitorRepo repo;

    public VisitorController(VisitorRepo repo) { this.repo = repo; }

    @PostMapping("/api/visit") // Explicit full path
    public String addVisit() {
        repo.save(new Visitor(LocalDateTime.now().toString()));
        return "Visit Recorded!";
    }

    @GetMapping("/api/visit/count") // Explicit full path
    public Map<String, Long> getCount() {
        return Map.of("count", repo.count()); 
    }
}