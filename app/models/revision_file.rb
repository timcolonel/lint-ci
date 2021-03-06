# Revision File model
class RevisionFile < ActiveRecord::Base
  include FriendlyId
  friendly_id :path, use: [:finders]

  belongs_to :revision
  has_many :offenses, foreign_key: 'file_id', dependent: :destroy

  delegate :branch, to: :revision
  delegate :repository, to: :branch

  validates :offense_count, presence: true
  validates :language, presence: true
  validates :path, uniqueness: {scope: :revision_id}

  default_scope do
    order(offense_count: :desc, id: :asc)
  end

  def status
    case offense_count
    when 0
      :perfect
    when 1
      :warning
    when 2..3
      :dirty
    else
      :bad
    end
  end

  def content
    repository.git.object("#{revision.sha}:#{path}").contents
  end
end
