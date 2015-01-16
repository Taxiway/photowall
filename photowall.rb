require 'chunky_png'
require_relative 'image_process'

class PhotoWall
  @@source_width = 5184
  @@source_height = 3456
  @@shrink_scale = 27
  @@rows = 18
  @@columns = 18
  @@photo_dir = "photos/"
  @@min_pct = 0.8
  @@max_pct = 0.9

  def photos
    plist = Array.new
    target = nil
    Dir.foreach(@@photo_dir) do |f|
      if f =~ /target.(JPG|jpg)/
        target = (@@photo_dir + f)
      elsif f =~ /.(JPG|jpg)/
        plist << (@@photo_dir + f)
      end
    end
    [target, plist]
  end

  def final_size
    [@@source_width / @@shrink_scale * @@columns,
      @@source_height / @@shrink_scale * @@rows]
  end

  def get_jpg filename
    VIPS::Image.jpeg(filename)
  end

  def gao
    target, plist = photos
    puts "#{plist.length} photos found"
    plist = plist.shuffle
    @target_jpg = get_jpg(target)

    final_width, final_height = final_size
    @target_jpg = ImageProcess.shrinktowidth(@target_jpg, final_width)
    @final_png = ImageProcess.jpg2png @target_jpg

    iter = plist.each

    0.upto(@@rows - 1) do |r|
      0.upto(@@columns - 1) do |c|
        f = iter.next
        puts "processing row #{r} col #{c} with image #{f}"

        jpg = get_jpg(f)
        jpg = ImageProcess.shrink(jpg, @@shrink_scale)
        png = ImageProcess.jpg2png jpg
        width, height = png.width, png.height

        pct = c * (@@max_pct - @@min_pct) / (@@columns - 1) + @@min_pct

        0.upto(width - 1) do |x|
          0.upto(height - 1) do |y|
            ox, oy = x + c * width, y + r * height
            c1, c2 = @final_png[ox, oy], png[x, y]
            r1, g1, b1 = ChunkyPNG::Color.r(c1), ChunkyPNG::Color.g(c1), ChunkyPNG::Color.b(c1)
            r2, g2, b2 = ChunkyPNG::Color.r(c2), ChunkyPNG::Color.g(c2), ChunkyPNG::Color.b(c2)
            @final_png[ox, oy] =
              ChunkyPNG::Color.rgb((r1 * pct + r2 * (1 - pct)).to_int,
                                   (g1 * pct + g2 * (1 - pct)).to_int,
                                   (b1 * pct + b2 * (1 - pct)).to_int)
          end
        end
      end
    end
    @final_jpg = ImageProcess.png2jpg @final_png
    @final_jpg.jpeg("final.jpg")
  end

end

PhotoWall.new.gao
