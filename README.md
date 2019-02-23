# MBRL - Model-Based Reinforcement Learning for Spatial navigation

This repository provides matlab code for the following *open-access* paper: Stoianov, Pennartz, Lansink, Pezzulo (2018) Model-Based Spatial Navigation in the Hyppocampus-Ventral Striatum Circuit: A Computational Analysis. *Plos Computational Biology*.

https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1006316
https://doi.org/10.1371/journal.pcbi.1006316

The code implements a novel model-based reinforcement learning algorithm that aligns Bayesian nonparametrics and model-based reinforcement learning (MB-RL) to investigate the computations during spatial navigation in the hippocampus (HC) and the ventral striatum (vStr) – a neuronal circuit that is increasingly recognized to be an appropriate model system to understand goal-directed (spatial) decisions and planning mechanisms in the brain. The simulations also investigate the benefits of biological forms of look-ahead prediction (forward sweeps) during both learning and control.

We tested the MB-RL agent in a contextual conditioning task that depends on intact hippocampus and ventral striatal (shell) function and show that the controller solves the task while showing key behavioral and neuronal signatures of the HC-vStr circuit. 

The environment used conduct the investigations is a discrete version of a y-shaped symmetric arena consisting of 3 identical square chambers rotated 120 degrees from each other and connected through a central triangular passage. Each chamber contained three goal locations located along the chamber walls, where reward was (probabilistically) delivered. Each reward location had a cue light above it. The MB-RL control circuit receives as input the combined activity of a set of grid-cells and head-direction unit. Thus, the controller does not receive explicit GPS-like position signal, but just implicit spatial information, which it needs to decode in order to successfully navigate.

## Prerequisites

This is Matlab code. Some slight adaptation might be needed to to run it on the freeware Octave.

## Installing

Get a local copy of this repository (download the zip or clone it with "git clone https://github.com/stoianov/MBRL").
  
## Running the simulations

* Evoke *ymaze_run* in Matlab to train MB-RL agents from scratch to navigate in the ymaze environment. By modifying the *ymaze_run.m* script, you might change the number of replicas per condition and select the conditions to test. The script as it is trains 5 replicas in the 4 learning conditions explored in the paper (with and without sweeps for value learning and action control), which should take about 15 min on a fast quad-core computer training with *parfor* each learning condition (use *for* if you don't have parallel-computung toolbox).

* Evoke "ymaze_plot_ltrend" to show various measures capturing the quality of the learning process. If you don't pass an argument (cell-array with models), the script tries to load from the disk models trained with *ymaze_run*. Please note that each learner uses its own randomly generated set of grid-cells, thus, expect only qualitative-level replication of the results published in the paper, i.e., advantage of MB-RL learning exploiting forward sweeps for both value learning and control. 

## Authors

* **Ivilin Stoianov** - *ideas, algorithm, and code* - [stoianov](https://github.com/stoianov)
* **Giovanni Pezzulo** - *ideas*

## License

This repository is licensed under the MIT License.

If you use the code for research, please cite the paper:  Stoianov IP, Pennartz CMA, Lansink CS, Pezzulo G (2018) Model-based spatial navigation in the hippocampus-ventral striatum circuit: A computational analysis. PLoS Comput Biol 14(9):e1006316. https://doi.org/10.1371/journal.pcbi.1006316

If you use the code for other purposes, please, give appropriate credit as well.

## Acknowledgments

* The code extends previous non-parametric reinforcement learning method implemented by the authors, outlined in the following paper: Stoianov, Genovesio, Pezzulo G., (2018) Prefrontal Goal Codes Emerge as Latent States in Probabilistic Value Learning. *J Cogn Neurosci. 28*, 140–157. 
