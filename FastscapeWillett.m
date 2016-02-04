% EPS 217 - Landscape Evolution Modelling with Jean Braun and Bill Dietrich

% Week 1

% Let's define the problem:
xl = 100.e3; % x-dimension in meters
yl = 100.e3; % y-dimension in meters
nx = 101;
ny = 101;
nn = nx*ny; % the total number of points
dx = xl/(nx-1); % x-dimension unit
dy = yl/(ny-1); % y-dimension unit
dt = 1000.; %timestep in yr
nstep = 1000; % number of steps
% lack of period indicates that what you've put is an integer
% period means a number, not necessarily an integer (FORTRAN thing)

% More conditions (for later)
k=1e-4;
n=1;
m=0.4;
u=2e-3; % uplift rate

% We want to solve the stream power equation
% First assume U is constant, uniform in space and time
% m = 1
% n = 0.4

% Recall we will need initial and boundary conditions
% CASE 1: h = 0 and U = 0 along all 4 boundaries (fixed base level)
% CASE 2: h = 0 at y = 0 and y = yl and cyclic boundary conditions between
% x = 0 and x = xl
% CASE 3: h = 0 and y = 0 and reflective boundary conditions at y = yl and
% cyclic boundary conditions between x = 0 and x = xl

% Assume h = 0 then add some 1m high noise onto the landscape

% Create an array to store the height and add random noise at each point
h = rand(nn,1); % one column with nn rows (NOT identifying entries by row#
% and column#)
%h = [0 0 0 0; 0 10 15 0; 0 9 7 0; 0 0 0 0];
for l = 1:nx
    for k = 1:ny
        h(k,1) = k;
    end
end

R = reshape(h,nx,ny);
figure
pcolor(R)

% To find oneself in the matrix given x and y positions (the way we didn't
% set it up), use the following code:
for j = 1:ny
    for i = 1:nx
        ij= i+(j-1)*nx;
    end
end

% BUILDING RECEIVER ARRAY
% For each ij (=1,...,nn), let's first compute the "steepest neighbor node"
% which will also be called the "receiver node" (rec(ij)) as well as the
% horizontal distance between node ij and its receiver node, length(ij);
% length will be 1, sqrt(2), or 0.

% In this version of the code, we will assume that the 4 boundaries are
% fixed at base level.  Boundary nodes are their own receivers and length
% is 0.

% Initialize storage
ij_neighbor=nan(9,1);
l_neighbor=nan(9,1);

len = nan(nn,1);
rec = nan(nn,1);

% Start by setting the "answer" to every cell as being its own receiver and
% having a length 0.  This is true for the boundaries.  The loop below will
% change the answer for internal points only
for ij=1:nn;
    len(ij) = 0;
    rec(ij) = ij;
end

% _______
% |7|8|9|
% _______
% |4|5|6|
% _______
% |1|2|3|
% _______

for i=2:(nx-1) % exclude edge cells from this calculation
    for j=2:(ny-1)
        ij = i+(j-1)*nx; % find your nn value based on i and j
        
        % identify neighbors and store them in neighbor array
        ij_neighbor(1) = (i-1)+((j-1)-1)*nx; %lower left neighbor
        ij_neighbor(2) = i+((j-1)-1)*nx; %below neighbor
        ij_neighbor(3) = (i+1)+((j-1)-1)*nx; %lower right neighbor
        ij_neighbor(4) = (i-1)+(j-1)*nx; %left neighbor
        ij_neighbor(5) = i+(j-1)*nx; %self
        ij_neighbor(6) = (i+1)+(j-1)*nx; %right neighbor
        ij_neighbor(7) = (i-1)+((j-1)+1)*nx; %upper left neighbor
        ij_neighbor(8) = i+((j-1)+1)*nx; %upper neighbor
        ij_neighbor(9) = (i+1)+((j-1)+1)*nx; %upper right neighbor
        
        l_neighbor(1) = sqrt(dx+dy);
        l_neighbor(3) = sqrt(dx+dy);
        l_neighbor(7) = sqrt(dx+dy);
        l_neighbor(9) = sqrt(dx+dy);
        l_neighbor(5) = 0;
        l_neighbor(2) = dy;
        l_neighbor(8) = dy;
        l_neighbor(4) = dx;
        l_neighbor(6) = dx;
        
        h_diff=-100;       
        % look to each neighbor and store its info only if it is lower than
        % previous neighbor
        for k=1:length(ij_neighbor)
            h_diff_temp = h(ij_neighbor(5))-h(ij_neighbor(k)); % self height - neighbor height
            if h_diff_temp > h_diff
                h_diff = h_diff_temp;
                rec(ij) = ij_neighbor(k);
                len(ij) = sqrt((l_neighbor(k))^2 + (h_diff)^2);
            end
        end
    end
end

% Week 2! Let's talk about meshes (and talk only)

% And now let's build a donor array

% From the receiver list, we now need to build the <<reversed>> list of the
% donor nodes. For each node ij, we need to compute how many neighboring
% nodes have ij as a receiver node and the list of these neightbors.  This
% will mean computing 2 lists, one of length nn, called, ndon, which is the
% number of donors for each node, and a double indexed array, donors(8,nn),
% containing up to 8 nodes per node (there are 8 neighbor to each node).
% Don't forget to initialize ndon to 0. Max # of donors is 8 (or 9...)

% one loop of length nn and be able to get ndon and donors! one loop!!!!

ndon = zeros(nn,1);
donor = zeros(nn,8);
n_self = 0;

for ij = 1:nn
    if rec(ij) ~= ij
        ijk = rec(ij);
        ndon(ijk) = ndon(ijk) + 1;
        donor(rec(ij),ndon(rec(ij))) = (ij);
    else
        n_self = n_self+1;
    end
end

