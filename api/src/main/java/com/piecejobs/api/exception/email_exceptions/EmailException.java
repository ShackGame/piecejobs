package com.piecejobs.api.exception.email_exceptions;

public class EmailException extends RuntimeException {
    public EmailException(String message) {
        super(message);
    }
}