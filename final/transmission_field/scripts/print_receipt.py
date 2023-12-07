from escpos.printer import Usb
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

def print():
    parser = argparse.ArgumentParser()

    parser.add_argument("name")
    parser.add_argument("x")
    parser.add_argument("y")
    parser.add_argument("encoding")
    parser.add_argument("atten")
    parser.add_argument("freq")
    parser.add_argument("msg")
    parser.add_argument("-t", "--transmit", action="store_true")

    args = parser.parse_args()

    p = Usb(0x0416, 0x5011, in_ep=0x81, out_ep=0x03, profile="NT-5890K")
    p.set(align="center")

    large_text(p)
    print_bolded(p, f"TRANSMISSION:\n{args.name}\n")
    normal_text(p)

    print_bolded(p, f"{'*'*PAPER_WIDTH}\n")
    p.set(align="left")
    if args.transmit:
        print_bolded(p, "Time of Transmission: ")
        p.text(f"{datetime.now()}\n") # TODO: change this
    else:
        print_bolded(p, "Time of Reception: ")
        p.text(f"{datetime.now()}\n")

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
    p.textln(args.msg)

    p.set(align="center", font="a")
    print_bolded(p, "-END TRANSMISSION-\n")
    p.ln()

    stars = generate_star_field(PAPER_WIDTH, 4, 10, args.name)
    for star_line in stars:
        p.textln(''.join(star_line))
    

    p.cut()
    

if __name__ == "__main__":
    print()