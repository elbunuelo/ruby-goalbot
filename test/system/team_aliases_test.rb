require "application_system_test_case"

class TeamAliasesTest < ApplicationSystemTestCase
  setup do
    @team_alias = team_aliases(:one)
  end

  test "visiting the index" do
    visit team_aliases_url
    assert_selector "h1", text: "Team aliases"
  end

  test "should create team alias" do
    visit team_aliases_url
    click_on "New team alias"

    fill_in "Alias", with: @team_alias.alias
    fill_in "Team", with: @team_alias.team_id
    click_on "Create Team alias"

    assert_text "Team alias was successfully created"
    click_on "Back"
  end

  test "should update Team alias" do
    visit team_alias_url(@team_alias)
    click_on "Edit this team alias", match: :first

    fill_in "Alias", with: @team_alias.alias
    fill_in "Team", with: @team_alias.team_id
    click_on "Update Team alias"

    assert_text "Team alias was successfully updated"
    click_on "Back"
  end

  test "should destroy Team alias" do
    visit team_alias_url(@team_alias)
    click_on "Destroy this team alias", match: :first

    assert_text "Team alias was successfully destroyed"
  end
end
