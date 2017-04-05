require 'spec_helper'

describe Members::RequestAccessService, services: true do
  let(:user) { create(:user) }

  shared_examples 'a service raising Gitlab::Access::AccessDeniedError' do
    it 'raises Gitlab::Access::AccessDeniedError' do
      expect { described_class.new(source, user).execute }.to raise_error(Gitlab::Access::AccessDeniedError)
    end
  end

  shared_examples 'a service creating a access request' do
    it 'succeeds' do
      expect { described_class.new(source, user).execute }.to change { source.requesters.count }.by(1)
    end

    it 'returns a <Source>Member' do
      member = described_class.new(source, user).execute

      expect(member).to be_a "#{source.class}Member".constantize
      expect(member.requested_at).to be_present
    end
  end

  context 'when source is nil' do
    it_behaves_like 'a service raising Gitlab::Access::AccessDeniedError' do
      let(:source) { nil }
    end
  end

  context 'when current user cannot request access to the project' do
    %i[empty_project group].each do |source_type|
      it_behaves_like 'a service raising Gitlab::Access::AccessDeniedError' do
        let(:source) { create(source_type, :private) }
      end
    end
  end

  context 'when access requests are disabled' do
    %i[empty_project group].each do |source_type|
      it_behaves_like 'a service raising Gitlab::Access::AccessDeniedError' do
        let(:source) { create(source_type, :public) }
      end
    end
  end

  context 'when current user can request access to the project' do
    %i[empty_project group].each do |source_type|
      it_behaves_like 'a service creating a access request' do
        let(:source) { create(source_type, :public, :access_requestable) }
      end
    end
  end
end
