require "test_helper"

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @category = categories(:programming_ebook)
    @product = products(:ruby_guide)
    @product.categories << @category
  end

  test "should show category" do
    get category_path(@category.slug)
    assert_response :success
  end

  test "should assign category" do
    get category_path(@category.slug)
    assert_equal @category, assigns(:category)
  end

  test "should assign products" do
    get category_path(@category.slug)
    assert_not_empty assigns(:products)
  end

  test "should show products in descending order" do
    get category_path(@category.slug)

    assert assigns(:products).first.id == @product.id
  end

  test "should only show products belonging to category" do
    other_category = categories(:design_template)
    other_product = products(:design_collection)
    other_category.products << other_product

    get category_path(@category.slug)

    assert_not_includes assigns(:products), other_product
    assert_includes assigns(:products), @product
  end
end
