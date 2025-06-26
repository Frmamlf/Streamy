import os
from PIL import Image, ImageDraw, ImageFont
import math

def create_gradient_background(size, colors):
    """Create a gradient background"""
    image = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    
    # Create gradient effect
    for y in range(size):
        # Calculate color interpolation
        ratio = y / size
        r = int(colors[0][0] * (1 - ratio) + colors[2][0] * ratio)
        g = int(colors[0][1] * (1 - ratio) + colors[2][1] * ratio)
        b = int(colors[0][2] * (1 - ratio) + colors[2][2] * ratio)
        
        draw.line([(0, y), (size, y)], fill=(r, g, b, 255))
    
    return image

def create_rounded_rectangle(size, radius, color):
    """Create a rounded rectangle mask"""
    image = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    draw.rounded_rectangle([0, 0, size-1, size-1], radius=radius, fill=color)
    return image

def create_streamy_icon(size):
    """Create the Streamy app icon"""
    # Colors
    primary_color = (98, 0, 234)  # #6200EA
    dark_purple = (55, 0, 179)    # #3700B3
    very_dark = (26, 0, 71)       # #1A0047
    white = (255, 255, 255, 243)  # Almost white with slight transparency
    
    # Create base image
    image = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    
    # Create gradient background
    gradient_bg = create_gradient_background(size, [primary_color, dark_purple, very_dark])
    
    # Create rounded rectangle mask
    corner_radius = int(size * 0.15)
    rounded_mask = create_rounded_rectangle(size, corner_radius, (255, 255, 255, 255))
    
    # Apply rounded corners to gradient
    gradient_bg.putalpha(rounded_mask.split()[-1])
    image = Image.alpha_composite(image, gradient_bg)
    
    # Draw on the image
    draw = ImageDraw.Draw(image)
    center = size // 2
    
    # Main play button circle
    circle_radius = int(size * 0.28)
    circle_bbox = [
        center - circle_radius,
        center - circle_radius,
        center + circle_radius,
        center + circle_radius
    ]
    draw.ellipse(circle_bbox, fill=white)
    
    # Play triangle
    play_size = int(size * 0.12)
    play_offset = int(size * 0.02)
    triangle_points = [
        (center - play_size + play_offset, center - play_size),
        (center - play_size + play_offset, center + play_size),
        (center + play_size + play_offset, center)
    ]
    draw.polygon(triangle_points, fill=primary_color)
    
    # Film strip elements (simplified)
    strip_width = int(size * 0.08)
    strip_height = int(size * 0.3)
    
    # Left film strip
    left_strip_x = center - int(size * 0.35)
    left_strip_y = center - int(size * 0.15)
    draw.rectangle([
        left_strip_x, left_strip_y,
        left_strip_x + strip_width, left_strip_y + strip_height
    ], fill=(255, 255, 255, 200))
    
    # Film holes on left strip
    hole_size = int(strip_width * 0.3)
    for i in range(5):
        hole_y = left_strip_y + int((strip_height / 4) * i)
        draw.rectangle([
            left_strip_x + int(strip_width * 0.1), hole_y,
            left_strip_x + int(strip_width * 0.1) + hole_size, hole_y + hole_size
        ], fill=primary_color)
        draw.rectangle([
            left_strip_x + strip_width - int(strip_width * 0.1) - hole_size, hole_y,
            left_strip_x + strip_width - int(strip_width * 0.1), hole_y + hole_size
        ], fill=primary_color)
    
    # Right film strip
    right_strip_x = center + int(size * 0.27)
    draw.rectangle([
        right_strip_x, left_strip_y,
        right_strip_x + strip_width, left_strip_y + strip_height
    ], fill=(255, 255, 255, 200))
    
    # Film holes on right strip
    for i in range(5):
        hole_y = left_strip_y + int((strip_height / 4) * i)
        draw.rectangle([
            right_strip_x + int(strip_width * 0.1), hole_y,
            right_strip_x + int(strip_width * 0.1) + hole_size, hole_y + hole_size
        ], fill=primary_color)
        draw.rectangle([
            right_strip_x + strip_width - int(strip_width * 0.1) - hole_size, hole_y,
            right_strip_x + strip_width - int(strip_width * 0.1), hole_y + hole_size
        ], fill=primary_color)
    
    # Small movie icons at bottom
    icon_size = int(size * 0.08)
    bottom_y = center + int(size * 0.25)
    
    # Left movie camera icon
    left_icon_x = center - int(size * 0.3)
    draw.rectangle([
        left_icon_x, bottom_y,
        left_icon_x + int(icon_size * 0.8), bottom_y + int(icon_size * 0.6)
    ], fill=(255, 255, 255, 200))
    
    # Right video screen icon
    right_icon_x = center + int(size * 0.22)
    draw.rectangle([
        right_icon_x, bottom_y,
        right_icon_x + int(icon_size * 0.8), bottom_y + int(icon_size * 0.6)
    ], fill=(255, 255, 255, 200))
    
    # Small play button on video screen
    small_play_points = [
        (right_icon_x + int(icon_size * 0.3), bottom_y + int(icon_size * 0.2)),
        (right_icon_x + int(icon_size * 0.3), bottom_y + int(icon_size * 0.4)),
        (right_icon_x + int(icon_size * 0.5), bottom_y + int(icon_size * 0.3))
    ]
    draw.polygon(small_play_points, fill=primary_color)
    
    return image

def create_all_icon_sizes():
    """Create all required Android icon sizes"""
    sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192,
        '4k': 4096,  # 4K version
        '1024': 1024  # Standard high-res version
    }
    
    # Create output directory
    output_dir = '/workspaces/Streamy/app_icons'
    os.makedirs(output_dir, exist_ok=True)
    
    # Generate icons
    for folder, size in sizes.items():
        print(f"Generating {size}x{size} icon for {folder}...")
        
        icon = create_streamy_icon(size)
        
        if folder.startswith('mipmap'):
            # Create Android resource directory structure
            res_dir = f"{output_dir}/android/{folder}"
            os.makedirs(res_dir, exist_ok=True)
            icon.save(f"{res_dir}/ic_launcher.png", "PNG")
        else:
            # Save special sizes
            icon.save(f"{output_dir}/streamy_icon_{folder}.png", "PNG")
    
    print("All icons generated successfully!")
    print(f"Icons saved to: {output_dir}")

if __name__ == "__main__":
    create_all_icon_sizes()
