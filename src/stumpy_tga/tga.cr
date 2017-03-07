require "stumpy_core"

module StumpyTGA
  class TGA
    property canvas : StumpyCore::Canvas
    property offset_x, offset_y : UInt16
    property pixel_depth : UInt8
    property image_id : String

    def initialize(buffer : Bytes, w, h, @pixel_depth, @offset_x = 0u16, @offset_y = 0u16, @image_id = "")
      bytesize = @pixel_depth / 8
      @canvas = StumpyCore::Canvas.new(w.to_i32, h.to_i32)
      ptr = buffer.pointer(0)
      h.times do |y|
        w.times do |x|
          @canvas[x, y] = ::StumpyTGA.bytes_to_rgba(ptr + (y * w + x) * bytesize, @pixel_depth)
        end
      end
    end

    def initialize(buffer : Array(RGBA), w, h, @pixel_depth, @offset_x = 0u16, @offset_y = 0u16, @image_id = "")
      bytesize = @pixel_depth / 8
      @canvas = StumpyCore::Canvas.new(w.to_i32, h.to_i32)
      h.times do |y|
        w.times do |x|
          @canvas[x, y] = buffer[y * w + x]
        end
      end
    end


  end
end
