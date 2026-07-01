# 🖼️ FPGA-Based Sobel Edge Detection Pipeline (Python + Verilog)

This project implements a full pipeline for **Sobel edge detection** using **Verilog** and **Python**. It starts with converting an image into grayscale pixel values using Python, passes the pixel data to a Verilog testbench for Sobel filtering, and finally retrieves the output from Verilog back into Python for visualization.

---

## 📌 Project Structure

---

## ⚙️ Step-by-Step Execution

### 1️⃣. Convert Input Image to Pixels using Python

Use the `image_pixel_Conversion.py` script to:
- Read an image (`image.png`)
- Resize it (e.g., 256x256)
- Convert to 8-bit grayscale
- Save the pixels in `pixels_output.txt`
  #### Example Pixel Output
  ```bash
  
  pixel_in = 8'd33; #10;
  pixel_in = 8'd24; #10;
  pixel_in = 8'd19; #10;
  pixel_in = 8'd18; #10;
  pixel_in = 8'd16; #10;
  .
  .
  65536 pixels 

### 2️⃣. Sobel Edge Detection (Verilog)
 
File: `sobel_filter.v`, `Sobel_Filter_tb.v`
- Reads pixels from `pixels_output.txt`
- Buffers rows to apply a 3×3 Sobel filter
- Computes gradients Gx and Gy
- Outputs gradient magnitude to `Sobel_output.txt`
- python3 `image_pixel_Conversion.py`
  #### Example Sobel_output.txt
  ```bash
  Sobel Output: 1
  Sobel Output: 1
  Sobel Output: 1
  Sobel Output: 1
  Sobel Output: 1
  Sobel Output: 0
  Sobel Output: 1
  Sobel Output: 1
  Sobel Output: 1
  
### 3️⃣. Pixels to Image (Python)
File: `Sobel_Out_to_Edge_image_Conversion.py`
- Reads `Sobel_output.txt` (edge magnitude values)
- Converts the data into a 2D image
- Saves result as `sobel_output_image.png`

## 📐Sobel Filter Logic
The Verilog Sobel filter computes edges using convolution:

  #### Sobel Kernels:
  ```bash
  Gx = [ [-1  0  +1],          Gy =[ [ +1  +2  +1],
         [-2  0  +2],                [  0   0   0],
         [-1  0  +1] ]               [ -1  -2  -1] ]
```
  #### Edge Magnitude:
                 
                 G=∣Gx∣+∣Gy∣   clamped to 0 – 255

## 🧠 Deep Explanation
#### 🔧 Verilog Architecture
- **Line Buffers** simulate memory storing 3 image rows
- **Sliding Window** extracts 3x3 pixels for filtering
- **Sobel Logic computes** Gx, Gy, and final edge strength
- **Testbench** feeds pixel values and stores output in text file

## 🖼️ Sample Input and Output
#### 🎯 Input Image

![dhanush](https://github.com/user-attachments/assets/5009447c-7d30-444b-b54d-829967b1571b)

#### 🎯 Output Image (Sobel Edge Detection)

![image](https://github.com/user-attachments/assets/4887545f-fa9d-48ef-bd6f-4b22cb28f863) 

## 🔄 Visual Data Flow

## ✅ Real-World FPGA Insight
This project emulates an actual FPGA design where:

- Pixels stream from a camera module
- Sobel filtering is done in hardware
- Output is displayed to LCD or VGA screen

By simulating in Verilog and processing with Python, you can test the design thoroughly before hardware implementation.

## 🚀 Future Work
- Add thresholding to output (binary edges)
- Integrate on FPGA board (e.g., DE2-70 or Artix-7)
- Display real-time video feed with edge overlay

## 🧪 Requirements
- Python 3.6+
- Pillow, matplotlib
- Icarus Verilog (or any Verilog simulator)

## 👨‍💻 Author
   This project was designed for **educational use** and **FPGA simulation**, showcasing how to integrate **Python and Verilog** for real-time digital image processing using the Sobel edge detection algorithm.
   ### Created by: DHANASANKAR K
   🔗 LinkedIn: (www.linkedin.com/in/dhanasankar-k-23b196291)







