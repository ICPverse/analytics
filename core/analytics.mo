import Array "mo:base/Array";
import Float "mo:base/Float";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Float";
import Debug "mo:base/Debug";

module{

    public type Complex = {
         re: Float;
         im: Float;
    };

    public func add_complex(c1: Complex, c2: Complex): async Complex {
        return {
            re = c1.re + c2.re;
            im = c1.im + c2.im;
        };
    };

    public func subtract_complex(c1: Complex, c2: Complex): async Complex {
        return {
            re = c1.re - c2.re;
            im = c1.im - c2.im;
        };
    };

    public func multiply_complex(c1: Complex, c2: Complex): async Complex {
        return {
            re = (c1.re * c2.re) - (c1.im * c2.im);
            im = (c1.im * c2.re) + (c1.re * c2.im);
        };
    };

    public func square_norm(c: Complex): async Float {
        return (c.re ** 2) + (c.im ** 2);
    };

    public func norm(c: Complex): async Float {
        return ((c.re ** 2) + (c.im ** 2)) ** (0.5);
    };

    public func inverse_complex(c: Complex): async Complex {
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

    


};