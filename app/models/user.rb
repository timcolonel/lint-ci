# User model
class User < ActiveRecord::Base
  include FriendlyId

  friendly_id :username, use: [:finders]

  has_many :repos, class_name: 'Repository', dependent: :destroy, foreign_key: :owner_id

  has_many :memberships, dependent: :destroy
  has_many :repositories, through: :memberships

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  validates :username, presence: true, uniqueness: true

  def password_required?
    active? && (!persisted? || !password.nil? || !password_confirmation.nil?)
  end

  def email_required?
    active?
  end

  def self.from_omniauth(auth)
    user = where(provider: auth.provider, uid: auth.uid).first
    return user unless user.nil?
    user = User.find_or_create_by(username: auth.info.nickname)
    user.provider = auth.provider
    user.uid = auth.uid
    user.email = auth.info.email
    user.password = Devise.friendly_token[0, 20]
    user.active = true
    user.save
    user
  end

  def self.new_with_session(_params, session)
    super.tap do |user|
      if (data = session['devise.github_data']) && session['devise.github_data']['extra']['raw_info']
        user.email = data['email'] if user.email.blank?
      end
    end
  end

  def self.find_or_create_owner(username)
    create_with(active: false).find_or_create_by(username: username)
  end

  # Sync the user project with github
  def sync_repositories(github)
    github.octokit.auto_paginate = true
    repos = github.octokit.repos(username, type: :all)
    repos.each do |github_repo|
      repo = find_or_create_repo(github_repo)
      repo.github_url = github_repo.html_url
      repo.save
      repositories << repo unless repositories.include?(repo)
    end
    save
  end

  def find_or_create_repo(github_repo)
    repo = Repository.find_by_full_name(github_repo.full_name)
    return repo unless repo.nil?

    repo = Repository.new
    repo.full_name = github_repo.full_name
    repo.name = github_repo.name
    repo.owner = User.find_or_create_owner(github_repo.owner.login)
    repo
  end

  def to_s
    username
  end
end
