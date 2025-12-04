const std = @import("std");
const print = std.debug.print;

const input_test = @embedFile("input-test.txt");
const input = @embedFile("input.txt");

fn part1(file_input: []const u8) !i32 {
    var it = std.mem.tokenizeScalar(u8, file_input, '\n');
    var dialLoc: i16 = 50;
    var ans: i32 = 0;
    while (it.next()) |token| {
        const rotation: i16 = try std.fmt.parseInt(i16, token[1..], 10);
        var newLoc: i16 = 0;
        if (token[0] == 'R') {
            newLoc = @mod(dialLoc + rotation, 100);
        } else {
            newLoc = @mod(dialLoc - rotation, 100);
        }
        if (newLoc == 0) {
            ans += 1;
        }
        dialLoc = newLoc;
    }
    return ans;
}

fn part2(file_input: []const u8) !i32 {
    var it = std.mem.tokenizeScalar(u8, file_input, '\n');
    var dialLoc: i16 = 50;
    var ans: i32 = 0;
    while (it.next()) |token| {
        const rotation: i16 = try std.fmt.parseInt(i16, token[1..], 10);
        var newLoc: i16 = 0;
        if (token[0] == 'R') {
            newLoc = @mod(dialLoc + rotation, 100);
            const crossings = @divFloor(dialLoc + rotation, 100);
            ans += crossings;
        } else {
            newLoc = @mod(dialLoc - rotation, 100);
            if (dialLoc > 0 and rotation >= dialLoc) {
                const crossings = 1 + @divFloor(rotation - dialLoc, 100);
                ans += crossings;
            } else if (dialLoc == 0) {
                const crossings = @divFloor(rotation, 100);
                ans += crossings;
            }
        }
        dialLoc = newLoc;
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
