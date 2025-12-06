const std = @import("std");
const dummy_input = @embedFile("day06_dummy.txt");
const input = @embedFile("day06.txt");

const Operator = enum { add, multiply };
const UintList = std.ArrayList(u64);
const StringList = std.ArrayList([]const u8);
const StringMatrix = std.ArrayList(StringList);
const Matrix = std.ArrayList(UintList);
const String = std.ArrayList(u8);

fn part1(alloc: std.mem.Allocator, data: []const u8) !u64 {
    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    var matrix = try Matrix.initCapacity(alloc, 1024);
    defer matrix.deinit(alloc);
    var results = try UintList.initCapacity(alloc, 1024);
    defer results.deinit(alloc);

    while (lines.next()) |line| {
        var numbers = std.mem.tokenizeScalar(u8, line, ' ');
        var i: usize = 0;
        while (numbers.next()) |number| {
            switch (number[0]) {
                '*' => {
                    var total: u64 = 1;
                    for (matrix.items[i].items) |val| {
                        total *= val;
                    }
                    try results.append(alloc, total);
                },
                '+' => {
                    var total: u64 = 0;
                    for (matrix.items[i].items) |val| {
                        total += val;
                    }

                    try results.append(alloc, total);
                },
                else => {
                    if (matrix.items.len <= i) {
                        // Need to create list for this column
                        try matrix.append(alloc, try UintList.initCapacity(alloc, 1024));
                    }
                    var column = &matrix.items[i]; // Important: Need to get this reference or else it doesnt get mutated lol
                    try column.append(alloc, try std.fmt.parseInt(u64, number, 10));
                },
            }

            i += 1;
        }
    }

    var return_value: u64 = 0;
    for (results.items) |val| {
        return_value += val;
    }

    for (matrix.items) |*list| {
        list.deinit(alloc);
    }

    return return_value;
}

fn compute_sizes(alloc: std.mem.Allocator, data: []const u8) !struct { UintList, usize } {
    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    var num_lines: usize = 0;
    var size_of_problems = try UintList.initCapacity(alloc, 1024);
    while (lines.next()) |line| {
        num_lines += 1;
        const is_last_line = std.mem.indexOf(u8, line, &[_]u8{'+'}) != null;
        if (!is_last_line) {
            continue;
        }

        var last_op_pos: usize = 0; // Always some operator at char 0
        for (line[1..], 1..) |value, i| {
            if (value == '+' or value == '*') {
                const size = (i - last_op_pos) - 1;
                try size_of_problems.append(alloc, size);
                last_op_pos = i;
            }
        }

        try size_of_problems.append(alloc, line.len - last_op_pos);
    }

    return .{ size_of_problems, num_lines };
}

pub fn transpose(alloc: std.mem.Allocator, rows: StringList) !StringList {
    var max_width: usize = 0;
    for (rows.items) |row| {
        if (row.len > max_width) max_width = row.len;
    }

    var result = try StringList.initCapacity(alloc, max_width);

    var j: usize = 0;
    while (j < max_width) : (j += 1) {
        var new_col_str = try String.initCapacity(alloc, 1024);

        for (rows.items) |row| {
            try new_col_str.append(alloc, row[j]);
        }

        try result.append(alloc, try new_col_str.toOwnedSlice(alloc));
    }

    return result;
}

fn part2(alloc: std.mem.Allocator, data: []const u8) !u64 {
    var problems_size, const num_lines = try compute_sizes(alloc, data);

    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    var problems = try StringMatrix.initCapacity(alloc, 1024);

    for (0..(num_lines - 1)) |_| {
        const current_line = lines.next().?;
        var index_counter: usize = 0;
        for (problems_size.items, 0..) |size, problem_index| {
            const problem_number = current_line[index_counter..(index_counter + size)];
            index_counter += size + 1;

            if (problems.items.len <= problem_index) {
                try problems.append(alloc, try StringList.initCapacity(alloc, 1024));
            }

            var problem = &problems.items[problem_index];
            try problem.append(alloc, problem_number);
        }
    }

    var transposed_problems = try StringMatrix.initCapacity(alloc, problems.items.len);
    // Free nested memory
    defer {
        for (problems.items) |*problem| {
            problem.deinit(alloc);
        }

        for (transposed_problems.items) |*problem| {
            for (problem.items) |value| {
                alloc.free(value);
            }
            problem.deinit(alloc);
        }
        problems_size.deinit(alloc);
        problems.deinit(alloc);
        transposed_problems.deinit(alloc);
    }

    for (problems.items) |problem| {
        try transposed_problems.append(alloc, try transpose(alloc, problem));
    }

    var operators = std.mem.tokenizeScalar(u8, lines.next().?, ' ');
    var sol: u64 = 0;
    for (transposed_problems.items) |problem| {
        const op = operators.next().?;
        switch (op[0]) {
            '*' => {
                var partial: u64 = 1;
                for (problem.items) |num| {
                    var trimmed_num_iter = std.mem.tokenizeScalar(u8, num, ' ');
                    const trimmed_num = trimmed_num_iter.next().?;
                    const my_num = try std.fmt.parseInt(u64, trimmed_num, 10);

                    partial *= my_num;
                }

                sol += partial;
            },
            '+' => {
                var partial: u64 = 0;
                for (problem.items) |num| {
                    var trimmed_num_iter = std.mem.tokenizeScalar(u8, num, ' ');
                    const trimmed_num = trimmed_num_iter.next().?;
                    const my_num = try std.fmt.parseInt(u64, trimmed_num, 10);
                    partial += my_num;
                }

                sol += partial;
            },
            else => {
                return error.NotValidOp;
            },
        }
    }

    return sol;
}

pub fn main() !void {
    const alloc = std.heap.smp_allocator;
    const sol1 = try part1(alloc, input);
    std.debug.print("Part1: {}\n", .{sol1});
    const sol2 = try part2(alloc, input);
    std.debug.print("Part 2 {}\n", .{sol2});
}

test "part 1" {
    const alloc = std.testing.allocator;
    try std.testing.expectEqual(4277556, part1(alloc, dummy_input));
}

test "part 2" {
    const alloc = std.testing.allocator;
    try std.testing.expectEqual(3263827, part2(alloc, dummy_input));
}
