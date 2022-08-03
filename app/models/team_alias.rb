class TeamAlias < ApplicationRecord
  belongs_to :team
  before_create :downcase_alias

  private

  def downcase_alias
    self.alias.downcase!
  end
end
