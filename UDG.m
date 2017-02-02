function y = UDG(n, lower, upper) %Random Uniform Distribution 

    
    y = ceil(lower + (upper - lower) * rand(1, n));
  
    end