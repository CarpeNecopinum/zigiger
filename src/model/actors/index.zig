const std = @import("std");
const sender433 = @import("./sender433.zig");

pub const Actor = struct {
    execute: fn(allocator: std.mem.Allocator, command: *std.json.Value, actor_data: []u8) anyerror!void 
};

pub const ActorMap = std.StringHashMap(Actor);
pub var actors_by_name: ActorMap = undefined;

pub fn init(allocator: std.mem.Allocator) !void {
    actors_by_name = ActorMap.init(allocator);

    try actors_by_name.put("Sender433", .{
        .execute = sender433.execute
    });
}