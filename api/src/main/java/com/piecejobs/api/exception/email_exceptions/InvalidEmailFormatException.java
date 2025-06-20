package com.piecejobs.api.exception.email_exceptions;

public class InvalidEmailFormatException extends  EmailException{

    public InvalidEmailFormatException() {
        super("Invalid email format");
    }

    public InvalidEmailFormatException(String message) {
        super(message);
    }
}
