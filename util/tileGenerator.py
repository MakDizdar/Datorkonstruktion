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
        board[0][x] = "x\"00000005\","
        board[59][x]= "x\"00000005\","
    
    for y in range(60):
        board[y][0] = "x\"00000005\","
        board[y][79]= "x\"00000005\","
    
    for y in range(30,35):
        board[y][4] = "x\"00000002\","
	board[y][7] = "x\"00000002\","
	board[y][9] = "x\"00000002\","
	board[y][11] = "x\"00000002\","
	board[y][14] = "x\"00000002\","
    
    for x in range(4,6):
        board[30][x] = "x\"00000002\","
	board[32][x] = "x\"00000002\","
    board[34][8] = "x\"00000002\","
    for x in range(11,13):
	board[30][x] = "x\"00000002\","
	board[34][x] = "x\"00000002\","
    board[32][15] = "x\"00000002\","
    board[31][16] = "x\"00000002\","
    board[33][16] = "x\"00000002\","
    board[30][17] = "x\"00000002\","
    board[34][17] = "x\"00000002\","
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
