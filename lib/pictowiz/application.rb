# frozen_string_literal: true

require 'sinatra/base'
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
      id = SecureRandom.uuid
      base_url = "#{request.env['rack.url_scheme']}://#{request.host}/images/#{id}"
      orig_ext = {'image/jpeg' => 'jpg', 'image/png' => 'png'}[request.content_type]

      next 415 if orig_ext.nil?

      urls = {}

      orig_file = "#{settings.images_dir}/#{id}.#{orig_ext}"
      File.write(orig_file, request.body.string, mode: 'wb')

      ['jpg', 'png'].each do |ext|
        urls["url_#{ext}"] = "#{base_url}.#{ext}"
        next if ext == orig_ext

        file = "#{settings.images_dir}/#{id}.#{ext}"
        image = MiniMagick::Image.open(orig_file)
        image.format(ext)
        image.write(file)
      end

      [201, { 'Content-Type' => 'application/json;charset=utf-8' }, urls.to_json]
    end

    get '/images/:id.:ext' do |id, ext|
      if File.file?("#{settings.images_dir}/#{id}.#{ext}")
        image_data = File.read("#{settings.images_dir}/#{id}.#{ext}")
        [200, { 'Content-Type' => { 'jpg' => 'image/jpeg', 'png' => 'image/png' }[ext] }, image_data]
      else
        404
      end
    end
  end
end
