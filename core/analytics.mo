import Array "mo:base/Array";
import Float "mo:base/Float";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Float";
import Debug "mo:base/Debug";
import Nat32 "mo:base/Nat32";
import Buffer "Buffer2";

module{

    public func cos(x: Float): Float {
        var f = x;
        if (x < 0.00){
            f := x * -1.0;
        };
        
        return 1.0 - (f**2)/2.0 + (f**4)/24.0 - (f**6)/720.0 + (f**8)/40320.0 - (f**10)/3628800.0;
    };

    public func sin(x: Float): Float {
        let f = x;
        
        
        return f - (f**3)/6.0 + (f**5)/120.0 - (f**7)/5040.0 + (f**9)/362880.0 - (f**11)/39916800.0;
    };
    
    public type Complex = {
         re: Float;
         im: Float;
    };

    public func add_complex(c1: Complex, c2: Complex):  Complex {
        return {
            re = c1.re + c2.re;
            im = c1.im + c2.im;
        };
    };

    public func subtract_complex(c1: Complex, c2: Complex):  Complex {
        return {
            re = c1.re - c2.re;
            im = c1.im - c2.im;
        };
    };

    public func multiply_complex(c1: Complex, c2: Complex):  Complex {
        return {
            re = (c1.re * c2.re) - (c1.im * c2.im);
            im = (c1.im * c2.re) + (c1.re * c2.im);
        };
    };

    public func complex_sum(c1: Complex, c2: Complex):  async Complex {
        return {
            re = c1.re + c2.re;
            im = c1.im + c2.im;
        };
    };

    public func complex_diff(c1: Complex, c2: Complex):  async Complex {
        return {
            re = c1.re - c2.re;
            im = c1.im - c2.im;
        };
    };

    public func complex_prod(c1: Complex, c2: Complex): async Complex {
        return {
            re = (c1.re * c2.re) - (c1.im * c2.im);
            im = (c1.im * c2.re) + (c1.re * c2.im);
        };
    };

    public func square_norm(c: Complex):  Float {
        return (c.re ** 2) + (c.im ** 2);
    };

    public func norm(c: Complex):  Float {
        return ((c.re ** 2) + (c.im ** 2)) ** (0.5);
    };

    public func inverse_complex(c: Complex):  Complex {
        let sq_norm : Float = (c.re ** 2) + (c.im ** 2);
        return {
            re = c.re/sq_norm;
            im = - c.im/sq_norm;
        };
    };

    public func complex_square_norm(c: Complex): async Float {
        return (c.re ** 2) + (c.im ** 2);
    };

    public func complex_norm(c: Complex): async Float {
        return ((c.re ** 2) + (c.im ** 2)) ** (0.5);
    };

    public func complex_inverse(c: Complex): async Complex {
        let sq_norm : Float = (c.re ** 2) + (c.im ** 2);
        return {
            re = c.re/sq_norm;
            im = - c.im/sq_norm;
        };
    };

    
    public func mean(arr : [Float]): ?Float{
        var sum : Float = 0.0;
        for (item in arr.vals()){
            sum += item;
        };
        let size : Int = arr.size();
        if (arr.size() == 0){
            return null;
        }
        else{
            return ?(Float.div(sum,Float.fromInt(size)));
        };
    };

    public func weightedMean(arr : [Float], minWeight : Float, weightIncrement : Float) : ?Float{
        var sum : Float = 0.0;
        var deno : Float = 0.0;
        var i : Float = 1.0;
        for (item in arr.vals()){
            sum += item*minWeight*(weightIncrement**(i-1));
            deno += minWeight*(weightIncrement**(i-1));
            i += 1;
        };
        if (arr.size() == 0){
            return null;
        }
        else {
            return ?(sum/deno);
        };

    };

    public func geometricMean(arr : [Float]): Float{
        if (arr.size() == 0){
            return 0.000;
        };
        var product : Float = 1.0;
        for (item in arr.vals()){
            product *= item;
        };
        let size : Int = arr.size();
        
        return product**(1/Float.fromInt(size));
    };

    public func median(arr : [Float]): Float{
        var newArr : [var Float] = Array.thaw(arr);
        Array.sortInPlace<Float>(newArr, Float.compare);
        
        if (arr.size() % 2 == 1){
            return newArr[(arr.size() - 1)/2];
        }
        else {
            var x = newArr[(arr.size()/2 - 1)];
            var y = newArr[arr.size()/2];
            
            return (x + y)/2;
        };

    };

    public func rootMeanSquare(arr: [Float]): ?Float{
        var sum : Float = 0.0;
        for (item in arr.vals()){
            sum += item*item;
        };
        let size : Int = arr.size();
        if (size == 0){
            return null;
        }
        else{
            return ?((Float.div(sum,Float.fromInt(size)))**0.5);
        };
    };

    public func correlation(arr1: [Float], arr2: [Float]): ?Float{
        if (arr1.size() != arr2.size()){
            return null;
        };
        let mean1_ = mean(arr1);
        let mean2_ = mean(arr2);
        var mean1: Float = 0.0;
        var mean2: Float = 0.0;
        switch mean1_{
            case null{
                return null;
            };
            case (?float){
                mean1 := float;
            };
        };
        switch mean2_{
            case null{
                return null;
            };
            case (?float){
                mean2 := float;
            };
        };
        var num : Float = 0.0;
        var den1 : Float = 0.0;
        var den2 : Float = 0.0;
        var i = 0;
        while (i < arr1.size()){
            num += ((arr1[i]-mean1)*(arr2[i]-mean2));
            den1 += (arr1[i]-mean1)**2;
            den2 += (arr2[i]-mean2)**2;
            i += 1;
        };
        let den : Float = (den1 * den2)**(0.5);
        if (den == 0){
            return null;
        }
        else {
            return ?(num/den);
        };
    };

    public func linearRegression(arr1: [Float], arr2: [Float]): ?(Float, Float){
        if (arr1.size() != arr2.size()){
            return null;
        };
        
        var i = 0;
        let size : Int = arr1.size();
        if (size == 0){
            return null;
        };
        var sumX = 0.0;
        var sumX2 = 0.0;
        var sumY = 0.0;
        var sumXY = 0.0;
        while (i < arr1.size()){
            sumX := sumX + arr1[i];
            sumX2 := sumX2 + arr1[i]*arr1[i];
            sumY := sumY + arr2[i];
            sumXY := sumXY + arr1[i]*arr2[i];
            i += 1;
        };
        var b: Float = (Float.fromInt(size)*sumXY-sumX*sumY)/(Float.fromInt(size)*sumX2-sumX*sumX);
        var a: Float = (sumY - b*sumX)/Float.fromInt(size);
        // best fit equation being a + b*x
        return ?(a,b);

    };

    public func kNearestNeighbors2(arr: [(Float, Float, Text)], inputVal: (Float, Float), classifications: [Text]): ?Text{
        if (arr.size() == 0){
            return null;

        };
        var i: Nat = 0;
        var d: [var (Int, Float)] = Array.thaw([]);
        var s1: Float = 0.0;
        var s2: Float = 0.0;
        var k1 = 0.0;
        var k2 = 0.0;
        while (i < arr.size()){
            s1 := s1 + arr[i].0;
            s2 := s2 + arr[i].1;
            i += 1;
        };
        i := 0;
        while(i < arr.size()) {
            var ind: Int = i;
            k1 := (arr[i].0 - inputVal.0)/s1;
            k2 := (arr[i].1 - inputVal.1)/s2;
            // Note: This is a simplified implementation using normalization with equal weight for the trait columns
            // More advanced model logic can be easily built in its place
            if (k1 + k2 < 0) {
                d := Array.thaw(Array.append(Array.freeze(d), Array.make((ind, -k1 -k2))));
            

            } 
            else {
               d := Array.thaw(Array.append(Array.freeze(d), Array.make((ind, k1 + k2))));
               
            };
            i += 1;
        };
        i := 0;
        var l: Int = 0;
        var j = 0;
        var k = 0.0;
        while(i < arr.size()) {
            while(j + 1 < arr.size()) {
                if (d[j].1 > d[j + 1].1) {
                    k := d[j].1;
                    d[j] := (d[j].0,d[j+1].1);
                    d[j+1] := (d[j+1].0, k);
                    
            
                    l := d[j].0;
                    d[j] := (d[j+1].0, d[j].1);
                    d[j+1] := (l,d[j+1].1);
                    
                };
                j += 1;
            };
            i += 1;
            j := 0;
        };
        var classificationCount : [var Nat] = Array.thaw([]);
        i := 0;
        while (i < classifications.size()){
            classificationCount := Array.thaw(Array.append(Array.freeze(classificationCount), Array.make(0)));
            i += 1;
        };
        i := 0;
        j := 0;
        while(i < arr.size()) {
            l := d[i].0;
            while (j < classifications.size()){
                if (arr[i].2 ==  classifications[j]) {
                    classificationCount[j] += 1;
                };
                j += 1;
            };
            i += 1;
            j := 0;
    
        };

        i := 0;
        var max = 0;
        var maxInd = 0;
        while (i < classificationCount.size()){
            if (classificationCount[i] > max){
                max := classificationCount[i];
                maxInd := i;
            };
            i += 1;
        };




        return (?classifications[maxInd]);
    };

    func  bitReverse(_n: Nat32, bits: Nat32): Nat32 {
        var reversedN: Nat32 = _n;
        var count = bits - 1;
        var n = _n;
        n >>= 1;
        while (n > 0) {
            reversedN := (reversedN << 1) | (n & 1);
            count -= 1;
            n >>= 1;
        };

        return ((reversedN << count) & ((1 << bits) - 1));
    };
    

    public func fast_fourier_transform_input_permutation(length: Nat32) : [Nat] {
        
        var length_nat = Nat32.toNat(length);
        var result = Buffer.Buffer2<Nat>(length_nat);
        
        var i = 0;
        while (i < length_nat) {
            result.add(i);
            i += 1;
        };
        var reverse: Nat32 = 0;
        var position: Nat32 = 1;
        
        while (position < length) {
            var bit = length >> 1;
            while (bit & reverse != 0) {
                reverse ^= bit;
                bit >>= 1;
            };
            reverse ^= bit;
            // This is equivalent to adding 1 to a reversed number
            if (position < reverse) {
                // Only swap each element once
                var temp = result.toArray()[Nat32.toNat(position)];
                result.put(Nat32.toNat(position), result.toArray()[Nat32.toNat(reverse)]);
                result.put(Nat32.toNat(reverse), temp);
                
            };
            position += 1;
        };
        return result.toArray();
    };

    

    //Binary Approach that Works for Number of Points that are a Power of 2
    public func fourier_fast_transform(b: Buffer.Buffer2<Complex>) : ?Buffer.Buffer2<Complex>{
        var buffer = b.clone();
        var bits : Nat32 = 0;
        while (Nat32.toNat(2**bits) < buffer.size()){
            bits += 1;
        };
        if (Nat32.toNat(2**bits) != buffer.size()){
            return null;
        };
        
        
        var j: Nat32 = 1;
        while (Nat32.toNat(j) < buffer.size() / 2) {

            var swapPos = bitReverse(j, bits);
            var temp = buffer.get(Nat32.toNat(j));
            buffer.put(Nat32.toNat(j), buffer.get(Nat32.toNat(swapPos)));
            buffer.put(Nat32.toNat(swapPos), temp);
            j += 1;
        };
        var N : Nat32= 2;
        while (Nat32.toNat(N) <= buffer.size()) {
            var i = 0;
            while (i < buffer.size()) {
                var k = 0;
                while (k < Nat32.toNat(N) / 2) {

                    var evenIndex = i + k;
                    var oddIndex = i + k + (Nat32.toNat(N) / 2);
                    var even = buffer.get(evenIndex);
                    var odd = buffer.get(oddIndex);

                    var term: Float = (-2.0 * 3.1416 * Float.fromInt(k)) /  Float.fromInt(Nat32.toNat(N));
                    var exp :  Complex= {
                        re=cos(term);
                        im= sin(term);
                    };
                    exp := multiply_complex(exp, odd);

                    buffer.put(evenIndex, add_complex(even, exp));
                    buffer.put(oddIndex, subtract_complex(even, exp));
                    k += 1;
                };
                i += Nat32.toNat(N);
            };
            N <<= 1;
        };
        return ?buffer;
    };

};