pub const Position = struct {
    x: c_int,
    y: c_int
};

pub const WindowEvent = union(enum) {
    paint,
    render,
    mouse_move: Position
};

pub const Color = struct {
    red: u8,
    green: u8,
    blue: u8
};

pub fn rgb(red: u8, green: u8, blue: u8) Color {
    return .{.red = red, .green = green, .blue = blue};
}
