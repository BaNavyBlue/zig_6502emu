const std = @import("std");
const M6502 = @import("M6502.zig");

pub var cpu = M6502.CPU{
    .PC = 0,
    .SP = 0,
    .A = 0,
    .X = 0,
    .Y = 0,
    .C = 0,
    .Z = 0,
    .I = 0,
    .D = 0,
    .B = 0,
    .V = 0,
    .N = 0,
};

pub const M6502Test = struct {
    var mem: M6502.Mem = undefined;

    pub fn testLoadImmediate(opCode: u8) void {
        cpu.Reset(&mem);
        mem.data[0xFFFC] = opCode;
        mem.data[0xFFFD] = 0x42;
        cpu.Execute(2, &mem);
    }

    pub fn testLoadZeroPage(opcode: u8) void {
        cpu.Reset(&mem);
        mem.data[0xFFFC] = opcode;
        mem.data[0xFFFD] = 0x42;
        mem.data[0x0042] = 0x37;
        cpu.Execute(3, &mem);
    }

    pub fn testLoadZeroPageX(opcode: u8) void {
        cpu.Reset(&mem);
        cpu.X = 0x05;
        mem.data[0xFFFC] = opcode;
        mem.data[0xFFFD] = 0x42;
        mem.data[0x0047] = 0x37;
        cpu.Execute(4, &mem);
    }

    pub fn testLoadZeroPageXWrap(opcode: u8) void {
        cpu.Reset(&mem);
        cpu.X = 0xFF;
        mem.data[0xFFFC] = opcode;
        mem.data[0xFFFD] = 0x80;
        mem.data[0x007F] = 0x37;
        cpu.Execute(4, &mem);
    }

    pub fn testLoadZeroPageY(opcode: u8) void {
        cpu.Reset(&mem);
        cpu.Y = 0x05;
        mem.data[0xFFFC] = opcode;
        mem.data[0xFFFD] = 0x42;
        mem.data[0x0047] = 0x37;
        cpu.Execute(4, &mem);
    }

    pub fn testLoadZeroPageYWrap(opcode: u8) void {
        cpu.Reset(&mem);
        cpu.Y = 0xFF;
        mem.data[0xFFFC] = opcode;
        mem.data[0xFFFD] = 0x80;
        mem.data[0x007F] = 0x37;
        cpu.Execute(4, &mem);
    }

    pub fn testLoadAbsolute(opcode: u8) void {
        cpu.Reset(&mem);
        //cpu.X = 0xFF;
        mem.data[0xFFFC] = opcode;
        mem.data[0xFFFD] = 0x80;
        mem.data[0xFFFE] = 0x44;
        mem.data[0x4480] = 0x37;
        cpu.Execute(4, &mem);
    }

    pub fn testLoadAbsoluteX(opcode: u8) void {
        cpu.Reset(&mem);
        cpu.X = 0x01;
        mem.data[0xFFFC] = opcode;
        mem.data[0xFFFD] = 0x80;
        mem.data[0xFFFE] = 0x44;
        mem.data[0x4481] = 0x37;
        cpu.Execute(4, &mem);
    }

    pub fn testLoadAbsoluteY(opcode: u8) void {
        cpu.Reset(&mem);
        cpu.Y = 0x01;
        mem.data[0xFFFC] = opcode;
        mem.data[0xFFFD] = 0x80;
        mem.data[0xFFFE] = 0x44;
        mem.data[0x4481] = 0x37;
        cpu.Execute(4, &mem);
    }

    pub fn testLoadAbsoluteXCrosses(opcode: u8) void {
        cpu.Reset(&mem);
        cpu.X = 0xFF;
        mem.data[0xFFFC] = opcode;
        mem.data[0xFFFD] = 0x02;
        mem.data[0xFFFE] = 0x44;
        mem.data[0x4501] = 0x37;
        cpu.Execute(5, &mem);
    }

    pub fn testLoadAbsoluteYCrosses(opcode: u8) void {
        cpu.Reset(&mem);
        cpu.Y = 0xFF;
        mem.data[0xFFFC] = opcode;
        mem.data[0xFFFD] = 0x02;
        mem.data[0xFFFE] = 0x44;
        mem.data[0x4501] = 0x37;
        cpu.Execute(5, &mem);
    }
};

pub fn main() !void {
    var mem: M6502.Mem = undefined;
    cpu.Reset(&mem);
    mem.data[0xFFFC] = M6502.INS_LDA_IM;
    mem.data[0xFFFD] = 0x42;
    cpu.Execute(2, &mem);
    std.debug.print("cpu.A: 0x{x}\r\ncpu.PC: 0x{x}\r\n", .{ cpu.A, cpu.PC });

    cpu.Reset(&mem);
    mem.data[0xFFFC] = M6502.INS_LDA_ZP;
    mem.data[0xFFFD] = 0x42;
    mem.data[0x0042] = 0x84;
    cpu.Execute(3, &mem);
    std.debug.print("cpu.A: 0x{x}\r\ncpu.PC: 0x{x}\r\n", .{ cpu.A, cpu.PC });

    cpu.Reset(&mem);
    mem.data[0xFFFC] = M6502.INS_JSR;
    mem.data[0xFFFD] = 0x42;
    mem.data[0xFFFE] = 0x42;
    mem.data[0x4242] = M6502.INS_LDA_IN;
    mem.data[0x4243] = 0x84;
    std.debug.print("Before\r\n", .{});
    std.debug.print("cpu.A: 0x{x}\r\ncpu.PC: 0x{x}\r\n", .{ cpu.A, cpu.PC });
    cpu.Execute(8, &mem);
    std.debug.print("After\r\n", .{});
    std.debug.print("cpu.A: 0x{x}\r\ncpu.PC: 0x{x}\r\n", .{ cpu.A, cpu.PC });
    std.debug.print("cpu.SP: 0x{x}\r\ncpu.PC: 0x{x}\r\n", .{ cpu.SP, cpu.PC });

    cpu.Reset(&mem);
    cpu.X = 0xFF;
    mem.data[0xFFFC] = M6502.INS_LDA_ABSX;
    mem.data[0xFFFD] = 0x02;
    mem.data[0xFFFE] = 0x44;
    mem.data[0x4501] = 0x37;
    cpu.Execute(5, &mem);
    std.debug.print("cpu.A: 0x{x}\r\ncpu.PC: 0x{x}\r\n", .{ cpu.A, cpu.PC });
    std.debug.print("cpu.SP: 0x{x}\r\ncpu.PC: 0x{x}\r\n", .{ cpu.SP, cpu.PC });

    cpu.Reset(&mem);
    cpu.Y = 0xFF;
    mem.data[0xFFFC] = M6502.INS_LDA_INDY;
    mem.data[0xFFFD] = 0x02;
    mem.data[0x0002] = 0x02;
    mem.data[0x0003] = 0x80;
    mem.data[0x8101] = 0x37;
    cpu.Execute(6, &mem);
    std.debug.print("cpu.A: 0x{x}\r\ncpu.PC: 0x{x}\r\n", .{ cpu.A, cpu.PC });
    std.debug.print("cpu.SP: 0x{x}\r\ncpu.PC: 0x{x}\r\n", .{ cpu.SP, cpu.PC });
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    //std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    //const stdout_file = std.io.getStdOut().writer();
    //var bw = std.io.bufferedWriter(stdout_file);
    //const stdout = bw.writer();

    //try stdout.print("Run `zig build test` to run the tests.\n", .{});

    //try bw.flush(); // don't forget to flush!
}

test "LDA IM Can Load Val into A Reg" {
    M6502Test.testLoadImmediate(M6502.INS_LDA_IM);
    try std.testing.expectEqual(@as(u8, 0x42), cpu.A);
}

test "LDX IM Can Load Val into X Reg" {
    M6502Test.testLoadImmediate(M6502.INS_LDX_IM);
    try std.testing.expectEqual(@as(u8, 0x42), cpu.X);
}

test "LDY IM Can Load Val into Y Reg" {
    M6502Test.testLoadImmediate(M6502.INS_LDY_IM);
    try std.testing.expectEqual(@as(u8, 0x42), cpu.Y);
}

test "LDA ZeroPage Can Load Val into A Reg" {
    M6502Test.testLoadZeroPage(M6502.INS_LDA_ZP);
    try std.testing.expectEqual(@as(u16, 0x37), cpu.A);
}

test "LDX ZeroPage Can Load Val into X Reg" {
    M6502Test.testLoadZeroPage(M6502.INS_LDX_ZP);
    try std.testing.expectEqual(@as(u16, 0x37), cpu.X);
}

test "LDY ZeroPage Can Load Val into Y Reg" {
    M6502Test.testLoadZeroPage(M6502.INS_LDY_ZP);
    try std.testing.expectEqual(@as(u16, 0x37), cpu.Y);
}

test "LDA ZeroPageX Can Load Val into A Reg" {
    M6502Test.testLoadZeroPageX(M6502.INS_LDA_ZPX);
    try std.testing.expectEqual(@as(u16, 0x37), cpu.A);
}

test "LDX ZeroPageY Can Load Val into X Reg" {
    M6502Test.testLoadZeroPageY(M6502.INS_LDX_ZPY);
    try std.testing.expectEqual(@as(u16, 0x37), cpu.X);
}

test "LDY ZeroPageX Can Load Val into Y Reg" {
    M6502Test.testLoadZeroPageX(M6502.INS_LDY_ZPX);
    try std.testing.expectEqual(@as(u16, 0x37), cpu.Y);
}

test "LDA ZeroPageX Can Load Val into A Reg when it wraps" {
    M6502Test.testLoadZeroPageX(M6502.INS_LDA_ZPX);
    try std.testing.expectEqual(@as(u16, 0x37), cpu.A);
}

test "LDX ZeroPageY Can Load Val into X Reg when it wraps" {
    M6502Test.testLoadZeroPageY(M6502.INS_LDX_ZPY);
    try std.testing.expectEqual(@as(u16, 0x37), cpu.X);
}

test "LDY ZeroPageX Can Load Val into Y Reg when it wraps" {
    M6502Test.testLoadZeroPageX(M6502.INS_LDY_ZPX);
    try std.testing.expectEqual(@as(u16, 0x37), cpu.Y);
}

test "LDA Absolute Can Load Val into A Reg" {
    M6502Test.testLoadAbsolute(M6502.INS_LDA_ABS);
    try std.testing.expectEqual(@as(u16, 0x37), cpu.A);
}

test "LDX Absolute Can Load Val into X Reg" {
    M6502Test.testLoadAbsolute(M6502.INS_LDX_ABS);
    try std.testing.expectEqual(@as(u16, 0x37), cpu.X);
}

test "LDY Absolute Can Load Val into Y Reg" {
    M6502Test.testLoadAbsolute(M6502.INS_LDY_ABS);
    try std.testing.expectEqual(@as(u16, 0x37), cpu.Y);
}

test "LDA AbsoluteX Can Load Val into A Reg" {
    M6502Test.testLoadAbsoluteX(M6502.INS_LDA_ABSX);
    try std.testing.expectEqual(@as(u16, 0x37), cpu.A);
}

test "LDA AbsoluteY Can Load Val into A Reg" {
    M6502Test.testLoadAbsoluteY(M6502.INS_LDA_ABSY);
    try std.testing.expectEqual(@as(u16, 0x37), cpu.A);
}

test "LDX AbsoluteY Can Load Val into X Reg" {
    M6502Test.testLoadAbsoluteY(M6502.INS_LDX_ABSY);
    try std.testing.expectEqual(@as(u16, 0x37), cpu.X);
}

test "LDY AbsoluteX Can Load Val into Y Reg" {
    M6502Test.testLoadAbsoluteX(M6502.INS_LDY_ABSX);
    try std.testing.expectEqual(@as(u16, 0x37), cpu.Y);
}

test "LDA AbsoluteX Can Load Val into A Reg crosses 8bit boundary" {
    M6502Test.testLoadAbsoluteXCrosses(M6502.INS_LDA_ABSX);
    try std.testing.expectEqual(@as(u16, 0x37), cpu.A);
}

test "LDA AbsoluteY Can Load Val into A Reg crosses 8bit boundary" {
    M6502Test.testLoadAbsoluteYCrosses(M6502.INS_LDA_ABSX);
    try std.testing.expectEqual(@as(u16, 0x37), cpu.A);
}

test "LDX AbsoluteY Can Load Val into X Reg crosses 8bit boundary" {
    M6502Test.testLoadAbsoluteYCrosses(M6502.INS_LDX_ABSY);
    try std.testing.expectEqual(@as(u16, 0x37), cpu.X);
}

test "LDY AbsoluteX Can Load Val into Y Reg crosses 8bit boundary" {
    M6502Test.testLoadAbsoluteXCrosses(M6502.INS_LDY_ABSX);
    try std.testing.expectEqual(@as(u16, 0x37), cpu.Y);
}

// test "LDA AbsoluteY Can Load Val into A Reg" {
//     var mem: M6502.Mem = undefined;
//     cpu.Reset(&mem);
//     cpu.Y = 0x01;
//     mem.data[0xFFFC] = M6502.INS_LDA_ABSY;
//     mem.data[0xFFFD] = 0x80;
//     mem.data[0xFFFE] = 0x44;
//     mem.data[0x4481] = 0x37;
//     cpu.Execute(4, &mem);

//     try std.testing.expectEqual(@as(u16, 0x37), cpu.A);
// }

// test "LDA AbsoluteY Can Load Val into A Reg crosses 8bit boundary" {
//     var mem: M6502.Mem = undefined;
//     cpu.Reset(&mem);
//     cpu.Y = 0xFF;
//     mem.data[0xFFFC] = M6502.INS_LDA_ABSY;
//     mem.data[0xFFFD] = 0x02;
//     mem.data[0xFFFE] = 0x44;
//     mem.data[0x4501] = 0x37;
//     cpu.Execute(5, &mem);

//     try std.testing.expectEqual(@as(u16, 0x37), cpu.A);
// }

test "LDA Indirect X Can Load Val into A Reg" {
    var mem: M6502.Mem = undefined;
    cpu.Reset(&mem);
    cpu.X = 0x04;
    mem.data[0xFFFC] = M6502.INS_LDA_INDX;
    mem.data[0xFFFD] = 0x02;
    mem.data[0x0006] = 0x00;
    mem.data[0x0007] = 0x80;
    mem.data[0x8000] = 0x37;
    cpu.Execute(6, &mem);

    try std.testing.expectEqual(@as(u16, 0x37), cpu.A);
}

test "LDA Indirect Y Can Load Val into A Reg" {
    var mem: M6502.Mem = undefined;
    cpu.Reset(&mem);
    cpu.Y = 0x04;
    mem.data[0xFFFC] = M6502.INS_LDA_INDY;
    mem.data[0xFFFD] = 0x02;
    mem.data[0x0002] = 0x00;
    mem.data[0x0003] = 0x80;
    mem.data[0x8004] = 0x37;
    cpu.Execute(5, &mem);

    try std.testing.expectEqual(@as(u16, 0x37), cpu.A);
}

test "LDA Indirect Y Can Load Val into A Reg cross page boundary" {
    var mem: M6502.Mem = undefined;
    cpu.Reset(&mem);
    cpu.Y = 0xFF;
    mem.data[0xFFFC] = M6502.INS_LDA_INDY;
    mem.data[0xFFFD] = 0x02;
    mem.data[0x0002] = 0x02;
    mem.data[0x0003] = 0x80;
    mem.data[0x8101] = 0x37;
    cpu.Execute(6, &mem);

    try std.testing.expectEqual(@as(u16, 0x37), cpu.A);
}
