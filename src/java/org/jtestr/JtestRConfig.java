/*
 * See the files LICENSE in distribution for license and copyright
 */
package org.jtestr;

import java.util.List;
import java.util.Arrays;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class JtestRConfig {
    public final static String DEFAULT_RESULT_HANDLER = "JtestR::GenericResultHandler";
    private int port = 22332;
    private String tests = "test";
    private String logging = "WARN";
    private String configFile = "jtestr_config.rb";
    private String outputLevel = "QUIET";
    private String output = "STDOUT";
    private String[] groups = new String[0];
    private String resultHandler = DEFAULT_RESULT_HANDLER;
    private String workingDirectory = getCurrentDirectory();
    private String test = System.getProperty("jtestr.test", "");

    private static String getCurrentDirectory() {
        try {
            return new java.io.File(".").getCanonicalPath();
        } catch(Exception e) {
            return ".";
        }
    }

    /**
     * Private constructor to enable builder pattern
     */
    private JtestRConfig() {
    }

    /**
     * Copy constructor for internal builder use
     */
    private JtestRConfig(JtestRConfig orig) {
        this.port = orig.port;
        this.tests = orig.tests;
        this.logging = orig.logging;
        this.configFile = orig.configFile;
        this.outputLevel = orig.outputLevel;
        this.output = orig.output;
        this.groups = orig.groups;
        this.resultHandler = orig.resultHandler;
        this.workingDirectory = orig.workingDirectory;
        this.test = orig.test;
    }

    public static JtestRConfig config() {
        return new JtestRConfig();
    }

    /**
     * Setter
     */
    public JtestRConfig port(int port) {
        JtestRConfig local = new JtestRConfig(this);
        local.port = port;
        return local;
    }

    /**
     * Getter
     */
    public int port() {
        return this.port;
    }

    /**
     * Setter
     */
    public JtestRConfig tests(String tests) {
        JtestRConfig local = new JtestRConfig(this);
        local.tests = tests;
        return local;
    }

    /**
     * Getter
     */
    public String tests() {
        return this.tests;
    }

    private final static List<String> LOGGING_LEVELS = Arrays.asList("NONE","ERR","WARN","INFO","DEBUG");

    /**
     * Setter
     */
    public JtestRConfig logging(String logging) {
        if(LOGGING_LEVELS.contains(logging)) {
            JtestRConfig local = new JtestRConfig(this);
            local.logging = logging;
            return local;
        } else {
            throw new IllegalArgumentException("Value " + logging + " is not a valid logging level. The only valid levels are: " + LOGGING_LEVELS);
        }
    }

    /**
     * Getter
     */
    public String logging() {
        return this.logging;
    }

    /**
     * Setter
     */
    public JtestRConfig configFile(String configFile) {
        JtestRConfig local = new JtestRConfig(this);
        local.configFile = configFile;
        return local;
    }

    /**
     * Getter
     */
    public String configFile() {
        return this.configFile;
    }

    private final static List<String> OUTPUT_LEVELS = Arrays.asList("NONE","QUIET","NORMAL","VERBOSE","DEFAULT");

    /**
     * Setter
     */
    public JtestRConfig outputLevel(String outputLevel) {
        if(OUTPUT_LEVELS.contains(outputLevel)) {
            JtestRConfig local = new JtestRConfig(this);
            local.outputLevel = outputLevel;
            return local;
        } else {
            throw new IllegalArgumentException("Value " + outputLevel + " is not a valid output level. The only valid levels are: " + OUTPUT_LEVELS);
        }
    }

    /**
     * Getter
     */
    public String outputLevel() {
        return this.outputLevel;
    }

    /**
     * Setter
     */
    public JtestRConfig output(String output) {
        JtestRConfig local = new JtestRConfig(this);

        if(output.equals("STDOUT") || 
           output.equals("STDERR") || 
           output.charAt(0) == '$' || 
           output.charAt(0) == '@') {
            local.output = output;
        } else {
            local.output = "File.open('" + output + "', 'a+')";
        }

        return local;
    }

    /**
     * Getter
     */
    public String output() {
        return this.output;
    }

    /**
     * Setter
     */
    public JtestRConfig groups(String[] groups) {
        JtestRConfig local = new JtestRConfig(this);
        local.groups = groups;
        return local;
    }

    /**
     * Setter
     */
    public JtestRConfig groups(String groups) {
        if(groups == null || groups.equals("")) {
            return groups(new String[0]);
        } else {
            return groups(groups.split(", ?"));
        }
    }

    /**
     * Getter
     */
    public String[] groups() {
        return this.groups;
    }

    /**
     * Getter
     */
    public String groupsAsString() {
        StringBuilder builder = new StringBuilder();
        String sep = "";
        for(int i=0;i<groups.length;i++) {
            builder.append(sep).append(groups[i]);
            sep = ",";
        }

        return builder.toString();
    }

    /**
     * Setter
     */
    public JtestRConfig resultHandler(String resultHandler) {
        JtestRConfig local = new JtestRConfig(this);
        local.resultHandler = resultHandler;
        return local;
    }

    /**
     * Getter
     */
    public String resultHandler() {
        return this.resultHandler;
    }

    /**
     * Setter
     */
    public JtestRConfig workingDirectory(String workingDirectory) {
        JtestRConfig local = new JtestRConfig(this);
        local.workingDirectory = workingDirectory;
        return local;
    }

    /**
     * Getter
     */
    public String workingDirectory() {
        return this.workingDirectory;
    }


    /**
     * Setter
     */
    public JtestRConfig test(String test) {
        JtestRConfig local = new JtestRConfig(this);
        local.test = test;
        return local;
    }

    /**
     * Getter
     */
    public String test() {
        return this.test;
    }

    public boolean equals(Object other) {
        boolean res = this == other;
        if(!res && other instanceof JtestRConfig) {
            JtestRConfig c = (JtestRConfig)other;
            res = 
                this.port == c.port &&
                ((this.tests == null) ? c.tests == null : this.tests.equals(c.tests)) && 
                ((this.logging == null) ? c.logging == null : this.logging.equals(c.logging)) && 
                ((this.configFile == null) ? c.configFile == null : this.configFile.equals(c.configFile)) && 
                ((this.outputLevel == null) ? c.outputLevel == null : this.outputLevel.equals(c.outputLevel)) && 
                ((this.output == null) ? c.output == null : this.output.equals(c.output)) && 
                ((this.groups == null) ? c.groups == null : java.util.Arrays.equals(this.groups, c.groups)) && 
                ((this.resultHandler == null) ? c.resultHandler == null : this.resultHandler.equals(c.resultHandler)) && 
                ((this.workingDirectory == null) ? c.workingDirectory == null : this.workingDirectory.equals(c.workingDirectory)) && 
                ((this.test == null) ? c.test == null : this.test.equals(c.test));
        }
        return res;
    }
}// JtestRConfig
