![maze1 (1)](https://user-images.githubusercontent.com/47477832/176163682-d0bdbbf1-806c-4bbb-be7c-5b4f63a04d6a.png)

Visualisation of various maze generation algorithms, as well as solvers. Plus a maze benchmarker.

### Maze_Visualisation:
- Contains the source code for the application, written in Java/Processing.
- NOTE: Blobby recursive lags on high speeds with low square size

Screenshots:

<img src="https://user-images.githubusercontent.com/47477832/156892125-d57dff65-688d-475c-bf2c-69c9432856af.PNG" width="700">

<img src="https://user-images.githubusercontent.com/47477832/156892108-cf032090-7ba3-44e1-80d3-79f4f40193d4.PNG" width="700">

<img src="https://user-images.githubusercontent.com/47477832/156892029-f8023e79-c3f5-4595-a117-2da54e977e9f.PNG" width="700">

- Generators:
  - Aldous-Broder
  - Backtracker
  - Binary Tree
  - Blobby Recursive
  - Ellers
  - Houston
  - Hunt & Kill
  - Kruskals
  - Prims
  - Recursive Division
  - Sidewinder
  - Wilson's
- Solvers:
  - A* (Manhattan heuristic)
  - Breadth-First Search
  - Depth-First Search (Random)
  - Left-First Depth-First Search
  - Right-First Depth-First Search

### Maze_Tester
- C program that solves a passed maze, mazes are passed as text files where '#' represents a wall and '-' represents an empty square.

```gcc main.c agent.c hash.c stack.c -o solve_maze```
```.\solve_maze.exe "maze.txt" 37 23 1 1 35 21 v```

- This use case would provide the following output:

```
Arguments:
Filename: maze.txt
Number of columns: 37
Number of rows: 23

Imported Maze:
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# - - - - - - - # - - - # - # - - - - - # - # - # - - - # - # - - - - - #
# # # - # - # # # # # - # - # - # - # # # - # - # - # - # - # # # - # - # 
# - - - # - # - - - - - - - # - # - # - - - # - # - # - - - - - # - # - # 
# - # - # - # # # # # - # # # - # # # - # - # - # # # - # # # - # - # # #
# - # - # - # - - - # - - - # - - - - - # - - - - - # - # - - - - - - - # 
# - # # # - # - # - # # # - # - # # # # # # # - # - # - # # # - # # # - #
# - # - - - # - # - - - - - # - # - # - # - - - # - - - - - # - - - # - #
# # # # # - # # # - # - # - # - # - # - # - # # # - # - # - # - # # # - # 
# - - - # - # - - - # - # - # - - - # - # - # - # - # - # - # - # - - - #
# - # # # - # # # - # - # - # - # # # - # - # - # - # # # # # # # # # - # 
# - - - # - # - - - # - # - # - # - # - # - # - - - - - - - # - - - - - #
# - # # # - # # # - # # # - # - # - # - # # # - # - # # # - # # # # # - #
# - - - - - - - - - # - # - # - # - - - # - - - # - # - - - - - - - # - #
# - # - # # # - # - # - # - # - # - # # # - # # # # # # # - # - # - # # #
# - # - # - - - # - - - # - # - - - # - # - # - - - - - # - # - # - # - #
# - # # # - # # # - # - # - # - # # # - # - # - # # # - # - # - # - # - #
# - - - # - # - - - # - # - # - - - # - - - # - - - # - - - # - # - - - # 
# - # # # # # # # - # - # - # - # - # # # - # - # - # # # - # - # # # - #
# - - - # - - - - - # - # - # - # - # - # - # - # - - - # - # - - - # - # 
# # # - # # # # # - # - # - # # # - # - # # # # # # # - # # # - # # # # #
# - - - - - # - - - # - # - - - - - - - # - - - - - - - - - # - - - - - #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

Solution:
[1, 1] -> [2, 1] -> [3, 1] -> [4, 1] -> [5, 1] -> [5, 2] -> [5, 3] -> [5, 4] -> [5, 5] -> [5, 6] -> [5, 7] -> [5, 8] -> [5, 9] -> [5, 10] -> [5, 11] -> [5, 12] -> [5, 13] -> [6, 13] -> [7, 13] -> [8, 13] -> [9, 13] -> [9, 12] -> [9, 11] -> [9, 10] -> [9, 9] -> [9, 8] -> [9, 7] -> [10, 7] -> [11, 7] -> [12, 7] -> [13, 7] -> [13, 8] -> [13, 9] -> [13, 10] -> [13, 11] -> [13, 12] -> [13, 13] -> [13, 14] -> [13, 15] -> [13, 16] -> [13, 17] -> [13, 18] -> [13, 19] -> [13, 20] -> [13, 21] -> [14, 21] -> [15, 21] -> [16, 21] -> [17, 21] -> [17, 20] -> [17, 19] -> [17, 18] -> [17, 17] -> [16, 17] -> [15, 17] -> [15, 16] -> [15, 15] -> [15, 14] -> [15, 13] -> [15, 12] -> [15, 11] -> [15, 10] -> [15, 9] -> [15, 8] -> [15, 7] -> [15, 6] -> [15, 
5] -> [16, 5] -> [17, 5] -> [18, 5] -> [19, 5] -> [19, 4] -> [19, 3] -> [20, 3] -> [21, 3] -> [21, 4] -> [21, 5] -> [22, 5] -> [23, 5] -> [24, 5] -> [25, 5] -> [25, 6] -> [25, 7] -> [25, 8] -> [25, 9] -> [25, 10] -> [25, 11] -> [26, 11] -> [27, 11] -> [28, 11] -> [29, 11] -> [29, 12] -> [29, 13] -> [30, 13] -> [31, 13] -> [31, 14] -> [31, 15] -> [31, 16] -> [31, 17] -> 
[31, 18] -> [31, 19] -> [31, 20] -> [31, 21] -> [32, 21] -> [33, 21] -> [34, 21] -> [35, 21]

Solution on maze:
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# s s s s s - - # - - - # - # - - - - - # - # - # - - - # - # - - - - - #
# # # - # s # # # # # - # - # - # - # # # - # - # - # - # - # # # - # - # 
# - - - # s # - - - - - - - # - # - # s s s # - # - # - - - - - # - # - #
# - # - # s # # # # # - # # # - # # # s # s # - # # # - # # # - # - # # # 
# - # - # s # - - - # - - - # s s s s s # s s s s s # - # - - - - - - - #
# - # # # s # - # - # # # - # s # # # # # # # - # s # - # # # - # # # - #
# - # - - s # - # s s s s s # s # - # - # - - - # s - - - - # - - - # - #
# # # # # s # # # s # - # s # s # - # - # - # # # s # - # - # - # # # - # 
# - - - # s # - - s # - # s # s - - # - # - # - # s # - # - # - # - - - #
# - # # # s # # # s # - # s # s # # # - # - # - # s # # # # # # # # # - #
# - - - # s # - - s # - # s # s # - # - # - # - - s s s s s # - - - - - # 
# - # # # s # # # s # # # s # s # - # - # # # - # - # # # s # # # # # - #
# - - - - s s s s s # - # s # s # - - - # - - - # - # - - s s s - - # - #
# - # - # # # - # - # - # s # s # - # # # - # # # # # # # - # s # - # # # 
# - # - # - - - # - - - # s # s - - # - # - # - - - - - # - # s # - # - #
# - # # # - # # # - # - # s # s # # # - # - # - # # # - # - # s # - # - # 
# - - - # - # - - - # - # s # s s s # - - - # - - - # - - - # s # - - - #
# - # # # # # # # - # - # s # - # s # # # - # - # - # # # - # s # # # - #
# - - - # - - - - - # - # s # - # s # - # - # - # - - - # - # s - - # - # 
# # # - # # # # # - # - # s # # # s # - # # # # # # # - # # # s # # # # #
# - - - - - # - - - # - # s s s s s - - # - - - - - - - - - # s s s s s #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

Agent Moves: 381
Solution Length: 107
```

### Scripts
- Contains the script that iterates over the mazes generated by the generators program and applies the Maze_Tester program in order to create the dataset used in the analysis/visualisation (not uploaded).
