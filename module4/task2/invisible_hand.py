import pygame
import socket

from typing import List
from perlin_noise import PerlinNoise

FULLSCREEN = False

# Wireless initialization
ESP32_ADDR = ("192.168.0.137", 6101)
client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
# client_socket.connect(ESP32_ADDR)

pygame.init()

if FULLSCREEN:
    screen_info = pygame.display.Info()
    WIDTH, HEIGHT = screen_info.current_w, screen_info.current_h
    screen_flags = pygame.FULLSCREEN
else:
    WIDTH = 1024
    HEIGHT = 512
    screen_flags = 0

screen = pygame.display.set_mode((WIDTH, HEIGHT), screen_flags)
pygame.display.set_caption("The Invisible Hand")

clock = pygame.time.Clock()
running = True

faucet_img = pygame.transform.scale_by(pygame.image.load("resources/faucet.png"), 0.25)

class Button:
    def __init__(self, x, y, width, height, text, callback, color=(1, 129, 129), text_color=(255, 255, 255), alt_text=""):
        self.rect = pygame.Rect(x, y, width, height)
        self.text = text
        self.callback = callback
        self.color = color
        self.text_color = text_color
        self.font = pygame.font.SysFont("SourceCodePro-Black.otf", 32)
        self.alt_text = alt_text

    def draw(self):
        pygame.draw.rect(screen, self.color, self.rect)
        self.text_surface = self.font.render(self.text, True, self.text_color)
        text_rect = self.text_surface.get_rect(center=self.rect.center)
        screen.blit(self.text_surface, text_rect)

    def is_clicked(self, pos):
        return self.rect.collidepoint(pos)

    def invoke_callback(self):
        self.callback()

    def is_hovered(self, pos):
        return self.rect.collidepoint(pos)

class TextBox(Button):
    def __init__(self, x, y, width, height, text_color=(0, 0, 0)):
        super().__init__(x, y, width, height, "", self.invoke_callback, (255, 255, 255), text_color)
        self._cursor_timer = 0
        self._cursor_visible = True

    def add_to_textbox(self, new_text: str):
        self.text += new_text.upper()

    def backspace(self):
        if len(self.text) > 0:
            self.text = self.text[:-1]

    def draw(self):
        super().draw()
        self._cursor_timer += 1
        if self._cursor_timer > 30:
            self._cursor_timer = 0
            self._cursor_visible = not self._cursor_visible

        if self._cursor_visible:
            cursor_x = self.rect.x + (self.rect.width//2) + (self.text_surface.get_width() // 2)
            pygame.draw.rect(screen, self.text_color, (cursor_x, self.rect.y + 5, 2, self.rect.height - 10))

    def invoke_callback(self):
        print("text box clicked")

class Money:
    WIDTH = 64
    HEIGHT = 64
    IMG = pygame.transform.scale(pygame.image.load("resources/money.png"), (WIDTH, HEIGHT))

    def __init__(self, x, y):
        self._x = x
        self._y = y
        self._fall_rate = 1
        
    def update_money(self):
        self._y += self._fall_rate
        self._fall_rate += 0.01

    def draw(self):
        self.update_money()
        screen.blit(Money.IMG, (self._x, self._y))

    def out_of_bounds(self):
        return self._y - 64 > HEIGHT

def draw_text(text, font, color, x, y):
    text_surface = font.render(text, True, color)
    text_rect = text_surface.get_rect()
    text_rect.topleft = (x, y)
    screen.blit(text_surface, text_rect)

def get_text_offset(coords, text, font):
    font_size = font.size(text)
    return (coords[0] - font_size[0]//2 , coords[1] - font_size[1]//2)

description_text = ""

def fund_cfpb():
    pass

def update_stock(new_ticker: str):
    global description_text
    description_text = f"Current Stock: {new_ticker}"



cfpb_button = Button((WIDTH*5//6)- 300, HEIGHT*5//6, 300, 50, "Fund CFPB", fund_cfpb, alt_text="Start recording new soundscape with junglebox")
title_text = "The Invisible Hand"
title_text_emoji = "🤑"
stock_input = TextBox((WIDTH//2) - 150, HEIGHT*5//6, 300, 36)

clickable_elements = [stock_input]
money_list: List[Money] = []

noise = PerlinNoise(10.23)

# initialize program to cheesecake factory
update_stock("CAKE")

print("Starting pygame interface")
while running:

    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
        elif event.type == pygame.MOUSEBUTTONDOWN:
            if event.button == 1:  # Left mouse button
                background_clicked = True
                for elem in clickable_elements:
                    if elem.is_clicked(event.pos):
                        elem.invoke_callback()
                        background_clicked = False
                        break
                
                if background_clicked:
                    print(event)
                    money_list.append(Money(event.pos[0]-Money.WIDTH//2, event.pos[1]-Money.HEIGHT//2))
            
        elif event.type == pygame.MOUSEMOTION:
            is_hovered = False
            for elem in clickable_elements:
                if elem.is_hovered(event.pos):
                    is_hovered = True
                    break

            if is_hovered:
                cursor = pygame.SYSTEM_CURSOR_HAND 
            else:
                cursor = pygame.SYSTEM_CURSOR_ARROW
    
            pygame.mouse.set_cursor(cursor)

        elif event.type == pygame.KEYDOWN:
            if event.key == pygame.K_RETURN:
                update_stock(stock_input.text)
            elif event.key == pygame.K_BACKSPACE:
                stock_input.backspace()
            else:
                cap = event.unicode.upper()
                if ord(cap) >= ord('A') and ord(cap) <= ord('Z'):
                    print(event)
                    stock_input.add_to_textbox(event.unicode)

    screen.fill((1, 129, 129))
    # screen.blit(bg_img, (0, 0))
    
    # Define font and text content
    font = pygame.font.SysFont("SourceCodePro-Black.otf", 72)
    
    # Draw the text element on the screen
    title_text_pos = get_text_offset((WIDTH//2, HEIGHT*1//5), title_text, font)
    description_text_pos = get_text_offset((WIDTH//2, HEIGHT*4//6), description_text, font)
    draw_text(title_text, font, (223, 223, 96), title_text_pos[0], title_text_pos[1])
    draw_text(description_text, font, (192, 192, 192), description_text_pos[0], description_text_pos[1])
    
    # draw UI elements
    cfpb_button.draw()
    stock_input.draw()

    # draw money animations
    for elem in money_list:
        if not elem.out_of_bounds():
            elem.draw()
        else:
            money_list.remove(elem)

    # draw faucet
    faucet_box = screen.blit(faucet_img, (-30, 30))

    # trickle down economics
    if abs(noise(pygame.time.get_ticks()/10000)) < 0.01:
        money_list.append(Money(faucet_box.bottomright[0]-40, faucet_box.bottomright[1]-15))
        # print(abs(noise(pygame.time.get_ticks()/10000)))

    pygame.display.flip()

    clock.tick(60)

pygame.quit()
client_socket.close()