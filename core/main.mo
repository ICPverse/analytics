import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Debug "mo:base/Debug";
import Analytics "analytics";
import Buffer "Buffer2";
import Nat32 "mo:base/Nat32";
import Complex "../types/Complex";

actor {
    public type Complex = Analytics.Complex;

    public func meanVal(arr : [Float]): async ?Float{
        return Analytics.mean(arr);
    };

    public func weightedMeanVal(arr : [Float], minWeight : Float, weightIncrement : Float): async ?Float{
        return Analytics.weightedMean(arr,minWeight,weightIncrement);
    };

    public func geometricMeanVal(arr : [Float]): async Float{
        return Analytics.geometricMean(arr);
    };

    public func medianVal(arr : [Float]): async Float{
        return Analytics.median(arr);
    };

    public func correlationVal(arr1: [Float], arr2: [Float]): async ?Float{
        return Analytics.correlation(arr1,arr2);
    };

    public func linReg(arr1: [Float], arr2: [Float]): async ?(Float,Float){
        return Analytics.linearRegression(arr1,arr2);
    };

    public func kNN(arr: [(Float, Float, Text)], inputVal: (Float, Float), classifications: [Text]): async ?Text{
        return Analytics.kNearestNeighbors2(arr, inputVal, classifications);
    };

    public func addComplex(c1: (Float, Float), c2: (Float, Float)): async Complex{
        let _c1 : Complex = {
            re = c1.0;
            im = c1.1;
        };
        let _c2 : Complex = {
            re = c2.0;
            im = c2.1;
        };
        return await Analytics.complex_sum(_c1, _c2);

    };

    public func inverse(c: (Float, Float)) : async Complex {
        let _c : Complex = {
            re = c.0;
            im = c.1;
        };
        return await Analytics.complex_inverse(_c);
    };

    public func fft_input_permutation(length: Nat32) :  async [Nat] {
        return  Analytics.fast_fourier_transform_input_permutation(length);
    };

    

    public func check_fft(r: [(Float, Float)]): async (){
        
        var i = 0;
        var c = Buffer.Buffer2<Complex>(r.size()); 
        
        while (i < r.size()){
            var c_el : Complex = {
                re = r[i].0;
                im = r[i].1;
            };
            c.add(c_el);
            i += 1;
        };
        
        let c_res = Analytics.fast_fourier_transform(c);

        switch c_res{
            case null {
                Debug.print("The number of points needs to be a power of 2");
            };
            case (?buff) {
                Debug.print(debug_show buff.get(r.size()/2));
            };
        };
        
    };

    public func testPolynomial(arr: [Float], value: Float): async Float {
        return  Analytics.poly(arr, value);
    };

    public func testCosh(x: Float): async Float {
        return Analytics.cosh(x);
    };

    //Make sure to input an array at least with 3 elements
    public func testRotateLeft(arr: [Nat]): async [Nat]{
        var i = 0;
        var c = Buffer.Buffer2<Nat>(arr.size()); 
        
        while (i < arr.size()){
            
            c.add(arr[i]);
            i += 1;
        };
        c.rotate_left(3);
        return c.toArray();
    };

    //Make sure to input an array at least with 2 elements
    public func testRotateRight(arr: [Nat]): async [Nat]{
        var i = 0;
        var c = Buffer.Buffer2<Nat>(arr.size()); 
        
        while (i < arr.size()){
            
            c.add(arr[i]);
            i += 1;
        };
        c.rotate_right(2);
        return c.toArray();
    };

    public func testMidBuffer(): async (){
        var arr = [1, 2, 3, 4, 5, 6];
        var i = 0;
        var c = Buffer.Buffer2<Nat>(arr.size()); 
        
        while (i < arr.size()){
            
            c.add(arr[i]);
            i += 1;
        };

        let middle = c.mid();
        Debug.print(debug_show middle);
    };

    public func testIntersectionBuffer(): async (){
        var arr1 = [1, 2, 4, 4, 5, 6, 9];
        var i = 0;
        var c = Buffer.Buffer2<Nat>(arr1.size()); 
        
        while (i < arr1.size()){
            
            c.add(arr1[i]);
            i += 1;
        };
        var arr2 = [3, 4, 4, 5, 6, 7];
        i := 0;
        var c2 = Buffer.Buffer2<Nat>(arr2.size()); 
        
        while (i < arr2.size()){
            
            c2.add(arr2[i]);
            i += 1;
        };

        let res = Buffer.intersection<Nat>(c, c2, Nat.compare);

        Debug.print(debug_show res.toArray());

        
    };

    public func testRand(scope: Nat8): async Nat {
        return Analytics.Rand2(scope);
    };

    public func testFill(size: Nat, el: Nat): async [Nat] {
        return Buffer.fill<Nat>(size, el).toArray();
    };
};