% Show behavioral trens
function ymaze_plot_ltrend(MH)
if nargin<1, 
  try
    load('ymaze_MBRL.mat','MH'); 
  catch
    disp('Model not provided neither stored on disk. Please, first train the model by running ymaze_run');
    return;
  end
end

h_fg=figure;clf reset;hold on;  

actcThr=MH{1,1}.actSweepCertThr;
nTr=MH{1,1}.task.ntrials;                                       % Number of trials (all learners are aligned by trials
nIpl=30;                                                        % Number of plot datapoints
Ipl=(1:nIpl)*(nTr/nIpl);                                        % Plot time (in trials)
nR=size(MH,1); % repetions
nC=size(MH,2); % conditions
hpl1=zeros(nC,1); 
Leg={'Baseline','swControl', 'swReward', 'swControl+Reward'};
clr='kgbr';  lst={'-.','--',':','-'}; 

for c=1:nC
 AC=zeros(nR,nIpl);  % Success
 PL=zeros(nR,nIpl);  % Path Length
 SL=zeros(nR,nIpl); % SweepLength
 DC=zeros(nR,nIpl); % ActionSelectionCertainty at final step
  
 for r=1:nR
   nTm=MH{r,c}.i;                                               % Number of time ticks
   nTr=MH{r,c}.ntrials;                                         % Actual number of trials to consider
   AC(r,:)=resampleivo(single(MH{r,c}.path.success(1:nTr)),1:nTr,nTr/nIpl); 
   PL(r,:)=resampleivo(single(MH{r,c}.path.len(1:nTr)),1:nTr,nTr/nIpl);
   % Action selection sweep
   SL(r,:)=resampleivo(single(MH{r,c}.lsweep(1:nTm)),1:nTm,nTm/nIpl,nIpl);
   DC(r,:)=resampleivo(single(MH{r,c}.cert(1:nTm)),1:nTm,nTm/nIpl,nIpl);   % Certainty at the point of decision
 end
 mAC=mean(AC,1)*100; sAC=std(AC,[],1)*100/sqrt(nR);
 mPL=mean(PL,1);     sPL=std(PL,[],1)/sqrt(nR);
 % Sweep
 mSL=mean(SL,1);     sSL=std(SL,[],1)/sqrt(nR);
 mDC=mean(DC,1);     sDC=std(DC,[],1)/sqrt(nR);
 
 if nR>1, nplt=4;
  subplot(1,nplt,1); hold on; hpl1(c)=plot(Ipl,mAC,clr(c),'LineWidth',3,'LineStyle',lst{c}); plot(Ipl,mAC-sAC,clr(c),'LineWidth',1,'LineStyle',lst{c});  plot(Ipl,mAC+sAC,clr(c),'LineWidth',1,'LineStyle',lst{c});
  subplot(1,nplt,2); hold on;         plot(Ipl,mPL,clr(c),'LineWidth',3,'LineStyle',lst{c}); plot(Ipl,mPL-sPL,clr(c),'LineWidth',1,'LineStyle',lst{c});  plot(Ipl,mPL+sPL,clr(c),'LineWidth',1,'LineStyle',lst{c});
  subplot(1,nplt,3); hold on;         plot(Ipl,mSL,clr(c),'LineWidth',3,'LineStyle',lst{c}); plot(Ipl,mSL-sSL,clr(c),'LineWidth',1,'LineStyle',lst{c});  plot(Ipl,mSL+sSL,clr(c),'LineWidth',1,'LineStyle',lst{c});
  subplot(1,nplt,4); hold on;         plot(Ipl,mDC,clr(c),'LineWidth',3,'LineStyle',lst{c}); plot(Ipl,mDC-sDC,clr(c),'LineWidth',1,'LineStyle',lst{c});  plot(Ipl,mDC+sDC,clr(c),'LineWidth',1,'LineStyle',lst{c});
 else     nplt=4;
  subplot(1,nplt,1); hold on; hpl1(c)=plot(Ipl,mAC,clr(c),'LineWidth',3,'LineStyle',lst{c}); 
  subplot(1,nplt,2); hold on;         plot(Ipl,mPL,clr(c),'LineWidth',3,'LineStyle',lst{c}); 
  subplot(1,nplt,3); hold on;         plot(Ipl,mSL,clr(c),'LineWidth',3,'LineStyle',lst{c});
  subplot(1,nplt,4); hold on;         plot(Ipl,mDC,clr(c),'LineWidth',3,'LineStyle',lst{c});
 end

end

l_cc=MH{1,1}.task.phase.trial_contextcue;

subplot(1,nplt,1); hold on;
  line([1;1]*l_cc,[0;100],'LineStyle',':','LineWidth',1);
  axis tight; set(gca,'FontSize',13,'YLim',[0 100],'LineWidth',2); 
  xlabel('Trial');   ylabel('Percentage success');  title('Accuracy');
  legend(hpl1,Leg,'Location','South');
  
subplot(1,nplt,2); hold on;
  line([1;1]*l_cc,[10;30],'LineStyle',':','LineWidth',1);
  axis tight; set(gca,'FontSize',13,'LineWidth',2,'YLim',[10 30]); 
  xlabel('Trial');   ylabel('Path length'); title('Path length');

subplot(1,nplt,3); hold on;
  line([1;1]*l_cc,[0;7],'LineStyle',':','LineWidth',1);
  axis tight; set(gca,'FontSize',13,'LineWidth',2,'YLim',[0 7]); 
  xlabel('Trial');   ylabel('Control-Sweep Length'); title('Sweep Depth');

subplot(1,nplt,4); hold on;
  line([1;1]*l_cc,[0;1],'LineStyle',':','LineWidth',1);
  axis tight; set(gca,'FontSize',13,'LineWidth',2,'YLim',[0 1]);
  xlabel('Trial');   ylabel('Certainty');
  title('Decision certainty');

end
