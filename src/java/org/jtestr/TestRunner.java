/*
 * See the file LICENSE in distribution for licensing and copyright
 */
package org.jtestr;

import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.Ruby;
import org.jruby.RubyKernel;
import org.jruby.runtime.Block;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class TestRunner {
    private Ruby runtime;

    private IRubyObject runner;

    public TestRunner(Ruby runtime) {
        this.runtime = runtime;
        RubyKernel.require(runtime.getTopSelf(), runtime.newString("jtestr.rb"), Block.NULL_BLOCK);
        runner = runtime.evalScriptlet("JtestR::TestRunner.new");
    }

    public boolean run() {
        return run(JtestRConfig.config().tests("test"), new String[0]);
    }

    public IRubyObject getAggregator() {
        return runner.callMethod(runtime.getCurrentContext(), "aggregator"); 
    }

    public boolean run(JtestRConfig config, String[] classPath) {
        IRubyObject[] arr = new IRubyObject[config.groups().length];
        for(int i=0;i<arr.length;i++) {
            arr[i] = runtime.newString(config.groups()[i]);
        }

        IRubyObject[] cp = new IRubyObject[classPath.length];
        for(int i=0;i<cp.length;i++) {
            cp[i] = runtime.newString(classPath[i]);
        }

        runtime.setCurrentDirectory(config.workingDirectory());

        return runner.callMethod(runtime.getCurrentContext(), "run", new IRubyObject[]{
                runtime.newString(config.tests()),
                runtime.evalScriptlet("JtestR::SimpleLogger::" + config.logging()),
                runtime.evalScriptlet("JtestR::GenericResultHandler::" + config.outputLevel()),
                runtime.evalScriptlet(config.output()),
                runtime.newArrayNoCopy(arr),
                runtime.evalScriptlet(config.resultHandler()),
                runtime.newArrayNoCopy(cp)
            }).isTrue();
    }

    public void report() {
        runner.callMethod(runtime.getCurrentContext(), "report", new IRubyObject[0]);
    }

    public Ruby getRuntime() {
        return runtime;
    }

    /**
     * Simple main method to execute functionality until the surrounding 
     * infrastructure for testing is in place.
     */
    public static void main(String[] args) {
        Ruby runtime = new RuntimeFactory("<test script>").createRuntime();
        try {
            TestRunner testRunner = new TestRunner(runtime);
            System.err.println("succeeded: " + testRunner.run());
        } finally {
            runtime.tearDown();
        }
    }
}// TestRunner
