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
end
