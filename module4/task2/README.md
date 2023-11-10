# Ronald Ratgan and the Invisible Paw
The 1980 election of Ronald Ratgan in the United States of Micerica has completely demolished the middle class. This kinetic sculpture shows the forces of the free market upon the everyday rat citizen. If the user-inputted stock has a negative close for the day, the rats are punished by the knife wielded by the “invisible paw”. The worse the stock performed during market hours, the more intense the pain will be… However, as long as regulatory bodies such as the Consumer Financial Protection Bureau receive funding, the rat citizens may be relieved from their torture.

[Demo Video](https://www.youtube.com/watch?v=CRRM5PzwWc0)

## Files
- `invisible_paw.py`: Pygame interface to control stock/CFPB funding
- `rat_society/rat_society.ino`: ESP32 code that controls the motors and communication

Note that `rat_society.ino` requires an imported `secrets.h` file which contains the following definitions:
```
#define API_KEY "..."
#define SSID "..."
#define WIFI_PASS "..."
```

## Writeup
[Link](writeup/writeup.pdf)