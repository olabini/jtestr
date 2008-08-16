/*
 * See the file LICENSE in distribution for licensing and copyright
 */
package org.jtestr.maven;

import org.apache.maven.plugin.AbstractMojo;
import org.apache.maven.plugin.MojoExecutionException;

import org.jtestr.BackgroundServer;

/**
 * The class responsible for starting a background server in Maven2.
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 * @goal server
 */
public class JtestRMavenServerMojo extends AbstractMojo {
    /**
     * Debug output from server.
     *
     * @parameter expression="true"
     */
    private boolean debug;

    /**
     * Port to start background server on.
     *
     * @parameter expression="22332"
     */
    private int port;

    /**
     * Amount of runtimes to start.
     *
     * @parameter expression="3"
     */
    private int runtimes;

    /**
     * Load strategy to use.
     *
     * @parameter expression=""
     */
    private String load;
    
    public void execute() throws MojoExecutionException {
        try {
            new BackgroundServer(port, runtimes, debug, load).startServer();
        } catch(java.io.IOException e) {
            throw new MojoExecutionException("Build server failed", e);
        }
    }    
}
