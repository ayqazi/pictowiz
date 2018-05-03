# frozen_string_literal: true

require 'bundler'

Bundler.setup(:default, ENV.fetch('APP_ENV', 'development').to_sym)

$LOAD_PATH.push(File.expand_path(__dir__))
