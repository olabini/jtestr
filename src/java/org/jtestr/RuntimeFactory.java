/*
 * See the file LICENSE in distribution for licensing and copyright
 */
package org.jtestr;

import java.util.ArrayList;
import java.util.List;

import org.jruby.Ruby;
import org.jruby.RubyInstanceConfig;
import org.jruby.RubyKernel;
import org.jruby.runtime.Block;
import org.jruby.runtime.IAccessor;
import org.jruby.internal.runtime.ValueAccessor;
import org.jruby.util.KCode;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class RuntimeFactory {
    private String programName;
    private List loadPath;
    private List<String> libraries;
    private boolean verbose;
    private boolean debug;
    ClassLoader loader;


    public RuntimeFactory(String programName) {
        this(programName, RuntimeFactory.class.getClassLoader());
    }

    public RuntimeFactory(String programName, ClassLoader loader) {
        this(programName, new ArrayList(), new ArrayList<String>(), false, false, loader);
    }

    public RuntimeFactory(String programName, List loadPath, List<String> libraries, boolean verbose, boolean debug, ClassLoader loader) {
        this.programName = programName;
        this.loadPath = loadPath;
        this.libraries = libraries;
        this.verbose = verbose;
        this.debug = debug;
        this.loader = loader;
    }

    public Ruby createRuntime() {
        RubyInstanceConfig config = new RubyInstanceConfig(){{
            setInput(System.in);
            setOutput(System.out);
            setError(System.err);
            setLoader(loader);
        }};
        Ruby runtime = Ruby.newInstance(config);
        runtime.setKCode(KCode.UTF8);
        
        runtime.setVerbose(runtime.newBoolean(this.verbose));
        runtime.setDebug(runtime.newBoolean(this.verbose));
        runtime.getObject().setInternalVariable("$VERBOSE", this.verbose ? runtime.getTrue() : runtime.getNil());
        
        defineGlobal(runtime, "$-p", false);
        defineGlobal(runtime, "$-n", false);
        defineGlobal(runtime, "$-a", false);
        defineGlobal(runtime, "$-l", false);

        IAccessor d = new ValueAccessor(runtime.newString(this.programName));
        runtime.getGlobalVariables().define("$PROGRAM_NAME", d);
        runtime.getGlobalVariables().define("$0", d);

        runtime.getLoadService().init(this.loadPath);

        for(String scriptName : this.libraries) {
            RubyKernel.require(runtime.getTopSelf(), runtime.newString(scriptName), Block.NULL_BLOCK);
        }

        return runtime;
    }

    private void defineGlobal(Ruby runtime, String name, boolean value) {
        runtime.getGlobalVariables().defineReadonly(name, new ValueAccessor(value ? runtime.getTrue() : runtime.getNil()));
    }

    /**
     * Simple main method to execute functionality until the surrounding 
     * infrastructure for testing is in place.
     */
    public static void main(String[] args) {
        Ruby runtime = new RuntimeFactory("<test script>").createRuntime();
        try {
            runtime.evalScriptlet("puts 'Hello World'");
        } finally {
            runtime.tearDown();
        }
    }
}// RuntimeFactory
