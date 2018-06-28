function pos1=ymaze_action(task,pos,a)

pos1=pos; % start from the current position

% Effects of 3 possible actions: move forward, move and turn left, move and turn right
s_scale=[1  1   1 ];
s_dir  =[0  1  -1 ];

step=task.act.step*s_scale(a)*(1+randn*.1);     % Size of step in the new direction
turn=s_dir(a)*task.act.turn+randn*0.1;          % Change of direction

pos1.d=pos1.d+turn;
if pos1.d<0, pos1.d=pos1.d+2*pi; end
if pos1.d>=2*pi, pos1.d=pos1.d-2*pi; end
 
[pos1.dx,pos1.dy]=pol2cart(pos1.d,step);
pos1.x=pos1.x+pos1.dx;
pos1.y=pos1.y+pos1.dy;

% should stay inside world
pos1.x=max(-task.wsize/2,min(task.wsize/2,pos1.x));
pos1.y=max(-task.wsize/2,min(task.wsize/2,pos1.y));

% Should stay inside arena
yw=max(1,min(task.wsize,round(pos1.y+task.wsize/2)));
xw=max(1,min(task.wsize,round(pos1.x+task.wsize/2)));
if not(task.world(yw,xw)), pos1=pos; end

return