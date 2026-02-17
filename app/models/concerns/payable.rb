module Payable
  extend ActiveSupport::Concern

  included do
    has_many :payment_evidences, -> { order(created_at: :desc) }, as: :payable, dependent: :destroy

    before_save :set_state_updated_at, if: :state_changed?
  end

  def latest_payment_evidence
    payment_evidences.first
  end

  def mark_evidences_as_checked
    payment_evidences.where(checked: false).update_all(checked: true)
  end

  private

  def set_state_updated_at
    self.state_updated_at = Time.now
  end
end
