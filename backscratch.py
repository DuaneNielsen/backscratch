import numpy as np


x = 1.0
w1 = 1.0
b1 = 1.0
w2 = 1.0
b2 = 1.0
y = 2.0


z1 = w1 * x + b1
a1 = np.tan(z1)
z2 = w2 * a1 + b2
a2 = np.tan(z2)
C = (a2 - y) ** 2

print("z1 " + str(z1) +" a1 " + str(a1) +" z2 " + str(z2) +" a2 " + str(a2) + " C " + str(C))

def sec2(z):
    return 1/(np.cos(z) ** 2)

dC_da2 = 2 * (a2 - y)
print ("dC_da2 " +  str(dC_da2))
da2_dz2 = sec2(z2)
print ("da2_dz2 " +  str(da2_dz2))
dC_dz2 = da2_dz2 * dC_da2
print ("dC_dz2 " +  str(dC_dz2))
dz2_da1 = w2
print ("dz2_da1 " +  str(dz2_da1))
dC_da1 = dz2_da1 * dC_dz2
print ("dC_da1 " +  str(dC_da1))
da1_dz1 = sec2(z1)
print ("da1_dz1 " +  str(da1_dz1))
dC_dz1 = da1_dz1 * dC_da1
print ("dC_dz1 " +  str(dC_dz1))

dz2_dw2 = a1
dz2_db2 = 1.0
dz1_dw1 = a1
dz1_db1 = 1.0

dC_dw2 = dC_dz2 * dz2_dw2
print ("dC_dw2 " +  str(dC_dw2))
dC_db2 = dC_dz2 * dz2_db2
print ("dC_db2 " +  str(dC_db2))
dC_dw1 = dC_dz1 * dz1_dw1
print ("dC_dw1 " +  str(dC_dw1))
dC_db1 = dC_dz1 * dz1_db1
print ("dC_db1 " +  str(dC_db1))

w1 = w1 + dC_dw1
b1 = b1 + dC_db1
w2 = w2 + dC_dw2
b2 = b2 + dC_db2

z1 = w1 * x + b1
a1 = np.tan(z1)
z2 = w2 * a1 + b2
a2 = np.tan(z2)
C = (a2 - y) ** 2

print("z1 " + str(z1) +" a1 " + str(a1) +" z2 " + str(z2) +" a2 " + str(a2) + " C " + str(C))

