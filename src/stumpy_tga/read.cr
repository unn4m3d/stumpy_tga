require "./header"
require "stumpy_core"
require "./tga"

module StumpyTGA
  include StumpyCore
  BYTE_ORDER = IO::ByteFormat::LittleEndian

  def self.dbg(str)
    puts str if ENV["DBG"]?
  end

  protected def self.read_runlength_packet(io, isize)
    header = io.read_bytes(UInt8, BYTE_ORDER)
    size = header & 0x7F
    if header & 0x80 == 0x80
      # This is RunLength packet
      dbg "Read RLP #{size} at #{io.pos - 1}"
      one = Bytes.new(isize)
      io.read_fully one
      b = Bytes.new(size*isize)
      size.times do |i|
        isize.times do |j|
          b[i*isize + j] = one[j]
        end
      end
      b
    else
      # This is raw packet
      dbg "Read Raw #{size}"
      b = Bytes.new(size*isize)
      io.read_fully(b)
      b
    end
  end

  protected def self.map_to_u16(val, max)
    ((val.to_f32/max)*UInt16::MAX).to_u16
  end

  protected def self.bytes_to_rgba(slice, bitsize)
    case bitsize
    when 16
      # Remember all data is stored in little endian
      b = slice[0] & 31
      g = slice[0] >> 5 & (slice[1] & 3)
      r = (slice[1] >> 2) & 31
      RGBA.new(
        map_to_u16(r, 31),
        map_to_u16(g, 31),
        map_to_u16(b, 31),
        UInt16::MAX
      )
    when 24 , 32
      b, g, r = slice
      RGBA.new(
        map_to_u16(r, UInt8::MAX),
        map_to_u16(g, UInt8::MAX),
        map_to_u16(b, UInt8::MAX),
        UInt16::MAX
      )
    else
      raise "Bit depth is not supported : #{bitsize}"
    end
  end

  protected def self.parse_color_map(offset, esize, bytes)
    map = {} of UInt64 => RGBA
    bytesize = (esize/8.0).ceil.to_i64
    idx = offset.to_u64
    bytes.each_slice bytesize, reuse: true do |sl|
      map[idx] = bytes_to_rgba sl, esize
      idx += 1
    end
    map
  end

  protected def self.read_int_le(io, len)
    bytes = Bytes.new((len/8.0).ceil.to_u64)
    io.read_fully(len)
    parse_int_le bytes
  end

  protected def self.parse_int_le(bytes)
    int = 0u64
    bytes.each_with_index do |e,i|
      int |= (e << i*8)
    end
    int
  end

  def self.read_raw(file : String)
    File.open(file) do |io|
      # First, read header
      header = io.read_bytes Header, BYTE_ORDER

      # Then read Image ID
      image_id = io.read_string(header.id_length)

      # Then read Color Map if exists

      color_map = if header.color_map_type == 0
        Bytes.new(0)
      else
        cmp = Bytes.new(header.color_map.entry_size * header.color_map.length)
        io.read_fully(cmp)
        cmp
      end

      # Then read Image Data
      # 1. Calculate number of bytes to store each index
      bytes_cnt = (header.image.pixel_depth / 8.0).ceil.to_u64
      dbg "Depth is #{header.image.pixel_depth}"
      dbg "Bytes per pixel : #{bytes_cnt}"

      # 2. Calculate image size
      size = header.image.width * header.image.height
      dbg "Size is #{size} (#{header.image.width}x#{header.image.height})"
      # 3. Read Image data
      image_data = Bytes.new(size.to_u64 * bytes_cnt)
      dbg "Buf size is #{size.to_u64 * bytes_cnt}"
      case header.image_type
      when 1 , 2
        io.read_fully(image_data)
      when 9 , 10
        bytes_read = 0u32
        while bytes_read < size
          buf = read_runlength_packet(io, bytes_cnt)
          ptr = image_data.pointer(0) + bytes_read
          raise "Read more than specified" if bytes_read + buf.size > size.to_u64 * bytes_cnt
          buf.copy_to(ptr, buf.size)
          bytes_read += buf.size
          dbg "# #{bytes_read}"
        end
      else
        raise "Unsupported image type #{header.image_type}"
      end

      if header.image_type & 2 == 2 # If RGB image
        TGA.new image_data,
          header.image.width,
          header.image.height,
          header.image.pixel_depth,
          header.image.x_origin,
          header.image.y_origin,
          image_id
      else
        cm_offset = header.color_map.index
        cm_elen = header.color_map.entry_size
        cm = parse_color_map cm_offset, cm_elen, color_map

        buffer = Array(RGBA).new(size, RGBA.new(0u16,0u16,0u16,0u16))

        idx = 0
        image_data.each_slice(bytes_cnt) do |sl|
          buffer[idx] = cm[parse_int_le sl]
        end
        TGA.new buffer,
          header.image.width,
          header.image.height,
          header.image.pixel_depth,
          header.image.x_origin,
          header.image.y_origin,
          image_id
      end
    end
  end

  def self.read(file)
    read_raw(file).canvas
  end
end
