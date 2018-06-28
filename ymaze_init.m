% Y-maze for simulations of spatial navigation.
% (C) Ivilin Stoianov, ISTC-CNR, Italy. Please, cite:
% Stoianov, Pennartz, Lansink, Pezzulo (2018) Model-Based Spatial Navigation in the Hyppocampus-Ventral Striatum Circuit: A Computational Analysis.  Plos Computational Biology

function t=ymaze_init(params)
t.params=params;
t.wsize=16;                     % World-size, width (16 or 18)
%% TRIALS-based setting
t.phase.trial_start2=360;       % Pennartz 360
t.phase.trial_contextcue=2000;  % Pennartz (360+1640)
t.ntrials=2700;                 % Pennartz (360+1640+700)
t.npaths=t.ntrials;             % Number of trials (paths)
t.nticks=t.ntrials*20;          % Expected average of 20 ticks per trial

%%
t.path_max_length=ceil(t.wsize*2); % How long at most each random walk
reward_room=3;                  % REWARDED room
t=reward(t,reward_room);        % Build reward data; indicating the high-reward room (1-3) during context conditining  
t.world=world(t);               % Create world
t.goals=goals(t);               % Create goals
t.grid=grid_cells(t,0);         % Create grid(spatial) cells; the 2nd argument is display yes/no
t.start=starts(t);              % Set-up start points in different learing phases.

t.act.actions={'|','>','<'};    % Actions: step ahead, or left, or right
t.act.step=1.5;                 % simple step
t.act.turn=pi/2;                % 90-degree turn
t.act.nturn=2*pi/t.act.turn;    
t.act.n=length(t.act.actions);

nStates=t.grid.nGridInput*t.act.nturn; % True Max
nStates=500;                    % Actual limit; safe space (not critical; we use expanding dictionary; the number here is just for some preallocations) 
t.nStim=[t.goals.n nStates];    % number of goal-stimuli and number of grid-stimuli 

fprintf('\n INIT TASK: Maze %dx%d with goals %d, nGridLevels %d. Learning trials: %d\n',t.wsize,t.wsize,t.goals.n,t.grid.nGridInput,t.ntrials);
end % End of main function

%% Create a map of the world
function W=world(t)
n=t.wsize;
W=zeros(n,n);       % square-shaped world
% Polygon
t=[-1/6 .047 .285]; r=[.41 1 1]*n/2*1.05;   % wsize=16 Define one of the 3 squares
%t=[-1/6 .045 .29]; r=[.43 1 1]*n/2*1.06;   % wsize=17 Define one of the 3 squares
%t=[-1/6 .047 .285]; r=[.42 1 1]*n/2*1.05;   % wsize=15 Define one of the 3 squares
t=[t t+2/3 t+4/3]*pi; r=[r r r];            % Replicate, turning them on 120 degrees
[xp,yp]=pol2cart(t,r);                      % Make them in cartesian coordiantes
xp=round(xp+n/2); yp=round(yp+n/2);
%xp=floor(xp+n/2); yp=floor(yp+n/2);
W=uint8(poly2mask(xp,yp,n,n));              % Use the 3 squares to make a filled polygon of the arena

if 0
for i=0:2
 %t=(-1/6+i*2/3)*pi; r=.36*n/2*1.05;   % wsize=16 Define one wall
 t=(-.18+i*2/3)*pi; r=.38*n/2*1.05;   % wsize=18 Define one wall
 [xp,yp]=pol2cart(t,r);                      % Make it in cartesian coordiantes
 xp=round(xp+n/2); yp=round(yp+n/2);
 for j=1:length(xp), W(yp(j),xp(j))=0; end
end
end
end

function G=goals(t)
r=t.wsize/2;                % Radius
G.t=[0.02   1/6 2/6-.0]*pi;       % Angular position of goals
%G.t=[0  1/6 2/6]*pi;       % Angular position of goals
G.r=[.75  1  .75]*r*.92;        % Distance of goals
G.r=[.75  1  .75]*r*.88;        % Distance of goals
G.t=[G.t G.t+pi*2/3 G.t+pi*4/3]'; % Replicated with 120 and 240 degrees shift
G.r=[G.r G.r G.r]'; 
G.room=[1 1 1 2 2 2 3 3 3]';% Index of rooms
[G.x,G.y]=pol2cart(G.t,G.r);% Goals in cartesian coordinates
G.n =length(G.room);        % Number of goals
end

function s=starts(t)
r=t.wsize/2;                % Radius
s.maxdist=[1/4 2/3]*r;      % max x-distance from center in two different learing phases
%s.maxdist=[1 1]*r;          % max x-distance from center in two different learing phases
end

function t=reward(t,hr)
%t.rewscale=[1;9/4]*2;         % Reward at each phase (double in the 2nd phase, to have about the same total reward
t.rewscale=[1;9/4]*1;       % Try without scale 2 Reward at each phase (double in the 2nd phase, to have about the same total reward
t.high_reward=hr;           % store an index of the high-reward room
t.rewprob=[3;1]*ones(1,3);  % Phase1: goals in each room distributed with 100% probability 
t.rewprob(2,hr)=2;          % Phase2: goals in one room with large probability and the others have small probability 
t.rewprob=t.rewprob/3;
end
