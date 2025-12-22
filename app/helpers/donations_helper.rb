module DonationsHelper
  def donation_form(model, &block)
    form_with model: model,
      url: supports_path,
      data: {
        turbo: false,
        controller: "form-control",
        form_control_required_fields_value: [ "amount" ],
        form_control_model_value: "donation"
      },
      &block
  end

  def maybe_donations(donations)
    if donations.none?
      tag.p "Belum ada donasi."
    else
      render @donations
    end
  end
end
