import matplotlib.pyplot as plt
import numpy as np
from matplotlib import rc
from os import listdir
from os.path import isfile, join
import csv
import matplotlib.ticker as ticker
import sys
from matplotlib.ticker import StrMethodFormatter

# ----------- params -----------

if len(sys.argv) < 2:
    print(f"./{sys.argv[0]} [target csv file]")
    exit()

# ----- styles -----

csfont = {'fontname': 'CMU Serif'}
plt.rcParams["font.family"] = "CMU Serif"
plt.rcParams['axes.linewidth'] = 1.0
axis_label_font_size = 14
axis_ticks_font_size = 10
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
f.set_figheight(3)

# fig, ax = plt.subplots()

plt.xticks(fontsize=axis_ticks_font_size)
plt.yticks(fontsize=axis_ticks_font_size)
plt.xlabel('Time (s)', **csfont, fontsize=axis_label_font_size)
plt.ylabel('Throughput (mb/s)', **csfont, fontsize=axis_label_font_size)
plt.grid(True, color='0.95')

plt.plot(x, y, marker='.', color='green')
plt.axvline(x=50, color='magenta')
plt.legend(['virtio-net-pci + vhost-net'], fontsize=legend_font_size)
plt.gca().yaxis.set_major_formatter(StrMethodFormatter('{x:,.0f}'))
# first mark
bbox_props = dict(boxstyle="square,pad=0.3", fc="w", ec="k", lw=0.72)
arrowprops = dict(arrowstyle="->", connectionstyle="angle,angleA=0,angleB=60")
kw = dict(xycoords='data', textcoords="axes fraction",
          arrowprops=arrowprops, bbox=bbox_props, ha="right", va="top")
plt.annotate('{}mb/s'.format(y[0]), xy=(x[0], y[0]), xytext=(0.2, 0.3), **kw)
# min mark
minyindex = y.index(min(y))
arrowprops = dict(arrowstyle="->", connectionstyle="angle,angleA=0,angleB=300")
kw = dict(xycoords='data', textcoords="axes fraction",
          arrowprops=arrowprops, bbox=bbox_props, ha="right", va="top")
plt.annotate('{}mb/s'.format(y[minyindex]),
             xy=(x[minyindex], y[minyindex]), xytext=(0.7, 0.3), **kw)


plt.tight_layout()
plt.savefig('netperf.png')
plt.show()
