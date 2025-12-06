const std = @import("std");
const print = std.debug.print;

const input_test = @embedFile("input-test.txt");
const input = @embedFile("input.txt");

const Range = struct { start: u49, end: u49 };

// Comparator function that sorts Range by the start value
fn lessThan(_: void, lhs: Range, rhs: Range) bool {
    return lhs.start < rhs.start;
}

fn part1(file_input: []const u8) !u64 {
    var it = std.mem.tokenizeSequence(u8, file_input, "\n\n");
    var ans: u64 = 0;
    var ranges_iterator = std.mem.tokenizeScalar(u8, it.next().?, '\n');
    var ingredients_iterator = std.mem.tokenizeScalar(u8, it.next().?, '\n');

    // ID range needs 49 bits minimum to represent it
    // ingredient ID needs 49 bits minimum to represent it

    var gpa_backing = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa_backing.deinit() == .ok);
    const allocator = gpa_backing.allocator();

    var ranges: std.ArrayList(Range) = .empty;
    while (ranges_iterator.next()) |range| {
        // each range is like <num>-<num>.
        // we can split on each one
        var rangeit = std.mem.tokenizeScalar(u8, range, '-');
        const range_start = try std.fmt.parseInt(u49, rangeit.next().?, 10);
        const range_end = try std.fmt.parseInt(u49, rangeit.next().?, 10);
        try ranges.append(allocator, Range{ .start = range_start, .end = range_end });
    }

    // sort the ranges by the start value
    std.mem.sort(Range, ranges.items, {}, lessThan);
    // Merge the ranges now
    var merged: std.ArrayList(Range) = .empty;
    defer merged.deinit(allocator);

    var first = ranges.items[0];
    for (1..ranges.items.len) |idx| {
        const curr = ranges.items[idx];

        if (curr.start <= first.end) {
            if (curr.end > first.end) {
                first.end = curr.end;
            }
        } else {
            // if no overlap, add the previous merged interval
            try merged.append(allocator, first);
            first = curr;
        }
    }
    try merged.append(allocator, first);
    ranges.deinit(allocator);

    while (ingredients_iterator.next()) |ingredientID| {
        const ingredient = try std.fmt.parseInt(u49, ingredientID, 10);
        for (merged.items) |range| {
            if (ingredient >= range.start and ingredient <= range.end) {
                ans += 1;
                break;
            }
        }
    }
    return ans;
}

fn part2(file_input: []const u8) !u64 {
    var it = std.mem.tokenizeSequence(u8, file_input, "\n\n");
    var ans: u64 = 0;
    var ranges_iterator = std.mem.tokenizeScalar(u8, it.next().?, '\n');

    // ID range needs 49 bits minimum to represent it
    // ingredient ID needs 49 bits minimum to represent it

    var gpa_backing = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa_backing.deinit() == .ok);
    const allocator = gpa_backing.allocator();

    var ranges: std.ArrayList(Range) = .empty;
    while (ranges_iterator.next()) |range| {
        // each range is like <num>-<num>.
        // we can split on each one
        var rangeit = std.mem.tokenizeScalar(u8, range, '-');
        const range_start = try std.fmt.parseInt(u49, rangeit.next().?, 10);
        const range_end = try std.fmt.parseInt(u49, rangeit.next().?, 10);
        try ranges.append(allocator, Range{ .start = range_start, .end = range_end });
    }

    // sort the ranges by the start value
    std.mem.sort(Range, ranges.items, {}, lessThan);
    // Merge the ranges now
    var merged: std.ArrayList(Range) = .empty;
    defer merged.deinit(allocator);

    var first = ranges.items[0];
    for (1..ranges.items.len) |idx| {
        const curr = ranges.items[idx];

        if (curr.start <= first.end) {
            if (curr.end > first.end) {
                first.end = curr.end;
            }
        } else {
            // if no overlap, add the previous merged interval
            try merged.append(allocator, first);
            first = curr;
        }
    }
    try merged.append(allocator, first);

    for (merged.items) |range| {
        ans += (range.end - range.start + 1);
    }
    ranges.deinit(allocator);
    return ans;
}

pub fn main() !void {
    var timer = try std.time.Timer.start();

    const p1_test_start = timer.read();
    const p1_test = try part1(input_test);
    const p1_test_time = timer.read() - p1_test_start;
    print("Part 1 (test): {d} ({d:.2}ms)\n", .{ p1_test, @as(f64, @floatFromInt(p1_test_time)) / std.time.ns_per_ms });

    const p1_real_start = timer.read();
    const p1_real = try part1(input);
    const p1_real_time = timer.read() - p1_real_start;
    print("Part 1 (real): {d} ({d:.2}ms)\n", .{ p1_real, @as(f64, @floatFromInt(p1_real_time)) / std.time.ns_per_ms });

    const p2_test_start = timer.read();
    const p2_test = try part2(input_test);
    const p2_test_time = timer.read() - p2_test_start;
    print("Part 2 (test): {d} ({d:.2}ms)\n", .{ p2_test, @as(f64, @floatFromInt(p2_test_time)) / std.time.ns_per_ms });

    const p2_real_start = timer.read();
    const p2_real = try part2(input);
    const p2_real_time = timer.read() - p2_real_start;
    print("Part 2 (real): {d} ({d:.2}ms)\n", .{ p2_real, @as(f64, @floatFromInt(p2_real_time)) / std.time.ns_per_ms });
}
