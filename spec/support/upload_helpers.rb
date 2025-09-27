module UploadHelpers
  def tiny_jpeg(name: 'a.jpg')
    io = StringIO.new("\xFF\xD8\xFF\xE0\x00\x10JFIF\x00\x01\x01\x00\x00\x01\x00\x01\x00\x00\xFF\xD9".b)
    Rack::Test::UploadedFile.new(io, 'image/jpeg', original_filename: name)
  end
end

RSpec.configure do |config|
  config.include UploadHelpers
end

