/*
 * See the file LICENSE in distribution for licensing and copyright
 */
package org.jtestr;

import java.util.HashMap;
import java.util.Map;
import org.jruby.Ruby;
import org.jruby.RubyArray;
import org.jruby.RubyHash;
import org.jruby.RubyKernel;
import org.jruby.runtime.Block;
import org.jruby.runtime.GlobalVariable;
import org.jruby.runtime.builtin.IRubyObject;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class TestRunner {
    private Ruby runtime;

    private IRubyObject runner;

    public TestRunner(Ruby runtime, String load) {
        this.runtime = runtime;
        if(load != null) {
            String[] parts = load.split(";\\s*");
            Map<IRubyObject, IRubyObject> valueMap = new HashMap<IRubyObject, IRubyObject>();
            for(String part : parts) {
                String[] values = part.split("\\s*=\\s*");
                String key = values[0];
                String[] paths = values[1].split(",\\s*");
                RubyArray ary = runtime.newArray(paths.length);
                for(String path : paths) {
                    ary.append(runtime.newString(path));
                }
                valueMap.put(runtime.newString(key), ary);
            }
            runtime.defineVariable(new GlobalVariable(runtime, "$JTESTR_LOAD_STRATEGY", RubyHash.newHash(runtime, valueMap, runtime.getNil())));
        }
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
            TestRunner testRunner = new TestRunner(runtime, null);
            System.err.println("succeeded: " + testRunner.run());
        } finally {
            runtime.tearDown();
        }
    }
}// TestRunner
