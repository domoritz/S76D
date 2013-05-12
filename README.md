# S76D #
S76D stands for _Singing Very High Speed Integrated Circuit Hardware Description Language Board_

## Description ##
The main file is `MusicPlayer.vhd`.

The dream of every geeky hardware hacker has come true. We build a working MMC/SD card reader, block ram buffer and a music player with a 12 DAC (Digital-Analog Converter) Bit for Mono WAV/RIFF on a Spartan 3 FPGA. The Hardware is implemented in VHDL which is a hardware description language. This means that everything is implemented in hardware and not software. 

This Project started as a student project a few months ago and today we were able to play the first song. Hope you like it as much as we enjoyed finally hearing the board singing.

If you want to know a little bit (:-P) more about the project or see nice picures go to [this blog post](http://domoritz.de/blog/2012/03/singing_vhdl_board/) (German)

Demo video on [YouTube](http://www.youtube.com/watch?v=qsjFVgriZzY).

### Features ###
* MMC Card reader via SPI interface
* plays Mono WAV/RIFF
* DAC controller
* PS/2 controller
* two octave keyboard
* uses block ram fifo

## Documentation ##
Take a look at the content of the folder `docs`.

* Easy to understand [Introduction to MMC/SD Cards (German)](http://www.ifas.htwk-leipzig.de/easytoweb/download/D&E_11_2006_Anbindung_von_SD-Karten.pdf)
* Samsung's [MMC Product Datasheet](http://html.alldatasheet.com/html-pdf/141187/SAMSUNG/MC2GH512NMCA-2SA00/305/1/MC2GH512NMCA-2SA00.html) which is really helpful and a great reference.


## Status ##
Working but needs documentation.

## Dependencies ##
* Custom board (see folder `schematics`)
* PS2 keyboard
* MMC (multimedia card)

## Tested on this hardware ##
* Spartan-3 Starter Kit Board (Digilent Inc.), with Xilinx Spartan 3 FPGA (200k gates)

## Developer ##
* Kai Fabian
* Dominik Moritz
