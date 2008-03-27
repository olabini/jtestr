package org.jtestr.test;

import org.testng.annotations.BeforeClass;
import org.testng.annotations.AfterClass;
import org.testng.annotations.AfterMethod;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.Test;
import static org.testng.AssertJUnit.*;

/**
 * Sample TestNG class
 */

@Test(groups = { "jtestr" }, enabled = true )
public class TestNG1 {

    @BeforeClass
    public static void setupClass() {
    }

    @AfterClass
    public static void tearDownClass1() {
    }

    @AfterClass
    public static void tearDownClass2() {
    }

    @BeforeMethod
    public void beforeTestMethod() {
    }

    @AfterMethod
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
