require "application_system_test_case"

class LeaguesTest < ApplicationSystemTestCase
  setup do
    @league = leagues(:one)
  end

  test "visiting the index" do
    visit leagues_url
    assert_selector "h1", text: "Leagues"
  end

  test "should create league" do
    visit leagues_url
    click_on "New league"

    fill_in "Name", with: @league.name
    fill_in "Ss", with: @league.ss_id
    click_on "Create League"

    assert_text "League was successfully created"
    click_on "Back"
  end

  test "should update League" do
    visit league_url(@league)
    click_on "Edit this league", match: :first

    fill_in "Name", with: @league.name
    fill_in "Ss", with: @league.ss_id
    click_on "Update League"

    assert_text "League was successfully updated"
    click_on "Back"
  end

  test "should destroy League" do
    visit league_url(@league)
    click_on "Destroy this league", match: :first

    assert_text "League was successfully destroyed"
  end
end
