% clear
% clc
function Parameter = ImportData_KSALNS(filename)
%file path
Path = ['INSTANCE\' filename];
data = load(Path);
Pick_Del_data = data.Pick_Del_data;
OD_Vehicle    = data.ODVehicle;
RV_Vehicle    = data.RVVehicle;
mindex = find(filename=='m',1);
oindex = find(filename=='o');
Ordertype = str2num(filename(mindex+1:oindex-2));

[N,~] = size(Pick_Del_data);
PickCustomerNum = N/2;
ODnum = size(OD_Vehicle,1);

RV_Vehicle1 = []; 
for i = 1:size(RV_Vehicle,1)
    num1 = RV_Vehicle(i,end);
    RV_Vehicle1 = [RV_Vehicle1;repmat(RV_Vehicle(i,1:end-1),num1,1)];
end
RVnum = size(RV_Vehicle1,1);

Vehicle = [[OD_Vehicle(:,1:end-1) zeros(ODnum,1)];[RV_Vehicle1(:,1:end) ones(RVnum,1)]];

% Merchant and Customers
MerCusXY = [];
MerCusD = [];
MerCusTime  = [];
MerCusType = [];
for i = 1:PickCustomerNum*2
    MerCusXY = [MerCusXY;repmat(Pick_Del_data(i,[2 3]),Ordertype,1)];
    MerCusD = [MerCusD;Pick_Del_data(i,7:7+Ordertype-1)'];
    MerCusTime = [MerCusTime;repmat(Pick_Del_data(i,[4 5]),Ordertype,1)];
    MerCusType = [MerCusType;[1:Ordertype]'];  
end
index = find(MerCusD~=0);
MerCus_XY = MerCusXY(index,:);
MerCus_Demand = MerCusD(index);
MerCus_Time = MerCusTime(index,:);
MerCus_Type = MerCusType(index);
MerCus_M2C = [length(MerCus_Demand)/2+1:length(MerCus_Demand) 1:length(MerCus_Demand)/2 ]'; 

PickOrderNum = length(MerCus_M2C)/2;

%Driver attributes 
KType = Vehicle(:,3:3+Ordertype-1);
KLocation = Vehicle(:,[1 2]);
KNum  = size(Vehicle,1);
Capacity = Vehicle(:,2+Ordertype+1);
TimeUp = Vehicle(:,end-1);

% Ctypelist
OD_ctypelist = cell(1,PickOrderNum);
RV_ctypelist = cell(1,PickOrderNum);
ctypelist = cell(1,PickOrderNum);
for i = 1:PickOrderNum
    ctype = MerCus_Type(i);
    OD_ctypelist{i} = find(KType(1:ODnum,ctype)==1);
    RV_ctypelist{i} = ODnum+find(KType(ODnum+1:KNum,ctype)==1);
    ctypelist{i} = find(KType(:,ctype)==1);
end
% Ktypelist
ktypelist = cell(KNum,1);
for i = 1:KNum
    ktype = find(KType(i,:)==1);
    ktypelist{i} = find(ismember(MerCus_Type(1:PickOrderNum),ktype)); 
end

%% Parameters
Parameter.Pick_Del_data = Pick_Del_data;
Parameter.Vehicle    = Vehicle;
Parameter.PickCustomer = PickCustomerNum;
Parameter.PickOrder  = PickOrderNum;
Parameter.ODnum = ODnum;
Parameter.RVnum = RVnum;
% Parameter.ctypelist = ctypelist;
Parameter.OD_ctypelist = OD_ctypelist;
Parameter.RV_ctypelist = RV_ctypelist;
Parameter.ctypelist    = ctypelist;
Parameter.ktypelist = ktypelist;
Parameter.KType = KType;

%Orders
S2M = pdist2(KLocation(1:ODnum,:),MerCus_XY); %ODs to Merchants and Customers
M2C = pdist2(MerCus_XY,MerCus_XY);            %Merchant to Customer order
RV_S2M  = pdist2(KLocation(ODnum+1,:),MerCus_XY);
%Customers
C2C = pdist2(Pick_Del_data(:,[2 3]),Pick_Del_data(:,[2 3]));

Parameter.MC_XY = MerCus_XY;
Parameter.ODs_XY = KLocation(1:ODnum,:);
Parameter.RVs_XY = KLocation(ODnum+1:end,:);

Parameter.S2M = S2M;
Parameter.M2C = M2C;
Parameter.RV_S2M = RV_S2M;
Parameter.C2C = C2C;

CDemand = Pick_Del_data(:,7:7+Ordertype-1);
Parameter.CDemand = CDemand;
dmax1 = max(max(M2C(1:PickOrderNum,1:PickOrderNum)));
dmax2 = max(max(M2C(PickOrderNum+1:2*PickOrderNum,PickOrderNum+1:2*PickOrderNum)));
% order to order realation matrix
RelationM_Orders = zeros(PickOrderNum);
for i = 1:PickOrderNum-1
   for j = i+1:PickOrderNum
       if i~=j
           part1 = (M2C(i,j)+M2C(i+PickOrderNum,j+PickOrderNum))/(dmax1+dmax2);
           part3 = abs(MerCus_Demand(i)-MerCus_Demand(j))/(MerCus_Demand(i)+MerCus_Demand(j));
           part4 = 1- length(intersect(ctypelist{i},ctypelist{j}))/KNum;
           RelationM_Orders(i,j) = part1 + part3 + part4;
       end
   end
end
RelationM_Orders = RelationM_Orders + RelationM_Orders' +diag(Inf(1,PickOrderNum));
Parameter.RM_Orders = RelationM_Orders;

% customer to customer relation matrix
maxC2C = max(max(Parameter.C2C(1:PickCustomerNum,1:PickCustomerNum)));
maxM2M = max(max(Parameter.C2C(PickCustomerNum+1:2*PickCustomerNum,PickCustomerNum+1:2*PickCustomerNum)));
RelationM_Customers = zeros(PickCustomerNum);
for i = 1:PickCustomerNum-1
   for j = i+1:PickCustomerNum
       part1 = (C2C(i,j)+C2C(i+PickCustomerNum,j+PickCustomerNum))/(maxC2C+maxM2M);
       part2 = sum(abs(CDemand(i,:)-CDemand(j,:)))/sum(CDemand(i,:)+CDemand(j,:));
       RelationM_Customers(i,j) = part1 + part2;
   end
end
RelationM_Customers = RelationM_Customers + RelationM_Customers' +diag(Inf(1,PickCustomerNum));
Parameter.RM_Customers = RelationM_Customers;

%Customer to order index
Customers2Orders = zeros(2*PickOrderNum,1);
number = 0;
for i = 1:size(Parameter.CDemand,1)
    for j = 1:size(Parameter.CDemand,2)
        if Parameter.CDemand(i,j)==0
            continue
        else
            number = number + 1;
            Customers2Orders(number) = i;
        end
    end
end
Parameter.Customers2Orders = Customers2Orders;

Parameter.MerCus_Type = MerCus_Type;
Parameter.MerCus_Demand = MerCus_Demand;
Parameter.Cap = Capacity;
Parameter.TimeUp = TimeUp;
Parameter.Si = ones(PickOrderNum*2,1)*0.01*max(TimeUp);
Parameter.Ai = MerCus_Time(:,1);
Parameter.Bi = MerCus_Time(:,2);

%Space-time distance
Parameter.ST_Matrix = ST_Distance(2*PickOrderNum,M2C,Parameter.Ai,Parameter.Bi,Parameter.Si);

%Space-time relation Matrix
N = 2*Parameter.PickOrder;
DisMax = max(Parameter.ST_Matrix(:));
RM_Distance = zeros(N);
RM_Location = zeros(N);
for i = 1:N
    for j = 1:N
        if i~=j
            RM_Distance(i,j) = DisMax - Parameter.ST_Matrix(i,j);
            if all(MerCus_XY(i,:) == MerCus_XY(j,:))
                RM_Location(i,j) = 1;
            end
        end
    end
end
Parameter.RM_Distance = RM_Distance;
Parameter.RM_Location = RM_Location;
end