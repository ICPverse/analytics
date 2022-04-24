import Array "mo:base/Array";
import Float "mo:base/Float";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Float";
import Debug "mo:base/Debug";

module{

    
    public func mean(arr : [Float]): Float{
        var sum : Float = 0.0;
        for (item in arr.vals()){
            sum += item;
        };
        let size : Int = arr.size();
        
        return Float.div(sum,Float.fromInt(size));
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

    public func correlation(arr1: [Float], arr2: [Float]): ?Float{
        if (arr1.size() != arr2.size()){
            return null;
        };
        let mean1 = mean(arr1);
        let mean2 = mean(arr2);
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


};