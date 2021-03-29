# A script that iterates through all of the mazes in the maze directory, uses the solve_maze 
# C program to solve the maze and retrieve the number of moves, and the length of the solution.
# This information is then written to a text file for visualisation.

import os
import sys
import subprocess

original_stdout = sys.stdout

path = os.getcwd()

outputFile = open('analysis.txt', 'w')

sys.stdout = outputFile

os.chdir('Mazes')

for directory in os.listdir(os.getcwd()):

    os.chdir(directory);

    for subdirectory in os.listdir(os.getcwd()):

        os.chdir(subdirectory)

        rows = subdirectory.split('x')[0];
        columns = subdirectory.split('x')[1];
        currDir = os.getcwd()

        sys.stdout = original_stdout
        print "Analysing Directory: ", os.getcwd().split("Mazes")[1]
        sys.stdout = outputFile

        count = 0
        movesTotal = 0
        solutionTotal = 0

        for maze in os.listdir(os.getcwd()):

           os.chdir(path)

           count+= 1

           output = subprocess.check_output(['./solve_maze', currDir + '/' + maze, rows, columns])
           movesTotal += int(output.decode().split()[0])
           solutionTotal += int(output.decode().split()[1])

           os.chdir(currDir)

        print currDir.split('Mazes/')[1].split('/')[0], str(1000 + int(rows))[1:], str(1000 + int(columns))[1:], str(100000 + (movesTotal/count))[1:], str(100000 + (solutionTotal/count))[1:]

        os.chdir('..')

    os.chdir('..')
