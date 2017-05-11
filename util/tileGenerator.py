"""This script is temporary for quick debugging.
Creates a textfile representing a picture-memory storing hexadecimal values
that point to a tile."""

def emptyBoard():
    a=[[]]
    for y in range(60):
        for x in range(80):
            a[y].append("x\"00000005\",")
        if not y == 59:
            a.append([])
    return a
def createBoard():
    board = emptyBoard()
    for x in range(80):
        board[0][x] = "x\"00000000\","
        board[59][x]= "x\"00000000\","
    
    for y in range(60):
        board[y][0] = "x\"00000000\","
        board[y][79]= "x\"00000000\","
    
    for y in range(30,35):
        board[y][4] = "x\"00000002\","
    
    for x in range(4,8):
        board[35][x] = "x\"00000002\","
    board[40][40] = "x\"00000001\","
    return board

def write_board_to_file(board):
    f=open('board','w')
    for line in board:
        f.write(" \n")
        for char in line:
            f.write(char)
        f.write(" \n")
    f.close()

write_board_to_file(createBoard())
