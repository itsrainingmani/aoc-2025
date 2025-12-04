const std = @import("std");
const print = std.debug.print;

const input_test = @embedFile("input-test.txt");
const input = @embedFile("input.txt");

var ID_BUFFER: [64]u8 = undefined;

// An Invalid ID contains a sequence of digits repeated twice
fn isIdInvalid(id: u64) !bool {
    var temp = id;
    var digits: u32 = 0;
    while (temp > 0) : (temp /= 10) digits += 1;

    if (digits % 2 != 0) return false;

    const half = digits / 2;
    const divisor = std.math.pow(u64, 10, half);
    const left = id / divisor;
    const right = id % divisor;

    return left == right;
}

fn isIdInvalid2(id: u64) !bool {
    var temp = id;
    var num_digits: u32 = 0;
    while (temp > 0) : (temp /= 10) num_digits += 1;

    var seq_len: u32 = 1;
    while (seq_len <= num_digits / 2) : (seq_len += 1) {
        if (num_digits % seq_len != 0) continue;

        const divisor = std.math.pow(u64, 10, seq_len);
        const pattern = id % divisor;

        var remaining = id;
        var all_match = true;
        while (remaining > 0) {
            if (remaining % divisor != pattern) {
                all_match = false;
                break;
            }
            remaining /= divisor;
        }

        if (all_match) return true;
    }

    return false;
}

fn part1(file_input: []const u8) !u64 {
    var it = std.mem.tokenizeScalar(u8, file_input, ',');
    var start: u64 = 0;
    var end: u64 = 0;
    var ans: u64 = 0;

    while (it.next()) |range| {
        var ids = std.mem.tokenizeScalar(u8, range, '-');
        const start_str = std.mem.trim(u8, ids.next().?, " \t\n\r");
        const end_str = std.mem.trim(u8, ids.next().?, " \t\n\r");

        start = try std.fmt.parseInt(u64, start_str, 10);
        end = try std.fmt.parseInt(u64, end_str, 10);

        for (start..end + 1) |value| {
            const val = @as(u64, value);
            if (try isIdInvalid(val)) {
                ans += val;
            }
        }
    }
    return ans;
}

fn part2(file_input: []const u8) !u64 {
    var it = std.mem.tokenizeScalar(u8, file_input, ',');
    var start: u64 = 0;
    var end: u64 = 0;
    var ans: u64 = 0;

    while (it.next()) |range| {
        var ids = std.mem.tokenizeScalar(u8, range, '-');
        const start_str = std.mem.trim(u8, ids.next().?, " \t\n\r");
        const end_str = std.mem.trim(u8, ids.next().?, " \t\n\r");

        start = try std.fmt.parseInt(u64, start_str, 10);
        end = try std.fmt.parseInt(u64, end_str, 10);

        for (start..end + 1) |value| {
            const val = @as(u64, value);
            if (try isIdInvalid2(val)) {
                ans += val;
            }
        }
    }
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
