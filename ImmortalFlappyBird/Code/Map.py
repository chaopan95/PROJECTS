# -*- coding: utf-8 -*-
'''
Map constructing module
'''
from pygame.display import update
from pygame.image import load
from Parameters import PARAS


class Map:
    '''
    Define a map class for drawing all needed elements, including background,
    bird, pipes, score etc.
    '''
    def __init__(self, screen, pipe, bird):
        self._screen = screen
        self._background = load(PARAS["images"]["background"])
        self._pipe = pipe
        self._bird = bird
        self._pipe_up = load(PARAS["images"]["pipeUp"])
        self._pipe_down = load(PARAS["images"]["pipeDown"])
        self._bird_action = {True: load(PARAS["images"]["birdUp"]),
                             False: load(PARAS["images"]["birdDown"])}
        self._bird_dead = load(PARAS["images"]["birdDead"])
        self._gameover = load(PARAS["images"]["gameover"])
        self._message = load(PARAS["images"]["message"])
        self._digit_img = {i: load(PARAS["images"]["digitImg"][i])
                           for i in range(10)}
        self._digit_size = {i: self._digit_img[i].get_rect()[2:]
                            for i in range(10)}

    def create_map(self):
        '''
        Creat map with existed stuffs
        '''
        self._screen.blit(self._background, (0, 0))
        _bird_width, _bird_height = self._bird.get_bird_position()
        _pipe_width = self._pipe.get_pipe_width()
        _pipe_up_height = self._pipe.get_pipe_up_height()
        _pipe_down_height = self._pipe.get_pipe_down_height()
        self._screen.blit(self._pipe_up, (_pipe_width, _pipe_up_height))
        self._screen.blit(self._pipe_down, (_pipe_width, _pipe_down_height))

        if self._bird.is_dead():
            rect = self._gameover.get_rect()
            pos_w = (PARAS["WIDTH"]-rect[2])/2
            pos_h = (PARAS["HEIGHT"]-rect[3])/2
            self._screen.blit(self._gameover, (pos_w, pos_h))
            self._screen.blit(self._bird_dead, (_bird_width, _bird_height))
        else:
            self._screen.blit(self._bird_action[self._bird.is_jumping()],
                              (_bird_width, _bird_height))
        self.display_score()
        self._pipe.move_pipe()
        self._bird.move_bird()
        self._bird.update_flapping(False)
        update()

    def display_score(self):
        '''
        Display the current score with images
        '''
        digits = []
        score = self._pipe.get_score()
        score_w = 0

        while True:
            remainder = score % 10
            digits.insert(0, remainder)
            score_w += self._digit_size[remainder][0]
            score = int(score/10)
            if score == 0:
                break
        score_w = (PARAS["WIDTH"]-score_w)/2
        score_h = 0
        for dgt in digits:
            self._screen.blit(self._digit_img[dgt], (score_w, score_h))
            score_w += self._digit_size[dgt][0]
        update()

    def display_message_before_game(self):
        '''
        Before starting the game, display a wellcome interface for players.
        '''
        self._screen.blit(self._background, (0, 0))
        _bird_width, _bird_height = self._bird.get_bird_position()
        _pipe_width = self._pipe.get_pipe_width()
        _pipe_up_height = self._pipe.get_pipe_up_height()
        _pipe_down_height = self._pipe.get_pipe_down_height()
        self._screen.blit(self._pipe_up, (_pipe_width, _pipe_up_height))
        self._screen.blit(self._pipe_down, (_pipe_width, _pipe_down_height))

        self._screen.blit(self._bird_action[self._bird.is_flapping()],
                          (_bird_width, _bird_height))

        rect = self._message.get_rect()
        pos_w = (PARAS["WIDTH"]-rect[2])/2
        pos_h = (PARAS["HEIGHT"]-rect[3])/2
        self._screen.blit(self._message, (pos_w, pos_h))
        update()
