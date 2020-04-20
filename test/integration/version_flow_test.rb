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
      assert_select "a[href=?]", revert_article_path(@article, @article.versions.last), text: "Revert to this version"
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
      assert_select "table tbody tr", count: 5
    end
  end

  test "should restore deleted article" do
    with_versioning do
      @article.destroy
      get deleted_articles_path
      assert_select "a[href=?]", restore_article_path(@article)
      post restore_article_path(@article)
      assert_redirected_to article_path(@article)
      follow_redirect!
      assert_match "Article was successfully restored.", @response.body
    end
  end

  test "should not render previously destroyed articles once restored" do
    with_versioning do
      @article.destroy
      post restore_article_path(@article)
      get deleted_articles_path
      assert_select "a[href=?]", restore_article_path(@article), count: 0
    end
  end

  test "should limit display to lastest destroyed version per article" do
    Article.destroy_all
    with_versioning do
      1.upto(2) do |i|
        @deleted_article = Article.create(title: "Deleted Article #{i} Version 1", body: Faker::Lorem.paragraph)
        @deleted_article.destroy
        @deleted_article = Article.new(id: @deleted_article.id).versions.last.reify
        @deleted_article.save
        @deleted_article.update(title: "Deleted Article #{i} Version 2")
        @deleted_article.destroy
      end
      Article.all.each do |article|
        assert_select "a[href=?]", restore_article_path(article), count: 1
        assert_select "td", text: article.title.to_s, count: 1
      end
    end
  end
end
