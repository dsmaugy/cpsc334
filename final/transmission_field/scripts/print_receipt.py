# from escpos.printer import Usb
from escpos.printer import Win32Raw
from datetime import datetime

import argparse

PAPER_WIDTH = 32

import random

def generate_star_field(width, height, num_stars, seed=None):
    random.seed(seed)
    star_field = [[' ' for _ in range(width)] for _ in range(height)]

    for _ in range(num_stars):
        x = random.randint(0, width - 1)
        y = random.randint(0, height - 1)
        star_field[y][x] = '*'

    return star_field

def large_text(printer):
    printer.set(double_height=True, double_width=True)

def normal_text(printer):
    printer.set(double_height=False, double_width=False, normal_textsize=True)

def print_bolded(printer, text):
    printer.set(bold=True)
    printer.text(text)
    printer.set(bold=False)

def print_receipt():
    parser = argparse.ArgumentParser()

    parser.add_argument("name")
    parser.add_argument("x")
    parser.add_argument("y")
    parser.add_argument("encoding")
    parser.add_argument("atten")
    parser.add_argument("freq")
    parser.add_argument("msg", nargs="...")

    action_type = parser.add_mutually_exclusive_group()
    action_type.add_argument("-t", "--transmit", action="store_true")
    action_type.add_argument("-d", "--decode", action="store_true")

    args = parser.parse_args()

    # p = Usb(0x0416, 0x5011, in_ep=0x81, out_ep=0x03, profile="NT-5890K")
    p = Win32Raw("POS-58", profile="NT-5890K")
    print(args.__repr__())

    # exit(1)
    p.set(align="center")

    large_text(p)
    print_bolded(p, f"TRANSMISSION:\n{args.name}\n")
    normal_text(p)

    print_bolded(p, f"{'*'*PAPER_WIDTH}\n")
    p.set(align="left")
    print_bolded(p, "Type: ")
    if args.transmit:
        p.text("TRANSMIT\n")
    else:
        p.text("DECODE\n")

    print_bolded(p, "Time: ")
    p.text(f"{datetime.strftime(datetime.now(), "%m-%d-%y %H:%M")}\n") 
    
    print_bolded(p, "Location: ")
    p.text(f"({args.x}, {args.y})\n")

    print_bolded(p, "Encoding Pattern: ")
    p.text(f"{args.encoding}\n")

    print_bolded(p, "Attenuation: ")
    p.text(f"{args.atten} DB\n")

    print_bolded(p, "Freq: ")
    p.text(f"{args.freq} HZ\n")

    p.set(align="center")
    print_bolded(p, f"{'*'*PAPER_WIDTH}\n")

    print_bolded(p, "-BEGIN TRANSMISSION-\n")

    p.set(font="b", align="left")
    p.textln("".join(args.msg))

    p.set(align="center", font="a")
    print_bolded(p, "-END TRANSMISSION-\n")
    p.ln()

    stars = generate_star_field(PAPER_WIDTH, 4, 10, args.name)
    for star_line in stars:
        p.textln(''.join(star_line))
    

    p.cut()
    

if __name__ == "__main__":
    print_receipt()