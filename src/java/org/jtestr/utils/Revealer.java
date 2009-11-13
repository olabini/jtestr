/*
 * See the file LICENSE in distribution for licensing and copyright
 */
package org.jtestr.utils;

import java.io.PrintStream;
import java.io.OutputStream;
import java.io.IOException;

/**
 * The purpose of this class is to allow someone to use
 * System.setOut or System.setErr and find out where something
 * gets printed from. It's pretty low level, but definitely
 * useful when you're getting stack trackes from the middle
 * of nowhere.
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class Revealer extends OutputStream {
    private String name;
    private PrintStream errOut;
    private OutputStream realOutput;
    private boolean printed = false;
    public Revealer(String name, PrintStream errOut, OutputStream realOutput) {
        super();
        this.name = name;
        this.errOut = errOut;
        this.realOutput = realOutput;
    }

    @Override
    public void write(int b) throws IOException {
        if(!printed) {
            errOut.println("[" + name + "] GOT: " + (char)b);
            new Exception().printStackTrace(errOut);
            printed = true;
        }
        
        realOutput.write(b);
    }
}
