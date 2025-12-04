import numpy as np
from scipy.signal import convolve2d


def part1(input_data):
    kernel = np.array([[1, 1, 1], [1, 0, 1], [1, 1, 1]])
    convolution = convolve2d(
        input_data, kernel, mode="same", boundary="fill", fillvalue=0
    )
    return (convolution < 4)[input_data == 1].sum()


def part2(input_data):
    kernel = np.array([[1, 1, 1], [1, 0, 1], [1, 1, 1]])
    input_data_copy = input_data.copy()
    total_removed = 0
    while True:
        convolution = convolve2d(
            input_data_copy, kernel, mode="same", boundary="fill", fillvalue=0
        )
        to_remove = (convolution < 4) & (input_data_copy == 1)
        num_removed = to_remove.sum()
        if num_removed == 0:
            break
        total_removed += num_removed
        input_data_copy[to_remove] = 0
    return total_removed


if __name__ == "__main__":
    initial = [
        [0 if x == "." else 1 for x in line.strip()]
        for line in open("day04.txt").readlines()
    ]
    initial_dummy = [
        [0 if x == "." else 1 for x in line.strip()]
        for line in open("day04_dummy.txt").readlines()
    ]

    data = np.array(initial)
    data_dummy = np.array(initial_dummy)
    assert part1(data_dummy) == 13
    assert part2(data_dummy) == 43

    print(part1(data))
    print(part2(data))
