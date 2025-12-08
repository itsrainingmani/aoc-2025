const std = @import("std");
const print = std.debug.print;

const input_test = @embedFile("input-test.txt");
const input = @embedFile("input.txt");

const TEST_CONNECTIONS: u64 = 10;
const REAL_CONNECTIONS: u64 = 1000;

const Connection = struct { a: usize, b: usize, dist: f32 };

fn compare(_: void, a: Connection, b: Connection) std.math.Order {
    return std.math.order(a.dist, b.dist);
}

const Coord = struct {
    X: u32,
    Y: u32,
    Z: u32,
    Circuit: u64,

    pub fn init(x: u32, y: u32, z: u32) Coord {
        const circ = constructHash(x, y, z);
        return Coord{ .X = x, .Y = y, .Z = z, .Circuit = circ };
    }

    fn constructHash(x: u32, y: u32, z: u32) u64 {
        var hasher = std.hash.Wyhash.init(0);
        std.hash.autoHash(&hasher, x);
        std.hash.autoHash(&hasher, y);
        std.hash.autoHash(&hasher, z);
        return hasher.final();
    }

    fn isEqual(self: Coord, b: Coord) bool {
        return self.X == b.X and self.Y == b.Y and self.Z == b.Z;
    }
};

// Comparator function that sorts Range by the start value
fn lessThan(_: void, lhs: Connection, rhs: Connection) bool {
    return lhs.dist < rhs.dist;
}

fn euclidean(a: Coord, b: Coord) f32 {
    const dx: f32 = @as(f32, @floatFromInt(a.X)) - @as(f32, @floatFromInt(b.X));
    const dy: f32 = @as(f32, @floatFromInt(a.Y)) - @as(f32, @floatFromInt(b.Y));
    const dz: f32 = @as(f32, @floatFromInt(a.Z)) - @as(f32, @floatFromInt(b.Z));
    return @sqrt(dx * dx + dy * dy + dz * dz);
}

fn part1(file_input: []const u8, num_connects: u64) !u128 {
    var it = std.mem.tokenizeScalar(u8, file_input, '\n');

    var gpa_backing = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa_backing.deinit() == .ok);
    const allocator = gpa_backing.allocator();

    var circuits = std.AutoHashMap(u64, u64).init(allocator);
    defer circuits.deinit();
    var junctionList: std.ArrayList(Coord) = .empty;
    defer junctionList.deinit(allocator);
    var smallestConnections = std.PriorityQueue(Connection, void, compare).init(allocator, {});
    defer smallestConnections.deinit();

    while (it.next()) |line| {
        var coord_it = std.mem.tokenizeScalar(u8, line, ',');
        const loc = Coord.init(
            try std.fmt.parseInt(u32, coord_it.next().?, 10),
            try std.fmt.parseInt(u32, coord_it.next().?, 10),
            try std.fmt.parseInt(u32, coord_it.next().?, 10),
        );
        try junctionList.append(allocator, loc);
        try circuits.put(loc.Circuit, 1);
    }

    for (junctionList.items, 0..) |juncA, i| {
        var j: usize = i + 1;
        while (j < junctionList.items.len) : (j += 1) {
            const cur_dist = euclidean(juncA, junctionList.items[j]);
            try smallestConnections.add(Connection{
                .a = i,
                .b = j,
                .dist = cur_dist,
            });
        }
    }

    var processed_pairs: u64 = 0;

    while (processed_pairs < num_connects) {
        const conn = smallestConnections.remove();
        const circ_a = junctionList.items[conn.a].Circuit;
        const circ_b = junctionList.items[conn.b].Circuit;

        if (circ_a != circ_b) {
            const old_circuit = circ_b;
            const new_circuit = circ_a;

            for (0..junctionList.items.len) |junc_idx| {
                if (junctionList.items[junc_idx].Circuit == old_circuit) {
                    junctionList.items[junc_idx].Circuit = new_circuit;
                }
            }

            const size_b = circuits.get(old_circuit).?;
            const size_a_ptr = circuits.getPtr(new_circuit).?;
            size_a_ptr.* += size_b;
            _ = circuits.remove(old_circuit);
        }
        processed_pairs += 1;
    }

    var sizes: std.ArrayList(u64) = .empty;
    defer sizes.deinit(allocator);

    var circuit_it = circuits.iterator();
    while (circuit_it.next()) |item| {
        try sizes.append(allocator, item.value_ptr.*);
    }

    std.mem.sort(u64, sizes.items, {}, comptime std.sort.desc(u64));

    const a = sizes.items[0];
    const b = sizes.items[1];
    const c = sizes.items[2];

    return @as(u128, a) * @as(u128, b) * @as(u128, c);
}

fn part2(file_input: []const u8) !u64 {
    var it = std.mem.tokenizeScalar(u8, file_input, '\n');
    var gpa_backing = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa_backing.deinit() == .ok);
    const allocator = gpa_backing.allocator();

    var circuits = std.AutoHashMap(u64, u64).init(allocator);
    defer circuits.deinit();
    var junctionList: std.ArrayList(Coord) = .empty;
    defer junctionList.deinit(allocator);
    var connections = std.PriorityQueue(Connection, void, compare).init(allocator, {});
    defer connections.deinit();

    while (it.next()) |line| {
        var coord_it = std.mem.tokenizeScalar(u8, line, ',');
        const loc = Coord.init(
            try std.fmt.parseInt(u32, coord_it.next().?, 10),
            try std.fmt.parseInt(u32, coord_it.next().?, 10),
            try std.fmt.parseInt(u32, coord_it.next().?, 10),
        );
        try junctionList.append(allocator, loc);
        try circuits.put(loc.Circuit, 1);
    }

    for (junctionList.items, 0..) |juncA, i| {
        var j: usize = i + 1;
        while (j < junctionList.items.len) : (j += 1) {
            const cur_dist = euclidean(juncA, junctionList.items[j]);
            try connections.add(Connection{
                .a = i,
                .b = j,
                .dist = cur_dist,
            });
        }
    }

    while (true) {
        const conn = connections.remove();

        const circ_a = junctionList.items[conn.a].Circuit;
        const circ_b = junctionList.items[conn.b].Circuit;

        if (circ_a != circ_b) {
            const old_circuit = circ_b;
            const new_circuit = circ_a;

            for (0..junctionList.items.len) |junc_idx| {
                if (junctionList.items[junc_idx].Circuit == old_circuit) {
                    junctionList.items[junc_idx].Circuit = new_circuit;
                }
            }

            const size_b = circuits.get(old_circuit).?;
            const size_a_ptr = circuits.getPtr(new_circuit).?;
            size_a_ptr.* += size_b;
            _ = circuits.remove(old_circuit);

            if (circuits.count() == 1) {
                return junctionList.items[conn.a].X * junctionList.items[conn.b].X;
            }
        }
    }
    return 0;
}

pub fn main() !void {
    var timer = try std.time.Timer.start();

    const p1_test_start = timer.read();
    const p1_test = try part1(input_test, TEST_CONNECTIONS);
    const p1_test_time = timer.read() - p1_test_start;
    print("Part 1 (test): {d} ({d:.2}ms)\n", .{ p1_test, @as(f64, @floatFromInt(p1_test_time)) / std.time.ns_per_ms });

    const p1_real_start = timer.read();
    const p1_real = try part1(input, REAL_CONNECTIONS);
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
