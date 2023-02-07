package com.benblamey.spark;

import static org.junit.jupiter.api.Assertions.*;

class BasicAuthFilterTest {


    @org.junit.jupiter.api.Test
    void getHashAsBase64() {
        BasicAuthFilter filter = new BasicAuthFilter();

        assertEquals("qpJyXvOegC8AoQpWW4zhJpF2xi7NT/46hFo0f8X7njg=",filter.getHashAsBase64("??"));
        assertEquals("gi/dBJ4aXUZJBZpftLtTKIyDaTy6reOgDxh6q+9Oweo=",filter.getHashAsBase64("??"));

    }
}