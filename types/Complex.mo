import Array "mo:base/Array";
import Float "mo:base/Float";

module {

    public class Complex(real: Float, imaginary: Float) = this {
        var re: Float = real;
        var im: Float = imaginary;

        public func getReal(): Float {
            return re;
        };

        public func getImaginary(): Float {
            return im;
        };

        public func getAll(): (Float, Float) {
            return (re, im);
        };

        public func square_norm():  Float {
            return (re ** 2) + (im ** 2);
        };

        public func norm():  Float {
            return ((re ** 2) + (im ** 2)) ** (0.5);
        };

        public func inverse():  Complex {
            let sq_norm : Float = (re ** 2) + (im ** 2);
            assert sq_norm != 0.00;
            let r = re/sq_norm;
            let i = - im/sq_norm;
            return  Complex(r, i);          
            
        };

        public func conjugate(): Complex {
            return Complex(re, -im);
        };
    };

    public func sum(c1: Complex, c2: Complex): Complex {
        let re = c1.getReal() + c2.getReal();
        let im = c1.getImaginary() + c2.getImaginary();
        return Complex(re, im);
            
        
    };

    public func diff(c1: Complex, c2: Complex): Complex {
        let re = c1.getReal() - c2.getReal();
        let im = c1.getImaginary() - c2.getImaginary();
        return Complex(re, im);
            
        
    };



    public func prod(c1: Complex, c2: Complex): Complex {
        let re = (c1.getReal() * c2.getReal()) - (c1.getImaginary() * c2.getImaginary());
        let im = (c1.getImaginary() * c2.getReal()) + (c1.getReal() * c2.getImaginary());
        return Complex(re, im);
    };


    public func div(c1: Complex, c2: Complex): Complex {
        assert (c2.square_norm() != 0.0);
        return prod(c1, c2.inverse());

    };

    public func pow(c: Complex, n: Nat): Complex {
        if (n == 0){
            assert (c.getReal() != 0 and c.getImaginary() != 0);
        };
        var i = 0;
        var res = Complex(1, 0);
        while (i < n) {
            res := prod(c, res);
            i += 1;
        };
        return res;
    };

    public func polar(c: Complex): (Float, Float) {
        let r = c.norm();
        let theta = Float.arctan2(c.getImaginary(), c.getReal());
        return (r, theta);
    };

   

    public func cosh(x: Float): Float {
        let res = 1.0 + Float.pow(x, 2.0)/2.0 + Float.pow(x, 4.0)/24.0 + Float.pow(x, 6.0)/720.0 + Float.pow(x, 8.0)/40320.0 + Float.pow(x, 10.0)/3628800.0;
        return res;
    };

    public func sinh(x: Float): Float {
        let res = x + Float.pow(x, 3.0)/6.0 + Float.pow(x, 5.0)/120.0 + Float.pow(x, 7.0)/5040.0 + Float.pow(x, 9.0)/362880.0 + Float.pow(x, 11.0)/39916800.0;
        return res;
    };

    public func sin(c: Complex): Complex {
        let re = Float.sin(c.getReal()) * cosh(c.getImaginary());
        let im = Float.cos(c.getReal()) * sinh(c.getImaginary());
        return Complex(re, im);
    };

    public func cos(c: Complex): Complex {
        let re = Float.cos(c.getReal()) * cosh(c.getImaginary());
        let im = - (Float.sin(c.getReal()) * sinh(c.getImaginary()));
        return Complex(re, im);
    };



};