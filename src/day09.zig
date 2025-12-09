const std = @import("std");
const Point = struct { i64, i64 };
const Axis = enum { x, y };
const Range = struct {
    origin: i64,
    end: i64,
    fixed: i64,
    axis: Axis,
};

fn read_input(alloc: std.mem.Allocator, data: []const u8) !std.ArrayList(Point) {
    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    var points = try std.ArrayList(Point).initCapacity(alloc, 1024);
    while (lines.next()) |line| {
        var numbers = std.mem.tokenizeScalar(u8, line, ',');
        const n1 = numbers.next().?;
        const n2 = numbers.next().?;

        try points.append(alloc, .{ try std.fmt.parseInt(i64, n1, 10), try std.fmt.parseInt(i64, n2, 10) });
    }

    return points;
}

fn part1(alloc: std.mem.Allocator, data: []const u8) !i65 {
    var points = try read_input(alloc, data);
    defer points.deinit(alloc);

    var max_area: i65 = 0;

    for (points.items) |p1| {
        for (points.items) |p2| {
            const new_area: i65 = (@abs(p1[0] - p2[0]) + 1) * (@abs(p1[1] - p2[1]) + 1);
            max_area = @max(new_area, max_area);
        }
    }

    return max_area;
}

fn create_range(p1: Point, p2: Point) Range {
    if (p1[0] == p2[0]) {
        return Range{ .axis = Axis.x, .fixed = p1[0], .origin = @min(p1[1], p2[1]), .end = @max(p1[1], p2[1]) };
    }

    return Range{ .axis = Axis.y, .fixed = p1[1], .origin = @min(p1[0], p2[0]), .end = @max(p1[0], p2[0]) };
}

// Functions from day 5
fn ranges_can_be_merged(first: Range, second: Range) bool {
    if (first.axis != second.axis or first.fixed != second.fixed) {
        // If not collinears
        return false;
    }
    const f1, const f2 = .{ first.origin, first.end };
    const s1, const s2 = .{ second.origin, second.end };

    // When an interval CANNOT be merged
    const cond1 = f1 < s1 and f2 < s1;
    const cond2 = f1 > s2 and f2 > s2;

    return !(cond1 or cond2);
}

fn merge_ranges(first: Range, second: Range) Range {
    return Range{ .axis = first.axis, .fixed = first.fixed, .origin = @min(first.origin, second.origin), .end = @max(first.end, second.end) };
}

fn merge_lists(alloc: std.mem.Allocator, ranges: std.ArrayList(Range)) !std.ArrayList(Range) {
    var merged_ranges = try std.ArrayList(Range).initCapacity(alloc, ranges.capacity);

    for (ranges.items) |range| {
        var need_to_be_inserted = true;

        for (merged_ranges.items, 0..) |merged, i| {
            const can_be_merged = ranges_can_be_merged(range, merged);

            if (can_be_merged) {
                need_to_be_inserted = false;
                merged_ranges.items[i] = merge_ranges(range, merged);
            }
        }

        if (need_to_be_inserted) {
            try merged_ranges.append(alloc, range);
        }
    }

    return merged_ranges;
}

fn obtain_simplex(alloc: std.mem.Allocator, point_list: std.ArrayList(Point)) !std.ArrayList(Range) {
    var simplex = try std.ArrayList(Range).initCapacity(alloc, 1024);
    defer simplex.deinit(alloc);
    for (0..(point_list.items.len - 1)) |i| {
        const p1 = point_list.items[i];
        const p2 = point_list.items[i + 1];

        try simplex.append(alloc, create_range(p1, p2));
    }

    // We need to wrap
    const p1 = point_list.items[point_list.items.len - 1];
    const p2 = point_list.items[0];

    try simplex.append(alloc, create_range(p1, p2));

    // Need to merge all ranges to having the simplest expression possible
    var previous_len = simplex.items.len;
    var previous_ranges = try simplex.clone(alloc);
    var merged_ranges = try merge_lists(alloc, simplex);
    defer previous_ranges.deinit(alloc);
    while (merged_ranges.items.len != previous_len) {
        previous_ranges.deinit(alloc);
        previous_ranges = try merged_ranges.clone(alloc);
        merged_ranges.deinit(alloc);

        previous_len = previous_ranges.items.len;
        merged_ranges = try merge_lists(alloc, previous_ranges);
    }

    return merged_ranges;
}

fn line_within_polyedra(line: Range, polyedra: std.ArrayList(Range)) bool {
    for (polyedra.items) |range| {
        if (line.axis != range.axis) {
            continue;
        }
        if (line.fixed != range.fixed) {
            continue;
        }

        const f1, const f2 = .{ line.origin, line.end };
        const r1, const r2 = .{ range.origin, range.end };

        const cond1 = f1 >= r1 and f2 <= r2;

        if (cond1) {
            return true;
        }
    }

    return false;
}

fn rectangle_within_simplex(p1: Point, p2: Point, simplex: std.ArrayList(Range)) bool {
    const upper_left_corner = Point{ @min(p1[0], p2[0]), @max(p1[1], p2[1]) };
    const upper_right_corner = Point{ @max(p1[0], p2[0]), @max(p1[1], p2[1]) };
    const bottom_left_corner = Point{ @min(p1[0], p2[0]), @min(p1[1], p2[1]) };
    const bottom_right_corner = Point{ @max(p1[0], p2[0]), @min(p1[1], p2[1]) };

    const upper_range = create_range(upper_left_corner, upper_right_corner);
    const bottom_range = create_range(bottom_left_corner, bottom_right_corner);
    const left_range = create_range(bottom_left_corner, upper_left_corner);
    const right_range = create_range(bottom_right_corner, upper_right_corner);

    // Debug
    if (std.meta.eql(p1, .{ 2, 3 }) and std.meta.eql(p2, .{ 9, 5 })) {
        std.debug.print("Checking rectangle: UL: {any}, UR: {any}, BL: {any}, BR: {any}\n", .{ upper_left_corner, upper_right_corner, bottom_left_corner, bottom_right_corner });
        const ranges = [_]Range{ upper_range, bottom_range, left_range, right_range };
        for (ranges) |r| {
            std.debug.print("Range: axis: {any}, fixed: {any}, origin: {any}, end: {any}\n", .{ r.axis, r.fixed, r.origin, r.end });
            for (simplex.items) |s| {
                std.debug.print("  Simplex Range: axis: {any}, fixed: {any}, origin: {any}, end: {any}. Falls within: {any}\n", .{ s.axis, s.fixed, s.origin, s.end, line_within_polyedra_via_raycasting(r, simplex) });
            }
        }
    }

    return line_within_polyedra(upper_range, simplex) and
        line_within_polyedra(bottom_range, simplex) and
        line_within_polyedra(left_range, simplex) and
        line_within_polyedra(right_range, simplex);
}

fn part2(alloc: std.mem.Allocator, data: []const u8) !i65 {
    var points = try read_input(alloc, data);
    defer points.deinit(alloc);

    var simplex = try obtain_simplex(alloc, points);
    defer simplex.deinit(alloc);

    var max_area: i65 = 0;

    for (points.items) |p1| {
        for (points.items) |p2| {
            if (!rectangle_within_simplex(p1, p2, simplex)) {
                continue;
            }
            const new_area: i65 = (@abs(p1[0] - p2[0]) + 1) * (@abs(p1[1] - p2[1]) + 1);
            max_area = @max(new_area, max_area);
        }
    }

    return max_area;
}

pub fn main() !void {
    const input = @embedFile("data/day09.txt");
    const alloc = std.heap.smp_allocator;
    const sol1 = try part1(alloc, input);
    std.debug.print("Part 1 {}\n", .{sol1});
    const sol2 = try part2(alloc, input);
    std.debug.print("Part 2 {}\n", .{sol2});
}

test "part 1" {
    const dummy = @embedFile("data/day09_dummy.txt");
    const alloc = std.testing.allocator;

    try std.testing.expectEqual(50, part1(alloc, dummy));
}

test "part 2" {
    const dummy = @embedFile("data/day09_dummy.txt");
    const alloc = std.testing.allocator;

    try std.testing.expectEqual(24, part2(alloc, dummy));
}
