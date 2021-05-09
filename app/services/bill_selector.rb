class BillSelector
  attr_reader :purchase_response

  def initialize(purchase_response)
    @purchase_response = purchase_response
  end

  def bill_attrs_for_handler
    {
      billing_cycle: purchase_response['billing_cycle'],
      on_free_trial: purchase_response['on_free_trial'],
      free_trial_ends_on: purchase_response['free_trial_ends_on'],
      next_billing_date: purchase_response['next_billing_date'],
      organization_billing_email: purchase_response['account']['organization_billing_email']
    }
  end
end
