
from PIL import Image
import collections

try:
    img = Image.open('c:\\Users\\sergio\\Desktop\\tribe\\tribe\\assets\\images\\final_icon.png')
    # Get color of top-left pixel (usually background)
    bg_color = img.getpixel((0, 0))
    # Convert to hex
    def to_hex(rgba):
        if len(rgba) == 3:
            return '#{:02x}{:02x}{:02x}'.format(*rgba)
        else:
            return '#{:02x}{:02x}{:02x}'.format(*rgba[:3])

    print(f"Top-left color: {bg_color}")
    print(f"Hex: {to_hex(bg_color)}")
    
    # Check distinct colors to see if it's flat
    colors = img.getcolors(maxcolors=1000)
    if colors:
        print(f"Number of unique colors: {len(colors)}")
        # print most common
        most_common = sorted(colors, reverse=True)[:5]
        print(f"Most common colors: {most_common}")

except Exception as e:
    print(f"Error: {e}")
