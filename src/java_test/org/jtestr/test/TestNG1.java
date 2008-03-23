package org.jtestr.test;

import org.testng.annotations.Configuration;

import org.testng.annotations.ExpectedExceptions;
import org.testng.annotations.Test;
import static org.testng.AssertJUnit.*;

/**
 * Sample TestNG class
 */

@Test(groups = { "jtestr" }, enabled = true )
public class TestNG1 {

    @Configuration(beforeTestClass = true)
    public static void setupClass() {
    }

    @Configuration(afterTestClass = true)
    public static void tearDownClass1() {;
    }

    @Configuration(afterTestClass = true)
    public static void tearDownClass2() {
    }

    @Configuration(beforeTestMethod = true)
    public void beforeTestMethod() {
    }

    @Configuration(afterTestMethod = true)
    public void afterTestMethod() {
    }


    @Test(groups = { "jtestr" } )
    public void testJtestr1() {
        assertEquals("jtestr", "jtestr");
    }


    /*@Test(groups = { "jtestr" } )
    public void sometestrForce() {
        throw new NullPointerException("checking testng");
    }*/


    /*@Test(groups = { "jtestr" } )
    public void noneJtestrPost() {

        String you = "you";
        String me = "me";
        assertEquals(me, you);
    }*/
}
