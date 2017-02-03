function [ xLine, yLine ] = discretelinefunction( center, m, xa, ya, xb, yb )
%plots discrete line at specified slope
%center = centerpoint of the input image
%m = slope of the line

if m > 1 %Large positive slope
    %Defining starting point on line and initial error value
    error(1) = 1/m;
    xLine(1) = center(2);
    yLine(1) = center(1);
    for i = 1:(yb)-center(1)
        
        if xLine(i) + error(i) < xLine(i) + 0.5
            %x value is not incremented
            yLine(i+1) = yLine(i) + 1;
            xLine(i+1) = xLine(i);
            
            error(i+1) = error(i)+1/m;
        else
            %x value is incremented
            yLine(i+1) = yLine(i) + 1;
            xLine(i+1) = xLine(i) + 1;
            
            error(i+1) = error(i)+1/m-1;
            
        end
        
    end
    
    %str = 'LP'
    
elseif m<=1 && m>0 %Small positive slope
    %Defining starting point
    error(1) = m;
    xLine(1) = center(2);
    yLine(1) = center(1);
    
    
    for i = 1:xb-(center(2)+1)
        %y value is not incremented
        if yLine(i) + error(i) < yLine(i) + 0.5
            xLine(i+1) = xLine(i) + 1;
            yLine(i+1) = yLine(i);
            
            error(i+1) = error(i)+m;
        else
            %y value is incremented
            xLine(i+1) = xLine(i) + 1;
            yLine(i+1) = yLine(i) + 1;
            
            error(i+1) = error(i) + m - 1;
        end
        
    end
    
    
    %str = 'SP'
    
elseif m<-1  %Large negative slope
    
    error(1) = 1/m;
    xLine(1) = center(2);
    yLine(1) = center(1);
    
    
    for i = 1:center(1)-(yb+1)
        %x value is not incremented
        if error(i) > -0.5
            yLine(i+1) = yLine(i) + 1;
            xLine(i+1) = xLine(i);
            
            error(i+1) = error(i)+1/m;
        else
            %y value is not incremented
            yLine(i+1) = yLine(i) + 1;
            xLine(i+1) = xLine(i) - 1;
            
            error(i+1) = error(i)+1/m + 1;
        end
        
    end
    
    
    %str = 'LN'
    
else %Small negative slope (between 0 and -1 inc)
    error(1) = m;
    xLine(1) = center(2);
    yLine(1) = center(1);
    
    
    for i = 1:xb-(center(2)+1)
        %y value is not incremented
        if error(i) > -0.5
            xLine(i+1) = xLine(i) + 1;
            yLine(i+1) = yLine(i);
            
            error(i+1) = error(i) + m;
        else
            %y value is incremented (reduced)
            xLine(i+1) = xLine(i) + 1;
            yLine(i+1) = yLine(i) - 1;
            
            error(i+1) = error(i)+ m + 1;
        end
        
    end
end

