package org.jtestr.test;

public class FooBean {
    public String getName() {
        return "FooBean";
    }

    public Object pass(Object p) {
        return p;
    }

    private String value;

    public void assignValue() { 
        value = createValue(); 
    }
    
    public String createValue() { 
        return "default value"; 
    }

    public String getValue() { 
        return value; 
    }
}
