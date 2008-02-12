/*
 * See the file LICENSE in distribution for licensing and copyright
 */
package org.jtestr.ant;

import java.io.IOException;

import java.net.InetSocketAddress;
import java.net.Socket;

import java.util.Arrays;
import java.util.List;

import org.jruby.Ruby;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

import org.jtestr.RuntimeFactory;
import org.jtestr.TestRunner;
import org.jtestr.BackgroundClientException;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class JtestRAntRunner extends Task {
    private boolean failOnError = true;
    private int port = 22332;
    private String tests = "test";
    private String logging = "WARN";
    private String configFile = "jtestr_config.rb";
    private String outputLevel = "QUIET";
    private String output = "STDOUT";
    private String groups = "";

    public void setFailonerror(boolean value) {
        failOnError = value;
    }

    public void setTests(String tests) {
        this.tests = tests;
    }

    public void setGroups(String groups) {
        this.groups = groups;
    }

    public void setPort(int port) {
        this.port = port;
    }

    public void setConfigurationfile(String configFile) {
        this.configFile = configFile;
    }

    private final static List<String> LOGGING_LEVELS = Arrays.asList("NONE","ERR","WARN","INFO","DEBUG");
    public void setLogging(String logging) {
        if(LOGGING_LEVELS.contains(logging)) {
            this.logging = logging;
        } else {
            throw new IllegalArgumentException("Value " + logging + " is not a valid logging level. The only valid levels are: " + LOGGING_LEVELS);
        }
    } 

    private final static List<String> OUTPUT_LEVELS = Arrays.asList("NONE","QUIET","NORMAL","VERBOSE","DEFAULT");
    public void setOutputlevel(String outputLevel) {
        if(OUTPUT_LEVELS.contains(outputLevel)) {
            this.outputLevel = outputLevel;
        } else {
            throw new IllegalArgumentException("Value " + outputLevel + " is not a valid output level. The only valid levels are: " + OUTPUT_LEVELS);
        }
    }

    public void setOutput(String output) {
        if(output.equals("STDOUT") || output.equals("STDERR")) {
            this.output = output;
        } else {
            this.output = "File.open(' " + output + "', 'a+')";
        }
    }

    public void execute() throws BuildException {
        boolean ran = false;
        try {
            Socket socket = new Socket();
            socket.connect(new InetSocketAddress("127.0.0.1",port));
            try {
                JtestRAntClient.executeClient(socket, tests, logging, outputLevel, output, groups);
            } catch(BackgroundClientException e) {
                throw new BuildException(e.getMessage(), e.getCause());
            }
            ran = true;
        } catch(IOException e) {}
        
        if(!ran) {
            Ruby runtime = new RuntimeFactory("<test script>", this.getClass().getClassLoader()).createRuntime();
            try {
                TestRunner testRunner = new TestRunner(runtime);
                boolean result = testRunner.run(tests, logging, outputLevel, output, groups.split(", ?"));
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
