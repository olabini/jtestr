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
        RubyKernel.require(runtime.getTopSelf(), runtime.newString("jtestr"), Block.NULL_BLOCK);
        runner = runtime.evalScriptlet("JtestR::TestRunner.new");
    }

    public boolean run() {
        return run("test");
    }

    public boolean run(String dirname) {
        return runner.callMethod(runtime.getCurrentContext(), "run", new IRubyObject[]{runtime.newString(dirname)}).isTrue();
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
