/*
 * See the file LICENSE in distribution for licensing and copyright
 */
package org.jtestr.maven;

import java.io.IOException;

import java.net.InetSocketAddress;
import java.net.Socket;

import java.util.Arrays;
import java.util.List;

import org.jruby.Ruby;

import org.jtestr.RuntimeFactory;
import org.jtestr.TestRunner;
import org.jtestr.JtestRRunner;

import org.jtestr.ant.JtestRAntClient;

import org.apache.maven.plugin.AbstractMojo;
import org.apache.maven.plugin.MojoExecutionException;

import org.jtestr.BackgroundClientException;

/**
 * This class is the main class responsible for integration with Maven2.
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 * @phase test
 * @goal test
 */
public class JtestRMavenMojo extends AbstractMojo {
    /**
     * @parameter expression="${project}"
     */
    private org.apache.maven.project.MavenProject config;

    /**
     * Fail on error.
     *
     * @parameter expression="true"
     */
    private boolean failOnError;

    /**
     * Port to look for background server on.
     *
     * @parameter expression="22332"
     */
    private int port;

    /**
     * Directory to find tests in.
     *
     * @parameter expression="test"
     */
    private String tests;

    /**
     * Log level.
     *
     * @parameter expression="WARN"
     */
    private String logging;

    /**
     * Configuration file name.
     *
     * @parameter expression="jtestr_config.rb"
     */
    private String configFile;

    /**
     * Output level.
     *
     * @parameter expression="QUIET"
     */
    private String outputLevel;

    /**
     * Place where output should go.
     *
     * @parameter expression="STDOUT"
     */
    private String output;

    /**
     * Groups to execute.
     *
     * @parameter expression=""
     */
    private String groups;
    
    public void execute() throws MojoExecutionException {
        System.out.println();
        String cwd = config.getBasedir().toString();
        String[] classPath = new String[0];

        try {
            classPath = (String[])(config.getTestClasspathElements().toArray(classPath));
        } catch(Exception e) {
            // Ignore
        }
        
        String test = "";
        if(System.getProperty("jtestr.test") != null) {
            test = System.getProperty("jtestr.test");
        }

        boolean ran = false;
        try {
            Socket socket = new Socket();
            socket.connect(new InetSocketAddress("127.0.0.1",port));
            try {
                JtestRAntClient.executeClient(socket, cwd, tests, logging, outputLevel, output, groups, JtestRRunner.DEFAULT_RESULT_HANDLER, classPath, test);
            } catch(BackgroundClientException e) {
                throw new MojoExecutionException(e.getMessage(), e.getCause());
            }
            ran = true;
        } catch(IOException e) {}
        
        if(!ran) {
            Ruby runtime = new RuntimeFactory("<test script>", this.getClass().getClassLoader()).createRuntime();
            try {
                TestRunner testRunner = new TestRunner(runtime);
                boolean result = testRunner.run(cwd, tests, logging, outputLevel, output, (groups == null) ? new String[0] : groups.split(", ?"), JtestRRunner.DEFAULT_RESULT_HANDLER, classPath);
                testRunner.report();
                if(failOnError && !result) {
                    throw new MojoExecutionException("Tests failed");
                }
            } catch(org.jruby.exceptions.RaiseException e) {
                System.err.println("Failure: "  + e);
                e.printStackTrace(System.err);

                StackTraceElement[] trace = e.getStackTrace();
                int externalIndex = 0;
                for (int i = 0; i < trace.length; i++) {
                    System.err.println(trace[i]);
                }

                throw new MojoExecutionException("Exception while running", e);
            } finally {
                try {
                    runtime.tearDown();
                } catch(org.jruby.exceptions.RaiseException e) {
                    // Catches SystemExit events
                }
            }
        }
    }
}
