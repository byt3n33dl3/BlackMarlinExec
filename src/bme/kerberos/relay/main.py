#Imports
import numpy as np
import torch
import torch.nn as nn
from torch.autograd import Variable
import torch.nn.functional as F
import gym
import time
import random
import pybullet_envs

import DDPG
import original_buffer
import PER_buffer
import utils

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

#Experimental Parameters

#Boolean to specify if we use prioritized experience replay
#False = original DDPG
#True = DDPG + PER
prioritized = True

#specificy PyBullet environment
env_name = "InvertedPendulumBulletEnv-v0"
#env_name = "HopperBulletEnv-v0"

#Set random seed number
seed = 0

#Output format
#True = training and testing results
#False = only testing results are printed
verbose = True


#Fixed Parameters
test_freq = 2000
train_steps = 100000

#DDPG parameters
batch_size = 64
gamma = 0.99
tau = 0.001
buffer_size = 1e6
buffer_size = int(buffer_size)

#PER parameters
prioritized_replay_alpha=0.6
prioritized_replay_beta0=0.4
prioritized_replay_beta_iters=None
prioritized_replay_eps=1e-6


def test_policy(policy):
    episode_rewards = np.zeros(10)
    for i in range(10):
        #reset environment
        #get initial state
        s = env.reset()
        done = False
        #Loop until end of episode
        while not done:
            #get action from policy
            #In testing we do not use exploration noise
            a = policy.get_action(np.array(s))
            #take step in environment with action
            #observe new state, reward and whether the episode is done
            s_new, r, done, _ = env.step(a)
            #add reward to episode reward
            episode_rewards[i] += r
            #update states
            s = s_new
    #calculate average episode reward over 10 tests
    print(np.mean(episode_rewards))
    return np.mean(episode_rewards)


if prioritized:
    file_name = "Priority_DDPG_"+env_name[:-12]+"_"+str(seed)
else:
    file_name = "DDPG_"+env_name[:-12]+"_"+str(seed)

print('Running: '+file_name)

env = gym.make(env_name)

# Set seeds
env.seed(seed)
torch.manual_seed(seed)
np.random.seed(seed)
# environment information
s_dim = env.observation_space.shape[0]
a_dim = env.action_space.shape[0]
a_max = float(env.action_space.high[0])

#Create DDPG policy
policy = DDPG.DDPG(s_dim, a_dim, a_max)

#If we are not doing prioritized experience replay
#Then we use my implementation of the uniform replay buffer
if not prioritized:
    replay_buffer = original_buffer.ReplayBuffer_org()
    beta_schedule = None
#If we are doing prioritized experience replay
#Then we use the OpenAI implementation
else:
    replay_buffer = PER_buffer.PrioritizedReplayBuffer(buffer_size, prioritized_replay_alpha)
    if prioritized_replay_beta_iters is None:
        prioritized_replay_beta_iters = train_steps
    #Create annealing schedule
    beta_schedule = utils.LinearSchedule(prioritized_replay_beta_iters, initial_p=prioritized_replay_beta0, final_p=1.0)

#test policy (at this point policy is just random)
test_scores = [test_policy(policy)]
#Save data file (used for plotting)
np.save("data/%s" % (file_name), test_scores)

total_time = 0
test_time = 0
episode = 0
done = True

t_0 = time.time()

while total_time < train_steps:

    if done:

        if total_time != 0:
            if verbose:
                print("Total Time Steps: "+str(total_time)+ " Episode Reward: "+str(episode_r)+" Runtime: "+str(int(time.time() - t_0)))

            #set beta value used for importance sampling weights
            beta_value = 0
            if prioritized:
                beta_value = beta_schedule.value(total_time)

            #train DDPG
            policy.train(replay_buffer, prioritized, beta_value, prioritized_replay_eps, episode_t, batch_size, gamma)

        #Check if we need to need to test DDPG
        if test_time >= test_freq:
            test_time %= test_freq
            test_scores.append(test_policy(policy))
            np.save("data/%s" % (file_name), test_scores)

        #reset environment
        #get intial state
        #reset episode statistics
        s = env.reset()
        done = False
        episode_r = 0
        episode_t = 0
        episode += 1

    #Given current state, get action
    a = policy.get_action(np.array(s))
    #Apply exploration noise to action
    a = (a + np.random.normal(0, 0.1, size=env.action_space.shape[0])).clip(env.action_space.low, env.action_space.high)
    #Using action, take step in environment, observe new state, reward and episode status
    s_new, r, done, _ = env.step(a)
    done_bool = 0 if episode_t + 1 == env._max_episode_steps else float(done)
    episode_r += r

    # Store data in replay buffer
    if not prioritized:
        replay_buffer.add((s, a, r, s_new, done_bool))
    else:
        replay_buffer.add(s, a, r, s_new, done_bool)

    #update state and episode statistics
    s = s_new
    episode_t += 1
    total_time += 1
    test_time += 1

#Final policy test
test_scores.append(test_policy(policy))
#Save data file (used for plotting)
np.save("data/%s" % (file_name), test_scores)
print(test_scores)
