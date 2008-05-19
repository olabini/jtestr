/*
 * See the files LICENSE in distribution for license and copyright
 */
package org.jtestr.ant;

import java.io.IOException;
import java.io.InputStream;

import java.net.Socket;
import java.net.ServerSocket;

import org.jtestr.JtestRRunner;
import org.jtestr.BackgroundClientException;

import junit.framework.Test;
import junit.framework.TestResult;

/**
 * This class allows you to run JtestR tests using JUnit. There are no
 * real provisions for configuring JUnit test suites outside of code,
 * so this solution uses Java system properties, all of the begins
 * with jtestr.junit.
 *
 * <ul>
 *  <li><i>jtestr.junit.tests</i>: Sets the directory to run the tests from.</li>
 * </ul>
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class JtestRSuite implements Test {
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

        private void readMatch(Socket sock, char sentinel) {
            try {
                char read = (char)sock.getInputStream().read();
                if(read != sentinel) {
                    throw new RuntimeException("Corrupted wire format. Expected sentinel " + sentinel + " but got " + read);
                }
            } catch(IOException e) {
            }
        }

        private static class JtestRTest implements Test {
            private String testName;

            public JtestRTest(String testName) {
                this.testName = testName;
            }

            public int countTestCases() {
                return -1;
            }

            public void run(final TestResult result) {
                // Can't run, should probably throw exception here
            }
        }

        private void dispatchOnSentinels(Socket sock, String name, String type) {
            try {
                InputStream input = sock.getInputStream();
                char sentinel = 0;
                String val = null;
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
                        this.result.endTest(currentTest);
                        this.result.addFailure(currentTest, null);
                        currentTest = null;
                        break;
                    case 'X': // X as in exception
                        this.result.endTest(currentTest);
                        this.result.addError(currentTest, null);
                        currentTest = null;
                        break;
                    case 'T': // T as in true success
                        this.result.endTest(currentTest);
                        currentTest = null;
                        break;
                    case 'D': // D as in fault data
                        break;
                    case 'E': // E as in ending
                        break;
                    }
                }
            } catch(IOException e) {
            }
        }

        public void run() {
            Socket sock = null;
            try {
                sock = server.accept();

                readMatch(sock, 'S');

                String name = readBounded(sock);
                String type = readBounded(sock);

                dispatchOnSentinels(sock, name, type);
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

        ResultListener listener = new ResultListener(result);

        Thread t = new Thread(listener);

        runner.setResultHandler("JtestR::JUnitResultSender.create_with_port(" + listener.getPort() + ")");

        t.start();

        try {
            runner.execute();
            t.join();
        } catch(BackgroundClientException e) {
            throw new RuntimeException(e.getMessage(), e.getCause());
        } catch(RuntimeException e) {
            if(!"Tests failed".equals(e.getMessage())) {
                throw e;
            }
        } catch(InterruptedException e) {
        } finally {
            listener.close();
        }
    }

    public static Test suite() {
        return new JtestRSuite();
    }
}// JtestRSuite
