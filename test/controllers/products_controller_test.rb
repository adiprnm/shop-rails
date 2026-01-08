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
end
