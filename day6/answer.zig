const std = @import("std");
const print = std.debug.print;

const Accumulator = struct { Adds: u128, Muls: u128 };

const input_test = @embedFile("input-test.txt");
const input = @embedFile("input.txt");

fn part1(file_input: []const u8) !u128 {
    var it = std.mem.tokenizeScalar(u8, file_input, '\n');
    var ans: u128 = 0;

    var gpa_backing = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa_backing.deinit() == .ok);
    const allocator = gpa_backing.allocator();

    const first_line = it.next().?;
    var fit = std.mem.tokenizeScalar(u8, first_line, ' ');
    var accoom: std.ArrayList(Accumulator) = .empty;
    defer accoom.deinit(allocator);

    while (fit.next()) |num| {
        const numeric_value = try std.fmt.parseInt(u16, num, 10);
        try accoom.append(allocator, Accumulator{ .Adds = numeric_value, .Muls = numeric_value });
    }

    while (it.next()) |line| {
        var num_idx: usize = 0;
        var num_it = std.mem.tokenizeScalar(u8, line, ' ');
        if (it.peek() == null) {
            while (num_it.next()) |op| {
                if (std.mem.eql(u8, op, "*")) {
                    ans += accoom.items[num_idx].Muls;
                } else {
                    ans += accoom.items[num_idx].Adds;
                }
                num_idx += 1;
            }
        } else {
            while (num_it.next()) |num| {
                const numeric_value = try std.fmt.parseInt(u16, num, 10);
                // print("{d} at {d}\n", .{ numeric_value, num_it.index });
                accoom.items[num_idx].Adds += numeric_value;
                accoom.items[num_idx].Muls *= numeric_value;
                num_idx += 1;
            }
        }
    }
    return ans;
}

fn reverse(buffer: []u8, s: []const u8) []u8 {
    for (0..s.len) |i| {
        buffer[s.len - 1 - i] = s[i];
    }
    return buffer[0..s.len];
}

fn part2(file_input: []const u8) !u128 {
    var ans: u128 = 0;
    var max_width: usize = 0;
    const trimmed = std.mem.trim(u8, file_input, "\n");
    var it = std.mem.splitScalar(u8, trimmed, '\n');
    var num_lines: usize = 0;

    var gpa_backing = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa_backing.deinit() == .ok);
    const allocator = gpa_backing.allocator();
    var ops_list: std.ArrayList([]const u8) = .empty;
    defer ops_list.deinit(allocator);

    while (it.next()) |line| {
        max_width = @max(max_width, line.len);
        num_lines += 1;

        if (it.peek() == null) {
            var ops_it = std.mem.tokenizeScalar(u8, line, ' ');
            while (ops_it.next()) |op| {
                try ops_list.append(allocator, op);
            }
        }
    }
    num_lines -= 1;
    it.reset();

    const matrix = try allocator.alloc(u8, num_lines * max_width);
    defer allocator.free(matrix);

    var line_idx: usize = 0;
    while (it.next()) |line| {
        if (it.peek() == null) {
            break;
        }
        for (0..max_width) |i| {
            const rev_i: usize = max_width - 1 - i;
            const c: u8 = if (rev_i < line.len) line[rev_i] else ' ';
            matrix[(line_idx * max_width) + i] = c;
        }
        line_idx += 1;
    }

    var row_buffer = try allocator.alloc(u8, num_lines);
    defer allocator.free(row_buffer);
    line_idx = 0;
    var calc: u128 = 0;
    for (0..max_width) |r| {
        for (0..num_lines) |c| {
            row_buffer[c] = matrix[c * max_width + r];
        }
        // Remove all spaces, not just leading/trailing
        const trimmed_row = std.mem.trim(u8, row_buffer, " ");
        if (trimmed_row.len > 0) {
            const n = try std.fmt.parseUnsigned(u32, trimmed_row, 10);
            // print("{s} | {d}\n", .{ trimmed_row, line_idx });
            if (calc == 0) {
                calc = n;
            } else {
                if (std.mem.eql(u8, ops_list.items[ops_list.items.len - 1 - line_idx], "+")) {
                    calc += n;
                } else {
                    calc *= n;
                }
            }
        } else {
            ans += calc;
            calc = 0;
            line_idx += 1;
        }
    }
    ans += calc;
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
