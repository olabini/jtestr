/*
 * See the file LICENSE in distribution for licensing and copyright
 */
package org.jtestr.ant;

import java.io.IOException;

import java.net.InetSocketAddress;
import java.net.Socket;

import org.jruby.Ruby;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

import org.jtestr.RuntimeFactory;
import org.jtestr.TestRunner;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class JtestRAntRunner extends Task {
    private boolean failOnError = true;
    private int port = 22332;
    private String tests = "test";

    public void setFailonerror(boolean value) {
        failOnError = value;
    }

    public void setTests(String tests) {
        this.tests = tests;
    }

    public void setPort(int port) {
        this.port = port;
    }

    public void execute() throws BuildException {
        boolean ran = false;
        try {
            Socket socket = new Socket();
            socket.connect(new InetSocketAddress("127.0.0.1",port));
            JtestRAntClient.executeClient(socket, tests);
            ran = true;
        } catch(IOException e) {}
        
        if(!ran) {
            Ruby runtime = new RuntimeFactory("<test script>", this.getClass().getClassLoader()).createRuntime();
            try {
                TestRunner testRunner = new TestRunner(runtime);
                boolean result = testRunner.run(tests);
                testRunner.report();
                if(failOnError && !result) {
                    throw new BuildException("Tests failed");
                }
            } catch(org.jruby.exceptions.RaiseException e) {
                System.err.println("Failure: "  + e);
                e.printStackTrace(System.err);

                StackTraceElement[] trace = e.getStackTrace();
                int externalIndex = 0;
                for (int i = 0; i < trace.length; i++) {
                    System.err.println(trace[i]);
                }

                throw new BuildException("Exception while running", e);
            } finally {
                try {
                    runtime.tearDown();
                } catch(org.jruby.exceptions.RaiseException e) {
                    // Catches SystemExit events
                }
            }
        }
    }
}// JtestRAntRunner
