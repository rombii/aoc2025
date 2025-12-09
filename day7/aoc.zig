const std = @import("std");
const path = "./input";

pub fn main() !void {
    var file = try std.fs.cwd().openFile(path, .{.mode = .read_only});
    defer file.close();

    var buffer: [20 * 1024]u8 = undefined;
    var reader = file.reader(&buffer);
    const firstLine = try reader.interface.takeDelimiter('\n');
    const startPos = std.mem.indexOf(u8, firstLine.?, "S");

    const allocator = std.heap.page_allocator;
    var list: std.ArrayList([2]usize) = .empty;
    try list.append(allocator, [_]usize {startPos.?, 1});
    var answer1: i64 = 0;

    while(try reader.interface.takeDelimiter('\n')) |line| {
        var newList: std.ArrayList([2]usize) = .empty;
        for(list.items) |item| {
            if(line[item[0]] == '^') {
                answer1 += 1;
                if(newList.items.len != 0 and newList.getLast()[0] == item[0] - 1) {
                    const temp = newList.pop().?;
                    try newList.append(allocator, [_]usize {item[0] - 1, temp[1] + item[1]});
                }
                else {
                    try newList.append(allocator, [_]usize {item[0] - 1, item[1]});
                }
                try newList.append(allocator, [_]usize {item[0] + 1, item[1]});
            }
            else {
                if(newList.items.len != 0 and newList.getLast()[0] == item[0]) {
                    const temp = newList.pop().?;
                    try newList.append(allocator, [_]usize {item[0], item[1] + temp[1]});
                }
                else {
                    try newList.append(allocator, [_]usize {item[0], item[1]});
                }
            }
        }

        list = try newList.clone(allocator);
        defer newList.deinit(allocator);
    }

    var answer2: usize = 0;
    for(list.items) |item| {
        answer2 += item[1];
    }
    std.debug.print("Part 1: {d}\nPart 2: {d}\n", .{answer1, answer2});

    defer list.deinit(allocator);
}
