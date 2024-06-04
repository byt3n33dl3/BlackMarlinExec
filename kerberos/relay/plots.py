import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.colors import colorConverter as cc
import numpy as np
from scipy import ndimage

Hyper_parameter_plot = False

if Hyper_parameter_plot:
    #Help from: https://stackoverflow.com/questions/4700614/how-to-put-the-legend-out-of-the-plot
    fig = plt.figure(figsize=(10,5))
    ax = plt.subplot(111)
    x = np.arange(0,102,2)

    #Ordinary Importance Sampling
    data = np.array(np.load('/content/Priority_DDPG_InvertedPendulum_0_OIS.npy'))
    ax.plot(x,data,label='\u03B2 = 0')

    #Weighted Importance Sampling, annealing from 0 to 1
    data = np.array(np.load('/content/Priority_DDPG_InvertedPendulum_0_WIS_0.npy'))
    ax.plot(x,data,label='\u03B2 = 0 \u2192 1 ')

    #Weighted Importance Sampling, annealing from 0.6 to 1
    data = np.array(np.load('/content/Priority_DDPG_InvertedPendulum_0_WIS_0_6.npy'))
    ax.plot(x,data,label='\u03B2 = 0.6 \u2192 1 ')


    box = ax.get_position()
    ax.set_position([box.x0, box.y0 + box.height * 0.1,
                    box.width, box.height * 0.9])

    ax.legend(loc='upper center', bbox_to_anchor=(0.5, 1.0),
            ncol=3, fancybox=True, shadow=True)

    #plt.legend()
    plt.title('\u03B2 Annealing Schedule', fontsize=18)
    plt.xlabel('time steps (1e3)',fontsize=14)
    plt.ylabel('average return',fontsize=14)
    plt.ylim(-50,1140)
    plt.show()

fig = plt.figure()
x = np.arange(0,102,2)
models = ['','Priority_']
labels = ['uniform replay sampling','prioritized replay sampling']

for i in range(len(models)):
    data = np.zeros([3,51])
    for j in range(3):
        filename = models[i]+'DDPG_InvertedPendulum_'+str(j)+'.npy'
        #print(filename)
        trial_data = np.array(np.load(filename))
        data[j,:] = trial_data

    mean = np.mean(data,axis=0)
    std = np.std(data,axis=0)
    mean = ndimage.uniform_filter(mean, size=3)
    std = ndimage.uniform_filter(std, size=3)
    plt.plot(x,mean,label=labels[i])
    plt.fill_between(x,mean-std,mean+std,alpha=0.15)

plt.legend(loc='lower right')
plt.title('Inverted Pendulum')
plt.xlabel('time steps (1e3)',fontsize=14)
plt.ylabel('average return',fontsize=14)
plt.show()


fig = plt.figure()
x = np.arange(0,102,2)
models = ['','Priority_']
labels = ['uniform replay sampling','prioritized replay sampling']

for i in range(len(models)):
    data = np.zeros([3,51])
    for j in range(3):
        filename = models[i]+'DDPG_Hopper_'+str(j)+'.npy'
        #print(filename)
        trial_data = np.array(np.load(filename))
        data[j,:] = trial_data

    mean = np.mean(data,axis=0)
    std = np.std(data,axis=0)
    mean = ndimage.uniform_filter(mean, size=3)
    std = ndimage.uniform_filter(std, size=3)
    plt.plot(x,mean,label=labels[i])
    plt.fill_between(x,mean-std,mean+std,alpha=0.15)

plt.legend(loc='lower right')
plt.title('Hopper', fontsize=18)
plt.xlabel('time steps (1e3)',fontsize=14)
plt.ylabel('average return',fontsize=14)
plt.show()


envs = ['DDPG_InvertedPendulum','DDPG_Hopper']
models = ['','Priority_']
labels = ['uniform replay sampling','prioritized replay sampling']

for i in range(len(models)):
    for env in envs:
        data = np.zeros([3,51])
        for j in range(3):
            filename = models[i]+env+'_'+str(j)+'.npy'
            #print(filename)
            trial_data = np.array(np.load(filename))
            data[j,:] = trial_data

        max_data = np.max(data,axis=1)
        print(models[i]+env)
        print('mean: ',np.mean(max_data))
        print('standard deviation: ',np.std(max_data))
