# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'
require 'pictowiz/application'
require 'json'

RSpec.describe "Retrieving and uploading images in Pictowiz:\n" do
  include Rack::Test::Methods

  let!(:app) { Pictowiz::Application }

  context 'uploading an image' do
    let(:image_data) { 'xxxxxxxxxx' }

    before do
      post '/images', image_data, 'CONTENT_TYPE' => 'application/octet-stream'
      @response = last_response
    end

    it 'generates a successful response' do
      expect(@response.status).to eql 201
    end

    it 'has content type of JSON' do
      expect(@response.content_type).to eql 'application/json;charset=utf-8'
    end

    it 'returns the image URL' do
      body = JSON.parse(@response.body)
      expect(body['url']).to match %r{^http://#{last_request.host}/images/(.+)}
    end
  end
end
