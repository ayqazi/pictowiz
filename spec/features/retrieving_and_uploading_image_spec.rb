# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'
require 'pictowiz/application'
require 'json'
require 'digest/sha1'

RSpec.describe 'Retrieving and uploading images in Pictowiz:' do
  include Rack::Test::Methods

  let!(:app) { Pictowiz::Application }
  let(:jpg_image_data) { File.read(__dir__ + '/../fixtures/images/testimage.jpg') }
  let(:png_image_data) { File.read(__dir__ + '/../fixtures/images/testimage.png') }

  before(:all) do
    # Using * can be dangerous so delete certain files explicitly
    %w[data content-type jpg png].each do |ext|
      Dir.glob(__dir__ + "/../../tmp/test_images/*.#{ext}").each { |f| File.unlink(f) }
    end
  end

  context 'uploading an image' do
    context 'in a supported format' do
      before do
        post '/images', jpg_image_data, 'CONTENT_TYPE' => 'image/jpeg'
      end

      it 'generates a successful response' do
        expect(last_response.status).to eql 201
      end

      it 'has content type of JSON' do
        expect(last_response.content_type).to eql 'application/json;charset=utf-8'
      end

      it 'returns the image URL' do
        body = JSON.parse(last_response.body)
        expect(body.fetch('url_jpg')).to match %r{^http://#{last_request.host.gsub('.', '\\.')}/images/(.+)\.jpg}
      end

      it 'gives it a unique name' do
        body = JSON.parse(last_response.body)
        matchdata = body.fetch('url_jpg').match(%r{^http://#{last_request.host.gsub('.', '\\.')}/images/(.+)\.jpg})
        name1 = matchdata[1]

        post '/images', jpg_image_data, 'CONTENT_TYPE' => 'image/jpeg'
        body = JSON.parse(last_response.body)
        matchdata = body.fetch('url_jpg').match(%r{^http://#{last_request.host.gsub('.', '\\.')}/images/(.+)\.jpg})
        name2 = matchdata[1]

        expect(name1).to_not eql name2
      end
    end

    context 'in an unsupported format' do
      it 'returns 415' do
        post '/images', 'xxxxxxxxxxxx', 'CONTENT_TYPE' => 'text/plain'
        expect(last_response.status).to eql 415
      end
    end
  end

  context 'retrieving an uploaded image' do
    context 'in the same file format' do
      let(:url_jpg) do
        post '/images', jpg_image_data, 'CONTENT_TYPE' => 'image/jpeg'
        url = JSON.parse(last_response.body).fetch('url_jpg')
        url = %r{http://#{last_request.host.gsub('.', '\\.')}(/.+)}.match(url)[1]
        url
      end

      before do
        get url_jpg
      end

      it 'returns 200' do
        expect(last_response.status).to eql 200
      end

      it 'has content type of image/jpeg' do
        expect(last_response.content_type).to eql 'image/jpeg'
      end

      it 'returns image data' do
        expect(Digest::SHA1.hexdigest(last_response.body)).to eql Digest::SHA1.hexdigest(jpg_image_data)
      end
    end

    context 'in a different file format' do
      let(:url_jpg) do
        post '/images', png_image_data, 'CONTENT_TYPE' => 'image/png'
        url = JSON.parse(last_response.body).fetch('url_jpg')
        url = %r{http://#{last_request.host.gsub('.', '\\.')}(/.+)}.match(url)[1]
        url
      end

      before do
        get url_jpg
      end

      it 'returns 200' do
        expect(last_response.status).to eql 200
      end

      it 'has content type of image/jpeg' do
        expect(last_response.content_type).to eql 'image/jpeg'
      end

      it 'returns image data as jpeg' do
        filename = "/tmp/pictowiz-image-#{Time.now.strftime('%F-%T')}.jpg"
        File.write(filename, last_response.body, mode: 'wb')
        expect(`file #{filename}`).to match 'JPEG image data'
      end
    end

    context 'for nonexistent file' do
      it 'returns 404' do
        get '/images/nonexistent.jpg'
        expect(last_response.status).to eql 404
      end
    end
  end
end
