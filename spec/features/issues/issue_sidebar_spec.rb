require 'rails_helper'

feature 'Issue Sidebar', feature: true do
  include WaitForAjax
  include MobileHelpers

  let(:project) { create(:project, :public) }
  let(:issue) { create(:issue, project: project) }
  let!(:user) { create(:user)}
  let!(:label) { create(:label, project: project, title: 'bug') }

  before do
    login_as(user)
  end

  context 'assignee', js: true do
    let(:user2) { create(:user) }
    let(:issue2) { create(:issue, project: project, author: user2) }

    before do
      project.team << [user, :developer]
      visit_issue(project, issue2)

      find('.block.assignee .edit-link').click

      wait_for_ajax
    end

    it 'shows author in assignee dropdown' do
      page.within '.dropdown-menu-user' do
        expect(page).to have_content(user2.name)
      end
    end

    it 'shows author when filtering assignee dropdown' do
      page.within '.dropdown-menu-user' do
        find('.dropdown-input-field').native.send_keys user2.name
        sleep 1 # Required to wait for end of input delay

        wait_for_ajax

        expect(page).to have_content(user2.name)
      end
    end

    it 'assigns yourself' do
      find('.block.assignee .dropdown-menu-toggle').click

      click_button 'assign yourself'

      wait_for_ajax

      find('.block.assignee .edit-link').click

      page.within '.dropdown-menu-user' do
        expect(page.find('.dropdown-header')).to be_visible
        expect(page.find('.dropdown-menu-user-link.is-active')).to have_content(user.name)
      end
    end
  end

  context 'as a allowed user' do
    before do
      project.team << [user, :developer]
      visit_issue(project, issue)
    end

    context 'sidebar', js: true do
      it 'changes size when the screen size is smaller' do
        sidebar_selector = 'aside.right-sidebar.right-sidebar-collapsed'
        # Resize the window
        resize_screen_sm
        # Make sure the sidebar is collapsed
        expect(page).to have_css(sidebar_selector)
        # Once is collapsed let's open the sidebard and reload
        open_issue_sidebar
        refresh
        expect(page).to have_css(sidebar_selector)
        # Restore the window size as it was including the sidebar
        restore_window_size
        open_issue_sidebar
      end
    end

    context 'editing issue labels', js: true do
      before do
        page.within('.block.labels') do
          find('.edit-link').click
        end
      end

      it 'shows option to create a new label' do
        page.within('.block.labels') do
          expect(page).to have_content 'Create new'
        end
      end

      context 'creating a new label', js: true do
        before do
          page.within('.block.labels') do
            click_link 'Create new'
          end
        end

        it 'shows dropdown switches to "create label" section' do
          page.within('.block.labels') do
            expect(page).to have_content 'Create new label'
          end
        end

        it 'adds new label' do
          page.within('.block.labels') do
            fill_in 'new_label_name', with: 'wontfix'
            page.find(".suggest-colors a", match: :first).click
            click_button 'Create'

            page.within('.dropdown-page-one') do
              expect(page).to have_content 'wontfix'
            end
          end
        end

        it 'shows error message if label title is taken' do
          page.within('.block.labels') do
            fill_in 'new_label_name', with: label.title
            page.find('.suggest-colors a', match: :first).click
            click_button 'Create'

            page.within('.dropdown-page-two') do
              expect(page).to have_content 'Title has already been taken'
            end
          end
        end
      end
    end
  end

  context 'as a guest' do
    before do
      project.team << [user, :guest]
      visit_issue(project, issue)
    end

    it 'does not have a option to edit labels' do
      expect(page).not_to have_selector('.block.labels .edit-link')
    end
  end

  context 'updating weight', js: true do
    before do
      project.team << [user, :master]
      visit_issue(project, issue)
    end

    it 'updates weight in sidebar to 1' do
      page.within '.weight' do
        click_link 'Edit'
        click_link '1'

        page.within '.value' do
          expect(page).to have_content '1'
        end
      end
    end

    it 'updates weight in sidebar to no weight' do
      page.within '.weight' do
        click_link 'Edit'
        click_link 'No Weight'

        page.within '.value' do
          expect(page).to have_content 'None'
        end
      end
    end
  end

  def visit_issue(project, issue)
    visit namespace_project_issue_path(project.namespace, project, issue)
  end

  def open_issue_sidebar
    page.within('aside.right-sidebar.right-sidebar-collapsed') do
      find('.js-sidebar-toggle').click
      sleep 1
    end
  end
end
