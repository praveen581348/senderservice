package com.example.senderservice.controller;

import com.example.senderservice.kafka.SenderService;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class SenderController {

    private final SenderService senderService;

    public SenderController(SenderService senderService) {
        this.senderService = senderService;
    }

    // Serve the HTML form
    @GetMapping("/")
    public String showForm() {
        return "index"; // Render index.html from src/main/resources/templates/
    }

    // Handle message submission
    @PostMapping("/send")
    public String sendMessage(@RequestParam("message") String message) {
        senderService.sendMessage(message); // Send message to Kafka
        return "message-sent";  // Redirect to message-sent.html
    }
}
