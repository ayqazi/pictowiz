# frozen_string_literal: true

require 'sinatra/base'

module Pictowiz
  class Application < Sinatra::Base
    post '/images' do
      url = "#{request.env['rack.url_scheme']}://#{request.host}/images/foo"
      [201, { 'Content-Type' => 'application/json;charset=utf-8' }, { url: url }.to_json]
    end
  end
end
