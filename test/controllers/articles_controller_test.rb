require "test_helper"

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @article = articles(:one)
  end

  test "should get index" do
    get articles_url
    assert_response :success
  end

  test "should get new" do
    get new_article_url
    assert_response :success
  end

  test "should create article" do
    assert_difference("Article.count") do
      post articles_url, params: {article: {body: @article.body, title: @article.title}}
    end

    assert_redirected_to article_url(Article.last)
  end

  test "should show article" do
    get article_url(@article)
    assert_response :success
  end

  test "should get edit" do
    get edit_article_url(@article)
    assert_response :success
  end

  test "should update article" do
    patch article_url(@article), params: {article: {body: @article.body, title: @article.title}}
    assert_redirected_to article_url(@article)
  end

  test "should destroy article" do
    assert_difference("Article.count", -1) do
      delete article_url(@article)
    end

    assert_redirected_to articles_url
  end

  test "should get versions" do
    get versions_article_path(@article)
    assert_response :success
  end

  test "should get versions if the only version is create" do
    with_versioning do
      @article = Article.create(title: "Version 1")
      get versions_article_path(@article)
      assert_response :success
    end
  end

  test "should get version" do
    with_versioning do
      @article.update(title: "New Version")
      get version_article_path(@article, @article.versions.last)
      assert_response :success
    end
  end

  test "should revert version" do
    with_versioning do
      @article = Article.create(title: "Version 1")
      @article.update(title: "Version 2")
      post revert_article_path(@article, @article.versions.last)
      assert_redirected_to article_path(@article)
      assert_equal "Version 1", @article.reload.title
    end
  end

  test "should get deleted" do
    with_versioning do
      Article.destroy_all
      get deleted_articles_path
      assert_response :success
    end
  end
end
