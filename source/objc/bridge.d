/**
    Foundation<->CoreFoundation Bridge.

    Copyright: Copyright © 2024-2025, Kitsunebi Games EMV
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module objc.bridge;
import numem.core.meta;
import numem.core.traits;
import numem;

import corefoundation.core : CFTypeRef;
import foundation : NSObjectProtocol;

/**
    Attribute which can be applied to types to tell Objective-D that the 
    symbol safely can be bridged to the other.
*/
struct objd_bridge(Allowed...){
    alias allowed = Allowed;
} 

/**
    Allows to safely bridge-cast between CoreFoundation and Foundation
    types.
*/
pragma(inline)
To __bridge(To, From)(From from) @nogc @trusted pure {
    static assert(objd_sym_bridgable!(To, From), From.stringof~" can't safely be bridged to "~To.stringof~"!");

    return *cast(To*)&from;
}

/**
    Casts a Foundation object to a CoreFoundation object, transferring the ownership
    to CoreFoundation.

    Params:
        A Objective-C class which can be bridge-cast to $(D To).

    Returns:
        CoreFoundation object with the CF refcount increased by 1.
*/
pragma(inline)
To __bridge_retained(To, From)(From from) @nogc @trusted pure if (is(To : NSObjectProtocol)) {
    static assert(objd_sym_bridgable!(To, From), From.stringof~" can't safely be bridged to "~To.stringof~"!");

    return cast(To)CFBridgingRetain(*cast(From*)&from);
}

/**
    Casts a CoreFoundation object to a Foundation object, transferring the ownership
    to Foundation.

    Params:
        A CFType which can be bridge-cast to $(D To).

    Returns:
        Foundation object with the CF refcount decreased by 1.
*/
pragma(inline)
To __bridge_transfer(To, From)(From from) @nogc @trusted pure if (is(To : CFTypeRef)) {
    static assert(objd_sym_bridgable!(To, From), From.stringof~" can't safely be bridged to "~To.stringof~"!");

    return cast(To)CFBridgingRelease(*cast(From*)&from);
}

/**
    Gets whether 2 types can be safely bridged between CoreFoundation
    and Foundation
*/
enum canBridgeBetween(T, U) =
    objd_sym_bridgable!(T, U);

@("CF-NS Bridge")
unittest {
    import foundation.nsstring;
    import corefoundation.cfstring;

    NSString myString = NSString.create("Hello, world!");

    CFStringRef myBridgedString = __bridge!CFStringRef(myString);
    myString = __bridge!NSString(myBridgedString);
    assert(myString == "Hello, world!");
}


private:

extern(C) extern void* CFBridgingRetain(void*);     // To CF
extern(C) extern void* CFBridgingRelease(void*);    // From CF

template objd_sym_bridgable(To, From) {
    alias toUda = getUDAs!(To, objd_bridge);
    alias fromUda = getUDAs!(From, objd_bridge);

    static if (toUda.length > 0) {
        enum objd_sym_bridgable = 
            anySatisfy!(objd_is_bridagable!To,      toUda[0].allowed) || 
            anySatisfy!(objd_is_bridagable!From,    toUda[0].allowed);
    } else static if (fromUda.length > 0) {
        enum objd_sym_bridgable = 
            anySatisfy!(objd_is_bridagable!To,      fromUda[0].allowed) || 
            anySatisfy!(objd_is_bridagable!From,    fromUda[0].allowed);
    } else enum objd_sym_bridgable = false;
}

template objd_is_bridagable(ToCheck) {
    template objd_is_bridagable(T) {
        enum objd_is_bridagable = is(T == ToCheck);
    }
}