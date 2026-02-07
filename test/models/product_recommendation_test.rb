require "test_helper"

class ProductRecommendationTest < ActiveSupport::TestCase
  test "validates recommendation_type enum" do
    product1 = products(:ruby_guide)
    product2 = products(:design_collection)

    recommendation = product1.source_recommendations.build(
      recommended_product: product2,
      recommendation_type: "upsell"
    )

    assert recommendation.valid?
    assert_equal "upsell", recommendation.recommendation_type
  end

  test "validates recommendation_type inclusion" do
    product1 = products(:ruby_guide)
    product2 = products(:design_collection)

    assert_raises(ArgumentError) do
      product1.source_recommendations.create!(
        recommended_product: product2,
        recommendation_type: "invalid_type"
      )
    end
  end

  test "cannot recommend self" do
    product = products(:ruby_guide)
    recommendation = product.source_recommendations.build(
      recommended_product: product,
      recommendation_type: "upsell"
    )
    assert_not recommendation.valid?
    assert_includes recommendation.errors[:recommended_product], "cannot be same as source product"
  end

  test "unique combination of source, recommended product and type" do
    product1 = products(:ruby_guide)
    product2 = products(:design_collection)

    product1.source_recommendations.create!(
      recommended_product: product2,
      recommendation_type: "upsell"
    )

    duplicate = product1.source_recommendations.build(
      recommended_product: product2,
      recommendation_type: "upsell"
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:source_product_id], "has already been taken"
  end

  test "can have same products with different types" do
    product1 = products(:ruby_guide)
    product2 = products(:design_collection)

    product1.source_recommendations.create!(
      recommended_product: product2,
      recommendation_type: "upsell"
    )

    cross_sell = product1.source_recommendations.build(
      recommended_product: product2,
      recommendation_type: "cross_sell"
    )
    assert cross_sell.valid?
  end

  test "scopes work correctly" do
    product = products(:ruby_guide)
    upsell = product.source_recommendations.create!(
      recommended_product: products(:design_collection),
      recommendation_type: "upsell"
    )
    cross_sell = product.source_recommendations.create!(
      recommended_product: products(:business_audio_course),
      recommendation_type: "cross_sell"
    )

    assert_includes ProductRecommendation.upsell, upsell
    refute_includes ProductRecommendation.upsell, cross_sell

    assert_includes ProductRecommendation.cross_sell, cross_sell
    refute_includes ProductRecommendation.cross_sell, upsell
  end
end
