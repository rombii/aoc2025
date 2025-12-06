const std = @import("std");
const path_oper = "./input_oper";
const path_num = "./input_num";

pub fn main() !void {
    var file_oper = try std.fs.cwd().openFile(path_oper, .{.mode = .read_only});
    defer file_oper.close();

    var buffer_oper: [4 * 1024]u8 = undefined;
    var reader_oper = file_oper.reader(&buffer_oper);

    const allocator = std.heap.page_allocator;
    var list_oper: std.ArrayList(u8) = .empty;
    var line_len: usize = 0;

    while(try reader_oper.interface.takeDelimiter('\n')) |line| {
        line_len = line.len;
        var operators = std.mem.splitAny(u8, line, &[_]u8 {' ', 10});
        while(operators.next()) |oper| {
            const trimmed_oper = std.mem.trim(u8, oper[0..], &[_]u8 {' '});
            if(trimmed_oper.len > 0 and (trimmed_oper[0] == 42 or trimmed_oper[0] == 43)) {
                try list_oper.append(allocator, trimmed_oper[0]);
            }
        }
    }

    var file_num = try std.fs.cwd().openFile(path_num, .{.mode = .read_only});
    defer file_num.close();

    var buffer_num: [16 * 1024]u8 = undefined;
    var reader_num = file_num.reader(&buffer_num);

    var line_count: usize = 0;

    while(try reader_num.interface.takeDelimiter('\n')) |_| {
        line_count += 1;
    }
    
    var col_counter: usize = 0;
    var list_num: std.ArrayList(i64) = .empty;

    for(list_oper.items) |oper| {
        switch (oper) {
            '*' => {
                try list_num.append(allocator, 1);
            },
            '+' => {
                try list_num.append(allocator, 0);
            },
            else => {}
        }
    }

    for(0..line_len) |len| {
        var value: i64 = 0;
        for(0..line_count) |count| {
            const index = len + ((line_len + 1) * count);
            if(buffer_num[index] >= '0' and buffer_num[index] <= '9') {
                value = value * 10 + (buffer_num[index] - '0');
            }
        }
        if(value != 0) {
            switch (list_oper.items[col_counter]) {
                '*' => {
                    list_num.items[col_counter] *= value;
                },
                '+' => {
                    list_num.items[col_counter] += value;
                },
                else => {}
            }
        }
        else {
            col_counter += 1;
        }

    }
    
    var answer2: i64 = 0;

    for(list_num.items) |num| {
        answer2 += num;
    }
    
    std.debug.print("Part 2: {d}\n", .{answer2});

    defer list_oper.deinit(allocator);
}
