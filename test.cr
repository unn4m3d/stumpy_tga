require "./src/stumpy_tga"

tga = StumpyTGA.read_raw("./ctc32.tga")
puts tga.canvas.width
