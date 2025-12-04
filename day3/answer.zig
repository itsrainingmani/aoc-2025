const std = @import("std");
const print = std.debug.print;

const input_test = @embedFile("input-test.txt");
const input = @embedFile("input.txt");

fn atod(c: u8) u8 {
    return c - 48;
}

fn voltage(l: u8, r: u8) u8 {
    return atod(l) * 10 + atod(r);
}

fn largestJoltage(bank: []const u8) u8 {
    var left: usize = 0;
    var max_l: usize = left;

    while (left < bank.len - 1) {
        if (atod(bank[max_l]) < atod(bank[left])) {
            max_l = left;
        }
        left += 1;
    }
    var right: usize = max_l + 1;
    var max_r: usize = right;

    while (right < bank.len) {
        if (atod(bank[max_r]) < atod(bank[right])) {
            max_r = right;
        }
        right += 1;
    }

    const max_vol = voltage(bank[max_l], bank[max_r]);
    // print("{d}\n", .{max_vol});
    return max_vol;
}

fn largestJoltage2(bank: []const u8) u64 {
    var result: u64 = 0;
    var prev_idx: usize = 0;

    // First digit: search [0, bank.len - 12]
    var max_idx: usize = 0;
    for (0..bank.len - 11) |idx| {
        if (atod(bank[idx]) > atod(bank[max_idx])) {
            max_idx = idx;
        }
    }
    result = atod(bank[max_idx]);
    prev_idx = max_idx;

    for (1..12) |i| {
        const start = prev_idx + 1;
        const remaining = 11 - i;
        const end = bank.len - remaining;

        max_idx = start;
        for (start..end) |idx| {
            if (atod(bank[idx]) > atod(bank[max_idx])) {
                max_idx = idx;
            }
        }
        result = result * 10 + atod(bank[max_idx]);
        prev_idx = max_idx;
    }

    return result;
}

fn part1(file_input: []const u8) !u64 {
    var it = std.mem.tokenizeScalar(u8, file_input, '\n');
    var ans: u64 = 0;
    while (it.next()) |line| {
        ans += largestJoltage(line);
    }
    return ans;
}

fn part2(file_input: []const u8) !u64 {
    var it = std.mem.tokenizeScalar(u8, file_input, '\n');
    var ans: u64 = 0;
    while (it.next()) |line| {
        ans += largestJoltage2(line);
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
