# -*- coding: utf-8 -*-
'''
Game module
'''
import sys
import cv2
import pygame
from pygame import Rect, KEYDOWN, K_ESCAPE, K_UP, K_SPACE, QUIT

from Map import Map
from Bird import Bird
from Pipe import Pipe
from Parameters import PARAS
from utils import capture_screen


class Game():
    '''
    Define a game class which import bird class and pipe class in order to
    execute a game.
    '''
    def __init__(self, screen, pipe, bird):
        self._screen = screen
        self._bird = bird
        self._pipe = pipe
        self._is_train = False

    def check_collision(self):
        '''
        When the bird meet a pipe, groud and roof, this is a collision
        '''
        # Rect(left, top, width, height)
        _bird_w, _bird_h = self._bird.get_bird_position()
        _bird_rect = Rect(_bird_w, _bird_h,
                          PARAS["birdRect"][2], PARAS["birdRect"][3])
        _pipe_width = self._pipe.get_pipe_width()
        _pipe_up_height = self._pipe.get_pipe_up_height()
        _pipe_down_height = self._pipe.get_pipe_down_height()
        _pipe_up_rect = Rect(_pipe_width, _pipe_up_height,
                             PARAS["pipeUpRect"][2], PARAS["pipeHeight"])
        _pipe_down_rect = Rect(_pipe_width, _pipe_down_height,
                               PARAS["pipeDownRect"][2], PARAS["pipeHeight"])
        # Check two rectangle intersect
        if _bird_rect.colliderect(_pipe_up_rect) or\
           _bird_rect.colliderect(_pipe_down_rect):
            self._bird.update_state(True)
        # Check if the bird touches upper bound and lower bound
        if _bird_h+PARAS["birdRect"][3] >= PARAS["HEIGHT"] or _bird_h <= 0:
            self._bird.update_state(True)
        if self._bird.is_dead():
            return True
        return False

    def play_dqn(self, action=0):
        '''
        Input an action, return a state s, a reward and an indicator if
        state s is a terminal
        '''
        if action == 0:
            self._bird.update_flapping(False)
        else:
            self._bird.update_flapping(True)
        if self.check_collision():
            _is_terminal = True
            _reward = PARAS["rewardDead"]
        else:
            _is_terminal = False
            if self._pipe.is_pass():
                _reward = 1
            else:
                _reward = PARAS["rewardLive"]
        _bird_width, _bird_height = self._bird.get_bird_position()
        _pipe_width = self._pipe.get_pipe_width()
        _pipe_up_height = self._pipe.get_pipe_up_height()
        _pipe_down_height = self._pipe.get_pipe_down_height()
        _img = capture_screen(_pipe_width, _pipe_up_height, _pipe_down_height,
                              (_bird_width, _bird_height))
        _img = cv2.resize(_img, (PARAS["imageSize"], PARAS["imageSize"]))
        return _img, _reward, _is_terminal

    def before_game(self, game_map):
        '''
        Before a game, a preparing image for players. They can press espace
        or keyup to start
        '''
        game_map.display_message_before_game()
        while True:
            if self._is_train:
                return
            for event in pygame.event.get():
                if event.type == QUIT or (event.type == KEYDOWN and
                                          event.key == K_ESCAPE):
                    pygame.quit()
                    sys.exit()
                if event.type == KEYDOWN and (event.key == K_SPACE or
                                              event.key == K_UP):
                    return

    def after_game(self, game_map):
        '''
        When the bird is dead, game process arrives here.
        One player have two choice, either restarting the game or
        exit the game.
        for restarting the game, all parameters will be reinitialised.
        '''
        game_map.create_map()
        while True:
            if self._is_train:
                pipe = Pipe()
                bird = Bird()
                game_map = Map(self._screen, pipe, bird)
                game = Game(self._screen, pipe, bird)
                return game, game_map, pipe, bird
            for event in pygame.event.get():
                if event.type == QUIT or (event.type == KEYDOWN and
                                          event.key == K_ESCAPE):
                    pygame.quit()
                    sys.exit()
                if event.type == KEYDOWN and (event.key == K_SPACE or
                                              event.key == K_UP):
                    pipe = Pipe()
                    bird = Bird()
                    game_map = Map(self._screen, pipe, bird)
                    game = Game(self._screen, pipe, bird)
                    return game, game_map, pipe, bird

    def get_pipe(self):
        '''
        Access to pipe protected member
        '''
        return self._pipe
