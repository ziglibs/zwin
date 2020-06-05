const builtin = @import("builtin");

pub usingnamespace switch (builtin.os.tag) {
    .windows => @import("win32.zig"),
    else => {
        @compileError("Your operator system is not supported!");
    }
};
