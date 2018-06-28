function r=ymaze_isgoal(stim,pos)
% is the position within 1 unit eucleadian distance to the goal ?
r=((pos.x-stim.goal.x)^2+(pos.y-stim.goal.y)^2)^.5<1;