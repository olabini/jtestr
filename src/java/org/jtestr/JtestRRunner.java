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
    private JtestRConfig config = JtestRConfig.config();
    private boolean failOnError = true;

    public void setWorkingDirectory(String value) {
        config = config.workingDirectory(value);
    }

    public void setFailonerror(boolean value) {
        failOnError = value;
    }

    public void setTests(String tests) {
        config = config.tests(tests);
    }

    public void setGroups(String groups) {
        config = config.groups(groups);
    }

    public void setPort(int port) {
        config = config.port(port);
    }

    public void setTest(String test) {
        config = config.test(test);
    }

    public void setConfigurationfile(String configFile) {
        config = config.configFile(configFile);
    }

    public void setResultHandler(String resultHandler) {
        config = config.resultHandler(resultHandler);
    }

    public void setLogging(String logging) {
        config = config.logging(logging);
    } 

    public void setOutputlevel(String outputLevel) {
        config = config.outputLevel(outputLevel);
    }

    public void setOutput(String output) {
        config = config.output(output);
    }

    public void setLoad(String load) {
        config = config.load(load);
    }

    public void execute() throws BackgroundClientException {
        boolean ran = false;
        try {
            Socket socket = new Socket();
            socket.connect(new InetSocketAddress("127.0.0.1",config.port()));
            JtestRAntClient.executeClient(socket, config, new String[0]);
            ran = true;
        } catch(IOException e) {}
        
        if(!ran) {
            Ruby runtime = new RuntimeFactory("<test script>", this.getClass().getClassLoader()).createRuntime();
            try {
                TestRunner testRunner = new TestRunner(runtime, config.load());
                boolean result = testRunner.run(config, new String[0]);
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

                throw new RuntimeException("Exception while running: " + e.getException().inspect().toString(), e);
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
