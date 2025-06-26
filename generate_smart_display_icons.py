import os
from PIL import Image, ImageDraw, ImageFont
import math

def create_adaptive_background(size, colors):
    """Create an adaptive background with gradient"""
    image = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    
    # Create radial gradient effect
    center = size // 2
    max_radius = size // 2
    
    for radius in range(max_radius, 0, -1):
        # Calculate color interpolation based on radius
        ratio = (max_radius - radius) / max_radius
        
        # Interpolate between colors
        r = int(colors[0][0] * (1 - ratio) + colors[1][0] * ratio)
        g = int(colors[0][1] * (1 - ratio) + colors[1][1] * ratio)
        b = int(colors[0][2] * (1 - ratio) + colors[1][2] * ratio)
        
        # Draw circle
        bbox = [center - radius, center - radius, center + radius, center + radius]
        draw.ellipse(bbox, fill=(r, g, b, 255))
    
    return image

def create_rounded_rectangle(size, radius, color):
    """Create a rounded rectangle mask for adaptive icons"""
    image = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    draw.rounded_rectangle([0, 0, size-1, size-1], radius=radius, fill=color)
    return image

def create_smart_display_icon(size, is_foreground=False):
    """Create the smart_display icon (Material Symbols)"""
    # Modern color scheme - streaming purple/blue gradient
    if is_foreground:
        # For adaptive foreground (monochrome)
        primary_color = (255, 255, 255, 255)  # White
        accent_color = (255, 255, 255, 200)   # Semi-transparent white
        bg_color = (0, 0, 0, 0)               # Transparent
    else:
        # For regular icon
        primary_color = (138, 43, 226)        # Blue Violet
        secondary_color = (72, 61, 139)       # Dark Slate Blue  
        accent_color = (255, 255, 255, 255)   # White
        bg_colors = [(138, 43, 226), (72, 61, 139)]  # Gradient
    
    # Create base image
    image = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    
    if not is_foreground:
        # Create gradient background for regular icon
        gradient_bg = create_adaptive_background(size, bg_colors)
        
        # Create rounded rectangle mask (for adaptive icons)
        corner_radius = int(size * 0.18)  # Material Design adaptive icon radius
        rounded_mask = create_rounded_rectangle(size, corner_radius, (255, 255, 255, 255))
        
        # Apply rounded corners to gradient
        gradient_bg.putalpha(rounded_mask.split()[-1])
        image = Image.alpha_composite(image, gradient_bg)
    
    # Draw the smart_display icon
    draw = ImageDraw.Draw(image)
    center = size // 2
    
    # Main display rectangle (smart_display base)
    display_width = int(size * 0.5)
    display_height = int(size * 0.36)
    display_x = center - display_width // 2
    display_y = center - display_height // 2
    
    # Create rounded rectangle for display
    display_radius = int(size * 0.04)
    display_bbox = [display_x, display_y, display_x + display_width, display_y + display_height]
    
    if is_foreground:
        # Simple white outline for adaptive foreground
        draw.rounded_rectangle(display_bbox, radius=display_radius, outline=primary_color, width=int(size * 0.025))
    else:
        # Filled display with subtle shadow
        shadow_offset = int(size * 0.008)
        shadow_bbox = [
            display_x + shadow_offset, 
            display_y + shadow_offset, 
            display_x + display_width + shadow_offset, 
            display_y + display_height + shadow_offset
        ]
        draw.rounded_rectangle(shadow_bbox, radius=display_radius, fill=(0, 0, 0, 60))
        draw.rounded_rectangle(display_bbox, radius=display_radius, fill=accent_color)
    
    # Play button in center of display
    play_size = int(size * 0.14)
    play_center_x = center + int(size * 0.012)  # Slightly offset right for visual balance
    play_center_y = center
    
    # Play triangle points
    triangle_points = [
        (play_center_x - play_size // 2, play_center_y - play_size // 2),
        (play_center_x - play_size // 2, play_center_y + play_size // 2),
        (play_center_x + play_size // 2, play_center_y)
    ]
    
    if is_foreground:
        draw.polygon(triangle_points, fill=primary_color)
    else:
        draw.polygon(triangle_points, fill=primary_color)
    
    # Smart display additional elements
    if not is_foreground:
        # Small indicator dots (streaming status)
        dot_size = int(size * 0.02)
        dot_spacing = int(size * 0.04)
        start_x = center - dot_spacing
        dot_y = display_y + display_height + int(size * 0.08)
        
        for i in range(3):
            dot_x = start_x + (i * dot_spacing)
            dot_bbox = [dot_x - dot_size, dot_y - dot_size, dot_x + dot_size, dot_y + dot_size]
            alpha = 255 - (i * 60)  # Fade effect
            draw.ellipse(dot_bbox, fill=(255, 255, 255, alpha))
        
        # Wireless signal indicator (top right corner of display)
        signal_x = display_x + display_width - int(size * 0.08)
        signal_y = display_y + int(size * 0.02)
        signal_size = int(size * 0.03)
        
        # Three curved lines for wireless signal
        for i in range(3):
            arc_size = signal_size + (i * int(size * 0.015))
            arc_bbox = [
                signal_x - arc_size, signal_y - arc_size,
                signal_x + arc_size, signal_y + arc_size
            ]
            alpha = 200 - (i * 40)
            draw.arc(arc_bbox, start=315, end=45, fill=(255, 255, 255, alpha), width=int(size * 0.008))
    
    return image

def create_adaptive_icon_set(size):
    """Create adaptive icon set (background + foreground)"""
    # Background (solid color or gradient)
    bg_image = Image.new('RGBA', (size, size), (138, 43, 226, 255))  # Solid purple background
    
    # Foreground (monochrome icon)
    fg_image = create_smart_display_icon(size, is_foreground=True)
    
    # Regular icon (combined)
    regular_icon = create_smart_display_icon(size, is_foreground=False)
    
    return bg_image, fg_image, regular_icon

def create_all_icon_sizes():
    """Create all required Android icon sizes with adaptive support"""
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
        
        if folder.startswith('mipmap'):
            # Create Android resource directory structure
            res_dir = f"{output_dir}/android/{folder}"
            os.makedirs(res_dir, exist_ok=True)
            
            # Create adaptive icon set
            bg_icon, fg_icon, regular_icon = create_adaptive_icon_set(size)
            
            # Save all variants
            regular_icon.save(f"{res_dir}/ic_launcher.png", "PNG")
            bg_icon.save(f"{res_dir}/ic_launcher_background.png", "PNG")
            fg_icon.save(f"{res_dir}/ic_launcher_foreground.png", "PNG")
            
            # Also create round icon
            regular_icon.save(f"{res_dir}/ic_launcher_round.png", "PNG")
            
        else:
            # Save special sizes (regular icon only)
            _, _, regular_icon = create_adaptive_icon_set(size)
            regular_icon.save(f"{output_dir}/streamy_icon_{folder}.png", "PNG")
    
    print("All icons generated successfully!")
    print(f"Icons saved to: {output_dir}")
    print("\nGenerated files:")
    print("- Regular icons: ic_launcher.png")
    print("- Adaptive background: ic_launcher_background.png") 
    print("- Adaptive foreground: ic_launcher_foreground.png")
    print("- Round icons: ic_launcher_round.png")

if __name__ == "__main__":
    create_all_icon_sizes()
