from PIL import Image, ImageDraw, ImageFont
import os

def create_feature_graphic():
    """Create a feature graphic for Google Play Store (1024x500)"""
    width, height = 1024, 500
    
    # Colors
    primary_color = (98, 0, 234)  # #6200EA
    dark_purple = (55, 0, 179)    # #3700B3
    very_dark = (26, 0, 71)       # #1A0047
    white = (255, 255, 255, 255)
    
    # Create base image
    image = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    
    # Create gradient background
    for y in range(height):
        ratio = y / height
        r = int(primary_color[0] * (1 - ratio) + very_dark[0] * ratio)
        g = int(primary_color[1] * (1 - ratio) + very_dark[1] * ratio)
        b = int(primary_color[2] * (1 - ratio) + very_dark[2] * ratio)
        draw.line([(0, y), (width, y)], fill=(r, g, b, 255))
    
    # Add some geometric elements
    center_x, center_y = width // 2, height // 2
    
    # Large play button
    play_radius = 80
    circle_bbox = [
        center_x - play_radius,
        center_y - play_radius,
        center_x + play_radius,
        center_y + play_radius
    ]
    draw.ellipse(circle_bbox, fill=(255, 255, 255, 240))
    
    # Play triangle
    play_size = 40
    play_offset = 8
    triangle_points = [
        (center_x - play_size + play_offset, center_y - play_size),
        (center_x - play_size + play_offset, center_y + play_size),
        (center_x + play_size + play_offset, center_y)
    ]
    draw.polygon(triangle_points, fill=primary_color)
    
    # Film strips on sides
    strip_width = 60
    strip_height = height - 100
    
    # Left strip
    left_x = 150
    draw.rectangle([left_x, 50, left_x + strip_width, 50 + strip_height], fill=(255, 255, 255, 200))
    
    # Right strip
    right_x = width - 150 - strip_width
    draw.rectangle([right_x, 50, right_x + strip_width, 50 + strip_height], fill=(255, 255, 255, 200))
    
    # Film holes
    hole_size = 20
    holes_count = 15
    for i in range(holes_count):
        hole_y = 50 + int((strip_height / (holes_count - 1)) * i)
        # Left strip holes
        draw.rectangle([left_x + 10, hole_y, left_x + 10 + hole_size, hole_y + hole_size], fill=primary_color)
        draw.rectangle([left_x + strip_width - 30, hole_y, left_x + strip_width - 10, hole_y + hole_size], fill=primary_color)
        # Right strip holes
        draw.rectangle([right_x + 10, hole_y, right_x + 10 + hole_size, hole_y + hole_size], fill=primary_color)
        draw.rectangle([right_x + strip_width - 30, hole_y, right_x + strip_width - 10, hole_y + hole_size], fill=primary_color)
    
    # Add text - we'll use a simple approach without external fonts
    title_y = height - 120
    subtitle_y = height - 80
    
    # Title - STREAMY
    try:
        # Try to use a system font
        title_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 72)
        subtitle_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 32)
    except:
        # Fallback to default font
        title_font = ImageFont.load_default()
        subtitle_font = ImageFont.load_default()
    
    # Get text dimensions and center it
    title_text = "STREAMY"
    subtitle_text = "Stream Movies, Shows & Anime"
    
    # Draw title with shadow effect
    shadow_offset = 3
    draw.text((center_x + shadow_offset, title_y + shadow_offset), title_text, 
              font=title_font, fill=(0, 0, 0, 100), anchor="mm")
    draw.text((center_x, title_y), title_text, 
              font=title_font, fill=white, anchor="mm")
    
    # Draw subtitle
    draw.text((center_x, subtitle_y), subtitle_text, 
              font=subtitle_font, fill=(255, 255, 255, 200), anchor="mm")
    
    return image

def create_promotional_assets():
    """Create promotional assets for app store"""
    output_dir = '/workspaces/Streamy/promotional_assets'
    os.makedirs(output_dir, exist_ok=True)
    
    # Feature graphic
    print("Creating feature graphic...")
    feature_graphic = create_feature_graphic()
    feature_graphic.save(f"{output_dir}/feature_graphic_1024x500.png", "PNG")
    
    # Create different sizes for various stores
    # App Store screenshot background (1242x2688 for iPhone X)
    print("Creating App Store assets...")
    app_store_bg = Image.new('RGBA', (1242, 2688), (26, 0, 71, 255))
    
    # Add the app icon to center
    icon_path = '/workspaces/Streamy/app_icons/streamy_icon_1024.png'
    if os.path.exists(icon_path):
        icon = Image.open(icon_path)
        icon = icon.resize((400, 400), Image.Resampling.LANCZOS)
        app_store_bg.paste(icon, (421, 1144), icon)
    
    app_store_bg.save(f"{output_dir}/app_store_screenshot_bg.png", "PNG")
    
    print(f"Promotional assets created in: {output_dir}")

if __name__ == "__main__":
    create_promotional_assets()
