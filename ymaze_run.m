% Bayesian Model-Based Reinforcement Learning controller
% (C) Ivilin Stoianov, ISTC-CNR, Italy. Please, cite:
% Stoianov, Pennartz, Lansink, Pezzulo (2018) Model-Based Spatial Navigation in the Hyppocampus-Ventral Striatum Circuit: A Computational Analysis.  Plos Computational Biology

% Parameters of each condition  [Alfa,Beta,ActionPolicy, maxActSweepLengh, discr.thr, RewardPolicy, maxRewSweepLength]
C =  {       
      'MBRL',[20 80 1 8 0.15 1 9],'BAS' % shallow action policy & reward search
      'MBRL',[20 80 3 8 0.15 1 9],'ACT' % Policy using Action sweeps
      'MBRL',[20 80 1 8 0.15 2 9],'REW' % Reward-search  sweeps
      'MBRL',[20 80 3 8 0.15 2 9],'A+R' % Action sweeps and Reward-search Sweeps 
     };
nc=size(C,1); nrep=5; MH=cell(nrep,nc);
fname=sprintf('ymaze_MBRL.mat'); fprintf('TRAIN %d replica ...\n',nrep);

for c=1:nc                               
  model=C{c,1}; params=C{c,2}; info=C{c,3};
  for r=1:nrep      
    rng('shuffle'); 
    task = ymaze_init(params);              % Init the navigation environment (ymaze)
    ST = []; M=[]; M.info=info; M.task=task; M.itrial=0; i=0;  % Empty stimulus and model
    while M.itrial<task.ntrials, 
      i=i+1;  
      ST = ymaze_stimuli(ST,task,i);        % Update environment 
      if ST.phase.justswitched,             % End of phase1-learning
        M.M1=M;  ST.phase.justswitched=0;   % Keep the last state of pre-cueing
      end 
      [M,ST] = MBRLcontroller(M,ST,i);      % Action selection (motor control) and model inference (learning)
    end
    M.ST=ST;                                % Store the last state of the stimulus
    MH{r,c}=M;                              % Store the learned model
  end
end
save(fname,'MH','C'); 
ymaze_plot_ltrend(MH);                      % plot learning trends