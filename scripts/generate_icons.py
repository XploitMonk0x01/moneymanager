"""
Simple placeholder icon generator for MoneyManager app.
Creates basic PNG icons that can be replaced with custom designs.

Requirements: pip install pillow
"""

from PIL import Image, ImageDraw
import os

def create_wallet_icon(size=1024, output_path="app_logo.png"):
    """Create a simple wallet icon"""
    # Create a transparent image
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Material 3 Primary Green
    color = (76, 175, 80, 255)  # #4CAF50
    
    # Draw wallet shape (simplified)
    # Main wallet body
    padding = size // 8
    wallet_rect = [padding, padding * 2, size - padding, size - padding]
    draw.rounded_rectangle(wallet_rect, radius=size//10, fill=color)
    
    # Wallet flap
    flap_rect = [padding, padding, size - padding, padding * 2.5]
    draw.rounded_rectangle(flap_rect, radius=size//10, fill=(67, 160, 71, 255))
    
    # Card slot indicator
    card_width = size // 3
    card_height = size // 6
    card_x = (size - card_width) // 2
    card_y = size // 2
    draw.rounded_rectangle(
        [card_x, card_y, card_x + card_width, card_y + card_height],
        radius=size//30,
        fill=(255, 255, 255, 200)
    )
    
    # Save image
    img.save(output_path, 'PNG')
    print(f"Created: {output_path}")

def create_foreground_icon(size=1024, output_path="app_logo_foreground.png"):
    """Create foreground icon for adaptive icons"""
    # Create a transparent image
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Material 3 Primary Green
    color = (76, 175, 80, 255)  # #4CAF50
    
    # Safe zone for adaptive icons (inner 432x432 of 1024x1024)
    center = size // 2
    safe_size = int(size * 0.42)  # 432px for 1024px image
    
    # Draw simplified wallet in safe zone
    padding = (size - safe_size) // 2
    wallet_rect = [
        padding + safe_size // 6,
        padding + safe_size // 4,
        size - padding - safe_size // 6,
        size - padding - safe_size // 6
    ]
    draw.rounded_rectangle(wallet_rect, radius=size//15, fill=color)
    
    # Wallet flap
    flap_rect = [
        padding + safe_size // 6,
        padding + safe_size // 6,
        size - padding - safe_size // 6,
        padding + safe_size // 3
    ]
    draw.rounded_rectangle(flap_rect, radius=size//15, fill=(67, 160, 71, 255))
    
    # Save image
    img.save(output_path, 'PNG')
    print(f"Created: {output_path}")

if __name__ == "__main__":
    print("MoneyManager Icon Generator")
    print("-" * 40)
    
    # Ensure assets/icons directory exists
    os.makedirs("../../assets/icons", exist_ok=True)
    
    # Generate icons
    create_wallet_icon(1024, "../../assets/icons/app_logo.png")
    create_foreground_icon(1024, "../../assets/icons/app_logo_foreground.png")
    
    print("-" * 40)
    print("✓ Icons generated successfully!")
    print("\nNext steps:")
    print("1. Run: flutter pub get")
    print("2. Run: flutter pub run flutter_launcher_icons:main")
    print("3. Rebuild your app")
