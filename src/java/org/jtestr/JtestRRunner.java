/*
 * See the file LICENSE in distribution for licensing and copyright
 */
package org.jtestr;

import java.io.IOException;

import java.net.InetSocketAddress;
import java.net.Socket;

import java.util.Arrays;
import java.util.List;

import org.jruby.Ruby;

import org.jtestr.ant.JtestRAntClient;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class JtestRRunner {
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

    public void execute() throws BackgroundClientException {
        boolean ran = false;
        try {
            Socket socket = new Socket();
            socket.connect(new InetSocketAddress("127.0.0.1",port));
            JtestRAntClient.executeClient(socket, tests, logging, outputLevel, output, groups);
            ran = true;
        } catch(IOException e) {}
        
        if(!ran) {
            Ruby runtime = new RuntimeFactory("<test script>", this.getClass().getClassLoader()).createRuntime();
            try {
                TestRunner testRunner = new TestRunner(runtime);
                boolean result = testRunner.run(tests, logging, outputLevel, output, groups.split(", ?"));
                testRunner.report();
                if(failOnError && !result) {
                    throw new RuntimeException("Tests failed");
                }
            } catch(org.jruby.exceptions.RaiseException e) {
                System.err.println("Failure: "  + e);
                e.printStackTrace(System.err);

                StackTraceElement[] trace = e.getStackTrace();
                int externalIndex = 0;
                for (int i = 0; i < trace.length; i++) {
                    System.err.println(trace[i]);
                }

                throw new RuntimeException("Exception while running", e);
            } finally {
                try {
                    runtime.tearDown();
                } catch(org.jruby.exceptions.RaiseException e) {
                    // Catches SystemExit events
                }
            }
        }
    }

    public static void main(String[] args) throws Exception {
        JtestRRunner runner = new JtestRRunner();
        if(args.length == 1 && (args[0].equals("-h") || args[0].equals("--help"))) {
            System.err.println("java org.jtestr.JtestRRunner [port] [tests] [logging] [configFile] [outputLevel] [output] [groups]");
        } else {
            switch(args.length) {
                // All of the following fall-throughs are by design
            case 7:
                runner.setGroups(args[6]);
            case 6:
                runner.setOutput(args[5]);
            case 5:
                runner.setOutputlevel(args[4]);
            case 4:
                runner.setConfigurationfile(args[3]);
            case 3:
                runner.setLogging(args[2]);
            case 2:
                runner.setTests(args[1]);
            case 1:
                runner.setPort(Integer.parseInt(args[0]));
            }

            runner.execute();
        }
    }
}
