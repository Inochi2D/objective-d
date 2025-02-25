/**
    NSEnumerator

    Copyright: Copyright © 2024-2025, Kitsunebi Games EMV
    License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
    Authors:   Luna Nielsen
*/
module foundation.nsenumerator;
import foundation;
import objc;

import core.attribute : selector, optional;
import core.stdc.config : c_ulong;

nothrow @nogc:
version(D_ObjectiveC):

/**
    This defines the structure used as contextual information 
    in the NSFastEnumeration protocol.
*/
struct NSFastEnumerationState {
@nogc nothrow:
    
    /**
        Arbitrary state information used by the iterator. 
        Typically this is set to 0 at the beginning of the iteration.
    */
    c_ulong state;
    
    /**
        A C array of objects.
    */
    id* itemsPtr;
    
    /**
        Arbitrary state information used to detect whether the collection has been mutated.
    */
    c_ulong* mutationsPtr;
    
    /**
        A C array that you can use to hold returned values.
    */
    c_ulong[5] extra;
}

extern(Objective-C)
extern interface NSFastEnumeration {
@nogc nothrow:

    /**
        Returns by reference a C array of objects over which the sender should iterate, 
        and as the return value the number of objects in the array.
    */
    NSUInteger countByEnumeratingWithState(NSFastEnumerationState* state, id* stackbuf, NSUInteger len) @selector("countByEnumeratingWithState:objects:count:");
}