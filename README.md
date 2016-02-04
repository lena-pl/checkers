[![Build Status](https://travis-ci.org/lena-pl/checkers.svg)](https://travis-ci.org/lena-pl/checkers)

# Checkers (English Draughts)

A Ruby on Rails version of the strategy board game checkers.

Setup
---
The game is played on an 8x8 chequered board with 2 piece colours between 2 players, who have 12 mono-coloured pieces each. At the start of the game, the pieces are arranged on the dark squares, on the 3 rows closest to their player.

Moves
---
There are 2 move types in checkers: simple and jump.
* A simple move consists of moving a piece diagonally 1 square forward.
* A jump move requires a player to "jump" over an immediately diagonally adjacent opponent piece to the next empty square. When a jump move is possible, the player must make a jump. Multiple jumps are enforced when the piece ends up in position for one more jump move immediately after completing a jump (even if the next jump is in a different diagonal direction).
A jumped piece is considered "captured" and has to be removed from the board for the rest of the game.

Piece classes
---
There are 2 piece classes in checkers: men and kings.
* Men are standard pieces every player acquires at the start of the game. They may only move diagonally forward.
* Kings are men who made their way to the last row on the opposite side of the board and have therefore been "crowned". Kings may move diagonally forward or backwards.

Winning/Losing
---
A player wins when their opponent has no more pieces or legal moves left. The game may end in a draw if no more legal moves are available to either player or both mutually decide on a draw.
