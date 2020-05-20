#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Dec 26 14:47:54 2019

@author: panchao
"""
import os
from collections import deque
import random
import sys
import numpy as np
import tensorflow as tf
import pygame
from pygame.display import set_mode, set_caption

from Map import Map
from Bird import Bird
from Pipe import Pipe
from Game import Game
from Parameters import PARAS

IMAGE_SIZE = PARAS["imageSize"]
REGULARIZER = 0.0001
# Channel of image
NUM_CHANNELS = 4
# First convolution layer
CONV1_SIZE = 8
CONV1_KERNEL_NUM = 32
# Second convolution layer
CONV2_SIZE = 4
CONV2_KERNEL_NUM = 64
# Third convolution layer
CONV3_SIZE = 3
CONV3_KERNEL_NUM = 64
# Full connected network input node
FC1_SIZE = 1600
FC2_SIZE = 512
BATCH_SIZE = 32
# Path of saving model
MODEL_SAVE_PATH = "./model/"
MODEL_NAME = "DQN"
# Discount factor
GAMMA = 0.99
# Timesteps to observe before training
OBSERVE = 100000
# Frames over which to anneal epsilon
EXPLORE = 1000000
# Balamcing exploration and exploitation
FINAL_EPSILON = 0.0001
INITIAL_EPSILON = 0.0001
# number of previous transitions to remember
REPLAY_MEMORY = OBSERVE
# Outpout node number
ACTIONS = 2


def get_weight(shape, regularizer=None):
    '''
    Get a weight for y = w*x + b
    '''
    weight = tf.Variable(tf.random.truncated_normal(shape, stddev=0.01))
    if regularizer is not None:
        # Regularization
        tf.add_to_collection("losses", tf.contrib.layers.
                             l2_regularizer(regularizer)(weight))
    return weight


def get_bias(shape):
    '''
    Get a bias for y = w*x + b
    '''
    return tf.Variable(tf.constant(0.01, shape=shape))


def conv2d(x_nodes, weight, stride=1):
    """
    Convolution kenerl
    """
    conv_2d = tf.nn.conv2d(x_nodes, weight, strides=[1, stride, stride, 1],
                           padding="SAME")
    return conv_2d


def max_pool_2x2(x_nodes):
    '''
    Max poolling with in 2x2 table to reduce the size of an image
    '''
    mp2 = tf.nn.max_pool(x_nodes, ksize=[1, 2, 2, 1], strides=[1, 2, 2, 1],
                         padding="SAME")
    return mp2


def forward(states):
    """
    Construct a forward propagation network with 3 convolution layer,
    and 2 fully-connected layers. Finaly output a (2, ) dimension array
    """
    # [8, 8, 4, 32]
    w_conv1 = get_weight(
        [CONV1_SIZE, CONV1_SIZE, NUM_CHANNELS, CONV1_KERNEL_NUM], REGULARIZER
    )
    # [32]
    b_conv1 = get_bias([CONV1_KERNEL_NUM])
    # [4, 4, 32, 64]
    w_conv2 = get_weight(
        [CONV2_SIZE, CONV2_SIZE, CONV1_KERNEL_NUM, CONV2_KERNEL_NUM],
        REGULARIZER
    )
    # [64]
    b_conv2 = get_bias([CONV2_KERNEL_NUM])
    # [3, 3, 64, 64]
    w_conv3 = get_weight(
        [CONV3_SIZE, CONV3_SIZE, CONV2_KERNEL_NUM, CONV3_KERNEL_NUM],
        REGULARIZER
    )
    # [64]
    b_conv3 = get_bias([CONV3_KERNEL_NUM])
    # [1600, 512]
    w_fc1 = get_weight([FC1_SIZE, FC2_SIZE], REGULARIZER)
    # [512]
    b_fc1 = get_bias([FC2_SIZE])
    # [512, 2]
    w_fc2 = get_weight([FC2_SIZE, ACTIONS], REGULARIZER)
    b_fc2 = get_bias([ACTIONS])

    # First convolution layer
    h_conv1 = max_pool_2x2(tf.nn.relu(conv2d(states, w_conv1, 4) + b_conv1))
    # Second convolution layer
    h_conv2 = tf.nn.relu(conv2d(h_conv1, w_conv2, 2) + b_conv2)
    # Third convolution layer
    h_conv3_flat = tf.reshape(tf.nn.relu(conv2d(h_conv2, w_conv3, 1)+b_conv3),
                              [-1, FC1_SIZE])
    # First fully connected layer
    h_fc1 = tf.nn.relu(tf.matmul(h_conv3_flat, w_fc1) + b_fc1)
    # Second fully connected layer
    return tf.matmul(h_fc1, w_fc2) + b_fc2


def backward(sess):
    """
    Back propagation is to ameliorate neural netwrok by dispatching loss value
    """
    # State
    state = tf.placeholder(tf.float32,
                           [None, IMAGE_SIZE, IMAGE_SIZE, NUM_CHANNELS])
    # Action
    action = tf.placeholder(tf.float32, [None, ACTIONS])
    # Q value
    y_val = tf.placeholder(tf.float32, [None])
    # Result by forward network
    readout = forward(state)
    readout_action = tf.reduce_sum(tf.multiply(readout, action),
                                   reduction_indices=1)
    # Loss function
    loss = tf.reduce_mean(tf.square(y_val - readout_action))
    train_step = tf.train.AdamOptimizer(1e-6).minimize(loss)
    # Container for ancient experiences
    queue = deque()
    # Save model
    saver = tf.train.Saver()
    epsilon = INITIAL_EPSILON
    sess.run(tf.global_variables_initializer())
    # Check model path
    if not os.path.exists(MODEL_SAVE_PATH):
        os.mkdir(MODEL_SAVE_PATH)
    # Reload check point files
    checkpoint = tf.train.get_checkpoint_state(MODEL_SAVE_PATH)
    if checkpoint and checkpoint.model_checkpoint_path:
        saver.restore(sess, checkpoint.model_checkpoint_path)
        print("Successfully loaded:", checkpoint.model_checkpoint_path)
    else:
        print("No checkpoint file")
    # Initialize a game
    pygame.init()
    screen = set_mode((PARAS["WIDTH"], PARAS["HEIGHT"]), 0, 32)
    set_caption("Flappy Bird")
    pipe = Pipe()
    bird = Bird()
    game_map = Map(screen, pipe, bird)
    game = Game(screen, pipe, bird)
    # Initial action
    img, reward, is_terminal = game.play_dqn()
    # 4 consective images
    s_t = np.stack((img, img, img, img), axis=2)
    step = 0
    episode = 1
    # In game
    while True:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()
        # Calculate a Q value function
        readout_t = readout.eval(feed_dict={state: [s_t]})[0]
        # Choose an action with epsilon greedy method
        a_t = np.zeros([ACTIONS])
        if random.random() <= epsilon:
            print("----------Random Action----------")
            action_index = np.random.randint(2)
            a_t[action_index] = 1
        else:
            action_index = np.argmax(readout_t)
            a_t[action_index] = 1
        # Diminish the epsilon
        if epsilon > FINAL_EPSILON and step > OBSERVE:
            epsilon -= (INITIAL_EPSILON - FINAL_EPSILON) / EXPLORE
        # Feed the choosen action into the game
        img, reward, is_terminal = game.play_dqn(action_index)
        # Resize the image
        img = np.reshape(img, (IMAGE_SIZE, IMAGE_SIZE, 1))
        # Assembler four consecutive images
        s_t1 = np.append(img, s_t[:, :, :3], axis=2)
        # Put such a tuple into a container
        queue.append((s_t, a_t, reward, s_t1, is_terminal))
        # Container is full
        if len(queue) > REPLAY_MEMORY:
            queue.popleft()
        if step > OBSERVE:
            # Pich up minibatch data randomly
            batch = random.sample(queue, BATCH_SIZE)
            # State
            s_j_batch = [batch[i][0] for i in range(BATCH_SIZE)]
            # Action
            a_batch = [batch[i][1] for i in range(BATCH_SIZE)]
            # Reward
            r_batch = [batch[i][2] for i in range(BATCH_SIZE)]
            # Next state
            s_j1_batch = [batch[i][3] for i in range(BATCH_SIZE)]
            # Updated Q value
            y_batch = []
            readout_j1_batch = readout.eval(feed_dict={state: s_j1_batch})
            for i in range(BATCH_SIZE):
                terminal = batch[i][4]
                # if terminal, only equals reward
                if terminal:
                    y_batch.append(r_batch[i])
                else:
                    y_batch.append(r_batch[i] +
                                   GAMMA * np.max(readout_j1_batch[i]))
            # Train
            train_step.run(feed_dict={y_val: y_batch, action: a_batch,
                                      state: s_j_batch})
        s_t = s_t1
        step += 1
        # Save progress every 10000 iterations
        if step % 10000 == 0:
            saver.save(sess, os.path.join(MODEL_SAVE_PATH, MODEL_NAME),
                       global_step=step)
        stage = ""
        if step <= OBSERVE:
            stage = "observe"
        elif OBSERVE < step <= OBSERVE + EXPLORE:
            stage = "explore"
        else:
            stage = "train"
        print(
            "step: ",
            step,
            "| episode: ",
            episode,
            "| stage: ",
            stage,
            "| epsilon: ",
            epsilon,
            "| action: ",
            action_index,
            "| reward: ",
            reward,
            "| Qmax: %e" % np.max(readout_t),
        )
        if is_terminal:
            # Record a score
            with open("log.txt", "a+") as log:
                log.write("{}\t{}\n".format(episode,
                                            game.get_pipe().get_score()))
            episode += 1
            # Restart a game
            pipe = Pipe()
            bird = Bird()
            game_map = Map(screen, pipe, bird)
            game = Game(screen, pipe, bird)
        game_map.create_map()


def main():
    '''
    Construct a network then train it
    '''
    # Set a session
    sess = tf.InteractiveSession()
    backward(sess)


if __name__ == "__main__":
    main()
