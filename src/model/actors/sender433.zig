const std = @import("std");

pub fn execute(allocator: std.mem.Allocator, command: *std.json.Value, actor_data: []u8) !void {
    _ = allocator;
    _ = actor_data;
    _ = command;

    const onoff = command.String;
    std.debug.print("Sender433 - would execute {s} with data {s}\n", .{onoff, actor_data});
}