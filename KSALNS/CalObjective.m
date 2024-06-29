% r is one route 
% example: r{route vehicle_index}: first node and last node mean vehicle index 
% Objlist = [Obj1 Obj2 Obj3 Obj4 Obj5]
% Obj1: RV fixed route cost 
% Obj2: RV variable route cost
% Obj3: OD variable route cost
% Obj4: receipt cost
% Obj5: delay time penalty
function [Objs,T_L,SDis] = CalObjective(r,k,Parameter,Setting) 
if isempty(r)
    Objs = 0;
    T_L  = 0;
    SDis = 0;
else
    L = length(r);
    NewC = Parameter.Customers2Orders(r);
    Objlist = zeros(1,5);
    Sik  = 0;
    T_L  = zeros(1,L);
    %ODs and RVs
    if k<= Parameter.ODnum %ODs
        for i = 1:L
            if i == 1 
                Objlist(3) = Objlist(3) + Parameter.S2M(k,r(i));
                Objlist(4) = Objlist(4) + 1;
                Sik = max(Parameter.S2M(k,r(i)),Parameter.Ai(r(i)));
                Objlist(5) = Objlist(5) + max(0,Sik - Parameter.Bi(r(i)));
            elseif i == L
                if ~any(NewC(1:i-1)==NewC(i))
                    Objlist(3) = Objlist(3) + Parameter.M2C(r(i-1),r(i));
                    Objlist(4) = Objlist(4) + 1;
                    Sik  =  max(Sik + Parameter.Si(r(i-1)) + Parameter.M2C(r(i-1),r(i)),Parameter.Ai(r(i)));
                    Objlist(5) = Objlist(5) + max(0,Sik - Parameter.Bi(r(i)));
                end
            else
                if ~any(NewC(1:i-1)==NewC(i))
                    Objlist(3) = Objlist(3) + Parameter.M2C(r(i-1),r(i));
                    Objlist(4) = Objlist(4) + 1;
                    Sik  =  max(Sik + Parameter.Si(r(i-1)) + Parameter.M2C(r(i-1),r(i)),Parameter.Ai(r(i)));
                    Objlist(5) = Objlist(5) + max(0,Sik - Parameter.Bi(r(i)));
                end
            end
            T_L(i) = Sik;
        end
        SDis = Objlist(3);
    else %RVs
        for i = 1:L
            if i == 1 
                Objlist(1) = Objlist(1) + 1;
                Objlist(2) = Objlist(2) + Parameter.RV_S2M(r(i));
                Objlist(4) = Objlist(4) + 1;
                Sik = max(Parameter.RV_S2M(r(i)),Parameter.Ai(r(i)));
                Objlist(5) = Objlist(5) + max(0,Sik - Parameter.Bi(r(i)));
            elseif i == L
                if ~any(NewC(1:i-1)==NewC(i))
                    Objlist(2) = Objlist(2) + Parameter.M2C(r(i-1),r(i)) + Parameter.RV_S2M(r(i));
                    Objlist(4) = Objlist(4) + 1;
                    Sik  =  max(Sik + Parameter.Si(r(i-1)) + Parameter.M2C(r(i-1),r(i)),Parameter.Ai(r(i)));
                    Objlist(5) = Objlist(5) + max(0,Sik - Parameter.Bi(r(i)));
                else
                    Objlist(2) = Objlist(2) + Parameter.RV_S2M(r(i));
                end
            else
                if ~any(NewC(1:i-1)==NewC(i))
                    Objlist(2) = Objlist(2) + Parameter.M2C(r(i-1),r(i));
                    Objlist(4) = Objlist(4) + 1;
                    Sik  =  max(Sik + Parameter.Si(r(i-1)) + Parameter.M2C(r(i-1),r(i)),Parameter.Ai(r(i)));
                    Objlist(5) = Objlist(5) + max(0,Sik - Parameter.Bi(r(i)));
                end
            end
            T_L(i) = Sik;
        end
        SDis = Objlist(2);
    end
    Objs = Setting.P*Objlist';
end
end