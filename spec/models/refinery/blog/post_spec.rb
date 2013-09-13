require 'spec_helper'

module Refinery
  module Blog
    describe Post do
      describe 'validations' do

        subject do
          FactoryGirl.create(:post,
            title: 'Refinery CMS'
            # authors: [user]
          )
        end

        it { should be_valid }
        its(:errors) { should be_empty }

        its(:title) { should == 'Refinery CMS' }

      end
    end
  end
end
