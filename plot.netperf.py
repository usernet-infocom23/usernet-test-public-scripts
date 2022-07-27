import matplotlib.pyplot as plt
import numpy as np
from matplotlib import rc
from os import listdir
from os.path import isfile, join
import csv
import matplotlib.ticker as ticker
import sys

# ----------- params -----------

if len(sys.argv) < 2:
    print(f"./{sys.argv[0]} [target csv file]")
    exit()

# ----- styles -----

csfont = {'fontname': 'CMU Serif'}
plt.rcParams["font.family"] = "CMU Serif"
plt.rcParams['axes.linewidth'] = 2.0
axis_label_font_size = 18
axis_ticks_font_size = 18
legend_font_size = 10

# ----------- data ------------

# ----- throughput -----
data = csv.reader(open(sys.argv[1], newline='',
                  encoding='utf-8'), delimiter=',')

x = []
y = []

for row in data:
    x.append(float(row[0]))
    y.append(float(row[1]))

f = plt.figure()
f.set_figwidth(6)
f.set_figheight(4)

plt.plot(x, y)
plt.xlabel('Seconds', **csfont, fontsize=axis_label_font_size)
plt.ylabel('Throughput', **csfont, fontsize=axis_label_font_size)
plt.grid(True, color='0.95')

plt.savefig('netperf.png')
