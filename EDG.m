function y = EDG(n, min, max) %Random Exponential Distribution 
    
    a = rand(1, n);
    
    z = (-1 / 2) * (log(1 - a));
    
    x = mod((z * max), max);
    
    if x < min
        x = x + min;
    end
    
    y = ceil(x);