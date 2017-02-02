function y = ALCG(n, a, b) %Additive Congruential Generator
    
    
    c = 53;
    x = ceil(rand(1, n) * b);
    
    for i=1:n
        
        z = x + c;
        y(i) = (ceil(mod(z, b)));
        
        if y(i) < b - a;
            y(i) = y(i) + a;
        end
        
        x = y(i);
    end