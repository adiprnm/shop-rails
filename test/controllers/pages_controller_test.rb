require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    Page.destroy_all
    @published_page = Page.create!(
      title: "Published Page",
      slug: "published-page",
      description: "Published description",
      content: "Published content",
      state: "published"
    )
    @draft_page = Page.create!(
      title: "Draft Page",
      slug: "draft-page",
      description: "Draft description",
      content: "Draft content",
      state: "draft"
    )
  end

  test "should show published page" do
    get "/#{@published_page.slug}"
    assert_response :success
    assert_equal @published_page, assigns(:page)
  end

  test "should not show draft page" do
    get "/#{@draft_page.slug}"
    assert_response :not_found
  end

  test "should return 404 for non-existent page" do
    get "/non-existent-slug"
    assert_response :not_found
  end

  test "should render page template" do
    get "/#{@published_page.slug}"
    assert_template :show
  end
end
