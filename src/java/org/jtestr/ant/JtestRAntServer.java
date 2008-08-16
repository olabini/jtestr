/*
 * See the file LICENSE in distribution for licensing and copyright
 */
package org.jtestr.ant;

import org.jtestr.BackgroundServer;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class JtestRAntServer extends Task {
    private int port = 22332;
    private int runtimes = 3;
    private boolean debug = true;
    private String load = null;

    public void setPort(int port) {
        this.port = port;
    }

    public void setRuntimes(int runtimes) {
        this.runtimes = runtimes;
    }

    public void setDebug(boolean debug) {
        this.debug = debug;
    }

    public void setLoad(String load) {
        this.load = load;
    }

    public void execute() throws BuildException {
        try {
            new BackgroundServer(port, runtimes, debug, load).startServer();
        } catch(java.io.IOException e) {
            throw new BuildException("Build server failed", e);
        }
    }    
}
