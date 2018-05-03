# frozen_string_literal: true

require 'securerandom'

module Pictowiz
  class Image
    class Error < RuntimeError; end
    class UnsupportedFormatError < Error; end
    class ImageNotFoundError < Error; end

    FORMAT_TO_CONTENT_TYPE = { 'jpg' => 'image/jpeg', 'png' => 'image/png' }.freeze
    CONTENT_TYPE_TO_FORMAT = FORMAT_TO_CONTENT_TYPE.invert.freeze
    FORMATS = FORMAT_TO_CONTENT_TYPE.keys.freeze
    CONTENT_TYPES = CONTENT_TYPE_TO_FORMAT.keys.freeze

    def initialize(data:, content_type:, image_dir:)
      raise UnsupportedFormatError, content_type unless CONTENT_TYPES.include?(content_type)
      instantiate(id: SecureRandom.uuid, image_dir: image_dir)
      @original_format = CONTENT_TYPE_TO_FORMAT.fetch(content_type)
      @data = data
    end

    def self.load_file(id:, image_dir:)
      image = allocate
      image.send(:instantiate, id: id, image_dir: image_dir)
      image
    end

    attr_reader :id, :image_dir, :original_format, :filenames, :file_paths

    def write!
      original_file_path = file_paths.fetch(original_format)
      File.write(original_file_path, data, mode: 'wb')

      FORMATS.each do |format|
        next if format == original_format
        file_path = file_paths.fetch(format)
        image = MiniMagick::Image.open(original_file_path)
        image.format(format)
        image.write(file_path)
      end
    end

    def in_format(format)
      path = file_paths[format]
      raise UnsupportedFormatError, format if path.nil?
      raise ImageNotFoundError, id unless File.file?(path)
      content_type = FORMAT_TO_CONTENT_TYPE.fetch(format)
      [path, content_type]
    end

    private

    attr_reader :data

    def instantiate(id:, image_dir:)
      @id = id
      @image_dir = image_dir
      @filenames = Hash[FORMATS.map { |ext| [ext, "#{id}.#{ext}"] }]
      @file_paths = Hash[@filenames.map { |ext, name| [ext, "#{image_dir}/#{name}"] }]
    end
  end
end
