class SubscriptionsController < ApplicationController
  include Internationalized
  around_action :switch_locale

  skip_before_action :verify_authenticity_token

  rescue_from Errors::EventNotFound, with: :render_not_found
  rescue_from Errors::TeamNotFound, with: :render_not_found

  def create
    all_params = subscription_params

    search_team = all_params.delete(:team)
    Rails.logger.info("Searching events matching #{search_team}")

    event = EventManager.find_matching search_team

    raise Errors::EventNotFound, I18n.t(:match_not_found) unless event

    subscription = event.subscriptions.find_or_initialize_by(all_params)

    render json: { message: "#{I18n.t :following_match} #{subscription.event.title}" } if subscription.save
  end

  private

  def subscription_params
    params.require(:subscription).permit(:team, :service, :conversation_id)
  end

  def render_not_found(err)
    render json: { message: err.to_s }, status: 400
  end
end
