function y = LCG(n, lower, upper)
    
    a = 13;
    c = 53;
    x = ceil(rand() * upper);

    for i = 1 : n
        z = a * x + c;
        y(i) = (ceil(mod(z, upper)));
        if y(i) < upper - lower
            y(i) = y(i) + lower;
        end
        x = y(i);
    end



    
               
