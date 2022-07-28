import sys
import os

if len(sys.argv) < 2:
    print(f"./{sys.argv[0]} [outputs directory]")
    exit()

for file in sorted(os.listdir(sys.argv[1]), key=lambda x: int(x.split('.')[0])):
    with open(os.path.join(sys.argv[1], file), 'r', encoding='utf-8') as f:
        x = file.split('.')[0]
        throughput = f.readlines()[65].strip().split('=')[1]
        print('{},{}'.format(x, throughput))
