const std = @import("std");
const path = "./input";

pub fn main() !void {
    var file = try std.fs.cwd().openFile(path, .{.mode = .read_only});
    defer file.close();

    var buffer: [4096]u8 = undefined;
    var reader = file.reader(&buffer);
    var answer1: i64 = 0;
    var answer2: i64 = 0;

    while(try reader.interface.takeDelimiter('\n')) |line| {
        // Part 1
        var maxV: u8 = '0';
        var maxVI: usize = undefined;
        for(0 .. line.len - 1) |i| {
            if(line[i] > maxV) {
                maxV = line[i];
                maxVI = i;
            }
        }
        var maxV2: u8 = '0';
        for(maxVI + 1 .. line.len) |i| {
            if(line[i] > maxV2) {
                maxV2 = line[i];
            }
        }

        const num: u8 = try std.fmt.parseInt(u8, &[_]u8 {maxV, maxV2}, 10);
        answer1 += num;

        // Part 2
        var num2V: [12]u8 = undefined;
        var nums2I: [12]usize = undefined;

        for(0 .. 12) |size| {
            num2V[size] = '0';

            const start = switch (size) {
                1...12 => nums2I[size - 1] + 1,
                else => 0
            };

            for(start .. line.len - (11 - size)) |i| {
                if(line[i] > num2V[size]) {
                    num2V[size] = line[i];
                    nums2I[size] = @intCast(i);
                }
            }
        }

        const nums2Int: i64 = try std.fmt.parseInt(i64, &num2V, 10);
        answer2 += nums2Int;

    }
    std.debug.print("Part 1: {d}\nPart 2: {d}", .{answer1, answer2});
}
