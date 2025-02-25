import os
from PIL import Image, ImageEnhance
import colorsys
import numpy

folder_path = "C:/Users/mathieu.yeche/Downloads/Temp(a suppr)/ppt_todarken"

for filename in os.listdir(folder_path):
    if filename.endswith(".jpg") or filename.endswith(".jpeg") or filename.endswith(".png") or filename.endswith(".PNG") or filename.endswith(".JPEG") or filename.endswith(".JPG"):
        image_path = os.path.join(folder_path, filename)
        image = Image.open(image_path)
        
        
        try:
            alpha = image.getchannel('A')
            alphastat = True
        except Exception as e:
            alphastat = False
            print(f"A warning occurred: {str(e)}")
        
        # Convert colors to HSL system and adjust lightness
        pixels = image.load()
        hls_array = numpy.empty(shape=(image.height, image.width, 3), dtype=float)
        
        for row in range(0, image.height):
            for column in range(0, image.width):
                rgb = pixels[column, row]
                hls = colorsys.rgb_to_hls(rgb[0]/255, rgb[1]/255, rgb[2]/255)
                hls_array[row, column, 0] = hls[0]
                hls_array[row, column, 1] = 1 - hls[1]
                hls_array[row, column, 2] = hls[2]
           
        #Convert back to RGB
        new_image = Image.new("RGB", (hls_array.shape[1], hls_array.shape[0]))
        for row in range(0, new_image.height):
            for column in range(0, new_image.width):
                rgb = colorsys.hls_to_rgb(hls_array[row, column, 0],
                                        hls_array[row, column, 1],
                                        hls_array[row, column, 2])
                rgb = (int(rgb[0]*255), int(rgb[1]*255), int(rgb[2]*255))
                new_image.putpixel((column, row), rgb)   
        
        if alphastat:
            new_image.putalpha(alpha)
        new_image.save(os.path.join(folder_path, "dark", filename))



