# frozen_string_literal: true

# Stripe::Event.retrieve('evt_1FAeMMCehPrJAqhpHCgYT3Kt')
module StripeHooks
  class Charge < Base
    # The `livemode` attribute tells whether or not the transaction was using a
    # real card which actually got charged/refunded. We don't need to alert
    # for a failed refund in test mode. We may need to later add a check for
    # which Heroku environment, since we might get a 'livemode=false' message
    # in production: https://stripe.com/docs/connect/webhooks
    def process
      return unless event.type == 'charge.refund.updated' &&
                    event.data.object.status == 'failed' &&
                    event.livemode?

      # Refund failed, we may need to contact customer or otherwise handle manually!
      Honeybadger.notify(
        '[Stripe Webhook] Refund failed to process!',
        context: {
          refund: refund.as_json(
            except: :registration_items,
            include: :registration_order
          ),
          livemode: event.livemode,
          object: event.data.object
        }
      )
    end

    def refund
      Refund.find_by(transaction_id: event.data.object.id)
    end
  end
end
