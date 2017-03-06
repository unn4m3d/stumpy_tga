require "./seq_struct"

module StumpyTGA
  seq_struct ColorMapSpec,
    index: UInt16,
    length: UInt16,
    entry_size: UInt8

  seq_struct ImageSpec,
    x_origin: UInt16,
    y_origin: UInt16,
    width: UInt16,
    height: UInt16,
    pixel_depth: UInt8,
    descriptor: UInt8

  seq_struct Header,
    id_length: UInt8,
    color_map_type: UInt8,
    image_type: UInt8,
    color_map: ColorMapSpec,
    image: ImageSpec

end
