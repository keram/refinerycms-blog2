# encoding: utf-8
require "spec_helper"

describe Refinery do
  describe "Blog" do
    describe 'Admin' do
      describe "categories" do
        refinery_login_with :refinery_user

        describe "categories list" do
          before do
            FactoryGirl.create(:category, title: 'UniqueTitleOne')
            FactoryGirl.create(:category, title: 'UniqueTitleTwo')
          end

          it 'shows two items' do
            visit refinery.admin_blog_categories_path
            page.should have_content('UniqueTitleOne')
            page.should have_content('UniqueTitleTwo')
          end
        end

        describe 'create' do
          before do
            Refinery::Blog::Category.destroy_all
            visit refinery.admin_blog_categories_path

            click_link "Add New Category"
          end

          context 'valid data' do
            it 'should succeed' do
              fill_in "Title", with: 'This is a test of the first string field'
              click_button "Save"

              page.should have_content("'This is a test of the first string field' was successfully added.")
              Refinery::Blog::Category.count.should == 1
            end
          end

          context 'invalid data' do
            it 'should fail' do
              click_button "Save"

              page.should have_content("Title can't be blank")
              Refinery::Blog::Category.count.should == 0
            end
          end

          context 'duplicate' do
            before { FactoryGirl.create(:category, title: 'UniqueTitle') }

            it 'should fail' do
              visit refinery.admin_blog_categories_path

              click_link "Add New Category"

              fill_in "Title", with: 'UniqueTitle'
              click_button "Save"

              page.should have_content("There were problems")
              Refinery::Blog::Category.count.should == 1
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
                visit refinery.admin_blog_categories_path

                click_link "Add New Category"
                fill_in "Title", with: 'First column'
                click_button "Save"
                visit refinery.admin_blog_categories_path
              end

              it 'should succeed' do
                Refinery::Blog::Category.count.should == 1
              end

              it "should show title in the admin menu" do
                p = Refinery::Blog::Category.last
                within "#category_#{p.id}" do
                  page.should have_content('First column')
                end
              end
            end

            describe "add a category with title for primary and secondary locale" do
              before do
                visit refinery.admin_blog_categories_path
                click_link "Add New Category"
                fill_in "Title", with: 'First column'
                click_button "Save"

                visit refinery.admin_blog_categories_path

                within '.actions' do
                  click_link "Edit this category"
                end

                within ".locale-picker" do
                  first('.flag-cs').click
                end

                fill_in "Title", with: 'First translated column'
                click_button "Save"
                visit refinery.admin_blog_categories_path
              end

              it 'should succeed' do
                Refinery::Blog::Category.count.should == 1
                Refinery::Blog::Category::Translation.count.should == 2
              end

              it "should show title in Globalize.locale locale" do
                p = Refinery::Blog::Category.last
                within "#category_#{p.id}" do
                  page.should have_content('First column')
                end

                first('.flag-cs').click

                within "#category_#{p.id}" do
                  page.should have_content('First translated column')
                end
              end
            end

            describe "add a title with title only for secondary locale" do
              before do
                visit refinery.admin_blog_categories_path

                click_link "Add New Category"
                within ".locale-picker" do
                  first('.flag-cs').click
                end

                fill_in "Title", with: 'First translated column'
                click_button "Save"

                visit refinery.admin_blog_categories_path
              end

              it 'should show title in backend locale in the admin menu' do
                p = Refinery::Blog::Category.last
                within "#category_#{p.id}" do
                  page.should have_content('First translated column')
                end
              end
            end
          end
        end

        describe 'edit' do
          before { FactoryGirl.create(:category, title: 'A title') }

          it 'should succeed' do
            visit refinery.admin_blog_categories_path

            p = Refinery::Blog::Category.last
            within "#category_#{p.id}" do
              click_link "Edit this category"
            end

            fill_in "Title", with: 'A different title'
            click_button "Save"

            page.should have_content("'A different title' was successfully updated.")
            page.should have_no_content("A title")
          end
        end

        describe 'destroy' do
          before do
            Refinery::Blog::Category.destroy_all
            FactoryGirl.create(:category, title: 'UniqueTitleOne')
          end

          it 'should succeed' do
            visit refinery.admin_blog_categories_path

            p = Refinery::Blog::Category.last
            within "#category_#{p.id}" do
              click_link "Remove this category forever"
            end

            page.should have_content("'UniqueTitleOne' was successfully removed.")
            Refinery::Blog::Category.count.should == 0
          end
        end

      end
    end
  end
end
