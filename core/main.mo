import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Debug "mo:base/Debug";
import Analytics "analytics";

actor {
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
};