# -*- coding: utf-8 -*-

"""
All parameters for Flappy Bird
"""

# Screen size
WIDTH = 401
HEIGHT = 701

# Pipe size
PIPE_HEIGHT = 500
PIPE_WIDTH = 94
# Pipe position
PIPE_W = WIDTH
PIPE_UP_H = -300
# Interval for up pipe and down pipe
PIPE_INTERVAL = 200
PIPE_DOWN_H = PIPE_HEIGHT + PIPE_UP_H + PIPE_INTERVAL

# Bird position
BIRD_W = 10
BIRD_H = 250
# Bird size
BIRD_WIDTH = 40
BIRD_HEIGHT = 30

# Velocity for pipe moving, bird rising and bird falling
FORWARD = 5
INIT_VAL = -5
GRAVITY = 0.3

# Initial score
SCORE = 0
# Images of digital numbers 0-9
DIGIT_IMAGE = {i: "assets/scores/{}.png".format(i) for i in range(10)}

# Images for all objeccts
IMAGES = {
    "pipeUp": "assets/images/top.png",
    "pipeDown": "assets/images/bottom.png",
    "background": "assets/images/background.png",
    "birdUp": "assets/images/1.png",
    "birdDown": "assets/images/0.png",
    "birdDead": "assets/images/dead.png",
    "message": "assets/images/message.png",
    "gameover": "assets/images/gameover.png",
    "digitImg": DIGIT_IMAGE,
}

# Reward
REWARD_LIVE = 0.1
REWARD_DEAD = -1

# DQN
IMAGE_SIZE = 80

# All parameters
PARAS = {
    "WIDTH": WIDTH,
    "HEIGHT": HEIGHT,
    "pipePos": [PIPE_W, PIPE_UP_H, PIPE_DOWN_H],
    "pipeWidth": PIPE_WIDTH,
    "pipeHeight": PIPE_HEIGHT,
    "pipeInterval": PIPE_INTERVAL,
    "pipeUpRect": (PIPE_W, PIPE_UP_H, PIPE_WIDTH, PIPE_HEIGHT + PIPE_UP_H),
    "pipeDownRect": (PIPE_W, PIPE_DOWN_H, PIPE_WIDTH, HEIGHT),
    "birdPos": (BIRD_W, BIRD_H),
    "birdRect": (BIRD_W, BIRD_H, BIRD_WIDTH, BIRD_HEIGHT),
    "forward": FORWARD,
    "initialVelocity": INIT_VAL,
    "gravity": GRAVITY,
    "score": SCORE,
    "scoreColor": (0, 255, 0),
    "scorePos": (WIDTH / 2, HEIGHT / 4),
    "images": IMAGES,
    "rewardLive": REWARD_LIVE,
    "rewardDead": REWARD_DEAD,
    "imageSize": IMAGE_SIZE,
}
