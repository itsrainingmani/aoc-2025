const std = @import("std");
const print = std.debug.print;

const input_test = @embedFile("input-test.txt");
const input = @embedFile("input.txt");

fn part1(file_input: []const u8) !i64 {
    var it = std.mem.tokenizeScalar(u8, file_input, '\n');
    var ans: i64 = 0;
    while (it.next()) |line| {
        _ = line;
        ans += 1;
    }
    return ans;
}

fn part2(file_input: []const u8) !i64 {
    var it = std.mem.tokenizeScalar(u8, file_input, '\n');
    var ans: i64 = 0;
    while (it.next()) |line| {
        _ = line;
        ans += 1;
    }
    return ans;
}

pub fn main() !void {
    print("Part 1 (test): {d}\n", .{try part1(input_test)});
    print("Part 1 (real): {d}\n", .{try part1(input)});
    print("Part 2 (test): {d}\n", .{try part2(input_test)});
    print("Part 2 (real): {d}\n", .{try part2(input)});
}
