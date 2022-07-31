import sys

if len(sys.argv) < 2:
    print(f"./{sys.argv[0]} [outputs]")
    exit()

with open(sys.argv[1], 'r', encoding='utf-8') as f:
    lc = 1
    for line in f.readlines():
        if "bits/s" in line:
            bitsps = line.strip().split(',')[0]
            print('{},{}'.format(lc, bitsps))
            lc += 1
