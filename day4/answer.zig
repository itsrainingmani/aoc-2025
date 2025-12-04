const std = @import("std");
const print = std.debug.print;

const input_test = @embedFile("input-test.txt");
const input = @embedFile("input.txt");

const Pos = struct { row: isize, col: isize };

const DIRS_8 = [_]Pos{
    .{ .row = -1, .col = 0 }, // up
    .{ .row = 1, .col = 0 }, // down
    .{ .row = 0, .col = -1 }, // left
    .{ .row = 0, .col = 1 }, // right
    .{ .row = -1, .col = -1 }, // up-left
    .{ .row = -1, .col = 1 }, // up-right
    .{ .row = 1, .col = -1 }, // down-left
    .{ .row = 1, .col = 1 }, // down-right
};

fn getCellSafe(data: []const u8, width: usize, height: usize, row: isize, col: isize) ?u8 {
    const h: isize = @intCast(height);
    const w: isize = @intCast(width);
    if (row < 0 or col < 0 or row >= h or col >= w - 1) return null;
    return data[@as(usize, @intCast(row)) * width + @as(usize, @intCast(col))];
}

// calculate 8-fold surrounding rolls
fn countAdjMatches(data: []const u8, width: usize, height: usize, row: usize, col: usize, target: u8) u4 {
    var count: u4 = 0;
    const r: isize = @intCast(row);
    const c: isize = @intCast(col);
    for (DIRS_8) |dir| {
        if (getCellSafe(data, width, height, r + dir.row, c + dir.col)) |cell| {
            if (cell == target) count += 1;
        }
    }

    return count;
}

fn part1(file_input: []const u8) !u64 {
    const width = std.mem.indexOfScalar(u8, file_input, '\n').? + 1;
    const height = file_input.len / width;
    var ans: u64 = 0;

    for (0..height) |row| {
        for (0..width - 1) |col| {
            const cell = file_input[row * width + col];
            if (cell == '@' and countAdjMatches(file_input, width, height, row, col, '@') < 4) {
                ans += 1;
            }
        }
    }

    return ans;
}

fn part2(comptime file_input: []const u8) !u64 {
    // copy of the file_input to modify for part2
    var data = file_input[0..].*;
    const width = std.mem.indexOfScalar(u8, &data, '\n').? + 1;
    const height = data.len / width;
    var rolls_removed: u64 = 0;

    while (true) {
        var removed_in_turn = false;
        for (0..height) |row| {
            for (0..width - 1) |col| {
                const cell = data[row * width + col];
                if (cell == '@' and countAdjMatches(&data, width, height, row, col, '@') < 4) {
                    removed_in_turn = true;
                    rolls_removed += 1;
                    data[row * width + col] = '.';
                }
            }
        }
        if (!removed_in_turn) break;
    }

    return rolls_removed;
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
