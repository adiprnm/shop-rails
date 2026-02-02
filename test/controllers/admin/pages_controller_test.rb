require "test_helper"

class Admin::PagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @page = pages(:one)
    @admin_auth = ActionController::HttpAuthentication::Basic.encode_credentials("admin", "admin123")
  end

  test "should require authentication" do
    get admin_pages_path
    assert_response :unauthorized
  end

  test "should get index as authenticated admin" do
    get admin_pages_path, headers: { "HTTP_AUTHORIZATION" => @admin_auth }
    assert_response :success
  end

  test "should get new" do
    get new_admin_page_path, headers: { "HTTP_AUTHORIZATION" => @admin_auth }
    assert_response :success
  end

  test "should create page" do
    assert_difference("Page.count") do
      post admin_pages_path, params: {
        page: {
          title: "New Page",
          slug: "new-page",
          description: "New description",
          content: "New content",
          state: "draft"
        }
      }, headers: { "HTTP_AUTHORIZATION" => @admin_auth }
    end

    assert_redirected_to edit_admin_page_path(Page.last)
    assert_equal "Laman berhasil dibuat", flash[:notice]
  end

  test "should show edit" do
    get edit_admin_page_path(@page), headers: { "HTTP_AUTHORIZATION" => @admin_auth }
    assert_response :success
  end

  test "should update page" do
    patch admin_page_path(@page), params: {
      page: {
        title: "Updated Title",
        slug: @page.slug,
        description: @page.description,
        content: @page.content,
        state: @page.state
      }
    }, headers: { "HTTP_AUTHORIZATION" => @admin_auth }

    assert_redirected_to edit_admin_page_path(@page)
    assert_equal "Laman berhasil diupdate", flash[:notice]
    @page.reload
    assert_equal "Updated Title", @page.title
  end

  test "should destroy page" do
    assert_difference("Page.count", -1) do
      delete admin_page_path(@page), headers: { "HTTP_AUTHORIZATION" => @admin_auth }
    end

    assert_redirected_to admin_pages_path
    assert_equal "Laman berhasil dihapus", flash[:notice]
  end

  test "should order pages by id descending" do
    page2 = Page.create!(
      title: "Page 2",
      slug: "page-2",
      description: "Desc",
      state: "draft"
    )
    page1 = Page.create!(
      title: "Page 1",
      slug: "page-1",
      description: "Desc",
      state: "draft"
    )

    get admin_pages_path, headers: { "HTTP_AUTHORIZATION" => @admin_auth }
    assert_response :success
    pages = assigns(:pages)
    page_ids = pages.map(&:id)
    assert_equal page_ids.sort.reverse, page_ids, "Pages should be ordered by id descending"
  end
end
