class HomeController < ApplicationController
  def index
    mappers = []
    @result = Wiki::ApiRequest.get_random_pages&.map do |page|
      mapper = Mapper::MapperService.call(doc: page.first.downcase)
      if mapper.success?
        mappers.push(mapper)
        final_hash = mapper.hash.sort_by { |_, v| v }.reverse.to_h
        helper = Chartkick::Mapper.new(hash: final_hash.slice(*final_hash.keys[0..Chartkick::COMMON_WORDS_COUNT - 1]),
                                       link: page.last,
                                       total_words: mapper.hash.inject(0) { |memo, (_, v)| memo + v },
                                       time_spent: mapper.time_spent)
        puts "Time spent on mapping #{helper.total_words} words - #{helper.time_spent} sec."
        puts "Page link: #{helper.link}"
        helper
      else
        nil
      end
    end&.compact
    @combined = Mapper::MapperCombiner.call(mappers: mappers)
  end
end
