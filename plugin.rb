# frozen_string_literal: true

# name: categories-and-news
# about: Custom categories view with news carousel
# version: 1.3
# authors: Ralph Rooding
# url: https://github.com/kabisa/discourse-categories-and-news

register_asset 'lib/slick.min.js'
register_asset 'lib/slick.css'
register_asset 'lib/slick-theme.css'
register_asset 'stylesheets/common/categories-and-news.scss'

after_initialize do
  SiteSetting.always_include_topic_excerpts = true

  NEWS_CATEGORY_STYLE = {
    name: 'category_page_style.categories_and_news',
    value: 'categories_and_news'
  }.freeze

  require_dependency 'category_page_style'
  class ::CategoryPageStyle
    class << self
      alias_method :values_without_news, :values

      def values
        values_without_news
        @values << NEWS_CATEGORY_STYLE unless @values.any?(NEWS_CATEGORY_STYLE)
        @values
      end
    end
  end

  Discourse::Application.routes.prepend do
    get 'categories_and_news' => 'categories#categories_and_news'
  end

  # Temporary until max length configurable
  require_dependency 'post'
  class ::Post
    def excerpt_for_topic
      Post.excerpt(cooked, 400, strip_links: true, strip_images: true, post: self)
    end
  end

  require_dependency 'category_list'
  class ::CategoryList
    def prune_excluded_categories
      return unless @options[:exclude_category_ids]

      @categories.delete_if do |c|
        @options[:exclude_category_ids].include?(c.id)
      end
    end
  end

  require_dependency 'categories_controller'
  class ::CategoriesController
    def categories_and_news
      discourse_expires_in 1.minute

      category_id = Category
                    .where(slug: SiteSetting.categories_and_news_category)
                    .pluck(:id).first

      category_options = {
        is_homepage: current_homepage == 'categories',
        parent_category_id: params[:parent_category_id],
        include_topics: true,
        exclude_category_ids: [category_id]
      }

      topic_options = {
        per_page: SiteSetting.categories_topics,
        no_definitions: true,
        category: category_id
      }

      result = CategoryAndTopicLists.new
      result.category_list = CategoryList.new(guardian, category_options)
      result.category_list.prune_excluded_categories
      result.topic_list = TopicQuery.new(current_user, topic_options).list_latest

      draft_key = Draft::NEW_TOPIC
      draft_sequence = DraftSequence.current(current_user, draft_key)
      draft = Draft.get(current_user, draft_key, draft_sequence) if current_user

      %w[category topic].each do |type|
        result.public_send(:"#{type}_list").draft = draft
        result.public_send(:"#{type}_list").draft_key = draft_key
        result.public_send(:"#{type}_list").draft_sequence = draft_sequence
      end

      render_serialized(result, CategoryAndTopicListsSerializer, root: false)
    end
  end
end
