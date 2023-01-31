require 'benchmark'

module Mapper
  class MapperService < ApplicationService
    WORD_REGEXP = /["',.;:\s\n\\\/()\t]+/.freeze

    attr_reader :hash, :doc, :time_spent

    def initialize(doc:)
      @doc = doc
      @hash = Hash.new(0)
    end

    def call
      map
    end

    private

    def map
      @time_spent = Benchmark.measure do
        words.each { |word| hash[word] += 1 }
      end.real
      success!
    end

    def words
      doc.split(WORD_REGEXP)
    end
  end

  class MapperCombiner < ApplicationService
    attr_accessor :hash, :mappers
    def initialize(mappers:)
      @mappers = mappers
    end

    def call
      combine
    end

    private

    def combine
      @hash = Hash.new(0)
      mappers.each { |mapper| mapper.hash.each { |key, value| @hash[key] += value } }
      @hash = @hash.sort_by { |_, v| v }.reverse.to_h
      @hash = @hash.slice(*@hash.keys[0..Chartkick::COMMON_WORDS_COUNT - 1])
      success!(data: hash)
    end
  end
end
