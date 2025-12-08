import numpy as np
import pandas as pd
from scipy.spatial import distance_matrix
from math import prod
from dataclasses import dataclass
import time


def flatten_pos_to_2d(pos, shape):
    _, cols = shape
    r = pos // cols
    c = pos % cols
    return np.stack((r, c), axis=1)


def select_points(positions, data):
    return np.stack((data[positions[:, 0]], data[positions[:, 1]]), axis=1)


@dataclass(frozen=True)
class Point:
    x: int
    y: int
    z: int


def part1(filename: str = "data/day08.txt", num_connections: int = 10) -> int:
    inp = pd.read_csv(filename, header=None, sep=",").to_numpy()
    dist_matrix = distance_matrix(inp, inp)
    order = dist_matrix.flatten().argsort()
    sorted_positions = flatten_pos_to_2d(order, dist_matrix.shape)[inp.shape[0] :][
        ::2
    ]  # Skip the diagonal and take every second point to avoid duplicates
    pairs = select_points(sorted_positions, inp)[:num_connections]

    sets = [set([Point(*point.tolist())]) for point in inp]
    for pair in pairs:

        p1, p2 = Point(*pair[0].tolist()), Point(*pair[1].tolist())
        share_set = any(p1 in s and p2 in s for s in sets)
        if share_set:
            continue

        p1_set_index = next(i for i, s in enumerate(sets) if p1 in s)
        p1_set = sets[p1_set_index]
        sets.pop(p1_set_index)

        p2_set_index = next(i for i, s in enumerate(sets) if p2 in s)
        p2_set = sets[p2_set_index]
        sets.pop(p2_set_index)

        merged_set = p1_set.union(p2_set)
        sets.append(merged_set)

    set_sizes = [len(s) for s in sets]
    return prod(sorted(set_sizes)[-3:])


def part2(filename: str = "data/day08.txt") -> int:
    inp = pd.read_csv(filename, header=None, sep=",").to_numpy()
    dist_matrix = distance_matrix(inp, inp)
    order = dist_matrix.flatten().argsort()
    sorted_positions = flatten_pos_to_2d(order, dist_matrix.shape)[inp.shape[0] :][
        ::2
    ]  # Skip the diagonal and take every second point to avoid duplicates
    pairs = select_points(sorted_positions, inp)

    sets = [set([Point(*point.tolist())]) for point in inp]
    for pair in pairs:
        p1, p2 = Point(*pair[0].tolist()), Point(*pair[1].tolist())
        share_set = any(p1 in s and p2 in s for s in sets)
        if share_set:
            continue

        p1_set_index = next(i for i, s in enumerate(sets) if p1 in s)
        p1_set = sets[p1_set_index]
        sets.pop(p1_set_index)

        p2_set_index = next(i for i, s in enumerate(sets) if p2 in s)
        p2_set = sets[p2_set_index]
        sets.pop(p2_set_index)

        merged_set = p1_set.union(p2_set)
        sets.append(merged_set)

        if len(sets) == 1:
            return p1.x * p2.x

    raise ValueError


if __name__ == "__main__":
    assert part1("data/day08_dummy.txt") == 40
    assert part2("data/day08_dummy.txt") == 216 * 117

    begin = time.time()
    print(part1("data/day08.txt", num_connections=1000))
    print(part2("data/day08.txt"))
    end = time.time()
    print(f"Execution time: {end - begin:.4f} seconds")
