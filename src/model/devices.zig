const std = @import("std");
const db = @import("../db.zig");

pub const Device = struct {
    id: i32,
    name: []u8,
    kind: ?[]u8,
    actor: []u8,
    actor_data: ?[]u8
};

pub fn init() !void {
    var stmt = try db.conn.prepare(
    \\ CREATE TABLE IF NOT EXISTS devices (
    \\     id INTEGER PRIMARY KEY AUTOINCREMENT,
    \\     name TEXT NOT NULL,
    \\     kind TEXT,
    \\     actor TEXT NOT NULL,
    \\     actor_data TEXT
    \\);
    );
    defer stmt.deinit();

    try stmt.exec(.{}, .{});
}

pub fn all(alloc: std.mem.Allocator) ![]Device {
    var stmt = try db.conn.prepare("SELECT * FROM devices");
    defer stmt.deinit();

    return stmt.all(Device, alloc, .{}, .{});
}