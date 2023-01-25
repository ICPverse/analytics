# analytics
This project aims to provide some much needed Higher Math Functionality implemented in Native Motoko to help builders build.

It contains (but is not limited to) the following:  
1. Complex Numbers 
2. Clustering (KNN, Linear Regression) 
3. Hyperbolic Functions 
4. Mean, Median, Mode, Wmean, etc  
5. Pseudorandom function with 2 degrees of randomness 
6. Covariance (NEW)  
7. Data Normalization (NEW)  
8. Progressions (NEW)    
9. Data Prediction (NEW)  


This is an open-source repository and we always encourage anyone who wants to contribute to freely do so.


# buffer2 
This is our implementation of Buffer from the Motoko base library, but with many added functions. A brief overview of the added functions is given below (and marked with //NEW in the code): 
1. split_permanent: the split will affect parent buffer permanently 
2. range: provides the max - min for a buffer where possible 
3. intersection: gives the intersection of the two input buffers 
4. rotate_left: rotates the elements of the buffer to the left around the specified axis 
5. rotate_right: rotates the elements of the buffer to the right around the specified axis 
6. swap: exchanges elements at given two positions of the buffer 
7. truncate: truncates the buffer beyond given length 
8. fill: creates a buffer with each element set to the same value as specified 
9. hashmapToBuffer: converts a hashmap to a tuple buffer 
10. split_first: outputs a tuple of the first element of the buffer, and a buffer composed of all other elements of it 

