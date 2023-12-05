const std = @import("std");

const INS_LDA_IN = 0xA9;
const INS_LDA_ZP = 0xA5;
const INS_LDA_ZPX = 0xB5;
const INS_JSR = 0x20;

const Mem: type = struct {
    const MAX_MEM = 1024 * 64;
    data: [MAX_MEM]u8,

    // Set Mem to 0
    pub fn Initialize(self: *Mem) void {
        for (&self.data) |*x| {
            x.* = 0;
        }
    }

    pub fn WriteWord(self: *Mem, value: u16, address: u16) void {
        self.data[address] = @as(u8, @truncate(value & 0xFF));
        self.data[address + 1] = @as(u8, @truncate(value >> 8));
    }
};

const CPU = packed struct {
    PC: u16, // Program Counter
    SP: u16, // Stack Pointer
    // Registers
    A: u8,
    X: u8,
    Y: u8,

    C: u1,
    Z: u1,
    I: u1,
    D: u1,
    B: u1,
    V: u1,
    N: u1,

    pub fn FetchByte(self: *CPU, mem: *Mem) u8 {
        const data = mem.data[self.PC];
        self.PC += 1;
        //self.SP -= 1;
        return data;
    }

    pub fn ReadByte(address: u8, mem: *Mem) u8 {
        return mem.data[address];
    }

    pub fn FetchWord(self: *CPU, mem: *Mem) u16 {
        var data: u16 = mem.data[self.PC];
        self.PC += 1;
        const temp: u16 = mem.data[self.PC];
        data |= temp << 8;
        return data;
    }

    pub fn Reset(self: *CPU, mem: *Mem) void {
        self.PC = 0xFFFC;
        self.SP = 0x00FF;
        self.C = 0;
        self.Z = 0;
        self.I = 0;
        self.D = 0;
        self.B = 0;
        self.V = 0;
        self.N = 0;
        mem.Initialize();
    }

    fn LDASetStatus(self: *CPU) void {
        self.Z = @intFromBool(self.A == 0);
        self.N = @intFromBool((self.A & 0b1000000) > 0);
    }

    pub fn Execute(self: *CPU, cycles: u32, mem: *Mem) void {
        var cyc = cycles;
        while (cyc > 0) {
            const ins = self.FetchByte(mem);
            cyc -= 1;
            switch (ins) {
                INS_LDA_IN => {
                    const value = self.FetchByte(mem);
                    cyc -= 1;
                    self.A = value;
                    LDASetStatus(self);
                    break;
                },
                INS_LDA_ZP => {
                    const address: u8 = self.FetchByte(mem);
                    cyc -= 1;
                    self.A = ReadByte(address, mem);
                    cyc -= 1;
                    LDASetStatus(self);
                    break;
                },
                INS_LDA_ZPX => {
                    var zPageAdd = self.FetchByte(mem);
                    cyc -= 1;
                    zPageAdd += self.X;
                    cyc -= 1;
                    self.A = ReadByte(zPageAdd, mem);
                    cyc -= 1;
                    LDASetStatus(self);
                    break;
                },
                INS_JSR => {
                    const subAddr = self.FetchWord(mem);
                    cyc -= 1;
                    mem.WriteWord(self.PC - 1, self.SP);
                    cyc -= 2;
                    self.SP += 1;
                    cyc -= 1;
                    self.PC = subAddr;
                    cyc -= 1;
                },
                else => {},
            }
        }
    }
};

var cpu = CPU{
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
    var mem: Mem = undefined;
    cpu.Reset(&mem);
    mem.data[0xFFFC] = INS_LDA_IN;
    mem.data[0xFFFD] = 0x42;
    cpu.Execute(2, &mem);
    std.debug.print("cpu.A: 0x{x}\r\ncpu.PC: 0x{x}\r\n", .{ cpu.A, cpu.PC });

    cpu.Reset(&mem);
    mem.data[0xFFFC] = INS_LDA_ZP;
    mem.data[0xFFFD] = 0x42;
    mem.data[0x0042] = 0x84;
    cpu.Execute(3, &mem);
    std.debug.print("cpu.A: 0x{x}\r\ncpu.PC: 0x{x}\r\n", .{ cpu.A, cpu.PC });

    cpu.Reset(&mem);
    mem.data[0xFFFC] = INS_JSR;
    mem.data[0xFFFD] = 0x42;
    mem.data[0xFFFE] = 0x42;
    mem.data[0x4242] = INS_LDA_IN;
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

// test "simple test" {
//     var list = std.ArrayList(i32).init(std.testing.allocator);
//     defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
//     try list.append(42);
//     try std.testing.expectEqual(@as(i32, 42), list.pop());
//}
