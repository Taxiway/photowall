require 'chunky_png'

class PhotoWall
  @@source_width = 5184
  @@source_height = 3456
  @@shrink_scale = 54
  @@rows = 20
  @@columns = 20

  def final_size
    [@@source_width / @@shrink_scale * @@columns,
      @@source_height / @@shrink_scale * @@rows]
  end

  def gao
    final_width, final_height = final_size
    @final_png = ChunkyPNG::Image.new(final_width, final_height)
    0.upto(final_width - 1) do |i|
      0.upto(final_height - 1) do |j|
        @final_png[i, j] = ChunkyPNG::Color.rgb(30, 100, 150)
      end
    end
    @final_png.save('final.png')
  end
end

PhotoWall.new.gao
