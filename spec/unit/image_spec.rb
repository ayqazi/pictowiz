# frozen_string_literal: true

require 'spec_helper'
require 'pictowiz/image'

RSpec::Matchers.define :be_a_jpg do
  match do |actual|
    `file '#{actual}'`.match('JPEG image data') != nil
  end
end

RSpec::Matchers.define :be_a_png do
  match do |actual|
    `file #{actual}`.match('PNG image data') != nil
  end
end

RSpec.describe Pictowiz::Image do
  let(:jpg_image_data) { File.read("#{__dir__}/../fixtures/images/testimage.jpg") }
  let(:png_image_data) { File.read("#{__dir__}/../fixtures/images/testimage.png") }

  before(:all) do
    # Using * can be dangerous so delete certain files explicitly
    %w[jpg png].each do |ext|
      Dir.glob(IMAGE_DIR + "*.#{ext}").each { |f| File.unlink(f) }
    end
  end

  shared_examples 'writes all images' do
    before do
      image.write!
    end

    it 'writes jpeg image' do
      file_path = "#{IMAGE_DIR}/#{image.id}.jpg"
      expect(image.file_paths.fetch('jpg')).to eql file_path
      expect(file_path).to be_a_jpg
    end

    it 'writes png image' do
      file_path = "#{IMAGE_DIR}/#{image.id}.png"
      expect(image.file_paths.fetch('png')).to eql file_path
      expect(file_path).to be_a_png
    end

    it 'returns filenames' do
      expect(image.filenames).to eql('png' => "#{image.id}.png", 'jpg' => "#{image.id}.jpg")
    end
  end

  context 'with jpeg data' do
    let(:image) do
      described_class.new(data: jpg_image_data, content_type: 'image/jpeg', image_dir: IMAGE_DIR)
    end

    include_examples('writes all images')
  end

  context 'with png data' do
    let(:image) do
      described_class.new(data: png_image_data, content_type: 'image/png', image_dir: IMAGE_DIR)
    end

    include_examples('writes all images')
  end

  context 'with unsupported data format' do
    it 'throws error' do
      expect { described_class.new(data: 'xxxx', content_type: 'text/plain', image_dir: IMAGE_DIR) }
        .to raise_error(described_class::UnsupportedFormatError)
    end
  end

  context 'loading an existing file' do
    let(:written_image) do
      written_image = described_class.new(data: jpg_image_data, content_type: 'image/jpeg', image_dir: IMAGE_DIR)
      written_image.write!
      written_image
    end

    it 'gets disk path and content type of file' do
      image = described_class.load_file(id: written_image.id, image_dir: IMAGE_DIR)

      expect(image.in_format('jpg')).to eql [written_image.file_paths['jpg'], 'image/jpeg']
      expect(image.in_format('png')).to eql [written_image.file_paths['png'], 'image/png']
    end

    it 'raises an error if image does not exist' do
      image = described_class.load_file(id: 'nonexistent', image_dir: IMAGE_DIR)
      expect { image.in_format('jpg') }.to raise_error described_class::ImageNotFoundError
    end

    it 'raises an error if requested format not supported' do
      image = described_class.load_file(id: written_image.id, image_dir: IMAGE_DIR)
      expect { image.in_format('xxx') }.to raise_error described_class::UnsupportedFormatError
    end
  end
end
