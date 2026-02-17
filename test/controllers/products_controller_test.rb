require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product = products(:ruby_guide)
  end

  test "should get index" do
    get products_path
    assert_response :success
  end

  test "should show active products in index" do
    get products_path
    assert_response :success
  end

  test "should not show inactive products in index" do
    @product.update(state: "inactive")
    get products_path
    assert_response :success
  end

  test "should show product" do
    get product_path(@product.slug)
    assert_response :success
  end

  test "show includes upsells and cross_sells" do
    product = products(:ruby_guide)
    recommended = products(:design_collection)

    product.source_recommendations.create!(
      recommended_product: recommended,
      recommendation_type: "upsell"
    )

    get product_path(product.slug)
    assert_response :success
    assert_not_nil assigns(:upsells)
    assert_not_nil assigns(:cross_sells)
  end

  test "show displays upsells section when upsells exist" do
    product = products(:ruby_guide)
    recommended = products(:design_collection)

    ProductRecommendation.where(source_product_id: product.id).destroy_all

    product.source_recommendations.create!(
      recommended_product: recommended,
      recommendation_type: "upsell"
    )

    get product_path(product.slug)
    assert_response :success
    assert_select "h2", count: 3
    css_selectors = css_select("h2")
    upsell_h2 = css_selectors.find { |h| h.text == "Kamu juga mungkin suka:" }
    assert upsell_h2.present?, "Expected to find h2 with text 'Kamu juga mungkin suka:'"
    assert_select "a[href=?]", product_path(recommended.slug), count: 1
  end

  test "show displays cross_sells section when cross_sells exist" do
    product = products(:ruby_guide)
    recommended = products(:business_audio_course)

    ProductRecommendation.where(source_product_id: product.id).destroy_all

    product.source_recommendations.create!(
      recommended_product: recommended,
      recommendation_type: "cross_sell"
    )

    get product_path(product.slug)
    assert_response :success
    assert_select "h2", count: 3
    css_selectors = css_select("h2")
    cross_sell_h2 = css_selectors.find { |h| h.text == "Produk terkait:" }
    assert cross_sell_h2.present?
    assert_select "a[href=?]", product_path(recommended.slug), count: 1
  end

  test "show does not display recommendation sections when no recommendations" do
    product = products(:ruby_guide)

    ProductRecommendation.where(source_product_id: product.id).destroy_all

    get product_path(product.slug)
    assert_response :success
    assert_select "h2", count: 1
    assert_select "h2", text: "Deskripsi"
  end
end
