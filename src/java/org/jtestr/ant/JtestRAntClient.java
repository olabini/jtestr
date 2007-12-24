/*
 * See the file LICENSE in distribution for licensing and copyright
 */
package org.jtestr.ant;

import java.io.PrintStream;
import java.io.InputStream;
import java.io.IOException;

import java.net.InetSocketAddress;
import java.net.Socket;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class JtestRAntClient extends Task {
    private int port = 22332;
    private String tests = "test";

    public void setTests(String tests) {
        this.tests = tests;
    }

    public void setPort(int port) {
        this.port = port;
    }

    static void executeClient(Socket socket, String tests) throws BuildException {
        try {
            InputStream is = socket.getInputStream();
            PrintStream os = new PrintStream(socket.getOutputStream());

            os.print("TEST");
            os.print(tests);
            os.flush();

            byte[] status = new byte[3];
            int read = is.read(status);
            if(read != read ||
               status[0] != '2' || 
               status[1] != '0' || 
               status[2] != '1') {
                socket.close();
                throw new BuildException("Test server failed - check logs for more information");
            }

            byte[] next = new byte[2];
            byte[] buf = new byte[256];
            boolean done = false;
            while(!done) {
                int readOne = is.read(next);

                if(readOne == -1) {
                    throw new BuildException("Test server closed with no tests");
                } else if(readOne == 1) {
                    is.read(next, 1, 1);
                }

                switch(next[0]) {
                case 'O':
                case 'E':{
                    int len = next[1]&0xFF;
                    if(len == 0) {
                        socket.close();
                        throw new BuildException("Zero length data");
                    }

                    int bread;
                    
                    while(len > 0) {
                        bread = is.read(buf,0,len);
                        if(next[0] == 'O') {
                            System.out.write(buf, 0, bread);
                        } else {
                            System.err.write(buf, 0, bread);
                        }
                        len-=bread;
                    }

                    break;
                }
                case 'R':
                    if(next[1] == 'F') {
                        socket.close();
                        throw new BuildException("Tests failed");
                    }
                    done = true;
                    break;
                }
            }

            socket.close();
        } catch(IOException e) {
            throw new BuildException("Connection with server failed", e);
        }
    }

    public void execute() throws BuildException {
        try {
            Socket socket = new Socket();
            socket.connect(new InetSocketAddress("127.0.0.1",port));
            executeClient(socket, tests);
        } catch(IOException e) {
            throw new BuildException("Connection with server failed", e);
        }
    }
}// JtestRAntClient
