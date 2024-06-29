% r one route 
% k vehicle index
% ObjT: Actual service time of each node
function T_L = CalObjT(r,k,Parameter)
L = length(r);
T_L = zeros(1,L);
for i = 1:L
    if i ==1 
        if k <= Parameter.ODnum
            Sik = max(Parameter.S2M(k,r(i)),Parameter.Ai(r(i)));
        else
            Sik = max(Parameter.RV_S2M(r(i)),Parameter.Ai(r(i)));
        end
        T_L(i) = Sik;
    elseif i==L
        if Parameter.Customers2Orders(r(i-1)) ~= Parameter.Customers2Orders(r(i))
            Sik  = max(Sik + Parameter.Si(r(i-1)) + Parameter.M2C(r(i-1),r(i)),Parameter.Ai(r(i)));
        end
        T_L(i) = Sik;
    else
        if Parameter.Customers2Orders(r(i-1)) ~= Parameter.Customers2Orders(r(i))
            Sik = max(Sik + Parameter.Si(r(i-1)) + Parameter.M2C(r(i-1),r(i)),Parameter.Ai(r(i)));
        end
        T_L(i) = Sik;
    end
end

end