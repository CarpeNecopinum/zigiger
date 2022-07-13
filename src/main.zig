const std = @import("std");
const web = @import("zhp");

const db = @import("./db.zig");
const Devices = @import("./model/devices.zig");

pub const io_mode = .evented;
pub const log_level = .info;

const ListDevicesHandler = struct {
    pub fn get(_: *ListDevicesHandler, _: *web.Request, response: *web.Response) !void {
        var devices = try Devices.all(response.allocator);

        try std.json.stringify(devices, .{.whitespace = .{}}, response.stream);

        // var jw = std.json.writeStream(response.stream, 4);
        // try jw.beginArray();

        // for (devices) |device| {
        //     try jw.arrayElem();


        //     try jw.emitJson(std.json.Value{.Object = device});

        //     // try jw.beginObject();
            
        //     // try jw.objectField("id");
        //     // try jw.emitNumber(device.id);

        //     // try jw.objectField("name");
        //     // try jw.emitString(device.name);

        //     // if (device.kind) |kind| {
        //     //     try jw.objectField("kind");
        //     //     try jw.emitString(kind);
        //     // }

        //     // try jw.objectField("actor");
        //     // try jw.emitString(device.actor);

        //     // try jw.endObject();
        // }

        // try jw.endArray();
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
    web.Route.create("listDevices", "/devices/list", ListDevicesHandler)
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

    var app = web.Application.init(allocator, .{ .debug = true });
    defer app.deinit();

    try app.listen("127.0.0.1", 9000);
    try app.start();
}
