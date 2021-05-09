# frozen_string_literal: true

class MarketplaceHandler
  attr_reader :payload, :action, :purchase

  def initialize(payload:, action:)
    @payload = payload
    @action = action
    @purchase = payload['marketplace_purchase']
  end

  def call
    if action == 'purchased' || action == 'marketplace'
      insert_bill(github_account)
      send_goto_mail(github_account)
    elsif action == 'changed'
      update_bill(github_account)
    elsif action == 'cancelled'
      cancel_bill(github_account)
    end
  end

  private

  def github_account
    acc_params = purchase['account']
    GithubAccount
      .create_with(
        login: acc_params['login'],
        account_type: acc_params['type']
      )
      .find_or_create_by(github_id: acc_params[:id])
  end

  def send_goto_mail(acc)
    AccountMailer
      .send_goto_mail(acc.bill.reload.organization_billing_email,
                      { login: acc.login },
                      'd-c820e3e4fb33423b873b705a3af1853f')
  end

  def insert_bill(acc)
    Bill
      .create_with(
        BillSelector.new(purchase).bill_attrs_for_handler
      )
      .find_or_create_by(
        account: acc
      )
  end

  def update_bill(acc)
    bill = Bill
           .find_by(
             account: acc
           )
    bill&.update_attributes(BillSelector.new(purchase).bill_attrs_for_handler)
  end

  def cancel_bill(acc)
    bill = Bill
           .find_by(
             account: acc
           )
    bill&.destroy
  end
end
