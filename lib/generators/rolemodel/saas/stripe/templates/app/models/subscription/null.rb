# frozen_string_literal: true

class Subscription
  class Null
    def initialize(*); end

    def plan_id; end

    def price; end

    def display_charge_cycle; end

    def display_price; end

    def display_payment_method; end

    def next_charge_amount; end

    def remaining_balance
      0
    end

    def cancel!; end

    def upgrade!; end
  end
end
