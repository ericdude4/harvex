defmodule Harvex.Invoice do
  use Harvex.Resource

  @moduledoc """
  Documentation for Harvex.Invoice module

  Responsible for Harvest Invoices API interactions.
  """
  defstruct [
    :id,
    :client,
    :line_items,
    :estimate,
    :retainer,
    :creator,
    :client_key,
    :number,
    :purchase_order,
    :amount,
    :due_amount,
    :tax,
    :tax_amount,
    :tax2,
    :tax2_amount,
    :discount,
    :discount_amount,
    :subject,
    :notes,
    :currency,
    :state,
    :period_start,
    :period_end,
    :issue_date,
    :due_date,
    :payment_term,
    :sent_at,
    :paid_at,
    :paid_date,
    :closed_at,
    :recurring_invoice_id,
    :created_at,
    :updated_at
  ]

  def harvest_resource_path(), do: "/invoices"
end
