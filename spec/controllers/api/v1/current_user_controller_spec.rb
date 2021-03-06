require 'rails_helper'

RSpec.describe Api::V1::CurrentUserController do
  let(:params) { {} }

  describe 'GET #show' do
    when_user_signed_in do
      can :current, User

      before do
        get :show
      end
      it { expect(json_response[:id]).to eq(@user.id) }
      it { expect(json_response[:username]).to eq(@user.username) }
    end

    when_user_signed_out do
      it_has_behavior 'require authorization', :show
    end
  end

  describe 'GET #current_repos' do
    when_user_signed_in do
      can :current, User

      before do
        @repo = FactoryGirl.create(:repository, owner: @user)
        @user.repositories << @repo
        @user.save
        get :current_repos
      end

      it { expect(json_response.size).to be 1 }
      it { expect(json_response.first[:id]).to eq(@repo.id) }
      it { expect(json_response.first[:name]).to eq(@repo.name) }
    end

    when_user_signed_out do
      it_has_behavior 'require authorization', :current_repos
    end
  end

  describe 'POST #sync_repos' do
    when_user_signed_in do
      can :current, User

      before do
        allow(SyncRepositoriesJob).to receive(:perform_later)
        get :sync_repos
      end

      it { expect(SyncRepositoriesJob).to have_received(:perform_later).with(@user) }
      it_behaves_like 'accepted api request'
    end

    when_user_signed_out do
      it_has_behavior 'require authorization', :current_repos
    end
  end
end
