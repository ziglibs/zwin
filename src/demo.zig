const std = @import("std");
const zwin = @import("main.zig");

var x: c_int = 0;
var y: c_int = 0;
var gdi: zwin.gdi.Graphics = undefined;

fn eventHandler(window: zwin.Window, event: zwin.WindowEvent) void {
    switch (event) {
        // .paint => {
            // window.hide();
        // },
        .mouse_move => |pos| {

            gdi.begin();

            if (x == 0 and y == 0) {
                x = pos.x;
                y = pos.y;
            }

            gdi.moveTo(x, y);
            gdi.lineTo(pos.x, pos.y);

            gdi.end();

            x = pos.x;
            y = pos.y;
        },
        else => {}
    }
}

pub fn main() !void {
    std.debug.warn("Running demo...", .{});
    const a = zwin.WindowInfo{
        .class_name = "DemoWindow",
        .title = "Demo Window",
        .event_handler = eventHandler
    };
    var window = try zwin.createWindow(a);
    gdi = zwin.gdi.init(&window);

    window.run();
}