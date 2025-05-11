/////////////////////////////////////////////////////////
// Fail Name: Image to Pixel Conversion                //
// Name : DHANASANKAR K                                //
// //////////////////////////////////////////////////////

from PIL import Image

# Load and convert the image to grayscale
img = Image.open("image.png").convert('L')

# Resize to 50x50 for your Verilog testbench
img = img.resize((256,256))

# Extract 8-bit grayscale values
pixel_values = []

for y in range(img.height):
    for x in range(img.width):
        pixel = img.getpixel((x, y))
        pixel_values.append(pixel)

# Write to output file
with open("pixels_output.txt", "w") as f:
    f.write(f"// Verilog pixel data for {img.width}x{img.height} image\n")
    f.write(f"reg [7:0] image [0:{len(pixel_values)-1}];\n")
    for idx, val in enumerate(pixel_values):
        f.write(f"pixel_in = 8'd{val}; #10;\n")
