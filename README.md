# Amosis Keyboard

The Amosis is a 40% split keywell board with a Cirque trackpad built into each side.  The case is 3D printed, and features a keywell shape similar to Kinesis or Dactyl keyboards, except with only three rows.

## Controller
This keyboard uses custom controller firmware written from scratch in Zig, and running on an RP2040.  If you want to use QMK, etc, you are welcome to try, but please don't ask me to do it for you; I have no interest in that.

## Trackpad
Each side of the keyboard integrates a 40mm Cirque GlidePoint trackpad from a Steam Controller.  While Valve stopped producing Steam Controllers years ago, you can still purchase the trackpads from [Mouser](https://www.mouser.com/c/?marcom=118816186), but you will likely need to make some modifications to make this work:

* There are several sizes available; the Steam Controller uses the largest 40mm size (TM40040), but you could use a smaller one if you adjust the case design.
* The retail Circues offer several options for plastic overlays, but the Steam Controller used custom overlays, so you may need to adjust the case design for your chosen overlay style.
* There are (or were) both SPI and I2C versions available.  The Steam Controller (and Pteron) only uses SPI, so you'll need to adjust the firmware if you want to use an I2C version (though I think you can change it just by adding/removing a resistor on the Cirque board).  The SPI versions have part numbers TMxx0xx-2024 while the I2C versions have part numbers TMxx0xx-2023.  At time of writing, it appears Mouser no longer carries the I2C version.
* The Steam Controller uses a customized connector pinout that's different than what's documented in the datasheet for the retail version.  You'll need to adjust the schematic board layout to accomodate this.
* An [Alps Haptic Reactor](https://www.mouser.com/ProductDetail/Alps-Alpine/AFT14A903A) force-feedback element is glued to the back of the Steam Controller version and its power is routed through the same FFC cable.  If you buy this separately, you'll have to figure out how you want to connect it to the board.

## Building

Have the controller boards manufactured using the files in the `kicad/gerbers/left/` and `kicad/gerbers/right` folders.

Ensure dependencies are available on your path:
* [Zig](https://ziglang.org/download/)
* [OpenSCAD](https://openscad.org/downloads.html) (2023.03.18 or newer; scroll down to "Development Snapshots")

Adjust the keymapping and layer logic as you like, then run `zig build`.

3D print a case using `zig-out/bin/left.stl` and `zig-out/bin/right.stl`.

Flash the `zig-out/bin/firmware_left.uf2` and `zig-out/bin/firmware_right.uf2` to the corresponding controllers.

Place switches and wire up the diode matrix such that each column signal connects to the cathode of a diode, and each row signal connects directly to one of the switch contacts.
