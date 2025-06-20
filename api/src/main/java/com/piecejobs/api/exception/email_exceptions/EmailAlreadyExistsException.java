package com.piecejobs.api.exception.email_exceptions;

public class EmailAlreadyExistsException extends EmailException{

    public EmailAlreadyExistsException() {
        super("Email already in use");
    }

    public EmailAlreadyExistsException(String message) {
        super(message);
    }
}
