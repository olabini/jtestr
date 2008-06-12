/*
 * See the files LICENSE in distribution for license and copyright
 */
package org.jtestr.ant;

import java.io.EOFException;
import java.io.IOException;
import java.io.InputStream;

import java.net.Socket;
import java.net.ServerSocket;

import org.jtestr.JtestRRunner;
import org.jtestr.BackgroundClientException;

import junit.framework.Test;
import junit.framework.TestCase;
import junit.framework.TestResult;

/**
 * This class allows you to run JtestR tests using JUnit. There are no
 * real provisions for configuring JUnit test suites outside of code,
 * so this solution uses Java system properties, all of the begins
 * with jtestr.junit.
 *
 * <ul>
 *  <li><i>jtestr.junit.tests</i>: Sets the directory to run the tests from.</li>
 *  <li><i>jtestr.junit.logging</i>: Sets the logging level.</li>
 * </ul>
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class JtestRSuite implements Test {

    private static String transformFile(String file) {
        if(file.startsWith("in ")) {
            return file.substring(3);
        }
        return file;
    }

    private static String transformOther(String other, String file) {
        String o2 = other;
        if(o2.startsWith("in `")) {
            int o = o2.indexOf("'");
            if(o != -1) {
                o2 = o2.substring(4,o);
                if(o2.equals(file)) {
                    o2 = "";
                }
            }
        }
        return o2;
    }
    
    /*
     * Refer to the tests for what this method should do
     */
    public static String[] separateStackTraceElements(String input) {
        String[] geh = input.split(":");
        String file = null;
        String other = null;
        String temp = null;
        int index = 0;
        int colons = 0;

        switch(geh.length) {
        case 2:
            // Handle cases like "<eval>:13"
            // or "/abc.rb:13"
            // or "in /abc.rb:13"
            return new String[]{"", transformFile(geh[0]), geh[1]};

        default:
            // When we have more than two elements we know
            // that either we have windows paths, or we have
            // file: paths, or possibly both, or possibly just
            // a simple three parter. This makes the
            // logic slightly more complicated... =)

            if(input.startsWith("in ")) {
                index = 3;
            }

            if(input.substring(index).startsWith("file://")) {
                index += 7;
                colons++;
            } else if(input.substring(index).startsWith("file:")) {
                index += 5;
                colons++;
            }

            // Check windows:
            if(input.length() > index+3) {
                temp = input.substring(index+1, index+3);
                if(temp.equals(":/") || temp.equals(":\\")) {
                    colons++;
                }
            }

            file = geh[0];
            for(int i=0;i<colons;i++) {
                file += (":" + geh[i+1]);
            }

            file = transformFile(file);

            other = "";
            if(geh.length > colons+2) {
                other = geh[colons+2];
                for(int i=colons+3;i<geh.length;i++) {
                    other += (":" + geh[i]);
                }

                other = transformOther(other, file);
            }

            return new String[]{other, file, geh[colons+1]};
        }
    }

    public static StackTraceElement stackTraceElementFrom(String input) {
        String[] elements = separateStackTraceElements(input);
        return new StackTraceElement(elements[0], "", elements[1], Integer.parseInt(elements[2]));
    }

    private static class ResultListener implements Runnable {
        private ServerSocket server;
        private TestResult result;

        public ResultListener(final TestResult result) {
            this.result = result;
            try {
                this.server = new ServerSocket(0);
            } catch(IOException e) {
                throw new RuntimeException("Couldn't establish connection: " + e);
            }
        }

        public int getPort() {
            return this.server.getLocalPort();
        }

        public void close() {
            try {
                this.server.close();
            } catch(IOException e) {
            }
        }

        private String readBounded(Socket sock) throws IOException {
            InputStream input = sock.getInputStream();
            int numbers = (int)input.read();
            byte[] length = new byte[numbers];

            int read0 = 0;
            while(read0 < numbers) {
                int bytesRead = input.read(length, read0, numbers-read0);
                read0 += bytesRead;
            }
            String slen = new String(length, 0, numbers);
            int len = Integer.parseInt(slen);
            byte[] output = new byte[len];
            read0 = 0;
            while(read0 < len) {
                int bytesRead = input.read(output, read0, len-read0);
                read0 += bytesRead;
            }
            return new String(output, 0, len);
        }

        private String[] readBoundedArray(Socket sock) throws IOException {
            InputStream input = sock.getInputStream();
            int numbers = (int)input.read();
            byte[] length = new byte[numbers];

            int read0 = 0;
            while(read0 < numbers) {
                int bytesRead = input.read(length, read0, numbers-read0);
                read0 += bytesRead;
            }
            String slen = new String(length, 0, numbers);
            int len = Integer.parseInt(slen);

            String[] output = new String[len];
            for(int i=0;i<len;i++) {
                output[i] = readBounded(sock);
            }
            return output;
        }

        private void readMatch(Socket sock, char sentinel) throws EOFException {
            try {
                int read = sock.getInputStream().read();
                if(read == -1) {
                    throw new EOFException();
                }
                if((char)read != sentinel) {
                    throw new RuntimeException("Corrupted wire format. Expected sentinel " + sentinel + " but got " + read);
                }
            } catch(EOFException e) {
                throw e;
            } catch(IOException e) {
            }
        }

        private static class JtestRTest extends TestCase {
            public JtestRTest(String testName) {
                super(testName);
            }

            public int countTestCases() {
                return 1;
            }

            @Override
            public void run(final TestResult result) {
                // Can't run, should probably throw exception here
            }

            @Override
            public String toString() {
                return getName();
            }
        }

        private static class FakeException extends Throwable {
            private String extra;
            private String[] trace;

            public FakeException(String message, String extra, String[] trace) throws Exception {
                super(message);
                this.extra = extra;
                this.trace = trace;

                StackTraceElement[] strace = new StackTraceElement[trace.length];
                for(int i=0;i<trace.length;i++) {
                    strace[i] = stackTraceElementFrom(trace[i]);
                }
                setStackTrace(strace);
            }

            public String toString() {
                return extra + ": " + getMessage();
            }

            public Throwable fillInStackTrace() {
                return this;
            }
        }

        private static class FakeAssertionFailedError extends junit.framework.AssertionFailedError {
            private String[] trace;

            public FakeAssertionFailedError(String message, String[] trace) throws Exception  {
                super(message);
                this.trace = trace;

                StackTraceElement[] strace = new StackTraceElement[trace.length];
                for(int i=0;i<trace.length;i++) {
                    strace[i] = stackTraceElementFrom(trace[i]);
                }
                setStackTrace(strace);
            }

            public String toString() {
                return getMessage();
            }

            public Throwable fillInStackTrace() {
                return this;
            }
        }

        private void dispatchOnSentinels(Socket sock, String name, String type) {
            try {
                InputStream input = sock.getInputStream();
                char sentinel = 0;
                String val = null;
                String extra = null;
                String[] res = null;
                JtestRTest currentTest = null;
                while(sentinel != 'E') {
                    sentinel = (char)input.read();
                    switch(sentinel) {
                    case 'B': // B as in begin simple
                        val = readBounded(sock);
                        currentTest = new JtestRTest(val);
                        this.result.startTest(currentTest);
                        break;
                    case 'F': // F as in failure
                        this.result.addFailure(currentTest, new FakeAssertionFailedError(val, res));
                        currentTest = null;
                        break;
                    case 'X': // X as in exception
                        this.result.addError(currentTest, new FakeException(val, extra, res));
                        currentTest = null;
                        break;
                    case 'T': // T as in true success
                        this.result.endTest(currentTest);
                        currentTest = null;
                        break;
                    case 'D': // D as in fault data
                        val = readBounded(sock);
                        extra = readBounded(sock);
                        res = readBoundedArray(sock);
                        break;
                    case 'E': // E as in ending
                        break;
                    }
                }
            } catch(IOException e) {
                e.printStackTrace();
            } catch(Exception e) {
                e.printStackTrace();
            }
        }

        public void run() {
            Socket sock = null;
            try {
                sock = server.accept();

                while(sock.isConnected() && !sock.isClosed() && !sock.isInputShutdown() && sock.isBound()) {
                    readMatch(sock, 'S');

                    String name = readBounded(sock);
                    String type = readBounded(sock);

                    dispatchOnSentinels(sock, name, type);
                }
            } catch(IOException e) {
            } finally {
                try {
                    sock.close();
                } catch(Exception e) {
                }
            }
        }
    }

    public int countTestCases() {
        return -1;
    }

    public void run(final TestResult result) {
        JtestRRunner runner = new JtestRRunner();

        String val;
        if((val=System.getProperty("jtestr.junit.tests")) != null) {
            runner.setTests(val);
        }
        if((val=System.getProperty("jtestr.junit.logging")) != null) {
            runner.setLogging(val);
        }

        ResultListener listener = new ResultListener(result);

        Thread t = new Thread(listener);

        runner.setResultHandler("JtestR::JUnitResultSender.create_with_port(" + listener.getPort() + ")");

        t.start();

        try {
            try {
                runner.execute();
            } catch(RuntimeException e) {
                if(!"Tests failed".equals(e.getMessage())) {
                    throw e;
                }
            }
            t.join();
        } catch(BackgroundClientException e) {
            throw new RuntimeException(e.getMessage(), e.getCause());
        } catch(InterruptedException e) {
            e.printStackTrace();
        } finally {
            listener.close();
        }
    }

    public static Test suite() {
        return new JtestRSuite();
    }
}// JtestRSuite
