#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Dec 26 17:13:49 2019

@author: panchao

A set of helpful functions
"""

import numpy as np
from Parameters import PARAS


def capture_screen(_pipe_w, _pipe_up_h,
                   _pipe_down_h, _bird_position):
    '''
    Get a capture of game window as an image filled with 0 or 255
    '''
    _width = PARAS["WIDTH"]
    _height = PARAS["HEIGHT"]
    pipe_width = PARAS["pipeWidth"]
    pipe_height = PARAS["pipeHeight"]
    _bird_w, _bird_h = _bird_position
    bird_width, bird_height = PARAS["birdRect"][2:]
    img = np.zeros((_height, _width))
    img[_bird_h:_bird_h+bird_height,
        _bird_w:_bird_w+bird_width] = 255
    img[:_pipe_up_h+pipe_height,
        _pipe_w:_pipe_w+pipe_width] = 255
    img[_pipe_down_h:, _pipe_w:_pipe_w+pipe_width] = 255
    return img


if __name__ == "__main__":
    capture_screen(200, -300, 350, (10, 250))
