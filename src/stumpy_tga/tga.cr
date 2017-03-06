require "stumpy_core"

module StumpyTGA
  class TGA
    property canvas : StumpyCore::Canvas
    property offset_x, offset_y : UInt16
    property pixel_depth : UInt8
    property image_id : String

    def initialize(buffer, w, h, @pixel_depth, @offset_x = 0u16, @offset_y = 0u16, @image_id = "")
      bytesize = @pixel_depth / 8
      @canvas = StumpyCore::Canvas.new((@offset_x + w).to_i32, (@offset_y + h).to_i32)
      @offset_x.times do |x|
        (@offset_y + h).times do |y|
          @canvas[x, y] = RGBA.new(0u16,0u16,0u16,0u16)
        end
      end
      w.times do |x|
        @offset_y.times do |y|
          canvas[x + @offset_x, y] = RGBA.new(0u16,0u16,0u16,0u16)
        end
      end
      ptr = buffer.pointer(0)
      h.times do |y|
        w.times do |x|
          @canvas[x, y] = ::StumpyTGA.bytes_to_rgba(ptr + (y * w + x) * bytesize, @pixel_depth)
        end
      end
    end
  end
end
