from PIL import Image

# Read the hex file and filter out address lines
with open('../img/fb-dump/frame_buffer.hex', 'r') as f:
    lines = f.readlines()

# Keep only lines that are valid hex values (2 characters, no //)
pixel_values = []
for line in lines:
    cleaned = line.strip()
    if cleaned and not cleaned.startswith('//') and len(cleaned) == 2:
        pixel_values.append(int(cleaned, 16))

# Verify we have the expected number of pixels
if len(pixel_values) != 320 * 240:
    print(f"Warning: Expected 76800 pixels, got {len(pixel_values)}")

# Create a new grayscale image
img = Image.new('L', (320, 240))

# Set pixel values
img.putdata(pixel_values)

# Save the image
img.save('../img/fb-dump/frame_buffer.png')
print("Image saved as frame_buffer.png")