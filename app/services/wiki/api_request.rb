require 'net/http'

module Wiki
  class ApiRequest
    WIKI_BASE_URL = 'https://en.wikipedia.org/wiki/'.freeze
    WIKI_API_URL = 'https://en.wikipedia.org/w/api.php'.freeze
    DEFAULT_RANDOM_COUNT = 3

    class << self
      def get(uri:, params: {})
        uri.query = URI.encode_www_form(params)
        Net::HTTP.get_response(uri)
      rescue => e
        e.message
      end

      def get_random_pages(amount: DEFAULT_RANDOM_COUNT)
        uri = URI(WIKI_API_URL)
        uri.query = URI.encode_www_form(default_random_params(amount))
        pages = Net::HTTP.get_response(uri)
        body = JSON.parse(pages.body)
        body['query']['random'].map do |page|
          new_uri = URI(WIKI_API_URL)
          response = JSON.parse(get(uri: new_uri, params: default_extracts_params(page['id'])).body)
          [page_content(response, page['id']), page_link(response, page['id'])]
        end
      rescue => e
        puts e.message
      end

      private

      def page_link(page, page_id)
        WIKI_BASE_URL + concrete_page(page, page_id)['title'].tr(' ', '_')
      end

      def page_content(page, page_id)
        concrete_page(page, page_id)['extract']
      end

      def concrete_page(page, page_id)
        page.dig('query', 'pages', page_id.to_s)
      end

      def default_random_params(count)
        {
          action: 'query',
          format: 'json',
          list: 'random',
          rnlimit: count,
          rnnamespace: 0
        }
      end

      def default_extracts_params(pageids)
        {
          action: 'query',
          pageids: pageids,
          prop: 'extracts',
          format: 'json',
          explaintext: true,
          exsectionformat: 'plain'
        }
      end
    end
  end
end
