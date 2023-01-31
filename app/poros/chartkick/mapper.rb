module Chartkick
  COMMON_WORDS_COUNT = 15

  class Mapper
    attr_accessor :hash, :link, :time_spent, :total_words

    def initialize(hash:, link:, time_spent:, total_words:)
      @hash = hash
      @link = link
      @time_spent = time_spent
      @total_words = total_words
    end
  end
end
