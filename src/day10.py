from dataclasses import dataclass
from typing import List
import heapq
from tqdm import tqdm
from functools import cache
import numpy as np
from scipy.optimize import linprog


@dataclass
class Problem:
    light_config: str
    buttons: list[tuple]
    joltage: tuple


def read_input(file_path: str) -> List[Problem]:
    with open(file_path, "r") as file:
        lines = file.readlines()

    def parse_line(line: str) -> Problem:
        parts = line.split(" ")
        light_config = parts[0][1:-1]
        buttons = [tuple(map(int, button[1:-1].split(","))) for button in parts[1:-1]]
        joltage = tuple(map(int, parts[-1][1:-1].split(",")))
        return Problem(light_config, buttons, joltage)

    return [parse_line(line.strip()) for line in lines]


@cache
def apply_button(state: str, button: tuple) -> str:
    state_list = list(state)
    for i in button:
        state_list[i] = "#" if state_list[i] == "." else "."
    return "".join(state_list)


def minimum_activations(problem: Problem) -> int:
    initial_state = "." * len(problem.light_config)
    target_state = problem.light_config

    pq = [(0, initial_state)]
    visited = {initial_state: 0}

    while pq:
        activations, current_state = heapq.heappop(pq)

        if current_state == target_state:
            return activations

        if activations > visited.get(current_state, float("inf")):
            continue

        for button in problem.buttons:
            new_state = apply_button(current_state, button)
            new_cost = activations + 1

            if new_state not in visited or new_cost < visited[new_state]:
                visited[new_state] = new_cost
                heapq.heappush(pq, (new_cost, new_state))
    raise ValueError("No solution found to reach the target light configuration.")


def part1(file_path: str) -> int:
    problems = read_input(file_path)
    results = []
    for problem in tqdm(problems, desc="Processing Problems"):
        results.append(minimum_activations(problem))
    return sum(results)


def presses_for_joltage(problem: Problem) -> int:
    # This is a linear equation problem
    # if we call B to the number of button configurations
    # an J to the array of joltage requirements
    # we want to find X such that B * X = J with X >= 0 and X integer
    num_lights = len(problem.joltage)
    num_buttons = len(problem.buttons)

    # A[i][j] = 1 if button j affects light i (models interactions)
    A = np.zeros((num_lights, num_buttons))
    for btn_idx, affected_lights in enumerate(problem.buttons):
        for light_idx in affected_lights:
            A[light_idx, btn_idx] = 1

    J = np.array(problem.joltage)
    c = np.ones(num_buttons)

    # Solve A * x = J, x >= 0
    res = linprog(c, A_eq=A, b_eq=J, bounds=(0, None), integrality=np.ones(num_buttons))

    if res.success:
        return int(round(res.fun))

    raise ValueError("No solution found for the given joltage requirements.")


def part2(file_path: str) -> int:
    problems = read_input(file_path)
    results = []
    for problem in tqdm(problems, desc="Processing Problems for Part 2"):
        results.append(presses_for_joltage(problem))
    return sum(results)


if __name__ == "__main__":
    assert part1("data/day10_dummy.txt") == 7
    print(part1("data/day10.txt"))
    assert part2("data/day10_dummy.txt") == 33
    print(part2("data/day10.txt"))
