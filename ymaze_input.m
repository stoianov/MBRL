function [stim,inp]=ymaze_input(task,stim,pos)
% Return the grid-cells code for the current input, and eventually updated grid-dictionary

gx=min(task.wsize,max(1,round(pos.x+task.wsize/2))); % Shift to positive coordinates and round to integer
gy=min(task.wsize,max(1,round(pos.y+task.wsize/2)));
dir=round(pos.d/(2*pi)*task.act.nturn); if dir==0, dir=task.act.nturn; end  % Map all directions on a discrete scale

g=task.grid.GRID(gy,gx);            % Enumerated grid-code at the current position 
g=(g-1)*task.act.nturn+dir;         % Add info about the orientation

if stim.grid.map(g)==0,             % Dictionary of grid inputs. Used to deacrease the table since to all inputs will be seen.
  stim.grid.n=stim.grid.n+1;        % Number of used grid levels
  stim.grid.list(stim.grid.n)=g;    % List of used grid levels
  stim.grid.map(g)=stim.grid.n;     % Map of used levels
end

inp=stim.grid.map(g);               % the grid at this position

end