
clear
clc
% Main for PDPTWOD-MCSDILC

%% Instance 
filename = 'AAn5m3-o1t0.mat';

%% Setting
Setting.Score = [50 30 15];     % Different new solution scores
Setting.PartC = 0.4;            % Percentage of removed orders
Setting.MaxOrder = 25;          % Remove the maximum number of orders
Setting.alpha = 5;              % Destruct the randomization parameters of the operator
Setting.Tend  = 0.05;           % Minimum temperature
Setting.Trate = 0.995;          % SA temperature attenuation factor
Setting.rho   = 0.3;            % Weight adjustment factor

Setting.Kxi   = [0.2 0.01 20];  % The level of noise in FE, the size of the penalty for the bad edge, and the length of the tabu
Setting.PenaltyNum = 0.01;      % The number of penalty edges
Setting.P = [500 1 1.5 10 2];   % RV fixed cost/RV variable cost /OD variable cost/reciept cos//delay penalty
Setting.tmax = 30;

Result = KSALNS(filename,Setting);
