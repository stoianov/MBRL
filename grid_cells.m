% Grid-cells for a maze.
% (C) Ivilin Stoianov, ISTC-CNR, Italy. Please, cite:
% Stoianov, Pennartz, Lansink, Pezzulo (2018) Model-Based Spatial Navigation in the Hyppocampus-Ventral Striatum Circuit: A Computational Analysis.  Plos Computational Biology

function F=grid_cells(t,display)
nxy=t.wsize;
if display, figure(901); clf; end

F.SF=2:5/10:7;                  % Spatial Frequencies
F.nSF=length(F.SF); 
F.GC={};
F.GRID=zeros(nxy,nxy);
F.nlevel=2;

grid=0;
for i_g=1:F.nSF,
 spatialFreq=F.SF(i_g);         % spatial frequency of the cosine/sine-wave carrier (cycles/image)
 orient_step=pi/3;              % three gratings with 60 degree difference in orientation
 phase = rand*pi;               % initial phase of the grating [-pi..pi]
 orient_0 = rand*pi;            % baseline orientation (in radians; pi/12 = 15 degrees)
 ramp_1D=linspace(-pi,pi,nxy)*spatialFreq+phase;
 [ramp_2D_X,ramp_2D_Y] = meshgrid(ramp_1D);

 for i=1:3   
  orient=orient_step*(i-1)+orient_0;   
  % 1) Oriented 2D-ramp is a cos-sin transformation of X and Y.
  ramp_2D_rotated = ramp_2D_X*cos(orient) + ramp_2D_Y*sin(orient);
  % 2) The grating is a sin-/cos-usoid on 2D ramp
  grating = cos(ramp_2D_rotated);
  % The grid is a sum of three gratings at 120 degree step.
  if i>1, grid=grid+grating/3; else grid=grating/3; end
  if display==2 && i==1, 
    subplot(1,3,1);  imagesc(ramp_2D_rotated);      colormap(gray(256)); axis off; axis equal;
    subplot(1,3,2);  imagesc(grating);   colormap(gray(256)); axis off; axis equal;
  end
 end
 grid=grid*2/3+1/3;
 if display==2, 
   subplot(1,3,3);  imagesc(grid);  colormap(gray(256)); axis off; axis equal;
 end
 F.GC{i_g}=grid;
 F.GRID=F.GRID*F.nlevel+F.GC{i_g}; % Grid-code at a given position is the summ of all grid cells at that position
end

F.GRID=round(F.GRID)+1;         % Make sure it is at least 1
F.grid=F.GRID(:);               % Linearize
F.nGridCells=F.nSF;             % How many grid cells
F.nGridInput=F.nlevel^F.nGridCells;
F.gmax_real=max(F.grid);
F.gmax=F.nlevel^F.nSF;

if display,
for i_g=1:F.nSF
  subplot(1,F.nSF+1,i_g);  
  imagesc(F.GC{i_g}); 
  colormap(gray(256)); axis off; axis equal;
end
subplot(1,F.nSF+1,F.nSF+1);plot(sort(diff(sort(F.grid)))); axis tight;  a=axis; axis([a(1:2) 0 10]);
end

end % function
