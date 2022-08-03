require "test_helper"

class TeamAliasesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @team_alias = team_aliases(:one)
  end

  test "should get index" do
    get team_aliases_url
    assert_response :success
  end

  test "should get new" do
    get new_team_alias_url
    assert_response :success
  end

  test "should create team_alias" do
    assert_difference("TeamAlias.count") do
      post team_aliases_url, params: { team_alias: { alias: @team_alias.alias, team_id: @team_alias.team_id } }
    end

    assert_redirected_to team_alias_url(TeamAlias.last)
  end

  test "should show team_alias" do
    get team_alias_url(@team_alias)
    assert_response :success
  end

  test "should get edit" do
    get edit_team_alias_url(@team_alias)
    assert_response :success
  end

  test "should update team_alias" do
    patch team_alias_url(@team_alias), params: { team_alias: { alias: @team_alias.alias, team_id: @team_alias.team_id } }
    assert_redirected_to team_alias_url(@team_alias)
  end

  test "should destroy team_alias" do
    assert_difference("TeamAlias.count", -1) do
      delete team_alias_url(@team_alias)
    end

    assert_redirected_to team_aliases_url
  end
end
