class LeaguesController < ApplicationController
  before_action :set_league, only: %i[show edit update destroy]

  # GET /leagues or /leagues.json
  def index
    @leagues = League.all
  end

  # POST /leagues or /leagues.json
  def create
    @league = League.new(league_params)

    respond_to do |format|
      if @league.save
        format.html { redirect_to league_url(@league), notice: 'League was successfully created.' }
        format.json { render :show, status: :created, location: @league }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @league.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Only allow a list of trusted parameters through.
  def league_params
    params.require(:league).permit(:name, :conversation_id, :service)
  end
end
