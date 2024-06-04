import numpy as np

class ReplayBuffer_org(object):
    def __init__(self, capacity=1e6):
        self.buffer = []
        self.capacity = capacity
        #used to track which experience is to be removed next
        self.current_pos = 0

    def add(self, data):
        #If buffer is at capacity, remove the experience that has been in
        #for the longest time and add the new experience in its place
        if len(self.buffer) == self.capacity:
            self.buffer[int(self.current_pos)] = data
            self.current_pos = (self.current_pos + 1) % self.capacity
        #If buffer is not at capacity, just add experience
        else:
            self.buffer.append(data)

    def sample(self, batch_size):
        #get minibatch of indexes
        indexes = np.random.randint(0, len(self.buffer), size=batch_size)
        s, s_new, a, r, d = [], [], [], [], []
        #copy experience data from buffer into minibatch
        for index in indexes:
            states, actions, rewards, new_states, done = self.buffer[index]
            s.append(np.array(states, copy=False))
            a.append(np.array(actions, copy=False))
            r.append(np.array(rewards, copy=False))
            s_new.append(np.array(new_states, copy=False))
            d.append(np.array(done, copy=False))
        #return minibatch of experience data
        return np.array(s), np.array(a), np.array(r).reshape(-1, 1), np.array(s_new), np.array(d).reshape(-1, 1)
