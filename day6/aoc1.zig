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

    while(try reader_oper.interface.takeDelimiter('\n')) |line| {
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

    var list_num: std.ArrayList(i64) = .empty;

    var safe_counter: u8 = 0;

    while(try reader_num.interface.takeDelimiter('\n')) |line| {
        var nums = std.mem.splitAny(u8, std.mem.trim(u8, line, " "), &[_]u8 {' ', 10});
        if(safe_counter == 0) {
            while(nums.next()) |num| {
                const trimmed_num = std.mem.trim(u8, num, &[_]u8 {' '});
                if(trimmed_num.len > 0) {
                    const num_as_int = try std.fmt.parseInt(i64, trimmed_num, 10);
                    try list_num.append(allocator, num_as_int);
                }
            }
        }
        else {
            var num_counter: usize = 0;
            while(nums.next()) |num| {
                const trimmed_num = std.mem.trim(u8, num, &[_]u8 {' '});
                if(trimmed_num.len > 0) {
                    const num_as_int = try std.fmt.parseInt(i64, trimmed_num, 10);
                    switch (list_oper.items[num_counter]) {
                        '*' => {
                            list_num.items[num_counter] *= num_as_int;
                        },
                        '+' => {
                            list_num.items[num_counter] += num_as_int;
                        },
                        else => {}
                    }
                    num_counter += 1;
                }
            }
        }
        safe_counter += 1;
    }

    var answer1: i64 = 0;

    for(list_num.items) |num| {
        answer1 += num;
    }

    std.debug.print("Part 1: {d}\n", .{answer1});

    defer list_oper.deinit(allocator);
    defer list_num.deinit(allocator);
}
