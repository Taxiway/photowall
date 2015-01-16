require 'vips'
require 'chunky_png'

class ImageProcess

  @@eps = 1e-5

  def self.shrinktowidth(jpg, width)
    scale = jpg.x_size * 1.0 / width
    scale -= @@eps
    jpg.shrink(scale)
  end

  def self.shrink(jpg, scale)
    jpg.shrink(scale)
  end

  def self.jpg2png jpg
    jpg.png('_out.png')
    ChunkyPNG::Image.from_file('_out.png')
  end

  def self.png2jpg png
    png.save('_out.png')
    Image.png('_out.png')
  end

end
