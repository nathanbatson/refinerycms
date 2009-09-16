class Admin::BaseController < ApplicationController
  
  layout :pick_refinery_admin_layout
  
  before_filter :login_required, :restrict_plugins, :restrict_controller

	def admin?
		true # we're in the admin base controller, so always true.
	end

protected

  def error_404
    @page = Page.find_by_menu_match("^/404$", :include => [:parts, :slugs])
    @page[:body] = @page[:body].gsub(/href=(\'|\")\/(\'|\")/, "href='/admin'").gsub("home page", "Dashboard")
    render :template => "/pages/show"
  end
  
  def restrict_plugins
    Refinery::Plugin.set_active( current_user.plugins | ["Dashboard", "Refinery", "Dialogs"] ) if current_user.respond_to?('plugins')
  end

	def restrict_controller
    if params[:controller] != "admin/base" and Refinery::Plugin.active.reject {|plugin| params[:controller] !~ Regexp.new(plugin.menu_match) }.empty?
			flash[:error] = "You do not have permission to access the #{params[:controller]} controller on this plugin."
			logger.warn("'#{current_user.login}' tried to access '#{params[:controller]}'")
			redirect_to admin_root_url
		end
	end
	
	def pick_refinery_admin_layout
	  "admin#{"_dialog" if from_dialog?}"
  end
  
end