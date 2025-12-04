const std = @import("std");
const path = "./input";

pub fn main() !void {
    var file = try std.fs.cwd().openFile(path, .{.mode = .read_only});
    defer file.close();

    var buffer: [24096]u8 = undefined;
    var reader = file.reader(&buffer);

    var totalCharsInLine: u64 = 0;
    var totalLines: u64 = 0;

    while(try reader.interface.takeDelimiter('\n')) |line| {
        totalLines += 1;
        totalCharsInLine = line.len;
    }

    const directions = [_][2]i8 {
        [_]i8 {-1, -1}, // UL
        [_]i8 {-1, 0},  // U
        [_]i8 {-1, 1},  // UR
        [_]i8 {0, -1},  // L
        [_]i8 {0, 1},   // R
        [_]i8 {1, -1},  // DL
        [_]i8 {1, 0},   // D
        [_]i8 {1, 1},   // DR
    };
    

    var answer1: i64 = 0;
    var answer2: i64 = 0;
    var counter: i32 = 1;
    var removed = true;

    
    while(removed) {
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        const allocator = gpa.allocator();
        var list: std.ArrayList([2]usize) = .empty;

        removed = false;
        
        std.debug.print("Calculating {d} epoch...\n", .{counter});
        
        for(0 .. totalLines) |i| {
            for(0 .. totalCharsInLine) |j| {
                var invalidNeighbours: i64 = 0;
                for(directions) |direction| {
                    const movedI = @as(i65, i) + direction[0];
                    const movedJ = @as(i65, j) + direction[1];

                    if(movedI >= 0 and movedI < totalLines and movedJ >= 0 and movedJ < totalCharsInLine) {
                        if(buffer[std.math.lossyCast(usize, movedI * (totalCharsInLine + 1)) + std.math.lossyCast(usize, movedJ)] == '@') {
                            invalidNeighbours += 1;
                        }
                    }
                }
                if(invalidNeighbours < 4 and buffer[i * (totalCharsInLine + 1) + j] == '@') {

                    try list.append(allocator, [2]usize{i, j});
                    removed = true;
                    answer2 += 1;
                }
            }
        }

        for(0 .. list.items.len) |k| {
            buffer[list.items[k][0] * (totalCharsInLine + 1) + list.items[k][1]] = '.';
        }

        if(counter == 1) {
            answer1 = answer2;
        }
        counter += 1;
        
        defer list.deinit(allocator);
    }


    std.debug.print("Part 1: {d}\nPart 2: {d}", .{answer1, answer2});
}
