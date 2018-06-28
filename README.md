# MBRL - Model-Based Reinforcement Learning for Spatial navigation

The repository provides matlab code for Stoianov, Pennartz, Lansink, Pezzulo (2018, in press) Model-Based Spatial Navigation in the Hyppocampus-Ventral Striatum Circuit: A Computational Analysis. *Plos Computational Biology*.

The code implements a novel model-based reinforcement learning algorithm that aligns Bayesian nonparametrics and model-based reinforcement learning (MB-RL) to investigate the computations during spatial navigation of the hippocampus (HC) and the ventral striatum (vStr) – a neuronal circuit that is increasingly recognized to be an appropriate model system to understand goal-directed (spatial) decisions and planning mechanisms in the brain. 

The maze used in this simulation is a y-shaped symmetric arena consisting of 3 identical square chambers rotated 120 degrees from each other and connected through a central triangular passage. Each chamber contained three goal locations located along the chamber walls, where reward was (probabilistically) delivered. Each reward location had a cue light above it. The MBRL control circuit receives as input the combined activity of a set of grid-cells and head-direction unit. Thus, the control circuit does not receive an explicit (GPS-like) position signal, but just a signal caring implicit spatial information, which should be decoded in order to allow successful navigation.

We tested the MB-RL agent in a contextual conditioning task that depends on intact hippocampus and ventral striatal (shell) function and show that it solves the task while showing key behavioral and neuronal signatures of the HC-vStr circuit. 

Our simulations also explore the benefits of biological forms of look-ahead prediction (forward sweeps) during both learning and control. 

## Prerequisites

This is Matlab code. Some slight adaptation might be needed to to run it on the freeware Octave.

## Installing

Get a local copy of this repository (download the zip or clone it with "git clone https://github.com/stoianov/MBRL").
  
## Running the tests

* To train the agents to navigate in the ymaze environment, run in Matlab "ymaze_run". You might want to set the number of replicas per condition. (On a fast quad-core computer, expect some 30 min to train 10 replicas of each of the 4 conditions.)

* To show the training result, run "ymaze_plot_ltrend".

## Authors

* **Ivilin Stoianov** - *ideas, algorithm, and code* - [stoianov](https://github.com/stoianov)
* **Giovanni Pezzulo** - *ideas*

## License

This repository is licensed under the MIT License.

If you use the code for research, cite: Stoianov, Pennartz, Lansink, & Pezzulo (2018, in press). Model-Based Spatial Navigation in the Hyppocampus-Ventral Striatum Circuit: A Computational Analysis. *Plos Computational Biology*.

## Acknowledgments

* The code extends previous non-parametric reinforcement learning method implemented by the authors, outlined here: Stoianov, Genovesio, Pezzulo G., (2018) Prefrontal Goal Codes Emerge as Latent States in Probabilistic Value Learning. *J Cogn Neurosci. 28*, 140–157. 

