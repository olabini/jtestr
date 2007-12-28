/*
 * See the file LICENSE in distribution for licensing and copyright
 */
package org.jtestr;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class BackgroundClientException extends Exception {
    public BackgroundClientException() {
        super();
    }
    public BackgroundClientException(String msg) {
        super(msg);
    }
    public BackgroundClientException(String msg, Throwable cause) {
        super(msg, cause);
    }
    public BackgroundClientException(Throwable cause) {
        super(cause);
    }
}
