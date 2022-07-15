const std = @import("std");
const web = @import("zhp");

const db = @import("./db.zig");
const Devices = @import("./model/devices.zig");
const Actors = @import("./model/actors/index.zig");

pub const io_mode = .evented;
pub const log_level = .info;

const DevicesListHandler = struct {
    pub fn get(_: *DevicesListHandler, _: *web.Request, response: *web.Response) !void {
        var devices = try Devices.all(response.allocator);
        try std.json.stringify(devices, .{.whitespace = .{}}, response.stream);
    }
};

const ExecuteRequest = struct {
    device_id: i32,
    command: std.json.Value
};

const DevicesExecuteHandler = struct {
    pub fn post(_: *DevicesExecuteHandler, req: *web.Request, res: *web.Response) !void {
        try req.readBody(req.stream.?);

        var parser = std.json.Parser.init(res.allocator, false);
        const request = try parser.parse(req.content.?.data.buffer);

        const device_id = request.root.Object.get("device_id").?.Integer;
        const device = try Devices.get(device_id, res.allocator);
        if (device) |dev| {
            const actor = Actors.actors_by_name.get(dev.actor).?;
            try actor.execute(res.allocator, &request.root.Object.get("command").?, dev.actor_data orelse "");
            _ = try res.writeFn("OK.");
        } else {
            res.status = web.responses.NOT_FOUND;
            _ = try res.writeFn("Unknown Device");
            return;
        }

    }
};



const HelloHandler = struct {
    pub fn get(self: *HelloHandler, request: *web.Request, response: *web.Response) !void {
        _ = self;
        _ = request;
        try response.headers.put("Content-Type", "text/plain");
        _ = try response.stream.write("Hello, World!");
    }
};

pub const routes = [_]web.Route{
    web.Route.create("home", "/", HelloHandler),
    web.Route.create("listDevices", "/devices/list", DevicesListHandler),
    web.Route.create("executeDevice", "/devices/execute", DevicesExecuteHandler)
};

pub const middleware = [_]web.Middleware{
    web.Middleware.create(web.middleware.LoggingMiddleware),
};

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(!gpa.deinit());
    const allocator = gpa.allocator();

    try db.init();
    defer db.deinit();

    try Devices.init();
    try Actors.init(allocator);

    var app = web.Application.init(allocator, .{ .debug = true });
    defer app.deinit();

    try app.listen("127.0.0.1", 9000);
    try app.start();
}
