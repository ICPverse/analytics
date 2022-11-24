

import Prim "mo:⛔";
import Result "mo:base/Result";
import Order "mo:base/Order";
import Array "mo:base/Array";
import HashMap "mo:base/HashMap";

module {
  type Order = Order.Order;

  
  private let INCREASE_FACTOR_NUME = 3;
  private let INCREASE_FACTOR_DENOM = 2;
  private let DECREASE_THRESHOLD = 4; // Don't decrease capacity too early to avoid thrashing
  private let DECREASE_FACTOR = 2;
  private let DEFAULT_CAPACITY = 8;

  private func newCapacity(oldCapacity : Nat) : Nat {
    if (oldCapacity == 0) {
      1;
    } else {
      // calculates ceil(oldCapacity * INCREASE_FACTOR) without floats
      ((oldCapacity * INCREASE_FACTOR_NUME) + INCREASE_FACTOR_DENOM - 1) / INCREASE_FACTOR_DENOM
    };
  };

  public class Buffer2<X>(initCapacity : Nat) = this {
    var _size : Nat = 0; // avoid name clash with `size()` method
    var elements : [var ?X] = Prim.Array_init(initCapacity, null);

    
    public func size() : Nat = _size;

    
    public func add(element : X) {
      if (_size == elements.size()) {
        reserve(newCapacity(elements.size()));
      };
      elements[_size] := ?element;
      _size += 1;
    };

    
    public func get(index : Nat) : X {
      switch (elements[index]) {
        case (?element) element;
        case null Prim.trap("Buffer index out of bounds in get");
      };
    };

    
    public func getOpt(index : Nat) : ?X {
      if (index < _size) {
        elements[index];
      } else {
        null;
      };
    };

    
    public func put(index : Nat, element : X) {
      if (index >= _size) {
        Prim.trap "Buffer index out of bounds in put";
      };
      elements[index] := ?element;
    };

    
    public func removeLast() : ?X {
      if (_size == 0) {
        return null;
      };

      _size -= 1;
      let lastElement = elements[_size];
      elements[_size] := null;

      if (_size < elements.size() / DECREASE_THRESHOLD) {
        // FIXME should this new capacity be a function of _size
        // instead of the current capacity? E.g. _size * INCREASE_FACTOR
        reserve(elements.size() / DECREASE_FACTOR);
      };

      lastElement;
    };

    
    public func remove(index : Nat) : X {
      if (index >= _size) {
        Prim.trap "Buffer index out of bounds in remove";
      };

      let element = elements[index];

      // copy elements to new array and shift over in one pass
      if ((_size - 1) : Nat < elements.size() / DECREASE_THRESHOLD) {
        let elements2 = Prim.Array_init<?X>(elements.size() / DECREASE_FACTOR, null);

        var i = 0;
        var j = 0;
        label l while (i < _size) {
          if (i == index) {
            i += 1;
            continue l;
          };

          elements2[j] := elements[i];
          i += 1;
          j += 1;
        };
        elements := elements2;
      } else {
        // just shift over elements
        var i = index;
        while (i < (_size - 1 : Nat)) {
          elements[i] := elements[i + 1];
          i += 1;
        };
        elements[_size - 1] := null;
      };

      _size -= 1;

      switch (element) {
        case (?element) {
          element
        };
        case null {
          Prim.trap "Malformed buffer in remove"
        }
      }
    };

    
    public func clear() {
      _size := 0;
      reserve(DEFAULT_CAPACITY);
    };

    
    public func filterEntries(predicate : (Nat, X) -> Bool) {
      var numRemoved = 0;
      let keep = Prim.Array_tabulate<Bool>(
        _size,
        func i {
          switch (elements[i]) {
            case (?element) {
              if (predicate(i, element)) {
                true;
              } else {
                numRemoved += 1;
                false;
              };
            };
            case null {
              Prim.trap "Malformed buffer in filter()";
            };
          };
        },
      );

      let capacity = elements.size();

      if ((_size - numRemoved : Nat) < capacity / DECREASE_THRESHOLD) {
        let elements2 = Prim.Array_init<?X>(capacity / DECREASE_FACTOR, null);

        var i = 0;
        var j = 0;
        while (i < _size) {
          if (keep[i]) {
            elements2[j] := elements[i];
            i += 1;
            j += 1;
          } else {
            i += 1;
          };
        };

        elements := elements2;
      } else {
        var i = 0;
        var j = 0;
        while (i < _size) {
          if (keep[i]) {
            elements[j] := elements[i];
            i += 1;
            j += 1;
          } else {
            i += 1;
          };
        };

        while (j < _size) {
          elements[j] := null;
          j += 1;
        }
      };

      _size -= numRemoved;
    };

    
    public func capacity() : Nat = elements.size();

    
    public func reserve(capacity : Nat) {
      if (capacity < _size) {
        Prim.trap "capacity must be >= size in reserve";
      };

      let elements2 = Prim.Array_init<?X>(capacity, null);

      var i = 0;
      while (i < _size) {
        elements2[i] := elements[i];
        i += 1;
      };
      elements := elements2;
    };

    /// Adds all elements in buffer `b` to this buffer.
    ///
    /// Amortized Runtime: O(size2), Worst Case Runtime: O(size1 + size2)
    ///
    /// Amortized Space: O(1), Worst Case Space: O(size1 + size2)
    public func append(buffer2 : Buffer2<X>) {
      let size2 = buffer2.size();
      // Make sure you only allocate a new array at most once
      if (_size + size2 > elements.size()) {
        // FIXME would be nice to have a tabulate for var arrays here
        reserve(newCapacity(_size + size2));
      };
      var i = 0;
      while (i < size2) {
        elements[_size + i] := buffer2.getOpt i;
        i += 1;
      };

      _size += size2;
    };

    
    public func insert(index : Nat, element : X) {
      if (index > _size) {
        Prim.trap "Buffer index out of bounds in insert";
      };
      let capacity = elements.size();

      if (_size + 1 > capacity) {
        let capacity = elements.size();
        let elements2 = Prim.Array_init<?X>(newCapacity capacity, null);
        var i = 0;
        while (i < _size + 1) {
          if (i < index) {
            elements2[i] := elements[i];
          } else if (i == index) {
            elements2[i] := ?element;
          } else {
            elements2[i] := elements[i - 1];
          };

          i += 1;
        };
        elements := elements2;
      } else {
        var i : Nat = _size;
        while (i > index) {
          elements[i] := elements[i - 1];
          i -= 1;
        };
        elements[index] := ?element;
      };

      _size += 1;
    };

    /// Inserts `buffer2` at `index`, and shifts all elements to the right of
    /// `index` over by size2. Traps if `index` is greater than size.
    ///
    /// Runtime: O(size)
    ///
    /// Amortized Space: O(1), Worst Case Space: O(size1 + size2)
    public func insertBuffer(index : Nat, buffer2 : Buffer2<X>) {
      if (index > _size) {
        Prim.trap "Buffer index out of bounds in insertBuffer";
      };

      let size2 = buffer2.size();
      let capacity = elements.size();

      // copy elements to new array and shift over in one pass
      if (_size + size2 > capacity) {
        let elements2 = Prim.Array_init<?X>(newCapacity(_size + size2), null);
        var i = 0;
        for (element in elements.vals()) {
          if (i == index) {
            i += size2;
          };
          elements2[i] := element;
          i += 1;
        };

        i := 0;
        while (i < size2) {
          elements2[i + index] := buffer2.getOpt(i);
          i += 1;
        };
        elements := elements2;
      } // just insert
      else {
        var i = index;
        while (i < index + size2) {
          if (i < _size) {
            elements[i + size2] := elements[i];
          };
          elements[i] := buffer2.getOpt(i - index);

          i += 1;
        };
      };

      _size += size2;
    };

    /// Sorts the elements in the buffer according to `compare`.
    /// Sort is deterministic, stable, and in-place.
    ///
    /// Runtime: O(size * log(size))
    ///
    /// Space: O(size)
    public func sort(compare : (X, X) -> Order.Order) {
      // Stable merge sort in a bottom-up iterative style
      if (_size == 0) {
        return;
      };
      let scratchSpace = Prim.Array_init<?X>(_size, null);

      let sizeDec = _size - 1 : Nat;
      var currSize = 1; // current size of the subarrays being merged
      // when the current size == size, the array has been merged into a single sorted array
      while (currSize < _size) {
        var leftStart = 0; // selects the current left subarray being merged
        while (leftStart < sizeDec) {
          let mid : Nat = if (leftStart + currSize - 1 : Nat < sizeDec) {
            leftStart + currSize - 1;
          } else { sizeDec };
          let rightEnd : Nat = if (leftStart + (2 * currSize) - 1 : Nat < sizeDec) {
            leftStart + (2 * currSize) - 1;
          } else { sizeDec };

          // Merge subarrays elements[leftStart...mid] and elements[mid+1...rightEnd]
          var left = leftStart;
          var right = mid + 1;
          var nextSorted = leftStart;
          while (left < mid + 1 and right < rightEnd + 1) {
            let leftOpt = elements[left];
            let rightOpt = elements[right];
            switch (leftOpt, rightOpt) {
              case (?leftElement, ?rightElement) {
                switch (compare(leftElement, rightElement)) {
                  case (#less or #equal) {
                    scratchSpace[nextSorted] := leftOpt;
                    left += 1;
                  };
                  case (#greater) {
                    scratchSpace[nextSorted] := rightOpt;
                    right += 1;
                  };
                };
              };
              case (_, _) {
                // only sorting non-null items
                Prim.trap "Malformed buffer in sort";
              };
            };
            nextSorted += 1;
          };
          while (left < mid + 1) {
            scratchSpace[nextSorted] := elements[left];
            nextSorted += 1;
            left += 1;
          };
          while (right < rightEnd + 1) {
            scratchSpace[nextSorted] := elements[right];
            nextSorted += 1;
            right += 1;
          };

          // Copy over merged elements
          var i = leftStart;
          while (i < rightEnd + 1) {
            elements[i] := scratchSpace[i];
            i += 1;
          };

          leftStart += 2 * currSize;
        };
        currSize *= 2;
      };
    };

    
    public func vals() : { next : () -> ?X } = object {
      // FIXME either handle modification to underlying list
      // or explicitly warn users in documentation
      var nextIndex = 0;
      public func next() : ?X {
        if (nextIndex >= _size) {
          return null;
        };
        let nextElement = elements[nextIndex];
        nextIndex += 1;
        nextElement;
      };
    };

    
    public func clone() : Buffer2<X> {
      let newBuffer = Buffer2<X>(elements.size());
      for (element in vals()) {
        newBuffer.add(element);
      };
      newBuffer;
    };

    public func upsize(len: Nat, initValue: X): Bool{
      if (_size >= len){
        return false;
      }
      else {
        var i = 0;
        while (i + _size < len ) {
          this.add(initValue);
          i += 1;
        };
      };
      return true;
    };
    

  // NEW  
  public func rotate_left(targets: Nat) {
    var b = this.clone();
    var i = 0;
    while (i + targets  < _size) {
      this.put(i, b.get(targets + i ));
      i += 1;
    };
    var j = 0;
    while (i < _size){
      this.put(i, b.get(j));
      j += 1;
      i += 1;
    };
  };

  // NEW
  public func rotate_right(targets: Nat) {
    var b = this.clone();
    var i = 0;
    while ( i < targets ) {
      this.put(i, b.get(_size - targets  + i));
      i += 1;
    };
    var j = 0;
    while (i < _size){
      this.put(i, b.get(j));
      j += 1;
      i += 1;
    };
  };

    public func toArray() : [X] =
    // immutable clone of array
    Prim.Array_tabulate<X>(
      _size,
      func(i : Nat) : X { get i },
    );

    
    public func toVarArray() : [var X] {
      if (_size == 0) { [var] } else {
        let newArray = Prim.Array_init<X>(_size, get 0);
        var i = 0;
        for (element in vals()) {
          newArray[i] := element;
          i += 1;
        };
        newArray;
      };
    };

    // NEW
    public func swap(m: Nat, n: Nat){
        let arr = this.toArray();
        var temp = arr[m];
        this.put(m, arr[n]);
        this.put(n, temp);
    };

    public func mid(): [X]{
      if (_size % 2 == 1){
        return Array.make(this.get((_size-1)/2));
      }
      else{
        return Array.append(Array.make(this.get(_size/2 - 1)), Array.make(this.get(_size/2)));
      };
    };

    // NEW
    public func split_permanent(ind: Nat): Buffer2<X>{
        if (ind < 0 or ind > this.size()) {
            Prim.trap "Index out of bounds in split";
            };

            let buffer1 = Buffer2<X>(newCapacity ind);
            let buffer2 = Buffer2<X>(newCapacity(this.size() - ind));

            var i = 0;
            while (i < ind) {
                buffer1.add(this.get(i));
                i += 1;
            };
            while (i < this.size()) {
                buffer2.add(this.get(i));
                i += 1;
            };
            var j = ind;
            while (this.size() > ind){
                let _res = this.removeLast();
            };
            return buffer2;
    };
  };

  
  public func isEmpty<X>(buffer : Buffer2<X>) : Bool = buffer.size() == 0;

  
  public func contains<X>(buffer : Buffer2<X>, element : X, equal : (X, X) -> Bool) : Bool {
    for (current in buffer.vals()) {
      if (equal(current, element)) {
        return true;
      };
    };

    false;
  };

  
  public func clone<X>(buffer : Buffer2<X>) : Buffer2<X> {
    let newBuffer = Buffer2<X>(buffer.capacity());
    for (element in buffer.vals()) {
      newBuffer.add(element);
    };
    newBuffer;
  };

  
  public func max<X>(buffer : Buffer2<X>, compare : (X, X) -> Order) : ?X {
    if (buffer.size() == 0) {
      return null;
    };

    var maxSoFar = buffer.get(0);
    for (current in buffer.vals()) {
      switch (compare(current, maxSoFar)) {
        case (#greater) {
          maxSoFar := current;
        };
        case _ {};
      };
    };

    ?maxSoFar;
  };

  
  public func min<X>(buffer : Buffer2<X>, compare : (X, X) -> Order) : ?X {
    if (buffer.size() == 0) {
      return null;
    };

    var minSoFar = buffer.get(0);
    for (current in buffer.vals()) {
      switch (compare(current, minSoFar)) {
        case (#less) {
          minSoFar := current;
        };
        case _ {};
      };
    };

    ?minSoFar;
  };

  // NEW
  public func range<X>(buffer: Buffer2<X>, compare: (X,X) -> Order, difference: (X,X) -> X) : ?X {
    if (buffer.size() == 0) {
      return null;
    };
    var minSoFar = buffer.get(0);
    for (current in buffer.vals()) {
      switch (compare(current, minSoFar)) {
        case (#less) {
          minSoFar := current;
        };
        case _ {};
      };
    };
    var maxSoFar = buffer.get(0);
    for (current in buffer.vals()) {
      switch (compare(current, maxSoFar)) {
        case (#greater) {
          maxSoFar := current;
        };
        case _ {};
      };
    };

    ?difference(maxSoFar, minSoFar);
  };

  
  public func equal<X>(buffer1 : Buffer2<X>, buffer2 : Buffer2<X>, equal : (X, X) -> Bool) : Bool {
    let size1 = buffer1.size();

    if (size1 != buffer2.size()) {
      return false;
    };

    var i = 0;
    while (i < size1) {
      if (not equal(buffer1.get(i), buffer2.get(i))) {
        return false;
      };
      i += 1;
    };

    true;
  };

  
  public func compare<X>(buffer1 : Buffer2<X>, buffer2 : Buffer2<X>, compare : (X, X) -> Order.Order) : Order.Order {
    let size1 = buffer1.size();
    let size2 = buffer2.size();
    let minSize = if (size1 < size2) { size1 } else { size2 };

    var i = 0;
    while (i < minSize) {
      switch (compare(buffer1.get(i), buffer2.get(i))) {
        case (#less) {
          return #less;
        };
        case (#greater) {
          return #greater;
        };
        case _ {};
      };
      i += 1;
    };

    if (size1 < size2) {
      #less;
    } else if (size1 == size2) {
      #equal;
    } else {
      #greater;
    };
  };

  
  public func toText<X>(buffer : Buffer2<X>, toText : X -> Text) : Text {
    let size : Int = buffer.size();
    var i = 0;
    var text = "";
    while (i < size - 1) {
      text := text # toText(buffer.get(i)) # ", "; // Text implemented as rope
      i += 1;
    };
    if (size > 0) {
      // avoid the trailing comma
      text := text # toText(buffer.get(i));
    };

    "[" # text # "]";
  };

  
  public func hash<X>(buffer : Buffer2<X>, hash : X -> Nat32) : Nat32 {
    let size = buffer.size();
    var i = 0;
    var accHash : Nat32 = 0;

    while (i < size) {
      accHash := Prim.intToNat32Wrap(i) ^ accHash ^ hash(buffer.get(i));
      i += 1;
    };

    accHash;
  };

  
  public func indexOf<X>(element : X, buffer : Buffer2<X>, equal : (X, X) -> Bool) : ?Nat {
    let size = buffer.size();
    var i = 0;
    while (i < size) {
      if (equal(buffer.get(i), element)) {
        return ?i;
      };
      i += 1;
    };

    null;
  };

  
  public func lastIndexOf<X>(element : X, buffer : Buffer2<X>, equal : (X, X) -> Bool) : ?Nat {
    let size = buffer.size();
    if (size == 0) {
      return null;
    };
    var i = size;
    while (i >= 1) {
      i -= 1;
      if (equal(buffer.get(i), element)) {
        return ?i;
      };
    };

    null;
  };

  
  public func indexOfBuffer<X>(subBuffer : Buffer2<X>, buffer : Buffer2<X>, equal : (X, X) -> Bool) : ?Nat {
    // Uses the KMP substring search algorithm
    // Implementation from: https://www.educative.io/answers/what-is-the-knuth-morris-pratt-algorithm
    let size = buffer.size();
    let subSize = subBuffer.size();
    if (subSize > size or subSize == 0) {
      return null;
    };

    // precompute lps
    let lps = Prim.Array_init<Nat>(subSize, 0);
    var i = 0;
    var j = 1;

    while (j < subSize) {
      if (equal(subBuffer.get(i), subBuffer.get(j))) {
        i += 1;
        lps[j] := i;
        j += 1;
      } else if (i == 0) {
        lps[j] := 0;
        j += 1;
      } else {
        i := lps[i - 1];
      };
    };

    // start search
    i := 0;
    j := 0;
    let subSizeDec = subSize - 1 : Nat; // hoisting loop invariant
    while (i < subSize and j < size) {
      if (equal(subBuffer.get(i), buffer.get(j)) and i == subSizeDec) {
        return ?(j - i);
      } else if (equal(subBuffer.get(i), buffer.get(j))) {
        i += 1;
        j += 1;
      } else {
        if (i != 0) {
          i := lps[i - 1];
        } else {
          j += 1;
        };
      };
    };

    null;
  };

  
  public func binarySearch<X>(element : X, buffer : Buffer2<X>, compare : (X, X) -> Order.Order) : ?Nat {
    var low = 0;
    var high = buffer.size();

    while (low < high) {
      let mid = (low + high) / 2;
      let current = buffer.get(mid);
      switch (compare(element, current)) {
        case (#equal) {
          return ?mid;
        };
        case (#less) {
          high := mid;
        };
        case (#greater) {
          low := mid + 1;
        };
      };
    };

    null;
  };

  
  public func subBuffer<X>(buffer : Buffer2<X>, start : Nat, length : Nat) : Buffer2<X> {
    let size = buffer.size();
    let end = start + length; // exclusive
    if (start >= size or end > size) {
      Prim.trap "Buffer index out of bounds in subBuffer";
    };

    let newBuffer = Buffer2<X>(newCapacity length);

    var i = start;
    while (i < end) {
      newBuffer.add(buffer.get(i));

      i += 1;
    };

    newBuffer;
  };

  
  public func isSubBufferOf<X>(subBuffer : Buffer2<X>, buffer : Buffer2<X>, equal : (X, X) -> Bool) : Bool {
    switch (indexOfBuffer(subBuffer, buffer, equal)) {
      case null subBuffer.size() == 0;
      case _ true;
    };
  };

  
  public func isStrictSubBufferOf<X>(subBuffer : Buffer2<X>, buffer : Buffer2<X>, equal : (X, X) -> Bool) : Bool {
    let subBufferSize = subBuffer.size();

    switch (indexOfBuffer(subBuffer, buffer, equal)) {
      case (?index) {
        index != 0 and index != (buffer.size() - subBufferSize : Nat) // enforce strictness
      };
      case null {
        subBufferSize == 0 and subBufferSize != buffer.size();
      };
    };
  };

  
  public func prefix<X>(buffer : Buffer2<X>, length : Nat) : Buffer2<X> {
    let size = buffer.size();
    if (length > size) {
      Prim.trap "Buffer index out of bounds in prefix";
    };

    let newBuffer = Buffer2<X>(newCapacity length);

    var i = 0;
    while (i < length) {
      newBuffer.add(buffer.get(i));
      i += 1;
    };

    newBuffer;
  };

  
  public func isPrefixOf<X>(prefix : Buffer2<X>, buffer : Buffer2<X>, equal : (X, X) -> Bool) : Bool {
    let sizePrefix = prefix.size();
    if (buffer.size() < sizePrefix) {
      return false;
    };

    var i = 0;
    while (i < sizePrefix) {
      if (not equal(buffer.get(i), prefix.get(i))) {
        return false;
      };

      i += 1;
    };

    return true;
  };

  
  public func isStrictPrefixOf<X>(prefix : Buffer2<X>, buffer : Buffer2<X>, equal : (X, X) -> Bool) : Bool {
    if (buffer.size() <= prefix.size()) {
      return false;
    };
    isPrefixOf(prefix, buffer, equal)
  };

  
  public func suffix<X>(buffer : Buffer2<X>, length : Nat) : Buffer2<X> {
    let size = buffer.size();

    if (length > size) {
      Prim.trap "Buffer index out of bounds in suffix";
    };

    let newBuffer = Buffer2<X>(newCapacity length);

    var i = size - length : Nat;
    while (i < size) {
      newBuffer.add(buffer.get(i));

      i += 1;
    };

    newBuffer;
  };

  
  public func isSuffixOf<X>(suffix : Buffer2<X>, buffer : Buffer2<X>, equal : (X, X) -> Bool) : Bool {
    let suffixSize = suffix.size();
    let bufferSize = buffer.size();
    if (bufferSize < suffixSize) {
      return false;
    };

    var i = bufferSize;
    var j = suffixSize;
    while (i >= 1 and j >= 1) {
      i -= 1;
      j -= 1;
      if (not equal(buffer.get(i), suffix.get(j))) {
        return false;
      };
    };

    return true;
  };

  
  public func isStrictSuffixOf<X>(suffix : Buffer2<X>, buffer : Buffer2<X>, equal : (X, X) -> Bool) : Bool {
    if (buffer.size() <= suffix.size()) {
      return false;
    };
    isSuffixOf(suffix, buffer, equal)
  };

  
  public func forAll<X>(buffer : Buffer2<X>, predicate : X -> Bool) : Bool {
    for (element in buffer.vals()) {
      if (not predicate element) {
        return false;
      };
    };

    true;
  };

  
  public func forSome<X>(buffer : Buffer2<X>, predicate : X -> Bool) : Bool {
    for (element in buffer.vals()) {
      if (predicate element) {
        return true;
      };
    };

    false;
  };

  
  public func forNone<X>(buffer : Buffer2<X>, predicate : X -> Bool) : Bool {
    for (element in buffer.vals()) {
      if (predicate element) {
        return false;
      };
    };

    true;
  };

  
  public func toArray<X>(buffer : Buffer2<X>) : [X] =
  // immutable clone of array
  Prim.Array_tabulate<X>(
    buffer.size(),
    func(i : Nat) : X { buffer.get(i) },
  );

  
  public func toVarArray<X>(buffer : Buffer2<X>) : [var X] {
    let size = buffer.size();
    if (size == 0) { [var] } else {
      let newArray = Prim.Array_init<X>(size, buffer.get(0));
      var i = 1;
      while (i < size) {
        newArray[i] := buffer.get(i);
        i += 1;
      };
      newArray;
    };
  };

  
  public func fromArray<X>(array : [X]) : Buffer2<X> {
    
    let newBuffer = Buffer2<X>(newCapacity(array.size()));

    for (element in array.vals()) {
      newBuffer.add(element);
    };

    newBuffer;
  };

  
  public func fromVarArray<X>(array : [var X]) : Buffer2<X> {
    let newBuffer = Buffer2<X>(newCapacity(array.size()));

    for (element in array.vals()) {
      newBuffer.add(element);
    };

    newBuffer;
  };

  
  public func fromIter<X>(iter : { next : () -> ?X }) : Buffer2<X> {
    let newBuffer = Buffer2<X>(DEFAULT_CAPACITY); // can't get size from `iter`

    for (element in iter) {
      newBuffer.add(element);
    };

    newBuffer;
  };

  
  public func trimToSize<X>(buffer : Buffer2<X>) {
    let size = buffer.size();
    if (size < buffer.capacity()) {
      buffer.reserve(size);
    };
  };

  
  public func map<X, Y>(buffer : Buffer2<X>, f : X -> Y) : Buffer2<Y> {
    let newBuffer = Buffer2<Y>(buffer.capacity());

    for (element in buffer.vals()) {
      newBuffer.add(f element);
    };

    newBuffer;
  };

  
  public func iterate<X>(buffer : Buffer2<X>, f : X -> ()) {
    for (element in buffer.vals()) {
      f element;
    };
  };

  
  public func mapEntries<X, Y>(buffer : Buffer2<X>, f : (Nat, X) -> Y) : Buffer2<Y> {
    let newBuffer = Buffer2<Y>(buffer.capacity());

    var i = 0;
    let size = buffer.size();
    while (i < size) {
      newBuffer.add(f(i, buffer.get(i)));
      i += 1;
    };

    newBuffer;
  };

 
  public func mapFilter<X, Y>(buffer : Buffer2<X>, f : X -> ?Y) : Buffer2<Y> {
    let newBuffer = Buffer2<Y>(buffer.capacity());

    for (element in buffer.vals()) {
      switch (f element) {
        case (?element) {
          newBuffer.add(element);
        };
        case _ {};
      };
    };

    newBuffer;
  };

  /// Creates a new buffer by applying `f` to each element in `buffer`.
  /// If any invocation of `f` produces an `#err`, returns an `#err`. Otherwise
  /// Returns an `#ok` containing the new buffer.
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func mapResult<X, Y, E>(buffer : Buffer2<X>, f : X -> Result.Result<Y, E>) : Result.Result<Buffer2<Y>, E> {
    let newBuffer = Buffer2<Y>(buffer.capacity());

    for (element in buffer.vals()) {
      switch (f element) {
        case (#ok result) {
          newBuffer.add(result);
        };
        case (#err e) {
          return #err e;
        };
      };
    };

    #ok newBuffer;
  };

  /// Creates a new buffer by applying `k` to each element in `buffer`,
  /// and concatenating the resulting buffers in order. This operation
  /// is similar to what in other functional languages is known as monadic bind.
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func chain<X, Y>(buffer : Buffer2<X>, k : X -> Buffer2<Y>) : Buffer2<Y> {
    let newBuffer = Buffer2<Y>(buffer.size() * 4);

    for (element in buffer.vals()) {
      newBuffer.append(k element);
    };

    newBuffer;
  };

  /// Collapses the elements in `buffer` into a single value by starting with `base`
  /// and progessively combining elements into `base` with `combine`. Iteration runs
  /// left to right.
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `combine` runs in O(1) time and space.
  public func foldLeft<A, X>(buffer : Buffer2<X>, base : A, combine : (A, X) -> A) : A {
    var accumulation = base;

    for (element in buffer.vals()) {
      accumulation := combine(accumulation, element);
    };

    accumulation;
  };

  /// Collapses the elements in `buffer` into a single value by starting with `base`
  /// and progessively combining elements into `base` with `combine`. Iteration runs
  /// right to left.
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `combine` runs in O(1) time and space.
  public func foldRight<X, A>(buffer : Buffer2<X>, base : A, combine : (X, A) -> A) : A {
    let size = buffer.size();
    if (size == 0) {
      return base;
    };
    var accumulation = base;

    var i = size;
    while (i >= 1) {
      i -= 1; // to avoid Nat underflow, subtract first and stop iteration at 1
      accumulation := combine(buffer.get(i), accumulation);
    };

    accumulation;
  };

  /// Returns the first element of `buffer`. Traps if `buffer` is empty.
  ///
  /// Runtime: O(1)
  ///
  /// Space: O(1)
  public func first<X>(buffer : Buffer2<X>) : X = buffer.get(0);

  /// Returns the last element of `buffer`. Traps if `buffer` is empty.
  ///
  /// Runtime: O(1)
  ///
  /// Space: O(1)
  public func last<X>(buffer : Buffer2<X>) : X = buffer.get(buffer.size() - 1);

  /// Returns a new buffer with capacity and size 1, containing `element`.
  ///
  /// Runtime: O(1)
  ///
  /// Space: O(1)
  public func make<X>(element : X) : Buffer2<X> {
    let newBuffer = Buffer2<X>(1);
    newBuffer.add(element);
    newBuffer;
  };

  /// Reverses the order of elements in `buffer`.
  ///
  /// Runtime: O(size)
  ///
  // Space: O(1)
  public func reverse<X>(buffer : Buffer2<X>) {
    let size = buffer.size();
    if (size == 0) {
      return;
    };

    var i = 0;
    var j = size - 1 : Nat;
    var temp = buffer.get(0);
    while (i < size / 2) {
      temp := buffer.get(j);
      buffer.put(j, buffer.get(i));
      buffer.put(i, temp);
      i += 1;
      j -= 1;
    };
  };

  /// Merges two sorted buffers into a single sorted buffer, using `compare` to define
  /// the ordering. The final ordering is stable. Behavior is undefined if either
  /// `buffer1` or `buffer2` is not sorted.
  ///
  /// Runtime: O(size1 + size2)
  ///
  /// Space: O(size1 + size2)
  ///
  /// *Runtime and space assumes that `compare` runs in O(1) time and space.
  public func merge<X>(buffer1 : Buffer2<X>, buffer2 : Buffer2<X>, compare : (X, X) -> Order) : Buffer2<X> {
    let size1 = buffer1.size();
    let size2 = buffer2.size();

    let newBuffer = Buffer2<X>(newCapacity(size1 + size2));

    var pointer1 = 0;
    var pointer2 = 0;

    while (pointer1 < size1 and pointer2 < size2) {
      let current1 = buffer1.get(pointer1);
      let current2 = buffer2.get(pointer2);

      switch (compare(current1, current2)) {
        case (#less) {
          newBuffer.add(current1);
          pointer1 += 1;
        };
        case _ {
          newBuffer.add(current2);
          pointer2 += 1;
        };
      };
    };

    while (pointer1 < size1) {
      newBuffer.add(buffer1.get(pointer1));
      pointer1 += 1;
    };

    while (pointer2 < size2) {
      newBuffer.add(buffer2.get(pointer2));
      pointer2 += 1;
    };

    newBuffer;
  };

  public func dedup<X>(buffer: Buffer2<X>, compare : (X, X) -> Order) : Buffer2<X>{
    let size = buffer.size();
    if (size == 0) {
      return buffer;
    };
    var resultBuffer = Buffer2<X>(size);
    var i = 0;
    resultBuffer.add(buffer.get(0));
    while (i + 1 < size) {
      if (compare(buffer.get(i), buffer.get(i + 1)) != #equal) {
        resultBuffer.add(buffer.get(i + 1));
      };
      i += 1;
    };
    resultBuffer;
  };

  public func removeDuplicates<X>(buffer : Buffer2<X>, compare : (X, X) -> Order) {
    let size = buffer.size();
    let indices = Prim.Array_tabulate<(Nat, X)>(size, func i = (i, buffer.get(i)));
    // Sort based on element, while carrying original index information
    // This groups together the duplicate elements
    let sorted = Array.sort<(Nat, X)>(indices, func(pair1, pair2) = compare(pair1.1, pair2.1));
    let uniques = Buffer2<(Nat, X)>(size);

    // Iterate over elements
    var i = 0;
    while (i < size) {
      var j = i;
      // Iterate over duplicate elements, and find the smallest index among them (for stability)
      var minIndex = sorted[j];
      label duplicates while (j < (size - 1 : Nat)) {
        let pair1 = sorted[j];
        let pair2 = sorted[j + 1];
        switch (compare(pair1.1, pair2.1)) {
          case (#equal) {
            if (pair2.0 < pair1.0) {
              minIndex := pair2;
            };
            j += 1;
          };
          case _ {
            break duplicates;
          };
        };
      };

      uniques.add(minIndex);
      i := j + 1;
    };

    // resort based on original ordering and place back in buffer
    uniques.sort(
      func(pair1, pair2) {
        if (pair1.0 < pair2.0) {
          #less;
        } else if (pair1.0 == pair2.0) {
          #equal;
        } else {
          #greater;
        };
      },
    );

    buffer.clear();
    buffer.reserve(uniques.size());
    for (element in uniques.vals()) {
      buffer.add(element.1);
    };
  };

  /// Splits `buffer` into a pair of buffers where all elements in the left
  /// buffer satisfy `predicate` and all elements in the right buffer do not.
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `predicate` runs in O(1) time and space.
  public func partition<X>(buffer : Buffer2<X>, predicate : X -> Bool) : (Buffer2<X>, Buffer2<X>) {
    let size = buffer.size();
    let trueBuffer = Buffer2<X>(size);
    let falseBuffer = Buffer2<X>(size);

    for (element in buffer.vals()) {
      if (predicate element) {
        trueBuffer.add(element);
      } else {
        falseBuffer.add(element);
      };
    };

    (trueBuffer, falseBuffer);
  };

  
  public func split<X>(buffer : Buffer2<X>, index : Nat) : (Buffer2<X>, Buffer2<X>) {
    let size = buffer.size();

    if (index < 0 or index > size) {
      Prim.trap "Index out of bounds in split";
    };

    let buffer1 = Buffer2<X>(newCapacity index);
    let buffer2 = Buffer2<X>(newCapacity(size - index));

    var i = 0;
    while (i < index) {
      buffer1.add(buffer.get(i));
      i += 1;
    };
    while (i < size) {
      buffer2.add(buffer.get(i));
      i += 1;
    };

    (buffer1, buffer2);
  };

  
  public func chunk<X>(buffer : Buffer2<X>, size : Nat) : Buffer2<Buffer2<X>> {
    if (size == 0) {
      Prim.trap "Chunk size must be non-zero in chunk";
    };

    // ceil(buffer.size() / size)
    let newBuffer = Buffer2<Buffer2<X>>((buffer.size() + size - 1) / size);

    var newInnerBuffer = Buffer2<X>(newCapacity size);
    var innerSize = 0;
    for (element in buffer.vals()) {
      if (innerSize == size) {
        newBuffer.add(newInnerBuffer);
        newInnerBuffer := Buffer2<X>(newCapacity size);
        innerSize := 0;
      };
      newInnerBuffer.add(element);
      innerSize += 1;
    };
    if (innerSize > 0) {
      newBuffer.add(newInnerBuffer);
    };

    newBuffer;
  };

  /// Groups equal and adjacent elements in the list into sub lists.
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `equal` runs in O(1) time and space.
  public func groupBy<X>(buffer : Buffer2<X>, equal : (X, X) -> Bool) : Buffer2<Buffer2<X>> {
    let size = buffer.size();
    let newBuffer = Buffer2<Buffer2<X>>(size);
    if (size == 0) {
      return newBuffer;
    };

    var i = 0;
    var baseElement = buffer.get(0);
    var newInnerBuffer = Buffer2<X>(size);
    while (i < size) {
      let element = buffer.get(i);

      if (equal(baseElement, element)) {
        newInnerBuffer.add(element);
      } else {
        newBuffer.add(newInnerBuffer);
        baseElement := element;
        newInnerBuffer := Buffer2<X>(size - i);
        newInnerBuffer.add(element);
      };
      i += 1;
    };
    if (newInnerBuffer.size() > 0) {
      newBuffer.add(newInnerBuffer);
    };

    newBuffer;
  };

  
  public func flatten<X>(buffer : Buffer2<Buffer2<X>>) : Buffer2<X> {
    let size = buffer.size();
    if (size == 0) {
      return Buffer2<X>(0);
    };

    let newBuffer = Buffer2<X>(
      if (buffer.get(0).size() != 0) {
        newCapacity(buffer.get(0).size() * size);
      } else {
        newCapacity(size);
      },
    );

    for (innerBuffer in buffer.vals()) {
      for (innerElement in innerBuffer.vals()) {
        newBuffer.add(innerElement);
      };
    };

    newBuffer;
  };

  
  public func zip<X, Y>(buffer1 : Buffer2<X>, buffer2 : Buffer2<Y>) : Buffer2<(X, Y)> {
    // compiler should pull lamda out as a static function since it is fully closed
    zipWith<X, Y, (X, Y)>(buffer1, buffer2, func(x, y) = (x, y));
  };

  
  public func zipWith<X, Y, Z>(buffer1 : Buffer2<X>, buffer2 : Buffer2<Y>, zip : (X, Y) -> Z) : Buffer2<Z> {
    let size1 = buffer1.size();
    let size2 = buffer2.size();
    let minSize = if (size1 < size2) { size1 } else { size2 };

    var i = 0;
    let newBuffer = Buffer2<Z>(newCapacity minSize);
    while (i < minSize) {
      newBuffer.add(zip(buffer1.get(i), buffer2.get(i)));
      i += 1;
    };
    newBuffer;
  };

  
  public func takeWhile<X>(buffer : Buffer2<X>, predicate : X -> Bool) : Buffer2<X> {
    let newBuffer = Buffer2<X>(buffer.size());

    for (element in buffer.vals()) {
      if (not predicate element) {
        return newBuffer;
      };
      newBuffer.add(element);
    };

    newBuffer;
  };

  
  public func dropWhile<X>(buffer : Buffer2<X>, predicate : X -> Bool) : Buffer2<X> {
    let size = buffer.size();
    let newBuffer = Buffer2<X>(size);

    var i = 0;
    var take = false;
    label iter for (element in buffer.vals()) {
      if (not (take or predicate element)) {
        take := true;
      };
      if (take) {
        newBuffer.add(element);
      };
    };
    newBuffer;
  };

  // NEW
  public func split_first<X>(buffer: Buffer2<X>): ?(X, Buffer2<X>){
    let size = buffer.size();
    if (size == 0){
      return null;
    };

    if (1 > size) {
      Prim.trap "Index out of bounds in split";
    };

    
    let buffer2 = Buffer2<X>(newCapacity(size - 1));

    var i = 1;
    while (i < size) {
      buffer2.add(buffer.get(i));
      i += 1;
    };
    

    ?(buffer.get(0), buffer2);
  };

// NEW
    public func truncate<X>(buffer: Buffer2<X>, len: Nat): Buffer2<X>{
        if (buffer.size() < len){
            return buffer;
        }
        else{
            var buff_2 = buffer;
            while (buff_2.size() > len){
                var _res = buff_2.removeLast();
            };
            return buff_2;
        };
        

    };

    // NEW
    public func fill<X>(size: Nat, el: X): Buffer2<X> {
      var b = Buffer2<X>(size);
      var i = 0;
      while (i < size){
        b.add(el);
        i += 1;
      };
      return b;
    };

    // NEW
    public func hashmapToBuffer<X, Y>(hashmap: HashMap.HashMap<X, Y>): Buffer2<(X, Y)> {
        var b = Buffer2<(X,Y)>(hashmap.size());
        for (e in hashmap.entries()){
          b.add(e);
        };
        return b;
    };

    // NEW
    public func intersection<X>(b1: Buffer2<X>, b2: Buffer2<X>, compare : (X, X) -> Order): Buffer2<X> {
        if (b1.size() > b2.size()){
          var big = b1.clone();
          var small = b2.clone();
          var i = 0;
          var j = 0;
          var intBuffer = Buffer2<X>(small.size());
          while (i < big.size()){
            while (j < small.size()){
              switch (compare(small.get(j), big.get(i))) {
                case (#equal) {
                  intBuffer.add(small.get(j));
                  let _res = small.remove(j);
                  j := small.size();
                };
                case _ {};
              };
              
              
              j += 1;
            };
            i += 1;
            j := 0;
          };
          return intBuffer;

        }
        else {
          var small = b1.clone();
          var big = b2.clone();
          var i = 0;
          var j = 0;
          var intBuffer = Buffer2<X>(small.size());
          while (i < big.size()){
            while (j < small.size()){
              switch (compare(small.get(j), big.get(i))) {
                case (#equal) {
                  intBuffer.add(small.get(j));
                  let _res = small.remove(j);
                  j := small.size();
                };
                case _ {};
              };
              
              
              j += 1;
            };
            i += 1;
            j := 0;
          };
          return intBuffer;

        };
    };
    

};
