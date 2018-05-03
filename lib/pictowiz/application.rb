# frozen_string_literal: true

require 'sinatra/base'
require 'yaml'
require 'securerandom'

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
      urls = {
        url_jpg: "#{base_url}.jpg"
      }
      File.write("#{settings.images_dir}/#{id}.data", request.body.string, mode: 'wb')
      File.write("#{settings.images_dir}/#{id}.content-type", request.content_type, mode: 'wb')
      [201, { 'Content-Type' => 'application/json;charset=utf-8' }, urls.to_json]
    end

    get '/images/:id.jpg' do |id|
      image_data = File.read("#{settings.images_dir}/#{id}.data")
      [200, { 'Content-Type' => 'image/jpeg' }, image_data]
    end
  end
end
