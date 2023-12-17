# Sonderful Transmissions

Final project for CPSC334.

“Sonderful Transmissions” is an installation that explores the idea behind encoding meaning in non-traditional, universal forms of communication. Users are presented with a navigable starfield that contains transmitted messages from other previous interactions with the installation. Users can choose to either transmit a message at a given coordinate or decode a pre-existing transmission. For transmitting, a message is entered and the parameters on the transmission device are tuned to the user’s liking. For decoding a message, a user has to replicate the same transmission parameters on the device to obtain the text of the original message. Upon both a successful transmission or decoding, a receipt is printed which serves as a physical stamp of that action and message.

## Files
`background_generator/` - Processing program to generate the static NxN starfield. Uses Perlin noise to generate "nebulas" and weighted randomness to generate stars, with a higher chance for stars in nebula regions.
`transmission_device/` - ESP32 code for the transmission device. 
`transmission_field/scripts/print_receipt.py` - Python script for printing to receipt printer.
`transmission_field/*.pde` - Processing interface to interact with starfield and send/decode messages.

All messages with their corresponding encoding values are stored in `transmission_field/resources/transmissions.csv`
The python-escpos library is needed to print from the receipt printer.

