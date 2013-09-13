# encoding: utf-8
require "spec_helper"

describe Refinery do
  describe "Blog" do
    describe 'Admin' do
      describe "posts" do
        refinery_login_with :refinery_user
        Refinery::Blog::Post.destroy_all

        describe "posts list" do
          before do
            FactoryGirl.create(:post, title: 'UniqueTitleOne')
            FactoryGirl.create(:post, title: 'UniqueTitleTwo')
          end

          it 'shows two items' do
            visit refinery.admin_blog_posts_path
            page.should have_content('UniqueTitleOne')
            page.should have_content('UniqueTitleTwo')
          end
        end

        describe 'create' do
          before do
            visit refinery.admin_blog_posts_path

            click_link "Add New Post"
          end

          context 'valid data' do
            it 'should succeed' do
              fill_in "Title", with: 'This is a test of the first string field'
              click_button "Save draft"

              page.should have_content("'This is a test of the first string field' was successfully added.")
              Refinery::Blog::Post.count.should == 1
            end
          end

          context 'invalid data' do
            it 'should fail' do
              click_button "Save draft"

              page.should have_content("Title can't be blank")
              Refinery::Blog::Post.count.should == 0
            end
          end

          context 'duplicate' do
            before { FactoryGirl.create(:post, title: 'UniqueTitle') }

            it 'should fail' do
              visit refinery.admin_blog_posts_path

              click_link "Add New Post"

              fill_in "Title", with: 'UniqueTitle'
              click_button "Save draft"

              page.should have_content("There were problems")
              Refinery::Blog::Post.count.should == 1
            end
          end

          context 'with translations' do
            before do
              Refinery::Testing::FeatureMacros::I18n.stub_frontend_locales :en, :cs
            end

            after do
              Refinery::Testing::FeatureMacros::I18n.unstub_frontend_locales
            end

            describe 'add a page with title for default locale' do
              before do
                visit refinery.admin_blog_posts_path
                click_link "Add New Post"
                fill_in "Title", with: 'First column'
                click_button "Save draft"
                visit refinery.admin_blog_posts_path
              end

              it 'should succeed' do
                Refinery::Blog::Post.count.should == 1
              end

              it "should show title in the admin menu" do
                p = Refinery::Blog::Post.last
                within "#post_#{p.id}" do
                  page.should have_content('First column')
                end
              end
            end

            describe "add a post with title for primary and secondary locale" do
              before do
                visit refinery.admin_blog_posts_path
                click_link "Add New Post"
                fill_in "Title", with: 'First column'
                click_button "Save draft"

                visit refinery.admin_blog_posts_path
                within '.actions' do
                  click_link "Edit this post"
                end

                within ".locale-picker" do
                  first('.flag-cs').click
                end

                fill_in "Title", with: 'First translated column'
                click_button "Save draft"
              end

              it 'should succeed' do
                Refinery::Blog::Post.count.should == 1
                Refinery::Blog::Post::Translation.count.should == 2
              end

              it "should show title in Globalize.locale (frontend_locale) locale" do
                visit refinery.admin_blog_posts_path

                p = Refinery::Blog::Post.last
                within "#post_#{p.id}" do
                  page.should have_content('First column')
                end

                first('.flag-cs').click

                within "#post_#{p.id}" do
                  page.should have_content('First translated column')
                end
              end
            end


            describe "add a title with title only for secondary locale" do
              before do
                visit refinery.admin_blog_posts_path

                click_link "Add New Post"

                within ".locale-picker" do
                  first('.flag-cs').click
                end

                fill_in "Title", with: 'First translated column'
                click_button "Save draft"

                visit refinery.admin_blog_posts_path
              end

              it 'should show title in backend locale in the first available locale' do
                p = Refinery::Blog::Post.last
                within "#post_#{p.id}" do
                  page.should have_content('First translated column')
                end
              end
            end
          end
        end

        describe 'edit' do
          before do
            FactoryGirl.create(:post, title: 'A title')
          end

          it 'should succeed' do
            visit refinery.admin_blog_posts_path

            within '.actions' do
              click_link "Edit this post"
            end

            fill_in "Title", with: 'A different title'
            click_button "Save draft"

            page.should have_content("'A different title' was successfully updated.")
            page.should have_no_content("A title")
          end
        end

        describe 'destroy' do
          before do
            FactoryGirl.create(:post, title: 'UniqueTitleOne')
          end

          it 'should succeed' do
            visit refinery.admin_blog_posts_path

            click_link "Remove this post forever"
            page.should have_content("'UniqueTitleOne' was successfully removed.")
            Refinery::Blog::Post.count.should == 0
          end
        end

      end
    end
  end
end
