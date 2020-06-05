const std = @import("std");
const common = @import("../common.zig");
const builtin = @import("builtin");
usingnamespace @import("../bindings/binding.zig");
usingnamespace @import("../headers/win32.zig");

// (
//     (COLORREF)(
        
//         ((BYTE) (r) | ((WORD)((BYTE)(g))<<8)) | (((DWORD)(BYTE)(b))<<16)

// ))
fn colorToRGB(color: common.Color) COLORREF {
    return @as(COLORREF, (color.red | @intCast(WORD, color.green) << 8) | @intCast(DWORD, color.blue) << 16);
}

pub const Graphics = struct {
    const Self = *@This();

    window: *Window,
    ps: PAINTSTRUCT,
    hdc: HDC = undefined,

    pub fn begin(self: Self) void {
        self.hdc = GetDC(self.window.handle);
    }

    pub fn end(self: Self) void {
        _ = ReleaseDC(self.window.handle, self.hdc);
    }

    pub fn moveTo(self: Self, x: c_int, y: c_int) void {
        _ = MoveToEx(self.hdc, x, y, null);
    }

    pub fn lineTo(self: Self, x: c_int, y: c_int) void {
        _ = LineTo(self.hdc, x, y);
    }

    pub fn setPixel(self: Self, x: c_int, y: c_int, color: common.Color) void {
        _ = SetPixel(self.hdc, x, y, colorToRGB(color));
    }
};

pub fn init(window: *Window) Graphics {
    if (builtin.os.tag != .windows) @compileError("GDI is only supported on Windows!");

    return Graphics{
        .window = window,

        .ps = undefined
    };
    // std.debug.warn("{}", .{window});
}
