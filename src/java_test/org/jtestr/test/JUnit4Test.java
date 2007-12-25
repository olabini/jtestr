
package org.jtestr.test;

import org.junit.Test;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

public class JUnit4Test {
    @Test public void junit4testRuns() {
        assertEquals("Hello","Hello");
    }

    @Test public void findOutHowAnExceptionLooks() {
        try {
            throw new RuntimeException("Foobar");
        } catch(RuntimeException e) {
            assertTrue(true);
        }
    }
}
