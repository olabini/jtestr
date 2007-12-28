/*
 * See the file LICENSE in distribution for licensing and copyright
 */
package org.jtestr.maven;

import org.apache.maven.plugin.Mojo;
import org.apache.maven.plugin.AbstractMojo;
import org.apache.maven.plugin.MojoExecutionException;

/**
 * This class is the main class responsible for integration with Maven2.
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 * @goal jtestr
 */
public class JtestRMavenMojo extends AbstractMojo implements Mojo {
    public void execute() throws MojoExecutionException {
        getLog().info("Hello world from JtestR");
    }
}
