/*
 * See the file LICENSE in distribution for licensing and copyright
 */
package org.jtestr;

import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintStream;
import java.io.IOException;

import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.net.ServerSocket;

import org.jruby.Ruby;

/**
 * A simple, serialized server that will run test jobs.
 * It will redirect stdout and stdin during the run to point
 * to the output stream of socket, using keepalive
 * and a simple protocol to control the socket.
 *
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class BackgroundServer {
    private final int port;

    public final PrintStream originalStandardOut = System.out;
    public final PrintStream originalStandardErr = System.err;

    private final ResultOutputStream resOut = new ResultOutputStream("O", this);
    private final ResultOutputStream resErr = new ResultOutputStream("E", this);

    private volatile boolean quit = false;

    private TestRunner[] runtimes;
    private int next = -1;

    private final boolean debug;

    private boolean running = false; // is the creator thread running?

    public BackgroundServer(int port, int count, boolean debug) {
        //        originalStandardErr.println("createing new BackgroundServer");

        this.port = port;
        this.debug = debug;

        runtimes = new TestRunner[count];

        for(int i = 0; i<count; i++) {
            createNewRuntime();
        }
    }

    private void debug(String str) {
        if(debug) {
            originalStandardOut.println(str);
        }
    }

    protected void createNewRuntime() {
        synchronized(this) {
            if(running) {
                return;
            }
            running = true;
        }

        PrintStream orgOut = System.out;
        PrintStream orgErr = System.err;
            
        System.setOut(new PrintStream(resOut));
        System.setErr(new PrintStream(resErr));

        try {
            while(next < runtimes.length - 1) {
                debug("creating runtime " + (next+1));
                
                Ruby runtime = new RuntimeFactory("<test script>", this.getClass().getClassLoader()).createRuntime();
                TestRunner runner = new TestRunner(runtime);

                synchronized(runtimes) {
                    runtimes[++next] = runner;
                    runtimes.notifyAll();
                }
            }
        } finally {
            System.setOut(orgOut);
            System.setErr(orgErr);

            synchronized(this) {
                running = false;
            }
        }
    }

    public void startServer() throws IOException {
        debug("starting server");
        ServerSocket server = new ServerSocket();
        server.bind(new InetSocketAddress("127.0.0.1",port));
        debug("listening");
        while(!quit) {
            try {
                Socket socket = server.accept();
                debug("accepted");
                run(socket);
                socket.close();
            } catch(IOException e) {
                debug("IO failed: " + e);
            } catch(Exception e) {
                debug("exception: " + e);
            }
        }
        server.close();
    }


    private String readBoundedName(InputStream input) throws IOException {
        int toRead = (int)input.read();
        byte[] buffer = new byte[toRead];
        int read0 = 0;
        while(read0 < toRead) {
            int bytesRead = input.read(buffer, read0, toRead-read0);
            read0 += bytesRead;
        }
        return new String(buffer, 0, toRead);
    }

    private void run(Socket socket) throws IOException {
        InputStream socketInput = socket.getInputStream();
        OutputStream socketOutput = socket.getOutputStream();

        // Read string 'TEST'
        byte[] buffer = new byte[4];
        int bytesRead = socketInput.read(buffer);
        if(bytesRead == 1 && buffer[0] == 'Q') {
            quit = true;
            socketOutput.write(new byte[]{'2','0','0'});
            socketOutput.flush();
            debug("quitting on request from a client");
            return;
        }

        if(bytesRead != 4 || !(buffer[0] == 'T' &&
                               buffer[1] == 'E' &&
                               buffer[2] == 'S' &&
                               buffer[3] == 'T')) {
            socketOutput.write(new byte[]{'4','0','0'});
            socketOutput.flush();
            return;
        }

        String dirname = readBoundedName(socketInput);
        debug("testing from directory: " + dirname);
        String loglevel = readBoundedName(socketInput);
        debug("testing with loglevel: " + loglevel);
        String outputlevel = readBoundedName(socketInput);
        debug("testing with outputlevel: " + outputlevel);
        String output = readBoundedName(socketInput);
        debug("testing with output: " + output);

        socketOutput.write(new byte[]{'2','0','1'});
        socketOutput.flush();

        resOut.setOutput(socketOutput);
        resErr.setOutput(socketOutput);
        
        TestRunner runtime = getRuntime();
        try {
            boolean result = runtime.run(dirname, loglevel, outputlevel, output);
            runtime.report();
            
            resOut.flush(); resErr.flush();

            socketOutput.write(new byte[]{'R', result ? (byte)'T' : (byte)'F'});
            socketOutput.flush();
        } catch(Exception e) {
            originalStandardErr.println("have Exception: " + e);
        } finally {
            recycleRuntime(runtime);
        }
    }

    private TestRunner getRuntime() {
        synchronized(runtimes) {
            while(next == -1) {
                try {
                    debug("waiting for runtimes");
                    runtimes.wait();
                    debug("woken up for runtimes");
                } catch(Exception e) {}
            }

            TestRunner runner = runtimes[next];
            runtimes[next] = null;
            next--;
            return runner;
        }
    }

    private void recycleRuntime(TestRunner runtime) {
        runtime.getRuntime().tearDown();
        new Thread(new Runnable() {
                public void run() {
                    createNewRuntime();
                }
            }).start();
    }

    public static void main(String[] args) throws Exception {
        int port = 22332;
        int count = 2;
        if(args.length > 0) {
            port = Integer.parseInt(args[0]);
            if(args.length > 1) {
                count = Integer.parseInt(args[1]);
            }
        }
        new BackgroundServer(port, count, true).startServer();
    }
}// BackgroundServer
