package com.leszko.calculator;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

/** Calculator Logic */ 
@Service
public class Calculator {
    int sum(int a, int b) {
        return a + b;
    }
}
