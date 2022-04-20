function Y=RemovePilot(X,pilot_loc)
Y=[];
count=1
for i=1:length(X)
    if(i~=pilot_loc(count))
        Y=[Y X(i)];          
    elseif count<length(pilot_loc)
        count=count+1;
    end
end