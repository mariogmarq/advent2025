const std = @import("std");
const dummy_input = @embedFile("day05_dummy.txt");
const input = @embedFile("day05.txt");

const TupleList = std.ArrayList(struct { u64, u64 });
const ItemList = std.ArrayList(u64);

fn parse_input(alloc: std.mem.Allocator, data: []const u8) !struct { TupleList, ItemList } {
    var input_parts = std.mem.tokenizeSequence(u8, data, "\n\n");
    const first_part = input_parts.next().?;
    const second_part = input_parts.next().?;

    var ranges = try TupleList.initCapacity(alloc, 1024);
    var items = try ItemList.initCapacity(alloc, 2048);

    var range_lines = std.mem.tokenizeScalar(u8, first_part, '\n');
    while (range_lines.next()) |line| {
        var line_parts = std.mem.tokenizeScalar(u8, line, '-');
        const first_number = try std.fmt.parseInt(u64, line_parts.next().?, 10);
        const second_number = try std.fmt.parseInt(u64, line_parts.next().?, 10);

        try ranges.append(alloc, .{ first_number, second_number });
    }

    var item_lines = std.mem.tokenizeScalar(u8, second_part, '\n');
    while (item_lines.next()) |item| {
        try items.append(alloc, try std.fmt.parseInt(u64, item, 10));
    }

    return .{ ranges, items };
}

fn number_in_range(range: struct { u64, u64 }, number: u64) bool {
    const lower, const upper = range;
    return lower <= number and number <= upper;
}

fn part1(ranges: TupleList, items: ItemList) u64 {
    var total: u64 = 0;

    for (items.items) |item| {
        for (ranges.items) |range| {
            const in_range = number_in_range(range, item);
            if (in_range) {
                total += 1;
                break;
            }
        }
    }

    return total;
}

fn ranges_can_be_merged(first: struct { u64, u64 }, second: struct { u64, u64 }) bool {
    const f1, const f2 = first;
    const s1, const s2 = second;

    // When an interval CANNOT be merged
    const cond1 = f1 < s1 and f2 < s1;
    const cond2 = f1 > s2 and f2 > s2;

    return !(cond1 or cond2);
}

fn merge_ranges(first: struct { u64, u64 }, second: struct { u64, u64 }) struct { u64, u64 } {
    const f1, const f2 = first;
    const s1, const s2 = second;

    return .{ @min(f1, s1), @max(f2, s2) };
}

fn merge_lists(alloc: std.mem.Allocator, ranges: TupleList) !TupleList {
    var merged_ranges = try TupleList.initCapacity(alloc, ranges.capacity);

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

fn part2(alloc: std.mem.Allocator, ranges: TupleList) !u64 {
    var previous_len = ranges.items.len;
    var previous_ranges = try ranges.clone(alloc);

    var merged_ranges = try merge_lists(alloc, ranges);
    while (merged_ranges.items.len != previous_len) {
        previous_ranges.deinit(alloc);
        previous_ranges = try merged_ranges.clone(alloc);
        merged_ranges.deinit(alloc);

        previous_len = previous_ranges.items.len;
        merged_ranges = try merge_lists(alloc, previous_ranges);
    }

    previous_ranges.deinit(alloc);

    var total: u64 = 0;
    for (merged_ranges.items) |range| {
        const lower, const upper = range;
        total += (upper - lower) + 1;
    }

    merged_ranges.deinit(alloc);
    return total;
}

pub fn main() !void {
    const alloc = std.heap.page_allocator;
    var ranges, var items = try parse_input(alloc, input);
    defer ranges.deinit(alloc);
    defer items.deinit(alloc);

    const sol1 = part1(ranges, items);
    std.debug.print("Part 1 {}\n", .{sol1});

    const sol2 = try part2(alloc, ranges);
    std.debug.print("Part 2 {}\n", .{sol2});
}

test "part2" {
    const alloc = std.testing.allocator;
    var ranges, var items = try parse_input(alloc, dummy_input);
    defer ranges.deinit(alloc);
    defer items.deinit(alloc);

    const sol2 = try part2(alloc, ranges);
    try std.testing.expectEqual(14, sol2);
}
