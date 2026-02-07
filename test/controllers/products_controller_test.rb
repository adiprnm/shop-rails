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

  test "should add product to cart" do
    post add_to_cart_product_path(@product.slug), params: { price: 75000 }

    assert_redirected_to product_path(@product.slug)
    assert_equal "Produk berhasil ditambahkan ke keranjang!", flash[:notice]
    assert_equal "add_product_to_cart", flash[:action]
  end

  test "should not add coming soon product to cart" do
    @product.productable.update(resource_url: nil)
    post add_to_cart_product_path(@product.slug), params: { price: 10000 }

    assert_redirected_to root_path
  end

  test "should not add product if price below minimum" do
    post add_to_cart_product_path(@product.slug), params: { price: 40000 }

    assert_redirected_to product_path(@product.slug)
    assert_not_nil flash[:alert]
    assert_equal "Harga yang kamu masukkan di bawah harga minimal!", flash[:alert]
  end

  test "should add product when price equals minimum" do
    assert_difference("CartLineItem.count") do
      post add_to_cart_product_path(@product.slug), params: { price: 50000 }
    end

    assert_redirected_to product_path(@product.slug)
  end

  test "should add product when no minimum price set" do
    product2 = products(:business_audio_course)

    assert_difference("CartLineItem.count") do
      post add_to_cart_product_path(product2.slug), params: { price: 80000 }
    end

    assert_redirected_to product_path(product2.slug)
  end

  test "should add product with custom price" do
    post add_to_cart_product_path(@product.slug), params: { price: 75000 }

    assert_equal 75000, CartLineItem.last.price
  end

  test "should redirect to referer after trying to add coming soon product" do
    @product.productable.update(resource_url: nil)

    post add_to_cart_product_path(@product.slug), params: { price: 10000 }, headers: { "HTTP_REFERER" => products_path }

    assert_redirected_to products_path
  end

  test "should add physical product with variant to cart" do
    physical_product = products(:premium_t_shirt)
    variant = product_variants(:t_shirt_red_small)

    assert_difference("CartLineItem.count") do
      post add_to_cart_product_path(physical_product.slug), params: { product_variant_id: variant.id }
    end

    assert_redirected_to product_path(physical_product.slug)
    assert_equal "Produk berhasil ditambahkan ke keranjang!", flash[:notice]
  end

  test "should not add physical product without variant" do
    physical_product = products(:premium_t_shirt)

    assert_no_difference("CartLineItem.count") do
      post add_to_cart_product_path(physical_product.slug), params: {}
    end

    assert_redirected_to product_path(physical_product.slug)
    assert_equal "Variant must be specified for physical products", flash[:alert]
  end

  test "should not add physical product with inactive variant" do
    physical_product = products(:premium_t_shirt)
    variant = product_variants(:t_shirt_discontinued)

    assert_no_difference("CartLineItem.count") do
      post add_to_cart_product_path(physical_product.slug), params: { product_variant_id: variant.id }
    end

    assert_redirected_to product_path(physical_product.slug)
    assert_equal "Selected variant is not available", flash[:alert]
  end

  test "should not add physical product with out of stock variant" do
    physical_product = products(:premium_t_shirt)
    variant = product_variants(:t_shirt_green_large)

    assert_no_difference("CartLineItem.count") do
      post add_to_cart_product_path(physical_product.slug), params: { product_variant_id: variant.id }
    end

    assert_redirected_to product_path(physical_product.slug)
    assert_equal "Selected variant is out of stock", flash[:alert]
  end

  test "should not add physical product with invalid variant" do
    physical_product = products(:premium_t_shirt)
    invalid_variant = product_variants(:ebook_black)

    assert_no_difference("CartLineItem.count") do
      post add_to_cart_product_path(physical_product.slug), params: { product_variant_id: invalid_variant.id }
    end

    assert_redirected_to product_path(physical_product.slug)
    assert_equal "Variant does not belong to this product", flash[:alert]
  end

  test "should add physical product with variant and correct price" do
    physical_product = products(:premium_t_shirt)
    variant = product_variants(:t_shirt_red_small)

    assert_difference("CartLineItem.count") do
      post add_to_cart_product_path(physical_product.slug), params: { product_variant_id: variant.id }
    end

    assert_equal variant.price, CartLineItem.last.price
  end

  test "should show physical product page" do
    physical_product = products(:premium_t_shirt)

    get product_path(physical_product.slug)

    assert_response :success
    assert_select "h1", text: physical_product.name
    assert_select "p", text: physical_product.short_description
  end

  test "should show variant dropdown for physical products" do
    physical_product = products(:premium_t_shirt)

    get product_path(physical_product.slug)

    assert_response :success
    assert_select "form[action=?]", add_to_cart_product_path(physical_product.slug)
    assert_select "select[name=?]", "product_variant_id"
  end

  test "should show only active and in-stock variants" do
    physical_product = products(:premium_t_shirt)

    get product_path(physical_product.slug)

    assert_response :success
    assert_select "select[name='product_variant_id'] option", text: /Red - Small/ do
      assert_select "[value=?]", product_variants(:t_shirt_red_small).id.to_s
    end
    assert_select "select[name='product_variant_id'] option", text: /Blue - Medium/ do
      assert_select "[value=?]", product_variants(:t_shirt_blue_medium).id.to_s
    end
    assert_select "select[name='product_variant_id'] option", text: /Green - Large/, count: 0
    assert_select "select[name='product_variant_id'] option", text: /Black - Extra Large/, count: 0
  end

  test "should show variant price and stock count" do
    physical_product = products(:premium_t_shirt)

    get product_path(physical_product.slug)

    assert_response :success
    assert_select "select[name='product_variant_id'] option", text: /150\.000.*Stok: 50/
  end

  test "should show different variants for different physical products" do
    ebook_reader = products(:ebook_reader)

    get product_path(ebook_reader.slug)

    assert_response :success
    assert_select "select[name='product_variant_id'] option", text: /Black/
    assert_select "select[name='product_variant_id'] option", text: /White/, count: 0
  end

  test "should add physical product with quantity to cart" do
    physical_product = products(:premium_t_shirt)
    variant = product_variants(:t_shirt_red_small)

    assert_difference("CartLineItem.count") do
      post add_to_cart_product_path(physical_product.slug), params: { product_variant_id: variant.id, quantity: 3 }
    end

    assert_redirected_to product_path(physical_product.slug)
    assert_equal 3, CartLineItem.last.quantity
    assert_equal "Produk berhasil ditambahkan ke keranjang!", flash[:notice]
  end

  test "should add physical product with default quantity of 1" do
    physical_product = products(:premium_t_shirt)
    variant = product_variants(:t_shirt_red_small)

    assert_difference("CartLineItem.count") do
      post add_to_cart_product_path(physical_product.slug), params: { product_variant_id: variant.id }
    end

    assert_equal 1, CartLineItem.last.quantity
  end

  test "should accumulate quantity when adding same physical product variant multiple times" do
    physical_product = products(:premium_t_shirt)
    variant = product_variants(:t_shirt_red_small)

    post add_to_cart_product_path(physical_product.slug), params: { product_variant_id: variant.id, quantity: 2 }
    post add_to_cart_product_path(physical_product.slug), params: { product_variant_id: variant.id, quantity: 3 }

    assert_no_difference("CartLineItem.count") do
      assert_equal 5, CartLineItem.last.quantity
    end
  end

  test "should default to 1 for invalid quantity" do
    physical_product = products(:premium_t_shirt)
    variant = product_variants(:t_shirt_red_small)

    post add_to_cart_product_path(physical_product.slug), params: { product_variant_id: variant.id, quantity: -5 }

    assert_equal 1, CartLineItem.last.quantity
  end

  test "should default to 1 for zero quantity" do
    physical_product = products(:premium_t_shirt)
    variant = product_variants(:t_shirt_red_small)

    post add_to_cart_product_path(physical_product.slug), params: { product_variant_id: variant.id, quantity: 0 }

    assert_equal 1, CartLineItem.last.quantity
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
    assert_select "h2", count: 2
    css_selectors = css_select("h2")
    upsell_h2 = css_selectors.find { |h| h.text == "Produk Premium" }
    assert upsell_h2.present?, "Expected to find h2 with text 'Produk Premium'"
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
    assert_select "h2", count: 2
    css_selectors = css_select("h2")
    cross_sell_h2 = css_selectors.find { |h| h.text == "Produk Terkait" }
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
