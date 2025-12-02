const std = @import("std");
const path = "./input";

pub fn main() !void {
    var file = try std.fs.cwd().openFile(path, .{.mode = .read_only});
    defer file.close();

    var buffer: [4096]u8 = undefined;
    var reader = file.reader(&buffer);

    var answer1: i64 = 0;
    var answer2: i64 = 0;

    while(try reader.interface.takeDelimiter(',')) |range| {
        var ids = std.mem.splitAny(u8, range, &[_]u8 {'-', 10});
        // Not looping through them cuz we have contraint that ids are in pairs
        var first = try std.fmt.parseInt(i64, ids.next().?, 10);
        const sec = try std.fmt.parseInt(i64, ids.next().?, 10);

        std.debug.print("Calculating range: {d} - {d}\n", .{first, sec});

        num_loop: while(first <= sec) : (first += 1)
        { 
            const allocator = std.heap.page_allocator;
            const id = try std.fmt.allocPrint(allocator, "{d}", .{first});
            const n = @divFloor(id.len, 2);
            var size: usize = 1;
            var possible = true;
            size_loop: while(size <= n) : (size += 1)
            {
                if(id.len % size != 0)
                {
                    continue;    
                }
                
                const sample = id[0 .. size];

                var i = size * 2;
                while(i <= id.len) : (i += size)
                {
                    possible = std.mem.eql(u8, sample, id[i - size .. i]);

                    if(!possible)
                    {
                        continue :size_loop;
                    }

                }
                
                if(possible)
                {
                    const idFH = id[0..id.len/2];
                    const idSH = id[id.len/2 .. id.len];
                    if(std.mem.eql(u8, idFH, idSH)) 
                    {
                        answer1 += first;
                    }

                    answer2 += first;
                    continue :num_loop;
                }

            }
        }

    }
    std.debug.print("Part 1: {d}\nPart 2: {d}\n", .{answer1, answer2});
}
