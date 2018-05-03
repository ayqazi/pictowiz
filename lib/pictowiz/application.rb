# frozen_string_literal: true

require 'sinatra/base'
require 'pictowiz/image'
require 'yaml'
require 'securerandom'
require 'mini_magick'

module Pictowiz
  class Application < Sinatra::Base
    configure :development, :production do
      YAML.load_file(File.expand_path(__dir__ + '../../config/app.yml')).each do |name, value|
        set name.to_sym, value
      end
    end

    post '/images' do
      image = nil
      begin
        image = Pictowiz::Image.new(data: request.body.read,
                                    content_type: request.content_type,
                                    image_dir: settings.images_dir)
      rescue Pictowiz::Image::UnsupportedFormatError
        next 415
      end

      image.write!

      base_url = "#{request.env['rack.url_scheme']}://#{request.host}/images"
      urls = {}
      Pictowiz::Image::FORMATS.map do |format|
        urls["url_#{format}"] = "#{base_url}/#{image.filenames.fetch(format)}"
      end

      [201, { 'Content-Type' => 'application/json;charset=utf-8' }, urls.to_json]
    end

    get '/images/:id.:ext' do |id, ext|
      image = Pictowiz::Image.load_file(id: id, image_dir: settings.images_dir)
      begin
        image_info = image.in_format(ext)
        [200, { 'Content-Type' => image_info[1] }, File.read(image_info[0])]
      rescue Pictowiz::Image::UnsupportedFormatError, Pictowiz::Image::ImageNotFoundError
        404
      end
    end
  end
end
