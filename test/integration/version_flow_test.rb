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
end
