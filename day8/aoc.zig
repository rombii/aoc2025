const std = @import("std");
const path = "./input";

pub fn main() !void {
    var file = try std.fs.cwd().openFile(path, .{ .mode = .read_only });
    defer file.close();

    var buffer: [20 * 1024]u8 = undefined;
    var reader = file.reader(&buffer);

    const allocator = std.heap.page_allocator;
    var list: std.ArrayList(Point) = .empty;


    while(try reader.interface.takeDelimiter('\n')) |line| {
        var coords = std.mem.splitAny(u8, line, &[_]u8 {',', 10});
        const x = try std.fmt.parseInt(i64, coords.next().?, 10);
        const y = try std.fmt.parseInt(i64, coords.next().?, 10);
        const z = try std.fmt.parseInt(i64, coords.next().?, 10);
        try list.append(allocator, .{
            .x = x,
            .y = y,
            .z = z
        });
    }

    var parent_array: std.ArrayList(usize) = .empty;

    for(0 .. list.items.len) |i| {
        try parent_array.append(allocator, i);
    }

    var distances: std.ArrayList(Distance) = .empty;


    for(0 .. list.items.len) |i| {
        for(i + 1 .. list.items.len) |j| {
            const x_part: f64 = @floatFromInt(std.math.pow(i64, list.items[i].x - list.items[j].x, 2));
            const y_part: f64 = @floatFromInt(std.math.pow(i64, list.items[i].y - list.items[j].y, 2));
            const z_part: f64 = @floatFromInt(std.math.pow(i64, list.items[i].z - list.items[j].z, 2));

            const distance: f64 = std.math.sqrt(x_part + y_part + z_part);

            try distances.append(allocator, .{
                .value = distance,
                .p1 = i,
                .p2 = j
            });

        }
    }
    
    QuickSort(&distances.items, 0, std.math.lossyCast(i64, distances.items.len - 1));
    
    for(0 .. 10000) |i| {
        Union(&parent_array, distances.items[i].p1, distances.items[i].p2);

        //Part 1
        if(i == 1000) {
            var max_three: [3]i64 = [_]i64 {0, 0, 0};
            for(0 .. list.items.len) |j| {
                var counter: i64 = 0;
                for(0 .. parent_array.items.len) |k| {
                    const parent = Find(&parent_array, parent_array.items[k]);
                    if(parent == j) {
                        counter += 1;
                    }
                }
                if(counter > max_three[0]) {
                    max_three[2] = max_three[1];
                    max_three[1] = max_three[0];
                    max_three[0] = counter;
                } 
                else if(counter > max_three[1]) {
                    max_three[2] = max_three[1];
                    max_three[1] = counter;

                }
                else if(counter > max_three[2]) {
                    max_three[2] = counter;
                }
            }
            std.debug.print("Part 1: {d} ", .{max_three[0] * max_three[1] * max_three[2]});
        }

        //Part 2
        var counter: i64 = 0;
        const og_parent = Find(&parent_array, distances.items[i].p1);
        for(0 .. parent_array.items.len) |j| {
            const parent = Find(&parent_array, parent_array.items[j]);
            if(parent == og_parent) {
                counter += 1;
            }
        }
        if(counter == 1000) {
            const multi = list.items[distances.items[i].p1].x * list.items[distances.items[i].p2].x; 
            std.debug.print("Part 2: {d}\n", .{multi});
            break;
        }
    }




    defer list.deinit(allocator);
    defer parent_array.deinit(allocator);
    defer distances.deinit(allocator);

    //GAMEPLAN
    //read every point as an 1x3 array
    //we calculate 1000 pairs for 1000 points which means 1000*1000*1000
    //for every closest pair we set on of their parents to another oone
    //for example pair 12 - 54 will both have parent of either 12 or 54
    //at the end we count every disctinct parent index and return multi of biggest 5
}

const Point = struct {
    x: i64,
    y: i64,
    z: i64
};

const Distance = struct {
    value: f64,
    p1: usize,
    p2: usize
};


fn Find(arr: *std.ArrayList(usize), i: usize) usize {
    if(arr.*.items[i] == i) {
        return i;
    }

    return Find(arr, arr.*.items[i]);
}

fn Union(arr: *std.ArrayList(usize), i: usize, j: usize) void {
    const i_parent = Find(arr, i);
    const j_parent = Find(arr, j);

    arr.*.items[i_parent] = j_parent;
}

fn QuickSort(arr: *[]Distance, low: i64, high: i64) void {
    if(low < high) {
        const pi: i64 = Partition(arr, low, high);

        QuickSort(arr, low, pi - 1);
        QuickSort(arr, pi + 1, high);
    }
}

fn Partition(arr: *[]Distance, low: i64, high: i64) i64 {
    const low_usize: usize = std.math.lossyCast(usize, low);
    const high_usize: usize = std.math.lossyCast(usize, high);
    const pivot: f64 = arr.*[high_usize].value;

    var i: i64 = low - 1;

    for(low_usize .. high_usize) |j| {
        if(arr.*[j].value < pivot) {
            i += 1;
            Swap(&arr.*[std.math.lossyCast(usize, i)], &arr.*[j]);

        }
    }

    Swap(&arr.*[std.math.lossyCast(usize, i + 1)], &arr.*[high_usize]);
    return i + 1;
}

fn Swap(a: *Distance, b: *Distance) void {
    const temp: Distance = a.*;
    a.* = b.*;
    b.* = temp;
}
