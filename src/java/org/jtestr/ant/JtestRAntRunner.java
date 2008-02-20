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
import org.jtestr.JtestRRunner;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class JtestRAntRunner extends Task {
    private JtestRRunner runner = new JtestRRunner();

    public void setFailonerror(boolean value) {
        runner.setFailonerror(value);
    }

    public void setTests(String tests) {
        runner.setTests(tests);
    }

    public void setGroups(String groups) {
        runner.setGroups(groups);
    }

    public void setPort(int port) {
        runner.setPort(port);
    }

    public void setConfigurationfile(String configFile) {
        runner.setConfigurationfile(configFile);
    }

    public void setLogging(String logging) {
        runner.setLogging(logging);
    } 

    public void setOutputlevel(String outputLevel) {
        runner.setOutputlevel(outputLevel);
    }

    public void setOutput(String output) {
        runner.setOutput(output);
    }

    public void execute() throws BuildException {
        try {
            runner.execute();
        } catch(BackgroundClientException e) {
            throw new BuildException(e.getMessage(), e.getCause());
        } catch(RuntimeException e) {
            throw new BuildException(e.getMessage());
        }
    }
}// JtestRAntRunner
