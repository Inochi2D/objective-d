/*
    Copyright © 2024, Kitsunebi Games EMV
    Distributed under the Boost Software License, Version 1.0, 
    see LICENSE file.
    
    Authors: Luna Nielsen
*/

/**
    Utility functions which are used to break the D type system.

    These should only be used when absolutely neccesary.
*/
module objc.utils;
import std.traits;

/**
    Forces a function to assume that it's nogc compatible.
*/
auto assumeNoGC(T) (T t) {
    static if (isFunctionPointer!T || isDelegate!T) {
        enum attrs = functionAttributes!T | FunctionAttribute.nogc;
        return cast(SetFunctionAttributes!(T, functionLinkage!T, attrs)) t;
    } else static assert(false);
}

/**
    Forces a function to assume that it's nothrow nogc compatible.
*/
auto assumeNothrowNoGC(T) (T t) {
    static if (isFunctionPointer!T || isDelegate!T) {
        enum attrs = functionAttributes!T | FunctionAttribute.nogc | FunctionAttribute.nothrow_;
        return cast(SetFunctionAttributes!(T, functionLinkage!T, attrs)) t;
    } else static assert(false);
}