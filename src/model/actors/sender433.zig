const std = @import("std");

pub fn execute(allocator: std.mem.Allocator, command: []u8, actor_data: []u8) !void {
    _ = allocator;
    std.debug.print("Sender433 - would execute {s} with data {s}", .{command, actor_data});
}