# PDPTWOD-MCSDILC
This project contains instances and code from Paper 《Knowledge-assist heuristic approaches for crowdsourcing vehicle routing problem with multi-commodity split delivery and incompatible loading constraints》

# Instance
Benchmark instances for PDPTWOD-MCSDILC problem Each '.mat' instance contains the 'RVVehicle', 'ODVehicle' and 'Pick_Del_data' arrays. 

In 'RVVechile', columns 1 to 2 represent the location of depot, columns 3 to 5(6) represent the type of commodities that the vehicle can serve (if vehicle can serve this type of commodity,it is 1, otherwise 0.), columns 6(7) represent the maximum capacity of the vehicle, 7 (8) represent the maximum distance of the vehicle, and 8 (9) represent the number of vehicles of this class. 

In 'ODVechile', Columns 1 to 2 represent the initial position of the vehicle, and the remaining columns are similar to the 'RVVechile'.

In 'Pick_Del_data', columns 1 represent the number, columns 2 to 3 represent the order pick-up location(delivery location), columns 4 to 5 represent the time window, columns 6 represent the total quantity of the order, and columns 7 to 9 (10) represent the quantity of each type of commodity in the order. Column 10 (11) represents the number of delivery location(pick-up location) corresponding to the order pickup location(delivery location).

# Code
The Main_Instance_Example file under KALNS provides a running example
