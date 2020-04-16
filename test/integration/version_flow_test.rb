require "test_helper"

class VersionFlowTest < ActionDispatch::IntegrationTest
  setup do
    @article = articles(:one)
  end

  test "should display versions" do
    with_versioning do
      10.times do |i|
        @article.update(title: "Version #{i}")
      end
      assert_equal 10, @article.versions.count
      get versions_article_path(@article)
      assert_select "table tbody tr", count: 10
    end
  end

  test "should display version" do
    original_title = @article.title
    with_versioning do
      assert_equal 0, @article.versions.count
      @article.update(title: "New Version")
      assert_equal 1, @article.versions.count
      get version_article_path(@article, @article.versions.first)
      assert_match original_title, @response.body
    end
  end

  test "should revert version" do
    with_versioning do
      @article = Article.create(title: "Version 1")
      @article.update(title: "Version 2")
      get version_article_path(@article, @article.versions.last)
      assert_select "a", text: "Revert to this version", href: revert_article_path(@article, @article.versions.last)
      post revert_article_path(@article, @article.versions.last)
      get article_path(@article)
      assert_match "Version 1", @response.body
    end
  end

  test "should display deleted articles" do
    Article.destroy_all
    with_versioning do
      5.times do |n|
        Article.create(title: "Article #{n + 1}", body: "Some text")
      end
      assert_equal 5, Article.count
      Article.destroy_all
      assert_equal 0, Article.count
      get deleted_articles_path
      assert_respose :success
      assert_select "table tbody tr", count: 5
    end
  end
end
