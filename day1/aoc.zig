const std = @import("std");

pub fn main() !void {
    const path = "./input";

    var file = try std.fs.cwd().openFile(path, .{.mode = .read_only});
    defer file.close();

    var buffer: [4096]u8 = undefined;
    var reader = file.reader(&buffer);


    var pos: i32 = 50;
    var answer1: i32 = 0;
    var answer2: i32 = 0;

    while(try reader.interface.takeDelimiter('\n')) |line| {
        const value = try std.fmt.parseInt(i32, line[1..], 10);
        const hunds = try std.math.divFloor(i32, value, 100);
        switch (line[0]) {
            'R' => {
                answer2 = answer2 + hunds;
                if(pos + (value - hunds * 100) > 100)
                {
                    answer2 = answer2 + 1;
                }
                pos = @mod(pos + value, 100);
            },
            'L' => {
                answer2 = answer2 + hunds;
                if(pos != 0 and pos - (value - hunds * 100) < 0 )
                {
                    answer2 = answer2 + 1;
                }
                pos = @mod(pos - value + 100, 100);
            },
            else => {}
        }
        if(pos == 0)
        {
            answer1 = answer1 + 1;
            answer2 = answer2 + 1;
        }
    }

    std.debug.print("Part 1: {d}\nPart 2: {d}", .{answer1, answer2});
}
