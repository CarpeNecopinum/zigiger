const sqlite = @import("sqlite");

pub var conn: sqlite.Db = undefined;

pub fn init() !void {
    conn = try sqlite.Db.init(.{
        .mode = sqlite.Db.Mode{ .File = "db.sqlite" },
        .open_flags = .{
            .write = true,
            .create = true
        }
    });
}

pub fn deinit() void {
    conn.deinit();
}