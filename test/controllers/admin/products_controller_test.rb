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
    get admin_product_path(@product), headers: { "HTTP_AUTHORIZATION" => @admin_auth }
    assert_response :success
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

  test "should create physical product with variants" do
    assert_difference("Product.count") do
      assert_difference("PhysicalProduct.count") do
        assert_difference("ProductVariant.count", 2) do
          post admin_products_path, params: {
            product: {
              name: "Physical Product",
              slug: "physical-product",
              price: 150000,
              short_description: "Short desc",
              description: "Description",
              state: "active",
              productable_type: "PhysicalProduct",
              productable: {
                weight: 500,
                requires_shipping: true,
                product_variants_attributes: [
                  { name: "Red", price: 150000, weight: 500, stock: 10, is_active: true },
                  { name: "Blue", price: 150000, weight: 500, stock: 10, is_active: true }
                ]
              }
            }
          }, headers: { "HTTP_AUTHORIZATION" => @admin_auth }
        end
      end
    end

    assert_redirected_to admin_products_path
    assert_equal 2, PhysicalProduct.last.product_variants.count
  end

  test "should update physical product" do
    physical_product = products(:premium_t_shirt)
    assert_difference("PhysicalProduct.last.product_variants.count", 1) do
      patch admin_product_path(physical_product), params: {
        product: { name: "Updated T-Shirt" },
        productable: {
          weight: 300,
          product_variants_attributes: [
            { name: "New Variant", price: 160000, weight: 300, stock: 5, is_active: true }
          ]
        }
      }, headers: { "HTTP_AUTHORIZATION" => @admin_auth }
    end

    assert_equal "Updated T-Shirt", physical_product.reload.name
  end

  test "should filter products by type" do
    get admin_products_path, params: { product_type: "PhysicalProduct" }, headers: { "HTTP_AUTHORIZATION" => @admin_auth }
    assert_response :success
    assert_equal [ products(:premium_t_shirt), products(:ebook_reader) ], assigns(:products).to_a
  end

  test "should filter products by digital type" do
    get admin_products_path, params: { product_type: "DigitalProduct" }, headers: { "HTTP_AUTHORIZATION" => @admin_auth }
    assert_response :success
    assert assigns(:products).to_a.all?(&:digital?)
  end

  test "should sort products by stock for physical products" do
    get admin_products_path, params: { sort_by: "stock" }, headers: { "HTTP_AUTHORIZATION" => @admin_auth }
    assert_response :success
    products = assigns(:products).to_a

    physical_products = products.select(&:physical?)
    assert physical_products.any?

    physical_stocks = physical_products.map { |p| p.productable.product_variants.sum(:stock) }
    assert_equal physical_stocks.sort, physical_stocks
  end

  test "should update physical product variant" do
    physical_product = products(:premium_t_shirt)
    variant = product_variants(:t_shirt_red_small)

    patch admin_product_path(physical_product), params: {
      product: { name: "T-Shirt" },
      productable: {
        product_variants_attributes: [
          { id: variant.id, name: "Red Small", price: 160000, stock: 15, is_active: true }
        ]
      }
    }, headers: { "HTTP_AUTHORIZATION" => @admin_auth }

    assert_equal "Red Small", variant.reload.name
    assert_equal 160000, variant.reload.price
    assert_equal 15, variant.reload.stock
  end

  test "should destroy physical product variant" do
    physical_product = products(:premium_t_shirt)
    variant = product_variants(:t_shirt_red_small)

    assert_difference("physical_product.productable.product_variants.count", -1) do
      patch admin_product_path(physical_product), params: {
        product: { name: "T-Shirt" },
        productable: {
          product_variants_attributes: [
            { id: variant.id, _destroy: "1" }
          ]
        }
      }, headers: { "HTTP_AUTHORIZATION" => @admin_auth }
    end
  end
end
