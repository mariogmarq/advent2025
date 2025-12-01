const std = @import("std");
const input = @embedFile("day01.txt");

fn part1() !void {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var position_dial: i32 = 50;
    var times_pointed_at_0: i32 = 0;
    while (lines.next()) |line| {
        const direction: i32 = if (line[0] == 'R') 1 else -1;
        const amount = try std.fmt.parseInt(i32, line[1..], 10);
        position_dial = @mod(direction * amount + position_dial, 100);

        if (position_dial == 0) {
            times_pointed_at_0 += 1;
        }
    }

    std.debug.print("Part 1: {d}\n", .{times_pointed_at_0});
}

fn part2() !void {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var position_dial: i32 = 50;
    var times_pointed_at_0: i32 = 0;
    while (lines.next()) |line| {
        const direction: i32 = if (line[0] == 'R') 1 else -1;
        var amount = try std.fmt.parseInt(i32, line[1..], 10);

        const full_loop = @divTrunc(amount, 100);
        amount -= 100 * full_loop;
        times_pointed_at_0 += full_loop;

        const new_position_dial = @mod(direction * amount + position_dial, 100);
        if (((direction == 1 and new_position_dial < position_dial) or (direction == -1 and new_position_dial > position_dial)) and new_position_dial != 0 and position_dial != 0) {
            times_pointed_at_0 += 1;
        }

        position_dial = new_position_dial;

        if (position_dial == 0) {
            times_pointed_at_0 += 1;
        }
    }

    std.debug.print("Part 2: {d}\n", .{times_pointed_at_0});
}

pub fn main() !void {
    try part1();
    try part2();
}
