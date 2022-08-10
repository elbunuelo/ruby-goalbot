class SubscriptionsController < ApplicationController
  include Internationalized
  around_action :switch_locale
  before_action :set_event

  skip_before_action :verify_authenticity_token

  rescue_from Errors::EventNotFound, with: :render_not_found
  rescue_from Errors::TeamNotFound, with: :render_not_found

  def create
    subscription = @event.subscriptions.find_or_initialize_by(subscription_params)

    render json: { message: "#{I18n.t :following_match} #{subscription.event.title}" } if subscription.save
  end

  def destroy
    subscription = @event.subscriptions.find_by!(subscription_params)

    render json: { message: "#{I18n.t :unfollowed_match} #{@event.title}" } if subscription.destroy
  rescue ActiveRecord::RecordNotFound
    render json: { message: "#{I18n.t :subscription_not_found}" }
  end

  private

  def set_event
    search_team = params[:subscription][:team]
    Rails.logger.info("Searching events matching #{search_team}")

    @event = EventManager.find_matching search_team
    raise Errors::EventNotFound, I18n.t(:match_not_found) unless @event
  end

  def subscription_params
    params.require(:subscription).permit(:service, :conversation_id)
  end

  def render_not_found(err)
    render json: { message: err.to_s }, status: 400
  end
end
