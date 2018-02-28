import numpy as np
import math

# test of algorithm for generation of kronecker matrix in CUDA

A = np.arange(4).reshape(2,2)
B = np.arange(6).reshape(2,3)

print(A)
print(B)


def kronecker(A,B):
    R = []
    for row in A:
        C = []
        for column in row.T:
            C.append(column * B)
        R.append(np.hstack(C))
    return np.vstack(R)

K = kronecker(A,B)

print(K)

k_width = K.shape[1]
k_height = K.shape[0]
b_width = B.shape[1]
b_height = B.shape[0]

print(k_width,k_height)

#row/column = address of CUDA cell in grid

#the below algorithm uses a CUDA style set of parameter
# and calculates the value of a cell in a kronecker matrix

for (row,column), value in np.ndenumerate(K):
    a_col = math.floor(column/b_width)
    b_col = column%b_width
    a_row = math.floor(row/b_height)
    b_row = row%b_height
    assert(A[a_row,a_col]*B[b_row,b_col] == value)
