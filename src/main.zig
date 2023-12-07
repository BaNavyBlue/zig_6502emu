const std = @import("std");
const M6502 = @import("M6502.zig");

var cpu = M6502.CPU{
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

pub fn main() !void {
    var mem: M6502.Mem = undefined;
    cpu.Reset(&mem);
    mem.data[0xFFFC] = M6502.INS_LDA_IN;
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
    var mem: M6502.Mem = undefined;
    cpu.Reset(&mem);
    mem.data[0xFFFC] = M6502.INS_LDA_IN;
    mem.data[0xFFFD] = 0x42;
    cpu.Execute(2, &mem);

    try std.testing.expectEqual(@as(u16, 0x42), cpu.A);
}
