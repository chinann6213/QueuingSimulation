function y = LCG(n, lower, upper)
    
    a = 13;
    x = ceil(float(rand() * upper));

    for i = 1 : n
        z = a * x;
        y(i) = (ceil(mod(z, upper)));
        if y(i) < upper - lower
            y(i) = y(i) + lower;
        end
        x = y(i);
    end