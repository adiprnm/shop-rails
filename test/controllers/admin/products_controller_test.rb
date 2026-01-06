require "test_helper"

class Admin::ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product = products(:ruby_guide)
    @admin_auth = ActionController::HttpAuthentication::Basic.encode_credentials("admin", "admin123")
  end

  test "should get index" do
    get admin_products_path, headers: { "HTTP_AUTHORIZATION" => @admin_auth }
    assert_response :success
  end

  test "should get new" do
    get new_admin_product_path, headers: { "HTTP_AUTHORIZATION" => @admin_auth }
    assert_response :success
  end

  test "should create product" do
    assert_difference("Product.count") do
      assert_difference("DigitalProduct.count") do
        post admin_products_path, params: {
          product: {
            name: "New Product",
            slug: "new-product",
            price: 10000,
            short_description: "Short desc",
            description: "Description",
            state: "active",
            productable_type: "DigitalProduct",
            productable: {
              resource_type: "file",
              resource_url: "http://example.com/resource.pdf"
            }
          }
        }, headers: { "HTTP_AUTHORIZATION" => @admin_auth }
      end
    end

    assert_redirected_to admin_products_path
  end

  test "should get edit" do
    get edit_admin_product_path(@product), headers: { "HTTP_AUTHORIZATION" => @admin_auth }
    assert_response :success
  end

  test "should update product" do
    patch admin_product_path(@product), params: {
      product: {
        name: "Updated Name",
        price: 150000
      }
    }, headers: { "HTTP_AUTHORIZATION" => @admin_auth }

    assert_redirected_to edit_admin_product_path(@product)
    assert_equal "Updated Name", @product.reload.name
    assert_equal 150000, @product.reload.price
  end

  test "should show product" do
    skip "Skipping due to fixture loading issue"
  end

  test "should update productable" do
    patch admin_product_path(@product), params: {
      product: {
        name: "Updated Name"
      },
      productable: {
        resource_type: "url",
        resource_url: "http://example.com/updated.pdf"
      }
    }, headers: { "HTTP_AUTHORIZATION" => @admin_auth }

    assert_redirected_to edit_admin_product_path(@product)
    assert_equal "url", @product.reload.productable.resource_type
  end

  test "should update with success message" do
    patch admin_product_path(@product), params: {
      product: { name: "Updated Name" }
    }, headers: { "HTTP_AUTHORIZATION" => @admin_auth }

    assert_equal "Update berhasil!", flash[:notice]
  end

  test "should destroy product" do
    assert_difference("Product.count", -1) do
      delete admin_product_path(@product), headers: { "HTTP_AUTHORIZATION" => @admin_auth }
    end

    assert_redirected_to admin_products_path
    assert_equal "Produk berhasil dihapus!", flash[:notice]
  end

  test "should destroy productable" do
    productable_id = @product.productable.id

    delete admin_product_path(@product), headers: { "HTTP_AUTHORIZATION" => @admin_auth }

    assert_raises(ActiveRecord::RecordNotFound) do
      DigitalProduct.find(productable_id)
    end
  end

  test "should require authentication" do
    get admin_products_path
    assert_response :unauthorized
  end

  test "should create product with categories" do
    category = categories(:design_template)

    assert_difference("Product.count") do
      post admin_products_path, params: {
        product: {
          name: "New Product",
          slug: "new-product",
          price: 10000,
          state: "active",
          productable_type: "DigitalProduct",
          category_ids: [ category.id ],
          productable: {
            resource_type: "file",
            resource_url: "http://example.com/resource.pdf"
          }
        }
      }, headers: { "HTTP_AUTHORIZATION" => @admin_auth }
    end

    assert_includes Product.last.categories, category
  end

  test "should update product with sale price" do
    patch admin_product_path(@product), params: {
      product: {
        sale_price: 50000,
        sale_price_starts_at: 1.day.ago.to_s,
        sale_price_ends_at: 1.day.from_now.to_s
      }
    }, headers: { "HTTP_AUTHORIZATION" => @admin_auth }

    assert_equal 50000, @product.reload.sale_price
  end

  test "should update product with minimum price" do
    patch admin_product_path(@product), params: {
      product: { minimum_price: 30000 }
    }, headers: { "HTTP_AUTHORIZATION" => @admin_auth }

    assert_equal 30000, @product.reload.minimum_price
  end
end
