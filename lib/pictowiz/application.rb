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
      file = "#{settings.images_dir}/#{id}.#{ext}"
      if File.file?(file)
        image_data = File.read(file)
        [200, { 'Content-Type' => { 'jpg' => 'image/jpeg', 'png' => 'image/png' }[ext] }, image_data]
      else
        404
      end
    end
  end
end
