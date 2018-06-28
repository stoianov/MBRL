function stim=ymaze_stimuli(stim,task,i)
if isempty(stim), stim=stim_init(task); end

%% New reward point and initial state
if not(stim.state==0),  % Goal reached (s=1) or time is expired (s=-1)    
  
  % Trial-based setting  (as in Pennartz)
  if stim.npath>task.phase.trial_start2,     stim.phase.start=2; end % 1=start from center, 2=start from anywhere
  if stim.npath==task.phase.trial_contextcue,stim.phase.justswitched=1; end
  if stim.npath>=task.phase.trial_contextcue, stim.phase.cont=2;   end % 1=uniform reward, 2="contex cueing", i.e., assymetric reward
  
  % Time-step based setting (the 1st simulations counted time ticks only)
  %if i>task.phase.start,   stim.phase.start=2; end    % 1:close-to-center points; 2: all-start-points
  %if i>task.phase.context, stim.phase.cont=2;  end    % Begining of context phase: assymetric reward (nord(1)=1; the others:1/4)  
    
  %% GOAL (one out of pre-selected positions)
  stim.goal.i=stim.goal.i+1;    % Next goal (from the list of all goals)
  if stim.goal.i>=task.goals.n, % If all goals are used, then reshufle
    stim.goal.I=randperm(task.goals.n);
    stim.goal.i=1;
  end
  stim.goal.s=stim.goal.I(stim.goal.i);  % index of goal 
  stim.goal.x=task.goals.x(stim.goal.s); % x-position of goal
  stim.goal.y=task.goals.y(stim.goal.s); % y-position of goal
  stim.goal.room=task.goals.room(stim.goal.s); % Associated room number
    
  %% START-POINT (tottaly random)
  start_ok=0;
  while not(start_ok)
    s_dista=rand*task.start.maxdist(stim.phase.start);      % position, distance from cetnre 
    s_theta=rand*2*pi;                                      % position, theta (0-360 degree)
    [stim.start.x,stim.start.y]=pol2cart(s_theta,s_dista);  % position in cartesian coordinates
    stim.start.d=rand*2*pi;                                     % random head-direction (0-360 degree)
    wx=max(1,min(task.wsize,round(stim.start.x+task.wsize/2)));
    wy=max(1,min(task.wsize,round(stim.start.y+task.wsize/2)));
    start_ok=task.world(wy,wx);                             % if positive, then it is in the arena
  end
  stim.pos.x=stim.start.x;
  stim.pos.y=stim.start.y;
  stim.pos.d=stim.start.d;
  
  
  %% Service vars
  stim.act=0;                  % Initially, no predicted action
  stim.npath=stim.npath+1;     % add a new path
  stim.lpath=0;                % empthy path
  stim.rewscale=task.rewscale(stim.phase.cont); 
  stim.rewprob =task.rewprob(stim.phase.cont,:); 
end

[stim,inp]=ymaze_input(task,stim,stim.pos); % inp={Grid-code at the current position x head-direction}

stim.ss=[stim.goal.s inp stim.pos.x stim.pos.y stim.pos.d stim.npath stim.lpath];    % Analysis(goal,stim,pos-x,pos-y,pos-dir,npath,lenpath) 
end

function stim=stim_init(task)
  %stim.pos=0;                  % Model-like map model (0: select new pos and goal. 1: use old state)
  stim.npath=0;                % How many paths thus far;
  stim.lpath=0;                % How long is the current paths;
  stim.state=2;                % Indicator to generate new goal & initial position
  stim.act=0;
  stim.goal.i=inf;             % Initial goal = intial state, to generate straight the real new goal and state 
  stim.pos.i=inf;              % Initial position 
  stim.pos.n=0;                % Initially no positions defined
  stim.phase.cont=1;           % 1st phase of contextualizing (all goals with the same probability)
  stim.phase.start=1;          % 1st phase of start points (close to center)
  stim.grid.map=zeros(task.grid.gmax*task.act.nturn,1,'single');
  stim.grid.list=[];
  stim.grid.n=0;
  stim.phase.justswitched=0;
end
