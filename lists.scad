//////////////////////////////////////////////////////////////////////
// LibFile: lists.scad
//   Functions for constructing and manipulating generic lists. 
// Includes:
//   include <BOSL2/std.scad>
//////////////////////////////////////////////////////////////////////

// Terminology:
//   **List** = An ordered collection of zero or more items.  ie: `["a", "b", "c"]`
//   **Vector** = A list of numbers. ie: `[4, 5, 6]`
//   **Array** = A nested list of lists, or list of lists of lists, or deeper.  ie: `[[2,3], [4,5], [6,7]]`
//   **Set** = A list of unique items.


// Section: List Query Operations


// Function: is_homogeneous()
// Alias: is_homogenous()
// Usage:
//   bool = is_homogeneous(list, depth);
// Topics: List Handling, Type Checking
// See Also: is_vector(), is_matrix()
// Description:
//   Returns true when the list has elements of same type up to the depth `depth`.
//   Booleans and numbers are not distinguinshed as of distinct types. 
// Arguments:
//   l = the list to check
//   depth = the lowest level the check is done
// Example:
//   a = is_homogeneous([[1,["a"]], [2,["b"]]]);     // Returns true
//   b = is_homogeneous([[1,["a"]], [2,[true]]]);    // Returns false
//   c = is_homogeneous([[1,["a"]], [2,[true]]], 1); // Returns true
//   d = is_homogeneous([[1,["a"]], [2,[true]]], 2); // Returns false
//   e = is_homogeneous([[1,["a"]], [true,["b"]]]);  // Returns true
function is_homogeneous(l, depth=10) =
    !is_list(l) || l==[] ? false :
    let( l0=l[0] )
    [] == [for(i=[1:1:len(l)-1]) if( ! _same_type(l[i],l0, depth+1) )  0 ];

function is_homogenous(l, depth=10) = is_homogeneous(l, depth);
                 

function _same_type(a,b, depth) = 
    (depth==0) ||
    (is_undef(a) && is_undef(b)) ||
    (is_bool(a) && is_bool(b)) ||
    (is_num(a) && is_num(b)) ||
    (is_string(a) && is_string(b)) ||
    (is_list(a) && is_list(b) && len(a)==len(b) 
          && []==[for(i=idx(a)) if( ! _same_type(a[i],b[i],depth-1) ) 0] ); 
  

// Function: min_length()
// Usage:
//   llen = min_length(array);
// Topics: List Handling
// See Also: max_length()
// Description:
//   Returns the length of the shortest sublist in a list of lists.
// Arguments:
//   array = A list of lists.
// Example:
//   slen = min_length([[3,4,5],[6,7,8,9]]);  // Returns: 3
function min_length(array) =
    assert(is_list(array), "Invalid input." )
    min([for (v = array) len(v)]);


// Function: max_length()
// Usage:
//   llen = max_length(array);
// Topics: List Handling
// See Also: min_length()
// Description:
//   Returns the length of the longest sublist in a list of lists.
// Arguments:
//   array = A list of lists.
// Example:
//   llen = max_length([[3,4,5],[6,7,8,9]]);  // Returns: 4
function max_length(array) =
    assert(is_list(array), "Invalid input." )
    max([for (v = array) len(v)]);




// Internal.  Not exposed.
function _list_shape_recurse(v) =
    !is_list(v[0])
    ?   len( [for(entry=v) if(!is_list(entry)) 0] ) == 0 ? [] : [undef]
    :   let(
          firstlen = is_list(v[0]) ? len(v[0]): undef,
          first = len( [for(entry = v) if(! is_list(entry) || (len(entry) != firstlen)) 0  ]   ) == 0 ? firstlen : undef,
          leveldown = flatten(v)
        ) 
        is_list(leveldown[0])
        ?  concat([first],_list_shape_recurse(leveldown))
        : [first];

function _list_shape_recurse(v) =
    let( alen = [for(vi=v) is_list(vi) ? len(vi): -1] )
    v==[] || max(alen)==-1 ? [] :
    let( add = max(alen)!=min(alen) ? undef : alen[0] ) 
    concat( add, _list_shape_recurse(flatten(v)));


// Function: list_shape()
// Usage:
//   dims = list_shape(v, [depth]);
// Topics: Matrices, Array Handling
// Description:
//   Returns the size of a multi-dimensional array, a list of the lengths at each depth.
//   If the returned value has `dims[i] = j` then it means the ith index ranges of j items.
//   The return `dims[0]` is equal to the length of v.  Then `dims[1]` is equal to the
//   length of the lists in v, and in general, `dims[i]` is equal to the length of the items
//   nested to depth i in the list v.  If the length of items at that depth is inconsistent, then
//   `undef` is returned.  If no items exist at that depth then `0` is returned.  Note that
//   for simple vectors or matrices it is faster to compute `len(v)` and `len(v[0])`.  
// Arguments:
//   v = list to get shape of
//   depth = depth to compute the size of.  If not given, returns a list of sizes at all depths. 
// Example:
//   a = list_shape([[[1,2,3],[4,5,6]],[[7,8,9],[10,11,12]]]);     // Returns [2,2,3]
//   b = list_shape([[[1,2,3],[4,5,6]],[[7,8,9],[10,11,12]]], 0);  // Returns 2
//   c = list_shape([[[1,2,3],[4,5,6]],[[7,8,9],[10,11,12]]], 2);  // Returns 3
//   d = list_shape([[[1,2,3],[4,5,6]],[[7,8,9]]]);                // Returns [2,undef,3]
function list_shape(v, depth=undef) =
    assert( is_undef(depth) || ( is_finite(depth) && depth>=0 ), "Invalid depth.")
    ! is_list(v) ? 0 :
    (depth == undef)
    ?   concat([len(v)], _list_shape_recurse(v))
    :   (depth == 0)
        ?  len(v)
        :  let( dimlist = _list_shape_recurse(v))
           (depth > len(dimlist))? 0 : dimlist[depth-1] ;



// Function: in_list()
// Usage:
//   bool = in_list(val, list, [idx]);
// Topics: List Handling
// Description:
//   Returns true if value `val` is in list `list`. When `val==NAN` the answer will be false for any list.
// Arguments:
//   val = The simple value to search for.
//   list = The list to search.
//   idx = If given, searches the given columns for matches for `val`.
// Example:
//   a = in_list("bar", ["foo", "bar", "baz"]);  // Returns true.
//   b = in_list("bee", ["foo", "bar", "baz"]);  // Returns false.
//   c = in_list("bar", [[2,"foo"], [4,"bar"], [3,"baz"]], idx=1);  // Returns true.

// Note that a huge complication occurs because OpenSCAD's search() finds
// index i as a hits if the val equals list[i] but also if val equals list[i][0].
// This means every hit needs to be checked to see if it's actually a hit,
// and if the first hit is a mismatch we have to keep searching.
// We assume that the normal case doesn't have mixed data, and try first
// with just one hit, but if this finds a mismatch then we try again
// with all hits, which could be slow for long lists.  
function in_list(val,list,idx) = 
    assert(is_list(list),"Input is not a list")
    assert(is_undef(idx) || is_finite(idx), "Invalid idx value.")
    let( firsthit = search([val], list, num_returns_per_match=1, index_col_num=idx)[0] )
    firsthit==[] ? false
    : is_undef(idx) && val==list[firsthit] ? true
    : is_def(idx) && val==list[firsthit][idx] ? true
    // first hit was found but didn't match, so try again with all hits
    : let ( allhits = search([val], list, 0, idx)[0])
      is_undef(idx) ? [for(hit=allhits) if (list[hit]==val) 1] != []
    : [for(hit=allhits) if (list[hit][idx]==val) 1] != [];


// Function: add_scalar()
// Usage:  
//   v = add_scalar(v, s);
// Topics: List Handling
// Description:
//   Given a list and a scalar, returns the list with the scalar added to each item in it.
//   If given a list of arrays, recursively adds the scalar to the each array.
// Arguments:
//   v = The initial array.
//   s = A scalar value to add to every item in the array.
// Example:
//   a = add_scalar([1,2,3],3);            // Returns: [4,5,6]
//   b = add_scalar([[1,2,3],[3,4,5]],3);  // Returns: [[4,5,6],[6,7,8]]
function add_scalar(v,s) = 
    is_finite(s) ? [for (x=v) is_list(x)? add_scalar(x,s) : is_finite(x) ? x+s: x] : v;




// Section: List Indexing

// Function: select()
// Topics: List Handling
// Description:
//   Returns a portion of a list, wrapping around past the beginning, if end<start. 
//   The first item is index 0. Negative indexes are counted back from the end.
//   The last item is -1.  If only the `start` index is given, returns just the value
//   at that position when `start` is a number or the selected list of entries when `start` is
//   a list of indices or a range.
// Usage:
//   item = select(list, start);
//   item = select(list, [s:d:e]);
//   item = select(list, [i0,i1...,ik]);
//   list = select(list, start, end);
// Arguments:
//   list = The list to get the portion of.
//   start = Either the index of the first item or an index range or a list of indices.
//   end = The index of the last item when `start` is a number. When `start` is a list or a range, `end` should not be given.
// See Also: slice(), column(), last()
// Example:
//   l = [3,4,5,6,7,8,9];
//   a = select(l, 5, 6);   // Returns [8,9]
//   b = select(l, 5, 8);   // Returns [8,9,3,4]
//   c = select(l, 5, 2);   // Returns [8,9,3,4,5]
//   d = select(l, -3, -1); // Returns [7,8,9]
//   e = select(l, 3, 3);   // Returns [6]
//   f = select(l, 4);      // Returns 7
//   g = select(l, -2);     // Returns 8
//   h = select(l, [1:3]);  // Returns [4,5,6]
//   i = select(l, [3,1]);  // Returns [6,4]
function select(list, start, end) =
    assert( is_list(list) || is_string(list), "Invalid list.")
    let(l=len(list))
    l==0
      ? []
      : end==undef
          ? is_num(start)
              ? list[ (start%l+l)%l ]
              : assert( start==[] || is_vector(start) || is_range(start), "Invalid start parameter")
                [for (i=start) list[ (i%l+l)%l ] ]
          : assert(is_finite(start), "When `end` is given, `start` parameter should be a number.")
            assert(is_finite(end), "Invalid end parameter.")
            let( s = (start%l+l)%l, e = (end%l+l)%l )
            (s <= e)
              ? [ for (i = [s:1:e])   list[i] ]
              : [ for (i = [s:1:l-1]) list[i], 
                  for (i = [0:1:e])   list[i] ] ;


// Function: slice()
// Usage:
//   list = slice(list, s, e);
// Description:
//   Returns a slice of a list, from the first position `s` up to and including the last position `e`.
//   The first item in the list is at index 0.  Negative indexes are counted back from the end.
//   An index of -1 refers to the last list item.
// Arguments:
//   list = The list to get the slice of.
//   s = The index of the first item to return.
//   e = The index of the last item to return.
// See Also: select(), column(), last()
// Example:
//   a = slice([3,4,5,6,7,8,9], 3, 5);   // Returns [6,7,8]
//   b = slice([3,4,5,6,7,8,9], 2, -1);  // Returns [5,6,7,8,9]
//   c = slice([3,4,5,6,7,8,9], 1, 1);   // Returns [4]
//   d = slice([3,4,5,6,7,8,9], 5);      // Returns [8,9]
//   e = slice([3,4,5,6,7,8,9], 2, -2);  // Returns [5,6,7,8]
//   f = slice([3,4,5,6,7,8,9], 4, 3;    // Returns []
function slice(list,s=0,e=-1) =
    assert(is_list(list))
    assert(is_int(s))
    assert(is_int(e))
    !list? [] :
    let(
        l = len(list),
        s = constrain(s + (s<0? l : 0), 0, l-1),
        e = constrain(e + (e<0? l : 0), 0, l-1)
    )
    [if (e>=s) for (i=[s:1:e]) list[i]];


// Function: last()
// Usage:
//   item = last(list);
// Topics: List Handling
// See Also: select(), slice(), column()
// Description:
//   Returns the last element of a list, or undef if empty.
// Arguments:
//   list = The list to get the last element of.
// Example:
//   l = [3,4,5,6,7,8,9];
//   x = last(l);  // Returns 9.
function last(list) =
    list[len(list)-1];


// Function: list_head()
// Usage:
//   list = list_head(list, [to]);
// Topics: List Handling
// See Also: select(), slice(), list_tail(), last()
// Description:
//   Returns the head of the given list, from the first item up until the `to` index, inclusive.
//   If the `to` index is negative, then the length of the list is added to it, such that
//   `-1` is the last list item.  `-2` is the second from last.  `-3` is third from last, etc.
//   If the list is shorter than the given index, then the full list is returned.
// Arguments:
//   list = The list to get the head of.
//   to = The last index to include.  If negative, adds the list length to it.  ie: -1 is the last list item.
// Example:
//   hlist1 = list_head(["foo", "bar", "baz"]);  // Returns: ["foo", "bar"]
//   hlist2 = list_head(["foo", "bar", "baz"], -3); // Returns: ["foo"]
//   hlist3 = list_head(["foo", "bar", "baz"], 2);  // Returns: ["foo","bar"]
//   hlist4 = list_head(["foo", "bar", "baz"], -5); // Returns: []
//   hlist5 = list_head(["foo", "bar", "baz"], 5);  // Returns: ["foo","bar","baz"]
function list_head(list, to=-2) =
   assert(is_list(list))
   assert(is_finite(to))
   to<0? [for (i=[0:1:len(list)+to]) list[i]] :
   to<len(list)? [for (i=[0:1:to]) list[i]] :
   list;


// Function: list_tail()
// Usage:
//   list = list_tail(list, [from]);
// Topics: List Handling
// See Also: select(), slice(), list_tail(), last()
// Description:
//   Returns the tail of the given list, from the `from` index up until the end of the list, inclusive.
//   If the `from` index is negative, then the length of the list is added to it, such that
//   `-1` is the last list item.  `-2` is the second from last.  `-3` is third from last, etc.
//   If you want it to return the last three items of the list, use `from=-3`.
// Arguments:
//   list = The list to get the tail of.
//   from = The first index to include.  If negative, adds the list length to it.  ie: -1 is the last list item.
// Example:
//   tlist1 = list_tail(["foo", "bar", "baz"]);  // Returns: ["bar", "baz"]
//   tlist2 = list_tail(["foo", "bar", "baz"], -1); // Returns: ["baz"]
//   tlist3 = list_tail(["foo", "bar", "baz"], 2);  // Returns: ["baz"]
//   tlist4 = list_tail(["foo", "bar", "baz"], -5); // Returns: ["foo","bar","baz"]
//   tlist5 = list_tail(["foo", "bar", "baz"], 5);  // Returns: []
function list_tail(list, from=1) =
   assert(is_list(list))
   assert(is_finite(from))
   from>=0? [for (i=[from:1:len(list)-1]) list[i]] :
   let(from = from + len(list))
   from>=0? [for (i=[from:1:len(list)-1]) list[i]] :
   list;



// Function: bselect()
// Usage:
//   array = bselect(array, index);
// Topics: List Handling
// See Also: list_bset()
// Description:
//   Returns the items in `array` whose matching element in `index` is true.
// Arguments:
//   array = Initial list to extract items from.
//   index = List of booleans.
// Example:
//   a = bselect([3,4,5,6,7], [false,true,true,false,true]);  // Returns: [4,5,7]
function bselect(array,index) =
    assert(is_list(array)||is_string(array), "Improper array." )
    assert(is_list(index) && len(index)>=len(array) , "Improper index list." )
    is_string(array)? str_join(bselect( [for (x=array) x], index)) :
    [for(i=[0:len(array)-1]) if (index[i]) array[i]];





// Section: List Construction


// Function: repeat()
// Usage:
//   list = repeat(val, n);
// Topics: List Handling
// See Also: count(), lerpn()
// Description:
//   Generates a list or array of `n` copies of the given value `val`.
//   If the count `n` is given as a list of counts, then this creates a
//   multi-dimensional array, filled with `val`.
// Arguments:
//   val = The value to repeat to make the list or array.
//   n = The number of copies to make of `val`.
// Example:
//   a = repeat(1, 4);        // Returns [1,1,1,1]
//   b = repeat(8, [2,3]);    // Returns [[8,8,8], [8,8,8]]
//   c = repeat(0, [2,2,3]);  // Returns [[[0,0,0],[0,0,0]], [[0,0,0],[0,0,0]]]
//   d = repeat([1,2,3],3);   // Returns [[1,2,3], [1,2,3], [1,2,3]]
function repeat(val, n, i=0) =
    is_num(n)? [for(j=[1:1:n]) val] :
    assert( is_list(n), "Invalid count number.")
    (i>=len(n))? val :
    [for (j=[1:1:n[i]]) repeat(val, n, i+1)];


// Function: count()
// Usage:
//   list = count(n, [s], [step], [reverse]);
// Description:
//   Creates a list of `n` numbers, starting at `s`, incrementing by `step` each time.
//   You can also pass a list for n and then the length of the input list is used.  
// Arguments:
//   n = The length of the list of numbers to create, or a list to match the length of
//   s = The starting value of the list of numbers.
//   step = The amount to increment successive numbers in the list.
//   reverse = Reverse the list.  Default: false.
// Example:
//   nl1 = count(5);  // Returns: [0,1,2,3,4]
//   nl2 = count(5,3);  // Returns: [3,4,5,6,7]
//   nl3 = count(4,3,2);  // Returns: [3,5,7,9]
//   nl4 = count(5,reverse=true);    // Returns: [4,3,2,1,0]
//   nl5 = count(5,3,reverse=true);  // Returns: [7,6,5,4,3]
function count(n,s=0,step=1,reverse=false) = let(n=is_list(n) ? len(n) : n)
                                             reverse? [for (i=[n-1:-1:0]) s+i*step]
                                                    : [for (i=[0:1:n-1]) s+i*step];



// Function: list_bset()
// Usage:
//   arr = list_bset(indexset, valuelist, [dflt]);
// Topics: List Handling
// See Also: bselect()
// Description:
//   Opposite of `bselect()`.  Returns a list the same length as `indexlist`, where each item will
//   either be 0 if the corresponding item in `indexset` is false, or the next sequential value
//   from `valuelist` if the item is true.  The number of `true` values in `indexset` must be equal 
//   to the length of `valuelist`.
// Arguments:
//   indexset = A list of boolean values.
//   valuelist = The list of values to set into the returned list.
//   dflt = Default value to store when the indexset item is false.
// Example:
//   a = list_bset([false,true,false,true,false], [3,4]);  // Returns: [0,3,0,4,0]
//   b = list_bset([false,true,false,true,false], [3,4], dflt=1);  // Returns: [1,3,1,4,1]
function list_bset(indexset, valuelist, dflt=0) =
    assert(is_list(indexset), "The index set is not a list." )
    assert(is_list(valuelist), "The `valuelist` is not a list." )
    let( trueind = search([true], indexset,0)[0] )
    assert( !(len(trueind)>len(valuelist)), str("List `valuelist` too short; its length should be ",len(trueind)) )
    assert( !(len(trueind)<len(valuelist)), str("List `valuelist` too long; its length should be ",len(trueind)) )
    concat(
        list_set([],trueind, valuelist, dflt=dflt),    // Fill in all of the values
        repeat(dflt,len(indexset)-max(trueind)-1)  // Add trailing values so length matches indexset
    );



// Function: list()
// Topics: List Handling, Type Conversion
// Usage:
//   list = list(l)
// Description:
//   Expands a range into a full list.  If given a list, returns it verbatim.
//   If given a string, explodes it into a list of single letters.
// Arguments:
//   l = The value to expand.
// See Also: scalar_vec3(), force_list()
// Example:
//   l1 = list([3:2:9]);  // Returns: [3,5,7,9]
//   l2 = list([3,4,5]);  // Returns: [3,4,5]
//   l3 = list("Foo");    // Returns: ["F","o","o"]
//   l4 = list(23);       // Returns: [23]
function list(l) = is_list(l)? l : [for (x=l) x];


// Function: force_list()
// Usage:
//   list = force_list(value, [n], [fill]);
// Topics: List Handling
// See Also: scalar_vec3()
// Description:
//   Coerces non-list values into a list.  Makes it easy to treat a scalar input
//   consistently as a singleton list, as well as list inputs.
//   - If `value` is a list, then that list is returned verbatim.
//   - If `value` is not a list, and `fill` is not given, then a list of `n` copies of `value` will be returned.
//   - If `value` is not a list, and `fill` is given, then a list `n` items long will be returned where `value` will be the first item, and the rest will contain the value of `fill`.
// Arguments:
//   value = The value or list to coerce into a list.
//   n = The number of items in the coerced list.  Default: 1
//   fill = The value to pad the coerced list with, after the firt value.  Default: undef (pad with copies of `value`)
// Example:
//   x = force_list([3,4,5]);  // Returns: [3,4,5]
//   y = force_list(5);  // Returns: [5]
//   z = force_list(7, n=3);  // Returns: [7,7,7]
//   w = force_list(4, n=3, fill=1);  // Returns: [4,1,1]
function force_list(value, n=1, fill) =
    is_list(value) ? value :
    is_undef(fill)? [for (i=[1:1:n]) value] : [value, for (i=[2:1:n]) fill];


// Section: List Modification

// Function: reverse()
// Usage:
//   rlist = reverse(list);
// Topics: List Handling
// See Also: select(), list_rotate()
// Description:
//   Reverses a list/array or string.
// Arguments:
//   x = The list or string to reverse.
// Example:
//   reverse([3,4,5,6]);  // Returns [6,5,4,3]
function reverse(x) =
    assert(is_list(x)||is_string(x), str("Input to reverse must be a list or string. Got: ",x))
    let (elems = [ for (i = [len(x)-1 : -1 : 0]) x[i] ])
    is_string(x)? str_join(elems) : elems;


// Function: list_rotate()
// Usage:
//   rlist = list_rotate(list, [n]);
// Topics: List Handling
// See Also: select(), reverse()
// Description:
//   Rotates the contents of a list by `n` positions left.
//   If `n` is negative, then the rotation is `abs(n)` positions to the right.
//   If `list` is a string, then a string is returned with the characters rotates within the string.
// Arguments:
//   list = The list to rotate.
//   n = The number of positions to rotate by.  If negative, rotated to the right.  Positive rotates to the left.  Default: 1
// Example:
//   l1 = list_rotate([1,2,3,4,5],-2); // Returns: [4,5,1,2,3]
//   l2 = list_rotate([1,2,3,4,5],-1); // Returns: [5,1,2,3,4]
//   l3 = list_rotate([1,2,3,4,5],0);  // Returns: [1,2,3,4,5]
//   l4 = list_rotate([1,2,3,4,5],1);  // Returns: [2,3,4,5,1]
//   l5 = list_rotate([1,2,3,4,5],2);  // Returns: [3,4,5,1,2]
//   l6 = list_rotate([1,2,3,4,5],3);  // Returns: [4,5,1,2,3]
//   l7 = list_rotate([1,2,3,4,5],4);  // Returns: [5,1,2,3,4]
//   l8 = list_rotate([1,2,3,4,5],5);  // Returns: [1,2,3,4,5]
//   l9 = list_rotate([1,2,3,4,5],6);  // Returns: [2,3,4,5,1]
function list_rotate(list,n=1) =
    assert(is_list(list)||is_string(list), "Invalid list or string.")
    assert(is_int(n), "The rotation number should be integer")
    let (
        ll = len(list),
        n = ((n % ll) + ll) % ll,
        elems = [
            for (i=[n:1:ll-1]) list[i],
            for (i=[0:1:n-1]) list[i]
        ]
    )
    is_string(list)? str_join(elems) : elems;

    

// Function: shuffle()
// Usage:
//   shuffled = shuffle(list, [seed]);
// Topics: List Handling
// See Also: sort(), sortidx(), unique(), unique_count()
// Description:
//   Shuffles the input list into random order.
//   If given a string, shuffles the characters within the string.
//   If you give a numeric seed value then the permutation
//   will be repeatable.
// Arguments:
//   list = The list to shuffle.
//   seed = Optional random number seed for the shuffling.
// Example:
//   //        Spades   Hearts    Diamonds  Clubs
//   suits = ["\u2660", "\u2661", "\u2662", "\u2663"];
//   ranks = [2,3,4,5,6,7,8,9,10,"J","Q","K","A"];
//   cards = [for (suit=suits, rank=ranks) str(rank,suit)];
//   deck = shuffle(cards);
function shuffle(list,seed) =
    assert(is_list(list)||is_string(list), "Invalid input." )
    is_string(list)? str_join(shuffle([for (x = list) x],seed=seed)) :
    len(list)<=1 ? list :
    let(
        rval = is_num(seed) ? rands(0,1,len(list),seed_value=seed)
                            : rands(0,1,len(list)),
        left  = [for (i=[0:len(list)-1]) if (rval[i]< 0.5) list[i]],
        right = [for (i=[0:len(list)-1]) if (rval[i]>=0.5) list[i]]
    ) 
    concat(shuffle(left), shuffle(right));



// Function: repeat_entries()
// Usage:
//   newlist = repeat_entries(list, N, [exact]);
// Topics: List Handling
// See Also: repeat()
// Description:
//   Takes a list as input and duplicates some of its entries to produce a list
//   with length `N`.  If the requested `N` is not a multiple of the list length then
//   the entries will be duplicated as uniformly as possible.  You can also set `N` to a vector,
//   in which case len(N) must equal len(list) and the output repeats the ith entry N[i] times.
//   In either case, the result will be a list of length `N`.  The `exact` option requires
//   that the final length is exactly as requested.  If you set it to `false` then the
//   algorithm will favor uniformity and the output list may have a different number of
//   entries due to rounding.
//   .
//   When applied to a path the output path is the same geometrical shape but has some vertices
//   repeated.  This can be useful when you need to align paths with a different number of points.
//   (See also subdivide_path for a different way to do that.) 
// Arguments:
//   list = list whose entries will be repeated
//   N = scalar total number of points desired or vector requesting N[i] copies of vertex i.  
//   exact = if true return exactly the requested number of points, possibly sacrificing uniformity.  If false, return uniform points that may not match the number of points requested.  Default: True
// Example:
//   list = [0,1,2,3];
//   a = repeat_entries(list, 6);  // Returns: [0,0,1,2,2,3]
//   b = repeat_entries(list, 6, exact=false);  // Returns: [0,0,1,1,2,2,3,3]
//   c = repeat_entries(list, [1,1,2,1], exact=false);  // Returns: [0,1,2,2,3]
function repeat_entries(list, N, exact=true) =
    assert(is_list(list) && len(list)>0, "The list cannot be void.")
    assert((is_finite(N) && N>0) || is_vector(N,len(list)),
            "Parameter N must be a number greater than zero or vector with the same length of `list`")
    let(
        length = len(list),
        reps_guess = is_list(N)? N : repeat(N/length,length),
        reps = exact ?
                 _sum_preserving_round(reps_guess) 
               : [for (val=reps_guess) round(val)]
    )
    [for(i=[0:length-1]) each repeat(list[i],reps[i])];


// Function: list_set()
// Usage:
//   list = list_set(list, indices, values, [dflt], [minlen]);
// Topics: List Handling
// See Also: list_insert(), list_remove(), list_remove_values()
// Description:
//   Takes the input list and returns a new list such that `list[indices[i]] = values[i]` for all of
//   the (index,value) pairs supplied and unchanged for other indices.  If you supply `indices` that are 
//   beyond the length of the list then the list is extended and filled in with the `dflt` value.  
//   If you set `minlen` then the list is lengthed, if necessary, by padding with `dflt` to that length.  
//   Repetitions in `indices` are not allowed. The lists `indices` and `values` must have the same length.  
//   If `indices` is given as a scalar, then that index of the given `list` will be set to the scalar value of `values`.
// Arguments:
//   list = List to set items in.  Default: []
//   indices = List of indices into `list` to set.
//   values = List of values to set.
//   dflt = Default value to store in sparse skipped indices.
//   minlen = Minimum length to expand list to.
// Example:
//   a = list_set([2,3,4,5], 2, 21);  // Returns: [2,3,21,5]
//   b = list_set([2,3,4,5], [1,3], [81,47]);  // Returns: [2,81,4,47]
function list_set(list=[],indices,values,dflt=0,minlen=0) = 
    assert(is_list(list))
    !is_list(indices)? (
        (is_finite(indices) && indices<len(list))
          ? concat([for (i=idx(list)) i==indices? values : list[i]], repeat(dflt, minlen-len(list)))
          : list_set(list,[indices],[values],dflt)
    ) :
    indices==[] && values==[]
      ? concat(list, repeat(dflt, minlen-len(list)))
      : assert(is_vector(indices) && is_list(values) && len(values)==len(indices),
               "Index list and value list must have the same length")
        let( midx = max(len(list)-1, max(indices)) )
        [
            for (i=[0:1:midx]) let(
                j = search(i,indices,0),
                k = j[0]
            )
            assert( len(j)<2, "Repeated indices are not allowed." )
            k!=undef
              ? values[k]
              : i<len(list) ? list[i] : dflt,
            each repeat(dflt, minlen-max(len(list),max(indices)))
        ];


// Function: list_insert()
// Usage:
//   list = list_insert(list, indices, values);
// Topics: List Handling
// See Also: list_set(), list_remove(), list_remove_values()
// Description:
//   Insert `values` into `list` before position `indices`.
// Example:
//   a = list_insert([3,6,9,12],1,5);  // Returns [3,5,6,9,12]
//   b = list_insert([3,6,9,12],[1,3],[5,11]);  // Returns [3,5,6,9,11,12]
function list_insert(list, indices, values) = 
    assert(is_list(list))
    !is_list(indices) ?
        assert( is_finite(indices) && is_finite(values), "Invalid indices/values." ) 
        assert( indices<=len(list), "Indices must be <= len(list) ." )
        [
          for (i=idx(list)) each ( i==indices?  [ values, list[i] ] : [ list[i] ] ),
          if (indices==len(list)) values
        ] :
    indices==[] && values==[] ? list :
    assert( is_vector(indices) && is_list(values) && len(values)==len(indices),
           "Index list and value list must have the same length")
    assert( max(indices)<=len(list), "Indices must be <= len(list)." )
    let(
        maxidx = max(indices),
        minidx = min(indices)
    ) [
        for (i=[0:1:minidx-1] ) list[i],
        for (i=[minidx : min(maxidx, len(list)-1)] )
            let(
                j = search(i,indices,0),
                k = j[0],
                x = assert( len(j)<2, "Repeated indices are not allowed." )
            ) each ( k != undef  ? [ values[k], list[i] ] : [ list[i] ] ),
        for ( i = [min(maxidx, len(list)-1)+1 : 1 : len(list)-1] ) list[i],
        if (maxidx == len(list)) values[max_index(indices)]
    ];


// Function: list_remove()
// Usage:
//   list = list_remove(list, ind);
// Topics: List Handling
// See Also: list_set(), list_insert(), list_remove_values()
// Description:
//   If `ind` is a number remove `list[ind]` from the list.  If `ind` is a list of indices
//   remove from the list the item all items whose indices appear in `ind`.  If you give
//   indices that are not in the list they are ignored.  
// Arguments:
//   list = The list to remove items from.
//   ind = index or list of indices of items to remove. 
// Example:
//   a = list_remove([3,6,9,12],1);      // Returns: [3,9,12]
//   b = list_remove([3,6,9,12],[1,3]);  // Returns: [3,9]
//   c = list_remove([3,6],3);           // Returns: [3,6]
function list_remove(list, ind) =
    assert(is_list(list), "Invalid list in list_remove")
    is_finite(ind) ?
        (
         (ind<0 || ind>=len(list)) ? list
         :                                        
            [
              for (i=[0:1:ind-1]) list[i],
              for (i=[ind+1:1:len(list)-1]) list[i]
            ]
        )
    :   ind==[] ? list
    :   assert( is_vector(ind), "Invalid index list in list_remove")
        let(sres = search(count(list),ind,1))
        [
            for(i=idx(list))
                if (sres[i] == []) 
                    list[i]
        ];

// This method is faster for long lists with few values to remove
//     let(   rem = list_set([], indices, repeat(1,len(indices)), minlen=len(list)))
//     [for(i=idx(list)) if (rem[i]==0) list[i]];



// Function: list_remove_values()
// Usage:
//   list = list_remove_values(list, values);
//   list = list_remove_values(list, values, all=true);
// Topics: List Handling
// See Also: list_set(), list_insert(), list_remove()
// Description:
//   Removes the first, or all instances of the given value or list of values from the list.
//   If you specify `all=false` and list a value twice then the first two instances will be removed.  
//   Note that if you want to remove a list value such as `[3,4]` then you must give it as
//   a singleton list, or it will be interpreted as a list of two scalars to remove.  
// Arguments:
//   list = The list to modify.
//   values = The value or list of values to remove from the list.
//   all = If true, remove all instances of the value `value` from the list `list`.  If false, remove only the first.  Default: false
// Example:
//   test = [3,4,[5,6],7,5,[5,6],4,[6,5],7,[4,4]];
//   a=list_remove_values(test,4); // Returns: [3, [5, 6], 7, 5, [5, 6], 4, [6, 5], 7, [4, 4]]
//   b=list_remove_values(test,[4,4]); // Returns: [3, [5, 6], 7, 5, [5, 6], [6, 5], 7, [4, 4]]
//   c=list_remove_values(test,[4,7]); // Returns: [3, [5, 6], 5, [5, 6], 4, [6, 5], 7, [4, 4]]
//   d=list_remove_values(test,[5,6]); // Returns: [3, 4, [5, 6], 7, [5, 6], 4, [6, 5], 7, [4, 4]]
//   e=list_remove_values(test,[[5,6]]); // Returns: [3,4,7,5,[5,6],4,[6,5],7,[4,4]]
//   f=list_remove_values(test,[[5,6]],all=true); // Returns: [3,4,7,5,4,[6,5],7,[4,4]]
//   animals = ["bat", "cat", "rat", "dog", "bat", "rat"];
//   animals2 = list_remove_values(animals, "rat");   // Returns: ["bat","cat","dog","bat","rat"]
//   nonflying = list_remove_values(animals, "bat", all=true);  // Returns: ["cat","rat","dog","rat"]
//   animals3 = list_remove_values(animals, ["bat","rat"]);  // Returns: ["cat","dog","bat","rat"]
//   domestic = list_remove_values(animals, ["bat","rat"], all=true);  // Returns: ["cat","dog"]
//   animals4 = list_remove_values(animals, ["tucan","rat"], all=true);  // Returns: ["bat","cat","dog","bat"]
function list_remove_values(list,values=[],all=false) =
    !is_list(values)? list_remove_values(list, values=[values], all=all) :
    assert(is_list(list), "Invalid list")
    len(values)==0 ? list :
    len(values)==1 ?
      (
        !all ?
           (
               let(firsthit = search(values,list,1)[0])
               firsthit==[] ? list
             : list[firsthit]==values[0] ? list_remove(list,firsthit)
             : let(allhits = search(values,list,0)[0],
                   allind = [for(i=allhits) if (list[i]==values[0]) i]
               )
               allind==[] ? list : list_remove(list,min(allind))
           )
        :
           (
             let(allhits = search(values,list,0)[0],
                 allind = [for(i=allhits) if (list[i]==values[0]) i]
             )
             allind==[] ? list : list_remove(list,allind)
           )
     )
    :!all ? list_remove_values(list_remove_values(list, values[0],all=all), list_tail(values),all=all)
    :    
    [
      for(i=idx(list))
        let(hit=search([list[i]],values,0)[0])
          if (hit==[]) list[i]
          else
            let(check = [for(j=hit) if (values[j]==list[i]) 1])
            if (check==[]) list[i]
    ];


// Section: List Length Manipulation


// Function: list_pad()
// Usage:
//   arr = list_pad(array, minlen, [fill]);
// Topics: List Handling
// See Also: list_trim(), list_fit()
// Description:
//   If the list `array` is shorter than `minlen` length, pad it to length with the value given in `fill`.
// Arguments:
//   array = A list.
//   minlen = The minimum length to pad the list to.
//   fill = The value to pad the list with.  Default: `undef`
// Example:
//   list = [3,4,5];
//   nlist = list_pad(list,5,23);  // Returns: [3,4,5,23,23]
function list_pad(array, minlen, fill) =
    assert(is_list(array), "Invalid input." )
    concat(array,repeat(fill,minlen-len(array)));


// Function: list_trim()
// Usage:
//   arr = list_trim(array, maxlen);
// Topics: List Handling
// See Also: list_pad(), list_fit()
// Description:
//   If the list `array` is longer than `maxlen` length, truncates it to be `maxlen` items long.
// Arguments:
//   array = A list.
//   minlen = The minimum length to pad the list to.
// Example:
//   list = [3,4,5,6,7,8];
//   nlist = list_trim(list,4);  // Returns: [3,4,5,6]
function list_trim(array, maxlen) =
    assert(is_list(array), "Invalid input." )
    [for (i=[0:1:min(len(array),maxlen)-1]) array[i]];


// Function: list_fit()
// Usage:
//   arr = list_fit(array, length, fill);
// Topics: List Handling
// See Also: list_pad(), list_trim()
// Description:
//   If the list `array` is longer than `length` items long, truncates it to be exactly `length` items long.
//   If the list `array` is shorter than `length` items long, pad it to length with the value given in `fill`.
// Arguments:
//   array = A list.
//   minlen = The minimum length to pad the list to.
//   fill = The value to pad the list with.  Default: `undef`
// Example:
//   list = [3,4,5,6];
//   nlist = list_fit(list,3);  // Returns: [3,4,5]
// Example:
//   list = [3,4,5,6];
//   nlist = list_fit(list,6,23);  // Returns: [3,4,5,6,23,23]
function list_fit(array, length, fill) =
    assert(is_list(array), "Invalid input." )
    let(l=len(array)) 
    l==length ? array : 
    l> length ? list_trim(array,length) 
              : list_pad(array,length,fill);


// Section: Iteration Helpers

// Function: idx()
// Usage:
//   rng = idx(list, [s=], [e=], [step=]);
//   for(i=idx(list, [s=], [e=], [step=])) ...
// Topics: List Handling, Iteration
// See Also: enumerate(), pair(), triplet(), combinations(), permutations()
// Description:
//   Returns the range of indexes for the given list.
// Arguments:
//   list = The list to returns the index range of.
//   s = The starting index.  Default: 0
//   e = The delta from the end of the list.  Default: -1 (end of list)
//   step = The step size to stride through the list.  Default: 1
// Example(2D):
//   colors = ["red", "green", "blue"];
//   for (i=idx(colors)) right(20*i) color(colors[i]) circle(d=10);
function idx(list, s=0, e=-1, step=1) =
    assert(is_list(list)||is_string(list), "Invalid input." )
    let( ll = len(list) )
    ll == 0 ? [0:1:ll-1] :
    let(
        _s = posmod(s,ll),
        _e = posmod(e,ll)
    ) [_s : step : _e];


// Function: enumerate()
// Usage:
//   arr = enumerate(l, [idx]);
//   for (x = enumerate(l, [idx])) ... // x[0] is the index number, x[1] is the item.
// Topics: List Handling, Iteration
// See Also: idx(), pair(), triplet(), combinations(), permutations()
// Description:
//   Returns a list, with each item of the given list `l` numbered in a sublist.
//   Something like: `[[0,l[0]], [1,l[1]], [2,l[2]], ...]`
// Arguments:
//   l = List to enumerate.
//   idx = If given, enumerates just the given columns items of `l`.
// Example:
//   enumerate(["a","b","c"]);  // Returns: [[0,"a"], [1,"b"], [2,"c"]]
//   enumerate([[88,"a"],[76,"b"],[21,"c"]], idx=1);  // Returns: [[0,"a"], [1,"b"], [2,"c"]]
//   enumerate([["cat","a",12],["dog","b",10],["log","c",14]], idx=[1:2]);  // Returns: [[0,"a",12], [1,"b",10], [2,"c",14]]
// Example(2D):
//   colors = ["red", "green", "blue"];
//   for (p=enumerate(colors)) right(20*p[0]) color(p[1]) circle(d=10);
function enumerate(l,idx=undef) =
    assert(is_list(l)||is_string(list), "Invalid input." )
    assert( _valid_idx(idx,0,len(l)), "Invalid index/indices." )
    (idx==undef)
    ?   [for (i=[0:1:len(l)-1]) [i,l[i]]]
    :   [for (i=[0:1:len(l)-1]) [ i, for (j=idx) l[i][j]] ];


// Function: pair()
// Usage:
//   p = pair(list, [wrap]);
//   for (p = pair(list, [wrap])) ...  // On each iteration, p contains a list of two adjacent items.
// Topics: List Handling, Iteration
// See Also: idx(), enumerate(), triplet(), combinations(), permutations()
// Description:
//   Takes a list, and returns a list of adjacent pairs from it, optionally wrapping back to the front.
// Arguments:
//   list = The list to iterate.
//   wrap = If true, wrap back to the start from the end.  ie: return the last and first items as the last pair.  Default: false
// Example(2D): Does NOT wrap from end to start,
//   for (p = pair(circle(d=40, $fn=12)))
//       stroke(p, endcap2="arrow2");
// Example(2D): Wraps around from end to start.
//   for (p = pair(circle(d=40, $fn=12), wrap=true))
//       stroke(p, endcap2="arrow2");
// Example:
//   l = ["A","B","C","D"];
//   echo([for (p=pair(l)) str(p.y,p.x)]);  // Outputs: ["BA", "CB", "DC"]
function pair(list, wrap=false) =
    assert(is_list(list)||is_string(list), "Invalid input." )
    assert(is_bool(wrap))
    let( L = len(list)-1)
    L<1 ? [] :
    [
      for (i=[0:1:L-1]) [list[i], list[i+1]],
      if(wrap) [list[L], list[0]]
    ];



// Function: triplet()
// Usage:
//   list = triplet(list, [wrap]);
//   for (t = triplet(list, [wrap])) ...
// Topics: List Handling, Iteration
// See Also: idx(), enumerate(), pair(), combinations(), permutations()
// Description:
//   Takes a list, and returns a list of adjacent triplets from it, optionally wrapping back to the front.
//   If you set `wrap` to true then the first triplet is the one centered on the first list element, so it includes
//   the last element and the first two elements.  If the list has fewer than three elements then the empty list is returned.
// Arguments:
//   list = list to produce triplets from
//   wrap = if true, wrap triplets around the list.  Default: false
// Example:
//   list = [0,1,2,3,4];
//   a = triplet(list);               // Returns [[0,1,2],[1,2,3],[2,3,4]]
//   b = triplet(list,wrap=true);     // Returns [[4,0,1],[0,1,2],[1,2,3],[2,3,4],[3,4,0]]
//   letters = ["A","B","C","D","E"];
//   [for (p=triplet(letters)) str(p.z,p.y,p.x)];     // Returns: ["CBA", "DCB", "EDC"]
// Example(2D):
//   path = [for (i=[0:24]) polar_to_xy(i*2, i*360/12)];
//   for (t = triplet(path)) {
//       a = t[0]; b = t[1]; c = t[2];
//       v = unit(unit(a-b) + unit(c-b));
//       translate(b) rot(from=FWD,to=v) anchor_arrow2d();
//   }
//   stroke(path);
function triplet(list, wrap=false) =
    assert(is_list(list)||is_string(list), "Invalid input." )
    assert(is_bool(wrap))
    let(L=len(list))
    L<3 ? [] :
    [
      if(wrap) [list[L-1], list[0], list[1]],
      for (i=[0:1:L-3]) [list[i],list[i+1],list[i+2]],
      if(wrap) [list[L-2], list[L-1], list[0]]
    ];


// Function: combinations()
// Usage:
//   list = combinations(l, [n]);
// Topics: List Handling, Iteration
// See Also: idx(), enumerate(), pair(), triplet(), permutations()
// Description:
//   Returns a list of all of the (unordered) combinations of `n` items out of the given list `l`.
//   For the list `[1,2,3,4]`, with `n=2`, this will return `[[1,2], [1,3], [1,4], [2,3], [2,4], [3,4]]`.
//   For the list `[1,2,3,4]`, with `n=3`, this will return `[[1,2,3], [1,2,4], [1,3,4], [2,3,4]]`.
// Arguments:
//   l = The list to provide permutations for.
//   n = The number of items in each permutation. Default: 2
// Example:
//   pairs = combinations([3,4,5,6]);  // Returns: [[3,4],[3,5],[3,6],[4,5],[4,6],[5,6]]
//   triplets = combinations([3,4,5,6],n=3);  // Returns: [[3,4,5],[3,4,6],[3,5,6],[4,5,6]]
// Example(2D):
//   for (p=combinations(regular_ngon(n=7,d=100))) stroke(p);
function combinations(l,n=2,_s=0) =
    assert(is_list(l), "Invalid list." )
    assert( is_finite(n) && n>=1 && n<=len(l), "Invalid number `n`." )
    n==1
      ? [for (i=[_s:1:len(l)-1]) [l[i]]] 
      : [for (i=[_s:1:len(l)-n], p=combinations(l,n=n-1,_s=i+1)) concat([l[i]], p)];


// Function: permutations()
// Usage:
//   list = permutations(l, [n]);
// Topics: List Handling, Iteration
// See Also: idx(), enumerate(), pair(), triplet(), combinations()
// Description:
//   Returns a list of all of the (ordered) permutation `n` items out of the given list `l`.  
//   For the list `[1,2,3]`, with `n=2`, this will return `[[1,2],[1,3],[2,1],[2,3],[3,1],[3,2]]`
//   For the list `[1,2,3]`, with `n=3`, this will return `[[1,2,3],[1,3,2],[2,1,3],[2,3,1],[3,1,2],[3,2,1]]`
// Arguments:
//   l = The list to provide permutations for.
//   n = The number of items in each permutation. Default: 2
// Example:
//   pairs = permutations([3,4,5,6]);  // // Returns: [[3,4],[3,5],[3,6],[4,3],[4,5],[4,6],[5,3],[5,4],[5,6],[6,3],[6,4],[6,5]]
function permutations(l,n=2) =
    assert(is_list(l), "Invalid list." )
    assert( is_finite(n) && n>=1 && n<=len(l), "Invalid number `n`." )
    n==1
      ? [for (i=[0:1:len(l)-1]) [l[i]]] 
      : [for (i=idx(l), p=permutations([for (j=idx(l)) if (i!=j) l[j]], n=n-1)) concat([l[i]], p)];





// Section: Changing list structure


           

// Function: list_to_matrix()
// Usage:
//   groups = list_to_matrix(v, [cnt], [dflt]);
// Description:
//   Takes a flat array of values, and groups items in sets of `cnt` length.
//   The opposite of this is `flatten()`.
// Topics: Matrices, Array Handling
// See Also: column(), submatrix(), hstack(), flatten(), full_flatten()
// Arguments:
//   v = The list of items to group.
//   cnt = The number of items to put in each grouping.  Default:2
//   dflt = The default value to fill in with if the list is not a multiple of `cnt` items long.  Default: 0
// Example:
//   v = [1,2,3,4,5,6];
//   a = list_to_matrix(v,2) returns [[1,2], [3,4], [5,6]]
//   b = list_to_matrix(v,3) returns [[1,2,3], [4,5,6]]
//   c = list_to_matrix(v,4,0) returns [[1,2,3,4], [5,6,0,0]]
function list_to_matrix(v, cnt=2, dflt=0) =
    [for (i = [0:cnt:len(v)-1]) [for (j = [0:1:cnt-1]) default(v[i+j], dflt)]];



// Function: flatten()
// Usage:
//   list = flatten(l);
// Topics: Matrices, Array Handling
// See Also: column(), submatrix(), hstack(), full_flatten()
// Description:
//   Takes a list of lists and flattens it by one level.
// Arguments:
//   l = List to flatten.
// Example:
//   l = flatten([[1,2,3], [4,5,[6,7,8]]]);  // returns [1,2,3,4,5,[6,7,8]]
function flatten(l) =
    !is_list(l)? l :
    [for (a=l) if (is_list(a)) (each a) else a];


// Function: full_flatten()
// Usage:
//   list = full_flatten(l);
// Topics: Matrices, Array Handling
// See Also: column(), submatrix(), hstack(), flatten()
// Description: 
//   Collects in a list all elements recursively found in any level of the given list.
//   The output list is ordered in depth first order.
// Arguments:
//   l = List to flatten.
// Example:
//   l = full_flatten([[1,2,3], [4,5,[6,7,8]]]);  // returns [1,2,3,4,5,6,7,8]
function full_flatten(l) =
    !is_list(l)? l :
    [for (a=l) if (is_list(a)) (each full_flatten(a)) else a];



// Function: zip()
// Usage:
//   pairs = zip(a,b);
//   triples = zip(a,b,c);
//   quads = zip([LIST1,LIST2,LIST3,LIST4]);
// Topics: List Handling, Iteration
// See Also: zip_long()
// Description:
//   Zips together two or more lists into a single list.  For example, if you have two
//   lists [3,4,5], and [8,7,6], and zip them together, you get [ [3,8],[4,7],[5,6] ].
//   The list returned will be as long as the shortest list passed to zip().
// Arguments:
//   a = The first list, or a list of lists if b and c are not given.
//   b = The second list, if given.
//   c = The third list, if given.
// Example:
//   a = [9,8,7,6]; b = [1,2,3];
//   for (p=zip(a,b)) echo(p);
//   // ECHO: [9,1]
//   // ECHO: [8,2]
//   // ECHO: [7,3]
function zip(a,b,c) =
    b!=undef? zip([a,b,if (c!=undef) c]) :
    let(n = min_length(a))
    [for (i=[0:1:n-1]) [for (x=a) x[i]]];


// Function: zip_long()
// Usage:
//   pairs = zip_long(a,b);
//   triples = zip_long(a,b,c);
//   quads = zip_long([LIST1,LIST2,LIST3,LIST4]);
// Topics: List Handling, Iteration
// See Also: zip()
// Description:
//   Zips together two or more lists into a single list.  For example, if you have two
//   lists [3,4,5], and [8,7,6], and zip them together, you get [ [3,8],[4,7],[5,6] ].
//   The list returned will be as long as the longest list passed to zip_long(), with
//   shorter lists padded by the value in `fill`.
// Arguments:
//   a = The first list, or a list of lists if b and c are not given.
//   b = The second list, if given.
//   c = The third list, if given.
//   fill = The value to pad shorter lists with.  Default: undef
// Example:
//   a = [9,8,7,6]; b = [1,2,3];
//   for (p=zip_long(a,b,fill=88)) echo(p);
//   // ECHO: [9,1]
//   // ECHO: [8,2]
//   // ECHO: [7,3]
//   // ECHO: [6,88]]
function zip_long(a,b,c,fill) =
    b!=undef? zip_long([a,b,if (c!=undef) c],fill=fill) :
    let(n = max_length(a))
    [for (i=[0:1:n-1]) [for (x=a) i<len(x)? x[i] : fill]];



// Section: Set Manipulation

// Function: set_union()
// Usage:
//   s = set_union(a, b, [get_indices]);
// Topics: Set Handling, List Handling
// See Also: set_difference(), set_intersection()
// Description:
//   Given two sets (lists with unique items), returns the set of unique items that are in either `a` or `b`.
//   If `get_indices` is true, a list of indices into the new union set are returned for each item in `b`,
//   in addition to returning the new union set.  In this case, a 2-item list is returned, `[INDICES, NEWSET]`,
//   where INDICES is the list of indices for items in `b`, and NEWSET is the new union set.
// Arguments:
//   a = One of the two sets to merge.
//   b = The other of the two sets to merge.
//   get_indices = If true, indices into the new union set are also returned for each item in `b`.  Returns `[INDICES, NEWSET]`.  Default: false
// Example:
//   set_a = [2,3,5,7,11];
//   set_b = [1,2,3,5,8];
//   set_u = set_union(set_a, set_b);
//   // set_u now equals [2,3,5,7,11,1,8]
//   set_v = set_union(set_a, set_b, get_indices=true);
//   // set_v now equals [[5,0,1,2,6], [2,3,5,7,11,1,8]]
function set_union(a, b, get_indices=false) =
    assert( is_list(a) && is_list(b), "Invalid sets." )
    let(
        found1 = search(b, a),
        found2 = search(b, b),
        c = [ for (i=idx(b))
                if (found1[i] == [] && found2[i] == i)
                    b[i] 
            ],
        nset = concat(a, c)
    ) 
    ! get_indices ? nset :
    let(
        la = len(a),
        found3 = search(b, c),
        idxs =  [ for (i=idx(b))
                    (found1[i] != [])? found1[i] : la + found3[i]
                ]
    ) [idxs, nset];


// Function: set_difference()
// Usage:
//   s = set_difference(a, b);
// Topics: Set Handling, List Handling
// See Also: set_union(), set_intersection()
// Description:
//   Given two sets (lists with unique items), returns the set of items that are in `a`, but not `b`.
// Arguments:
//   a = The starting set.
//   b = The set of items to remove from set `a`.
// Example:
//   set_a = [2,3,5,7,11];
//   set_b = [1,2,3,5,8];
//   set_d = set_difference(set_a, set_b);
//   // set_d now equals [7,11]
function set_difference(a, b) =
    assert( is_list(a) && is_list(b), "Invalid sets." )
    let( found = search(a, b, num_returns_per_match=1) )
    [ for (i=idx(a)) if(found[i]==[]) a[i] ];


// Function: set_intersection()
// Usage:
//   s = set_intersection(a, b);
// Topics: Set Handling, List Handling
// See Also: set_union(), set_difference()
// Description:
//   Given two sets (lists with unique items), returns the set of items that are in both sets.
// Arguments:
//   a = The starting set.
//   b = The set of items to intersect with set `a`.
// Example:
//   set_a = [2,3,5,7,11];
//   set_b = [1,2,3,5,8];
//   set_i = set_intersection(set_a, set_b);
//   // set_i now equals [2,3,5]
function set_intersection(a, b) =
    assert( is_list(a) && is_list(b), "Invalid sets." )
    let( found = search(a, b, num_returns_per_match=1) )
    [ for (i=idx(a)) if(found[i]!=[]) a[i] ];




// vim: expandtab tabstop=4 shiftwidth=4 softtabstop=4 nowrap
