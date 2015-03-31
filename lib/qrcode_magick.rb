require 'qrcode_magick/version'
require 'rqrcode'
require 'rmagick'

module QRCodeMagick
  
  def self.draw(string, *args)
    opts = self.defaults
    self.parse_options(args, opts)
    qrcode = RQRCode::QRCode.new(string, :size => opts[:size], :level => opts[:level])
    opts[:drawing] = self.generate_drawing(qrcode, opts[:drawing], opts[:scale])
  end
  
  def self.draw_image (string, *args)
    opts = self.defaults
    self.parse_options(args, opts)
    qrcode = RQRCode::QRCode.new(string, :size => opts[:size], :level => opts[:level])
    opts[:drawing].stroke(opts[:fg])
    opts[:drawing].fill(opts[:fg])
    opts[:drawing] = self.generate_drawing(qrcode, opts[:drawing], opts[:scale])
    opts[:canvas] = self.generate_canvas(qrcode, opts[:scale], opts[:bg]) unless opts[:canvas]
    opts[:drawing].draw(opts[:canvas])
    opts[:canvas].write(opts[:write_to]) if opts[:write_to]
    opts[:canvas]
  end
  
  private
  
  def self.defaults
    {
      :size => 4,
      :level => :h,
      :scale => 20,
      :write_to => nil,
      :drawing => Magick::Draw.new,
      :canvas => nil,
      :fg => 'black',
      :bg => 'white'
    }
  end
  
  def self.parse_options(args, opts)
    if hash = args.first
      Hash[hash].each do |k,v|
        raise ArgumentError, "unknown option: #{k}" unless opts.key?(k)
        opts[k] = v
      end
    end
  end
  
  def self.generate_canvas(qrcode, scale, bg)
    canvas_side = (qrcode.module_count * scale) + (2 * scale)
    Magick::Image.new(canvas_side, canvas_side){ self.background_color = bg }
  end
  
  def self.generate_drawing(qrcode, drawing, scale)
    offset = scale - 1
    
    qrcode.module_count.times do |row|
      y = (row * scale) + scale
      qrcode.module_count.times do |column|
        x = (column * scale) + scale
        drawing.rectangle(x, y, (x + offset), (y + offset)) if qrcode.is_dark(row, column)
      end
    end
    
    drawing
  end
end
