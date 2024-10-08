import sys
from random import randint


def get_width():
    if len(sys.argv) > 2:
        if sys.argv[1] == '-w':
            return int(sys.argv[2])
    return 80 # default width


def extract_words():
    return [x.strip(' ') for x in sys.stdin.read().replace('\n\n', ' __paragraph_break__ ').replace('\n', ' ').replace('\t', ' ').split(' ') if not x == '']


def justify_line(words, width, is_last_line=False):
    spaces = len(words) - 1
    if spaces < 0:
        return
    actual_length = sum(len(word) + 1 for word in words) - 1
    if is_last_line and actual_length / width < 0.8:
        return
    extra_spaces = width - actual_length
    index = randint(0, max(0, spaces-1))
    while extra_spaces > 0:
        words[index] += ' '
        index += 1
        if index > spaces - 1:
            index = 0
        extra_spaces -= 1
    return words


def gen_lines(words, width):
    lines = list()
    current_line = list()
    counter = 0
    for word in words:

        # calculate length + space character
        # create a new line if total cost of current line exceeds width
        # otherwise append word to current line
        cost = len(word) + 1
        if counter + cost > width + 1 or word == '__paragraph_break__':
            lines.append(current_line)
            if not word == '__paragraph_break__':
                current_line = [word]
                counter = cost
            else:
                current_line = list()
                lines.append(list())
                counter = 0
        else:
            counter += cost
            current_line.append(word)
    if not counter == 0:
        lines.append(current_line)

    for n, line in enumerate(lines):
        justify_line(line, width, n == len(lines) - 1)

    return '\n'.join([' '.join(x) for x in lines])
    

if __name__ == '__main__':
    width = get_width()
    words = extract_words()
    text = gen_lines(words, width)
    print(text)

