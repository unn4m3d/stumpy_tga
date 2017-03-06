require "stumpy_core"

module StumpyTGA
  class TGA
    property canvas : StumpyCore::Canvas
    property offset_x, offset_y : UInt16
    property pixel_depth : UInt8
    property image_id : String

    @[AlwaysInline]
    private def origin!(w, h)
      @offset_x.times do |x|
        (@offset_y + h).times do |y|
          @canvas[x, y] = RGBA.new(0u16,0u16,0u16,0u16)
        end
      end
      w.times do |x|
        @offset_y.times do |y|
          @canvas[x + @offset_x, y] = RGBA.new(0u16,0u16,0u16,0u16)
        end
      end
    end

    def initialize(buffer : Bytes, w, h, @pixel_depth, @offset_x = 0u16, @offset_y = 0u16, @image_id = "")
      bytesize = @pixel_depth / 8
      @canvas = StumpyCore::Canvas.new((@offset_x + w).to_i32, (@offset_y + h).to_i32)
      origin! w, h
      ptr = buffer.pointer(0)
      h.times do |y|
        w.times do |x|
          @canvas[x, y] = ::StumpyTGA.bytes_to_rgba(ptr + (y * w + x) * bytesize, @pixel_depth)
        end
      end
    end

    def initialize(buffer : Array(RGBA), w, h, @pixel_depth, @offset_x = 0u16, @offset_y = 0u16, @image_id = "")
      bytesize = @pixel_depth / 8
      @canvas = StumpyCore::Canvas.new((@offset_x + w).to_i32, (@offset_y + h).to_i32)
      origin! w,h
      h.times do |y|
        w.times do |x|
          @canvas[x, y] = buffer[y * w + x]
        end
      end
    end


  end
end
