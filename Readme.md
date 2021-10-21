# Sudoku solver

## Overview 

This simple project is a Sudoku solver that I implemented in Ada.
The main purpose of this project was to discover and understand backtracking algorithm.

Example of backtracking algorithm

![Exemple](https://upload.wikimedia.org/wikipedia/commons/8/8c/Sudoku_solved_by_bactracking.gif)

## Features

The program provides a command line interface to interact with it :

* ```generate```  : generate a sudoku grid and display it.

* ```play```  : display the same grid but with holes, it is a playable grid with an unique solution.

* ```save```  : save the current grid into a text file. 

* ```load```  : load a grid from a text file. 

* ```resolve```  : resolve the current grid by guessing the numbers in holes.

## Suggested improvements

A way of improvement would be to have an user interface that will allows playing to Sudoku and see the backtracking algorithm working.

A second idea that comes to my mind is to read an incomplete grid from a picture. It will be good trainning because I do not have experiance in image processing.

## Setup

* Clone this projet
```bash
git clone https://github.com/DamDC91/sudoku
```
* Compile it with gprbuild (you need [GNAT](https://www.adacore.com/download))
```bash
gprbuild -p -P main.gpr
```

