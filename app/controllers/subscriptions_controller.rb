class SubscriptionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  rescue_from Errors::EventNotFound, with: :render_event_not_found

  def create
    all_params = subscription_params

    search_team = all_params.delete(:team)

    event = EventManager.find_matching search_team

    raise Errors::EventNotFound, "No events for #{search_team} found." unless event

    subscription = event.subscriptions.build(all_params)

    render json: subscription.to_json if subscription.save
  end

  private

  def subscription_params
    params.require(:subscription).permit(:team, :service, :conversation_id)
  end

  def render_event_not_found(err)
    render json: { message: err.to_s }
  end
end
