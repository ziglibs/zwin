const std = @import("std");
const common = @import("../common.zig");
usingnamespace @import("../headers/win32.zig");

fn GET_X_LPARAM(lParam: LPARAM) c_int {
    return @intCast(c_int, @intCast(c_ushort,
        lParam & 0xFFFF
    ));
}

fn GET_Y_LPARAM(lParam: LPARAM) c_int {
    return @intCast(c_int, @intCast(c_ushort,
        lParam >> 16 & 0xFFFF
    ));
}

pub const WindowInfo = struct {
    class_name: []const u8,
    title: []const u8,
    event_handler: fn (Window, common.WindowEvent) void
};

pub const Window = struct {
    const Self = @This();
    
    info: WindowInfo,
    class: WNDCLASSA,
    handle: HWND,
    
    pub fn show(self: Self) void {
        _ = ShowWindow(self.handle, SW_SHOW);
    }

    pub fn hide(self: Self) void {
        _ = ShowWindow(self.handle, SW_HIDE);
    }

    pub fn run(self: Self) void {
        var msg: MSG = undefined;
        while (GetMessage(&msg, null, 0, 0) == TRUE)
        {
            _ = TranslateMessage(&msg);
            _ = DispatchMessage(&msg);
        }
    }
};

var handleWindowMap = std.AutoHashMap(HWND, Window).init(std.heap.c_allocator);

fn WindowProc(hwnd: HWND, uMsg: UINT, wParam: WPARAM, lParam: LPARAM) callconv(.C) LRESULT {
    if (handleWindowMap.getValue(hwnd)) |window| {
        window.info.event_handler(window, .render);
        switch (uMsg) {
            WM_DESTROY => {
                PostQuitMessage(0);
                return 0;
            },
            WM_PAINT => {
                std.debug.warn("{}", .{1});
                var ps: PAINTSTRUCT = undefined;
                var hdc = BeginPaint(hwnd, &ps);

                var a: c_uint = COLOR_WINDOW + 1;
                _ = FillRect(hdc, &ps.rcPaint, @ptrCast([*c]struct_HBRUSH__, &a));

                _ = EndPaint(hwnd, &ps);

                // window.info.event_handler(window, .paint);
            },
            WM_MOUSEMOVE => {
                window.info.event_handler(window, .{ .mouse_move = .{
                    .x = GET_X_LPARAM(lParam),
                    .y = GET_Y_LPARAM(lParam)
                } });
            },
            else => {}
        }
    }

    return DefWindowProc(hwnd, uMsg, wParam, lParam);
}

pub fn createWindow(info: WindowInfo) !Window {
    var window = Window{
        .info = info,
        .class = undefined,
        .handle = undefined
    };

    var windowClass = std.mem.zeroes(WNDCLASSA);
    windowClass.style = CS_DBLCLKS;
    windowClass.lpfnWndProc = WindowProc;
    windowClass.hInstance = GetModuleHandleA(0);
    windowClass.hIcon = LoadIcon(null, IDI_APPLICATION);
    windowClass.hCursor = LoadCursor(null, IDC_ARROW);
    windowClass.lpszClassName = info.class_name.ptr;
    _ = RegisterClassA(&windowClass);

    window.class = windowClass;

    window.handle = CreateWindowExA(
        0,
        windowClass.lpszClassName,
        info.title.ptr,
        WS_OVERLAPPEDWINDOW | WS_VISIBLE,

        // Size and position
        100, 100, 500, 500,

        null,
        null,
        windowClass.hInstance,
        null
    );

    if (window.handle == null) {
        return error.NullHandle;
    }

    _ = try handleWindowMap.put(window.handle, window);

    return window;
}
