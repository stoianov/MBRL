% Action-selection for Model-Based Reinforcement Learning.
% (C) Ivilin Stoianov, ISTC-CNR, Italy. Please, cite:
% Stoianov, Pennartz, Lansink, Pezzulo (2018) Model-Based Spatial Navigation in the Hyppocampus-Ventral Striatum Circuit: A Computational Analysis.  Plos Computational Biology

% Requires a model (m), target (ct) and current state (st).
function [a,swl,swcert,Nr]=action_selection(m,ct,st)
% Pm(s'|s,a) is the conditional distribution describing the probability to land to state s' following the transition (s,a)->s' (i.e., the model of the world)
% Pr(r |c,s) is the conditional distribution of obtaining either non-reward(r=0) or reward(r=1) if we are at state s and the target is c

Nr=zeros(2,m.nA,'single'); % for each action, accumulate during sweep the Beta-priors of the reward distribution

switch m.actpolicy
    
case 1 % Full distribution, 1-step
 % P(r=1|s,c,a:) = P(r=1|s':,c)*P(s':|s,a:)
 % To infer the action, clamp r=2, state=st, target=ct and get the action that brings to max reward. 
 pA=reshape(m.Pr(2,ct,:),1,m.nCAT)*squeeze(m.Pm(:,st,:));
 swl=1; swcert=acertainty(pA);  % Certainty of the action to be taken
  
case 3 % Sweeps of length based on discriminative uncertainty
    
 pA=zeros(1,m.nA,'single'); stX=pA;     % Collect the probability to obtain reward following each action a
 swcert=zeros(1,m.lsweepA,'single');    % Collect the certainty of the choice of aciton
 % The 1st-step of all sweeps
 for iA=1:m.nA                          % Init the sweep of each action
   [~,stX(iA)]=max(m.Pm(:,st,iA));      % Apply the model to find the state after taking action iA (the 1st action iA of the sweep is imposed and not selected)
   pA(iA)=m.Pr(2,ct,stX(iA));           % The reward at the state where we had landed after taking the action iA
 end
 swcert(1)=acertainty(pA);
 
 % Follow sweeps that accumulate evidence for choice of action. 
 % Sweeps consist of a series of states that are selected on the basis of greatest expected reward.
 swl=1;
 while (swl<m.lsweepA) && (swcert(swl)<m.actSweepCertThr)
   swl=swl+1;
   for iA=1:m.nA                        % Build the sweep for each action
    stX(iA)=localmax(m.Pm(:,stX(iA),:),m.Pr(2,ct,:)); % The next most promicing state
    pA(iA)  =pA(iA) + m.Pr(2,ct,stX(iA)); % Accumuluate reward evidence 
  end
  swcert(swl)=acertainty(pA); 
 end
 
end

a=xmax(pA,m.beta);                      % The action with greatest chance for reward (noisy selection)

end


function c=acertainty(pA)               % Return the certainty of the most probable action given the available evidence
  pAs=sort(pA,'descend');c=log(pAs(1)/pAs(2))/log(2); % Certainty (in bits) of the 1st relative to the 2nd most probable action.
end  


function st=localmax(Pm,Pr)            % Select the action that locally brings to max reward at this step of the sweep. Input is Pm(st1:,state,iA:) and Pr(2,st1:,target)
 [~,S]=max(Pm,[],1);                   % The most probable set of States (search on the 1st dimension) following  each possible action (the action is the 3rd dimension in Pm and the new state is the 1st dimension)
 [~,a]=max(Pr(S));                     % The action with max local reward (at each selected state)
 st=S(a);                              % "Apply" the action to go to the next state of the sweep (the most probable state for this action)
end
