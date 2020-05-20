# -*- coding: utf-8 -*-

'''
Bird module
'''

from Parameters import PARAS


class Bird:
    """
    Define a bird class, including bird position, bird status and bird action.
    In bird status, true is alive and false is dead; in bird action, true is
    for rising and false if for falling
    """

    def __init__(self):
        self._action = {True: 1, False: 0}
        # Check if bird is flapping
        self._is_flapping = False
        self._is_jumping = False
        self._w, self._h = PARAS["birdPos"]
        # Velocity for rise and fall
        self._is_dead = False
        self._initial_velocity = 0
        self._gravity = PARAS["gravity"]
        self._t = 1
        self._h0 = self._h

    def move_bird(self):
        """
        Bird will rise if flapping, otherwise it will fall
        """
        if self._is_flapping:
            self._is_jumping = True
            self._initial_velocity = PARAS["initialVelocity"]
            self._t = 1
            self._h0 = self._h
        if self._initial_velocity + self._gravity * self._t > 0:
            self._is_jumping = False
        self._h = int(self._h0 + self._initial_velocity * self._t +
                      0.5 * self._gravity * self._t ** 2)
        self._t += 1

    def get_bird_position(self):
        '''
        Access to bird posotion
        '''
        return self._w, self._h

    def is_flapping(self):
        '''
        Access to _is_flapping
        '''
        return self._is_flapping

    def update_flapping(self, _is_flapping):
        '''
        Update _is_flapping
        '''
        self._is_flapping = _is_flapping

    def is_jumping(self):
        '''
        Access _is_jumping
        '''
        return self._is_jumping

    def is_dead(self):
        '''
        Access to _is_dead
        '''
        return self._is_dead

    def update_state(self, _is_dead):
        '''
        Update state
        '''
        self._is_dead = _is_dead
