const std = @import("std");
const print = std.debug.print;

const input_test = @embedFile("input-test.txt");
const input = @embedFile("input.txt");

fn part1(file_input: []const u8) !u64 {
    var it = std.mem.tokenizeScalar(u8, file_input, '\n');
    var ans: u64 = 0;
    const first_line = it.next().?;
    const starting_pos = std.mem.indexOfScalar(u8, first_line, 'S').?;
    const line_len: usize = first_line.len;

    // Optimistically large even since the max length of the row is 141 characters
    var row_buf = @as(@Vector(256, bool), @splat(false));
    row_buf[starting_pos] = true;

    while (it.next()) |line| {
        for (0..line_len) |i| {
            if (line[i] == '^' and row_buf[i]) {
                ans += 1;
                row_buf[i] = false;
                if (i >= 1) row_buf[i - 1] = true;
                if (i + 1 < line_len) row_buf[i + 1] = true;
            }
        }
    }
    return ans;
}

fn part2(file_input: []const u8) !u64 {
    var it = std.mem.tokenizeScalar(u8, file_input, '\n');
    const first_line = it.next().?;
    const starting_pos = std.mem.indexOfScalar(u8, first_line, 'S').?;
    const line_len: usize = first_line.len;
    var row_buf = @as(@Vector(256, u64), @splat(0));
    row_buf[starting_pos] = 1;
    while (it.next()) |line| {
        for (0..line_len) |i| {
            if (line[i] == '^' and row_buf[i] > 0) {
                const count = row_buf[i];
                row_buf[i] = 0;
                if (i >= 1) row_buf[i - 1] += count;
                if (i + 1 < line_len) row_buf[i + 1] += count;
            }
        }
    }
    return @reduce(.Add, row_buf);
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
