# -*- coding: utf-8 -*-
'''
Pipe module
'''
import random
from Parameters import PARAS


class Pipe:
    '''
    Define a claas of pipe, including pipe position, pipe size as well as
    score for passing a pair of pipes successfully
    '''
    def __init__(self):
        # Two objects for a pair of pipes, up pipe and down pipe
        self._pipe_width = PARAS["pipePos"][0]
        self._pipe_up_height = PARAS["pipePos"][1]
        self._pipe_down_height = PARAS["pipePos"][2]
        self._score = PARAS["score"]
        # Check if score has been already counted
        self._is_counted = False
        self._is_pass = False

    def move_pipe(self):
        '''
        In this game, a pair of pipes moves towards left at some velocity.
        When the bird has passed it, get a score reward.
        When one pair of pipes disappears in the left side, a new pair
        appears in the right side
        '''
        self._is_pass = False
        self._pipe_width -= PARAS["forward"]
        if self._pipe_width + PARAS["pipeWidth"] < PARAS["birdPos"][0]:
            self._is_pass = True
            if not self._is_counted:
                self._score += 1
                self._is_counted = True
        if self._pipe_width + PARAS["pipeWidth"] <= 0:
            self._pipe_width = PARAS["pipePos"][0]
            self.generate_random_pipe_pair()
            self._is_counted = False

    def generate_random_pipe_pair(self):
        '''
        generate random pipe up and down
        '''
        while True:
            _pipe_up_height = int(random.uniform(200-PARAS["pipeHeight"],
                                                 500-PARAS["pipeInterval"] -
                                                 PARAS["pipeHeight"]))
            _pipe_down_height = PARAS["pipeHeight"] + _pipe_up_height +\
                PARAS["pipeInterval"]
            if _pipe_down_height+PARAS["pipeHeight"] > PARAS["HEIGHT"] and\
               _pipe_down_height < PARAS["HEIGHT"]:
                self._pipe_up_height = _pipe_up_height
                self._pipe_down_height = _pipe_down_height
                break

    def get_score(self):
        '''
        Access to score
        '''
        return self._score

    def get_pipe_width(self):
        '''
        Access to pipe width
        '''
        return self._pipe_width

    def get_pipe_up_height(self):
        '''
        Access to pipe width
        '''
        return self._pipe_up_height

    def get_pipe_down_height(self):
        '''
        Access to pipe down height
        '''
        return self._pipe_down_height

    def is_pass(self):
        '''
        Access _is_pass
        '''
        return self._is_pass
