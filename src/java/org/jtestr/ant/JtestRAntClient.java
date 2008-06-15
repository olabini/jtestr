/*
 * See the file LICENSE in distribution for licensing and copyright
 */
package org.jtestr.ant;

import java.io.PrintStream;
import java.io.InputStream;
import java.io.IOException;

import java.net.InetSocketAddress;
import java.net.Socket;

import java.util.Arrays;
import java.util.List;

import org.jtestr.BackgroundClientException;
import org.jtestr.JtestRConfig;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class JtestRAntClient {
    private static void printLengthAndValue(PrintStream os, String[] output) throws IOException {
        os.write((byte)output.length);
        for(String cp : output) {
            printLengthAndValue(os, cp);
        }
    }

    private static void printLengthAndValue(PrintStream os, String output) throws IOException {
        if(output == null) {
            os.write((byte)0);
        } else {
            os.write((byte)output.length());
            os.print(output);
        }
    }

    public static void executeClient(Socket socket, JtestRConfig config,  String[] classPath) throws BackgroundClientException {
        try {
            InputStream is = socket.getInputStream();
            PrintStream os = new PrintStream(socket.getOutputStream());

            os.print("TEST");

            printLengthAndValue(os, config.workingDirectory());
            printLengthAndValue(os, config.tests());
            printLengthAndValue(os, config.logging());
            printLengthAndValue(os, config.outputLevel());
            printLengthAndValue(os, config.output());
            printLengthAndValue(os, config.groupsAsString());
            printLengthAndValue(os, config.resultHandler());
            printLengthAndValue(os, classPath);
            printLengthAndValue(os, config.test());

            os.flush();

            byte[] status = new byte[3];
            int read = is.read(status);
            if(read != read ||
               status[0] != '2' || 
               status[1] != '0' || 
               status[2] != '1') {
                socket.close();
                throw new BackgroundClientException("Test server failed - check logs for more information");
            }

            byte[] next = new byte[2];
            byte[] buf = new byte[256];
            boolean done = false;
            while(!done) {
                int readOne = is.read(next);

                if(readOne == -1) {
                    throw new BackgroundClientException("Test server closed with no tests");
                } else if(readOne == 1) {
                    is.read(next, 1, 1);
                }

                switch(next[0]) {
                case 'O':
                case 'E':{
                    int len = next[1]&0xFF;
                    if(len == 0) {
                        socket.close();
                        throw new BackgroundClientException("Zero length data");
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
                        throw new BackgroundClientException("Tests failed");
                    }
                    done = true;
                    break;
                }
            }

            socket.close();
        } catch(IOException e) {
            throw new BackgroundClientException("Connection with server failed", e);
        }
    }
}// JtestRAntClient
