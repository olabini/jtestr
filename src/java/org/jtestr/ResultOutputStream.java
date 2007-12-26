/*
 * See the file LICENSE in distribution for licensing and copyright
 */
package org.jtestr;

import java.io.IOException;
import java.io.ByteArrayOutputStream;
import java.io.OutputStream;

/**
 * @author <a href="mailto:ola.bini@gmail.com">Ola Bini</a>
 */
public class ResultOutputStream extends OutputStream {
    private byte[] prefix = new byte[]{'E'};
    private OutputStream realStream;
    private BackgroundServer backgroundServer;
    
    public ResultOutputStream(String prefix, BackgroundServer backgroundServer) {
        this.prefix = prefix.getBytes();
        this.backgroundServer = backgroundServer;
    }

    void setOutput(OutputStream realStream) {
        this.realStream = realStream;
    }

    /**
     * A data class to store information about a buffer. Such information
     * is stored on a per-thread basis.
     */
    private static class BufferInfo {
        /**
         * The per-thread output stream.
         */
        private ByteArrayOutputStream buffer;

        /**
         * Indicates we have just seen a carriage return. It may be part of
         * a crlf pair or a single cr invoking processBuffer twice.
         */
         private boolean crSeen = false;
    }

    /** Maximum buffer size. */
    private static final int MAX_SIZE = 1024;

    /** Initial buffer size. */
    private static final int INTIAL_SIZE = 132;

    /** Carriage return */
    private static final int CR = 0x0d;

    /** Linefeed */
    private static final int LF = 0x0a;

    private BufferInfo buffer = null;

    private BufferInfo getBufferInfo() {
        if (buffer == null) {
            buffer = new BufferInfo();
            buffer.buffer = new ByteArrayOutputStream(INTIAL_SIZE);
            buffer.crSeen = false;
        }
        return buffer;
    }

    private void resetBufferInfo() {
        try {
            buffer.buffer.close();
        } catch (IOException e) {
            // Shouldn't happen
        }
        buffer.buffer = new ByteArrayOutputStream();
        buffer.crSeen = false;
    }

    private void removeBuffer() {
        buffer = null;
    }

    public void write(int cc) throws IOException {
        //        System.err.println("GAGA WRITE: " + cc);
        final byte c = (byte) cc;

        BufferInfo bufferInfo = getBufferInfo();

        if (c == '\n') {
            // LF is always end of line (i.e. CRLF or single LF)
            bufferInfo.buffer.write(cc);
            processBuffer(bufferInfo.buffer);
        } else {
            if (bufferInfo.crSeen) {
                // CR without LF - send buffer then add char
                processBuffer(bufferInfo.buffer);
            }
            // add into buffer
            bufferInfo.buffer.write(cc);
        }
        bufferInfo.crSeen = (c == '\r');
        if (!bufferInfo.crSeen && bufferInfo.buffer.size() > MAX_SIZE) {
            processBuffer(bufferInfo.buffer);
        }
    }

    protected void processBuffer(ByteArrayOutputStream buffer) throws IOException {
        //        System.err.println("Sending to real stream");
        processFlush(buffer);
    }

    protected void processFlush(ByteArrayOutputStream buffer) throws IOException {
        //        backgroundServer.originalStandardErr.println("Sending to real stream");
        byte[] buff = buffer.toByteArray();
        int len = buff.length;
        int ix = 0;
        if(realStream != null) {
            while(len > 255) {
                realStream.write(prefix);
                realStream.write((byte)255);
                realStream.write(buff,ix,255);
                ix += 255;
                len -= 255;
            }

            realStream.write(prefix);
            realStream.write((byte)len);
            realStream.write(buff,ix,len);
            realStream.flush();
            resetBufferInfo();
        } else {
            backgroundServer.originalStandardErr.write(buff, ix, len);
            resetBufferInfo();
        }
    }

    public void close() throws IOException {
        flush();
        removeBuffer();
    }

    public void flush() throws IOException {
        BufferInfo bufferInfo = getBufferInfo();
        if (bufferInfo.buffer.size() > 0) {
            processFlush(bufferInfo.buffer);
        }
    }

    public void write(byte[] b, int off, int len) throws IOException {
        //        System.err.println("GAGA WRITE: " + new String(b, off, len));
        int offset = off;
        int blockStartOffset = offset;
        int remaining = len;
        BufferInfo bufferInfo = getBufferInfo();
        while (remaining > 0) {
            while (remaining > 0 && b[offset] != LF && b[offset] != CR) {
                offset++;
                remaining--;
            }
            int blockLength = offset - blockStartOffset;
            if (blockLength > 0) {
                bufferInfo.buffer.write(b, blockStartOffset, blockLength);
            }
            while (remaining > 0 && (b[offset] == LF || b[offset] == CR)) {
                write(b[offset]);
                offset++;
                remaining--;
            }
            blockStartOffset = offset;
        }
    }
}// ResultOutputStream
