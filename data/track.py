from pynput import mouse

def on_click(x, y, button, pressed):
    if pressed:
        print(f"Mouse clicked at ({x}, {y}) with {button}")

with mouse.Listener(on_click=on_click) as listener:
    listener.join()


# Mouse clicked at (107, 728) with Button.left
# Mouse clicked at (109, 850) with Button.left
# Mouse clicked at (1556, 738) with Button.left

# Mouse clicked at (2097, 735) with Button.left
# Mouse clicked at (337, 693) with Button.left        
# Mouse clicked at (351, 806) with Button.left  