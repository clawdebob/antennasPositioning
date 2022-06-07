int: mapWidth = 2500;
int: mapHeight = 500;
int: paramsNum = 4;
int: x0 = 1;
int: y0 = 2;
int: width = 3;
int: height = 4;
int: antennasNumber = 10;
int: housesNumber = 6;
int: signalRadius = 400;

set of int: x = 0..mapWidth;
set of int: y = 0..mapHeight;
set of int: housesIndexes = 1..housesNumber;
set of int: antennasIndexes = 1..antennasNumber;
set of int: antennasRadius = {200, 250};

array[housesIndexes, x0..height] of 0..max(mapHeight, mapWidth): housesData = [|
  0, 0, 200, 200
  | 50, 250, 200, 250
  | 300, 300, 150, 150
  | 1800, 100, 350, 350
  | 850, 125, 240, 180
  | 1200, 200, 200, 200
|];

predicate is_in_radius(int: x, int: y, var int: a, var int: b, var antennasRadius: r) =
  (x - a) * (x - a) + (y - b) * (y - b) <= r * r;
  
predicate is_in_radius_f(float: x, float: y, int: a, int: b, var int: r) =
  (x - a) * (x - a) + (y - b) * (y - b) <= r * r;
  
predicate is_suitable(int: width, int: height, var antennasRadius: r) =
 is_in_radius_f(-width/2, height/2, 0, 0, r)
 /\ is_in_radius_f(-width/2, -height/2, 0, 0, r)
 /\ is_in_radius_f(width/2, height/2, 0, 0, r)
 /\ is_in_radius_f(width/2, -height/2, 0, 0, r);
  
array[antennasIndexes, x0..y0] of var -1..max(mapHeight, mapWidth): antennasData;
array[antennasIndexes] of var antennasRadius: radiusData;
array[antennasIndexes] of var 0..1000000: prices;
var set of antennasIndexes: included;
var 0..antennasNumber: quantity;

constraint forall(i in housesIndexes)(exists(j in antennasIndexes)(
  antennasData[j, y0] in y /\ antennasData[j, x0] in x
  /\ j in included
  /\ prices[j] = radiusData[j] * 1000
  /\ is_in_radius(housesData[i, x0], housesData[i, y0], antennasData[j, x0], antennasData[j, y0], radiusData[j])
  /\ is_in_radius(housesData[i, x0] + housesData[i, width], housesData[i, y0], antennasData[j, x0], antennasData[j, y0], radiusData[j])
  /\ is_in_radius(housesData[i, x0], housesData[i, y0] + housesData[i, height], antennasData[j, x0], antennasData[j, y0], radiusData[j])
  /\ is_in_radius(housesData[i, x0] + housesData[i, width], housesData[i, y0] + housesData[i, height], antennasData[j, x0], antennasData[j, y0], radiusData[j])
));

% constraint forall(i in included)(antennasData[i, x0] >= 0 /\ antennasData[i, y0] >= 0);
constraint quantity = sum([if antennasData[i, x0] >= 0 then 1 else 0 endif | i in antennasIndexes]);

%prices = [if i in included then 1000 else 0 endif | i in antennasIndexes];

solve minimize sum([prices[i] | i in included]);

%solve minimize sum([if antennasData[i, x0] >= 0 /\ antennasData[i, y0] >= 0 then 1000 * radiusData[i] else 0 endif | i in antennasIndexes]);

%output [show_int(6, sum([if antennasData[i, x0] >= 0 /\ antennasData[i, y0] >= 0 then 1000 * radiusData[i] else 0 endif | i in antennasIndexes]))];