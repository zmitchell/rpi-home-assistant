import os
from collections import deque

items = os.listdir('.')
req_filename = [item for item in items if item == 'requirements.txt']
req_filename = req_filename[0]
blacklisted = [
    'nuimo',
    'anel-pwrctrl'
]


def is_blacklisted(line):
    for item in blacklisted:
        if item in line:
            return True
    return False


with open(req_filename, 'r') as req_file:
    patched_lines = deque()
    for line in req_file:
        if is_blacklisted(line) and (line[0] != '#'):
            patched_line = '#' + line
            patched_lines.append(patched_line)
        else:
            patched_lines.append(line)
    with open('patched-requirements.txt', 'w') as patched_file:
        contents = ''.join(patched_lines)
        patched_file.write(contents)


if __name__ == '__main__':
    pass
