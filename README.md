# GOLPlay
A simulation of Conway's Game of Life

Ross Metcalfe 2019

Made in one day.
Conways game of life implementation.
Birth and Survive rules can be changed by pressing numbers on the keyboard when the mouse is on the left and right hand side of the screen.
Try mode 3 with rule B3/S2345
Try B1/S123456789
Optimised somewhat over a naive implementation by keeping track of changed (active) cells and only checking the surrounding 8 cells for changes.
Inactive areas can be ignored this way.
Cell changes are drawn instead of drawing the entire grid each frame.
Both these optimisations improved large grid performance significantly
Instead of O(N) where N is the area of the grid, the time complexity scales with number of active cells which is dynamic
