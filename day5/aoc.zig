const std = @import("std");
const pathP1 = "./input1";
const pathP2 = "./input2";

pub fn main() !void {
    var file1 = try std.fs.cwd().openFile(pathP1, .{.mode = .read_only});
    defer file1.close();

    var buffer1: [8192]u8 = undefined;
    var reader1 = file1.reader(&buffer1);

    const allocator = std.heap.page_allocator;
    var list: std.ArrayList([2]u64) = .empty;

    while(try reader1.interface.takeDelimiter('\n')) |line| {
        var ids = std.mem.splitAny(u8, line, &[_]u8 {'-', 10});
        const start = try std.fmt.parseInt(u64, ids.next().?, 10);
        const end = try std.fmt.parseInt(u64, ids.next().?, 10);
        try list.append(allocator, [2]u64 {start, end});
    }


    var file2 = try std.fs.cwd().openFile(pathP2, .{.mode = .read_only});
    defer file2.close();

    var buffer2: [16384]u8 = undefined;
    var reader2 = file2.reader(&buffer2);
    var answer1: i64 = 0;
    var answer2: u64 = 0;

    try bubble_sort(&list.items);
    var currentRangeS = list.items[0][0];
    var currentRangeE = list.items[0][1];

    for(list.items) |range| {
        if(range[0] <= currentRangeE) {
            currentRangeE = @max(range[1], currentRangeE);
        }
        else {
            answer2 += currentRangeE - (currentRangeS - 1);
            currentRangeS = range[0];
            currentRangeE = range[1];
        }
    }
    answer2 += currentRangeE - (currentRangeS - 1);
        
    //if start2 > end1 -> continue
    //else end1 = math.max(end1, end2)

    while(try reader2.interface.takeDelimiter('\n')) |line| {
        const id = try std.fmt.parseInt(u64, line, 10);
        var fresh = false;
        for(list.items) |range| {
            if(id >= range[0] and id <= range[1]) {
                fresh = true;
                break;
            }
        }

        if(fresh) {
            answer1 += 1;
        }
    }

    std.debug.print("{d} {d}", .{answer1, answer2});

    defer list.deinit(allocator);
    
}


pub fn bubble_sort(arr: *[][2]u64) !void {
    for(0 .. arr.*.len) |i| {
        var swapped = false;
        for(0 .. arr.*.len - i - 1) |j| {
            if(arr.*[j][0] > arr.*[j + 1][0]) {
                try swap(arr, j, j + 1);
                swapped = true;
            }
        }

        if(!swapped) {
            break;
        }
    }
}

pub fn swap(arr: *[][2]u64, i: usize, j: usize) !void {
    const temp: [2]u64 = arr.*[i];
    arr.*[i] = arr.*[j];
    arr.*[j] = temp;
}
