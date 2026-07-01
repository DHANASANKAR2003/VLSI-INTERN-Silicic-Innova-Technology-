///////////////////////////////////////////////////////////////////////
// Fail Name : Sobel output to sobel edge detection Output           //
// Name : DHANASANKAR K                                              //
///////////////////////////////////////////////////////////////////////
  
import numpy as np
import matplotlib.pyplot as plt

def convert_sobel_output_to_image(input_file):
    # Read the Sobel output from the text file
    with open(input_file, 'r') as f:
        lines = f.readlines()

    sobel_values = []
    for line in lines:
        # Only extract value after 'Sobel Output:'
        if 'Sobel Output:' in line:
            try:
                value = int(line.split(':')[-1].strip())
                sobel_values.append(value)
            except ValueError:
                continue  # Skip any invalid lines

    print(f"Extracted {len(sobel_values)} Sobel values.")

    # Adjust the list to exactly 1024 values
    if len(sobel_values) < 65536:
        sobel_values.extend([0] * (65536 - len(sobel_values)))
        print(f"Padded Sobel values to 393216. Total values: {len(sobel_values)}")
    elif len(sobel_values) > 65536:
        sobel_values = sobel_values[:65536]
        print(f"Trimmed Sobel values to 65536. Total values: {len(sobel_values)}")

    # Convert to 2D array
    sobel_image = np.array(sobel_values).reshape((256,256))

    # Display the image
    plt.imshow(sobel_image, cmap='gray')
    plt.title('Sobel Edge Detection Output')
    plt.colorbar()
    plt.show()

    # Save the image as PNG
    plt.imsave('sobel_output_image.png', sobel_image, cmap='gray')
    print("Image saved as 'sobel_output_image.png'.")

# === Run this part ===
if __name__ == "__main__":
    input_file = 'sobel_output.txt'  # Replace with your actual file path
    convert_sobel_output_to_image(input_file)
