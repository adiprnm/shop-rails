require "test_helper"

class PageTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    page = Page.new(
      title: "Test Page",
      slug: "test-page",
      description: "Test description",
      content: "Test content",
      state: "draft"
    )
    assert page.valid?
  end

  test "should require title" do
    page = Page.new(title: nil)
    assert_not page.valid?
    assert_includes page.errors[:title], "can't be blank"
  end

  test "should require slug" do
    page = Page.new(slug: nil)
    assert_not page.valid?
    assert_includes page.errors[:slug], "can't be blank"
  end

  test "should require description" do
    page = Page.new(description: nil)
    assert_not page.valid?
    assert_includes page.errors[:description], "can't be blank"
  end

  test "should require state" do
    page = Page.new(state: nil)
    assert_not page.valid?
    assert_includes page.errors[:state], "can't be blank"
  end

  test "should set slug from title when slug is blank" do
    page = Page.new(
      title: "My Test Page",
      description: "Test",
      state: "draft"
    )
    page.valid?
    assert_equal "my-test-page", page.slug
  end

  test "should not set slug when slug is already set" do
    page = Page.new(
      title: "My Test Page",
      slug: "custom-slug",
      description: "Test",
      state: "draft"
    )
    page.valid?
    assert_equal "custom-slug", page.slug
  end

  test "should set state_updated_at when state changes" do
    page = Page.create(
      title: "Test Page",
      slug: "test-page",
      description: "Test",
      state: "draft"
    )
    page.update_column(:state_updated_at, nil)

    page.state = "published"
    page.save
    assert_not_nil page.state_updated_at
  end

  test "should set state_updated_at on creation" do
    page = Page.create(
      title: "Test Page",
      slug: "test-page",
      description: "Test",
      state: "draft"
    )
    assert_not_nil page.state_updated_at
  end

  test "should have draft state" do
    page = Page.new(
      title: "Test Page",
      slug: "test-page",
      description: "Test",
      state: "draft"
    )
    assert_equal "draft", page.state
    assert page.draft?
  end

  test "should have published state" do
    page = Page.new(
      title: "Test Page",
      slug: "test-page",
      description: "Test",
      state: "published"
    )
    assert_equal "published", page.state
    assert page.published?
  end

  test "should find published pages" do
    published_page = Page.create(
      title: "Published Page",
      slug: "published-page",
      description: "Published",
      content: "Content",
      state: "published"
    )
    draft_page = Page.create(
      title: "Draft Page",
      slug: "draft-page",
      description: "Draft",
      content: "Content",
      state: "draft"
    )

    assert_includes Page.published, published_page
    assert_not_includes Page.published, draft_page
  end

  test "should parameterize title for slug" do
    page = Page.new(
      title: "Test Title With Spaces & Special! Characters",
      description: "Test",
      state: "draft"
    )
    page.valid?
    assert_equal "test-title-with-spaces-special-characters", page.slug
  end

  test "should validate slug uniqueness" do
    Page.create!(
      title: "Page One",
      slug: "unique-slug",
      description: "Description",
      state: "draft"
    )

    page2 = Page.new(
      title: "Page Two",
      slug: "unique-slug",
      description: "Description",
      state: "draft"
    )
    assert_not page2.valid?
    assert_includes page2.errors[:slug], "has already been taken"
  end
end
