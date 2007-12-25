
package org.jtestr.test;

import junit.framework.TestCase;

public class JUnit3Test extends TestCase {
    public JUnit3Test(String name) {
        super(name);
    }

    public void testThatThisTestRuns() {
        assertEquals("Goodbye","Goodbye");
    }
}
